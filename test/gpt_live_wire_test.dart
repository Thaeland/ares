// GPT-Live wire parity with Hermes Desktop b7ee21c14e (lib/voice-live.ts and
// use-voice-live-conversation.ts): how a delegation becomes a Hermes turn and
// what the client sends on `oai-events` and to POST /voice-live/session.
// The real GptLiveConversation runs over a fake peer; nothing leaves the test.
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/services/gpt_live_conversation.dart';

import 'support/fake_live_webrtc.dart';

Map<String, dynamic> _delegation(String id) => {
  'type': 'session.delegation.created',
  'event_id': 'event_$id',
  'delegation': {'id': id, 'type': 'delegation', 'target': 'client'},
};

void main() {
  group('delegation timing: vendor start_ms/end_ms are session-relative', () {
    test("Desktop's 0-3200 ms fixture delegates the user's last words "
        '(review probe G3)', () async {
      final live = await startFakeLive();
      addTearDown(live.conversation.dispose);
      String? delegationId;
      Map<String, String>? delegated;
      live.conversation.onDelegation = (id, prompt) {
        delegationId = id;
        delegated = prompt;
      };

      final channel = live.peer.channel;
      channel.receive(liveTranscriptDelta('assistant', 'Hi, how ', 0, 1000));
      channel.receive(
        liveTranscriptDelta('assistant', 'can I help?', 1000, 1500),
      );
      channel.receive(liveTranscriptDelta('user', 'What is ', 1500, 2500));
      channel.receive(
        liveTranscriptDelta('user', 'the weather in Paris?', 2500, 3200),
      );
      channel.receive(_delegation('dlg_1'));

      expect(delegationId, 'dlg_1');
      expect(delegated?['prompt'], 'What is the weather in Paris?');
      expect(
        delegated?['context'],
        'Voice assistant: Hi, how can I help?\n'
        'User: What is the weather in Paris?',
      );
    });

    test('the context window reaches five minutes back from the LAST '
        "fragment's end, not from the wall clock", () async {
      final live = await startFakeLive();
      addTearDown(live.conversation.dispose);
      Map<String, String>? delegated;
      live.conversation.onDelegation = (_, prompt) => delegated = prompt;

      final channel = live.peer.channel;
      // Ten minutes into the session: the first exchange is out of the window.
      channel.receive(liveTranscriptDelta('user', 'Book a table.', 0, 1200));
      channel.receive(liveTranscriptDelta('assistant', 'Done.', 1200, 2000));
      // Exactly at the floor (600000 - 300000): kept, as Desktop's `>=`.
      channel.receive(
        liveTranscriptDelta('assistant', 'Anything else?', 299000, 300000),
      );
      channel.receive(
        liveTranscriptDelta('user', 'Yes, check my mail.', 598000, 600000),
      );
      channel.receive(_delegation('dlg_2'));

      expect(delegated?['prompt'], 'Yes, check my mail.');
      expect(
        delegated?['context'],
        'Voice assistant: Anything else?\nUser: Yes, check my mail.',
      );
    });

    test('at most the last 80 fragments ride along (Desktop '
        'CONTEXT_MAX_FRAGMENTS)', () async {
      final live = await startFakeLive();
      addTearDown(live.conversation.dispose);
      Map<String, String>? delegated;
      live.conversation.onDelegation = (_, prompt) => delegated = prompt;

      final channel = live.peer.channel;
      for (var i = 0; i < 100; i++) {
        channel.receive(
          liveTranscriptDelta('user', 'w$i ', i * 100, i * 100 + 100),
        );
      }
      channel.receive(_delegation('dlg_3'));

      final words = delegated!['prompt']!.split(' ');
      expect(words, hasLength(80));
      expect(words.first, 'w20');
      expect(words.last, 'w99');
    });

    test('with no user words the prompt is the LAST 400 characters of the '
        'context (Desktop transcript.slice(-400))', () {
      final spoken = List.generate(60, (i) => 'Sentence number $i.').join(' ');
      final prompt = delegationPrompt([
        LiveFragment(
          speaker: 'assistant',
          text: spoken,
          startMs: 0,
          endMs: 9000,
        ),
      ]);
      final context = 'Voice assistant: $spoken';
      expect(prompt['context'], context);
      expect(prompt['prompt'], context.substring(context.length - 400));
      expect(prompt['prompt'], endsWith('Sentence number 59.'));
    });
  });
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get workspace_workers => '运行中的子代理';

  @override
  String get workers_unattached => '仅显示数量。要向子代理发送指令，请在已连接的上级对话中选择“运行中的子代理”。';

  @override
  String get slash_local_arguments => '此处的快捷命令不支持参数。请使用应用中的控件；草稿已保留。';

  @override
  String get fallback_title => '备用模型';

  @override
  String get fallback_notice => '主模型不可用时按顺序尝试。更改仅适用于此配置；请明确保存完整列表。';

  @override
  String get fallback_unavailable => '备用设置不可用或无效。请检查连接、所选配置和主机版本，然后重试。';

  @override
  String get fallback_discovery_unavailable =>
      '无法获取提供商列表。现有条目会保留；重试后可选择提供商和模型。';

  @override
  String get fallback_empty => '此备用列表中没有条目。';

  @override
  String get fallback_incomplete => '保存前，请为每个条目选择提供商和模型，或删除未完成的条目。';

  @override
  String get fallback_add => '添加备用模型';

  @override
  String get fallback_save => '保存备用列表';

  @override
  String get fallback_save_failed => '无法验证已保存的备用列表。草稿已保留。请重新保存，或刷新以重新加载主机设置。';

  @override
  String get fallback_saved => '备用列表已保存并验证。';

  @override
  String get fallback_legacy_title => '旧版备用设置（只读）';

  @override
  String get fallback_legacy_notice =>
      '主机还会在此列表之后使用 fallback_model，并跳过重复路由。即使上方列表为空，这些旧版条目也会保留。请在主机上编辑。';

  @override
  String fallback_priority(String position) {
    return '优先级 $position';
  }

  @override
  String get fallback_move_up => '上移';

  @override
  String get fallback_move_down => '下移';

  @override
  String get fallback_routing_read_only =>
      '路由详情或未列出的提供商已保留。请在主机上编辑此提供商／模型；此处仍可调整顺序或删除条目。';

  @override
  String get cron_model_default => '使用默认设置';

  @override
  String get cron_model_notice =>
      '仅适用于此 cron 任务。未固定模型时，Hermes 先使用 cron 默认模型，再使用主模型。请在主机上管理自定义模型。';

  @override
  String get model_management_unavailable => '无法加载或保存模型设置。请刷新后重试。';

  @override
  String get model_management_subtitle => '此配置的主模型、备用模型和辅助模型';

  @override
  String get usage => '用量';

  @override
  String get nous_portal => 'Nous Portal';

  @override
  String get portal_menu_subtitle => '网关状态和已记录用量';

  @override
  String get portal_read_only =>
      '网关只读数据。请在 Hermes 主机上管理 Nous 身份验证。这些端点不提供订阅余额或积分。';

  @override
  String get portal_status => '网关 Portal 状态';

  @override
  String get portal_free_tier => '免费层访问（未登录账户）';

  @override
  String get portal_signed_in => '已登录';

  @override
  String get portal_signed_out => '未登录';

  @override
  String get portal_account_tier => '账户等级';

  @override
  String get portal_recorded_usage => '已记录用量';

  @override
  String get portal_all_providers => '所选网关配置中的所有提供商。记录费用为零并不表示模型免费。';

  @override
  String portal_period(String days) {
    return '最近 $days 天';
  }

  @override
  String get portal_sessions => '会话';

  @override
  String get portal_input => '输入令牌';

  @override
  String get portal_output => '输出令牌';

  @override
  String get portal_estimated => '已记录的预估费用';

  @override
  String get portal_actual => '已记录的实际费用';

  @override
  String get portal_recorded_models => '已记录模型';

  @override
  String get portal_no_models => '没有已记录模型。';

  @override
  String get portal_unavailable => '不可用。请检查连接、所选配置和网关版本，然后重试。';

  @override
  String get paste_attachment_failed_text_kept => '无法将粘贴的文本添加为附件。文本已保留在消息中。';

  @override
  String get background_task_report => '后台任务';

  @override
  String get background_process_report => '后台进程';

  @override
  String get background_report_issues => '已报告问题，展开查看详情。';

  @override
  String get background_report_expand => '展开报告';

  @override
  String get background_report_collapse => '收起报告';

  @override
  String get copy_session_id => '复制会话 ID';

  @override
  String get copy_session_id_failed => '无法复制会话 ID。';

  @override
  String get setup_interface_title => '选择界面';

  @override
  String get setup_interface_classic => 'Classic';

  @override
  String get setup_interface_nextgen => 'NextGen';

  @override
  String get setup_interface_classic_description =>
      '原有的 Ares 工作区，提供完整的连接控制和所有 Classic 设置。';

  @override
  String get setup_interface_nextgen_description =>
      '全新界面，只需登录仪表盘一次，并提供实时计划、子代理和通知。';

  @override
  String get setup_interface_switch_later => '你可以随时在“设置”中切换。';

  @override
  String get ng_confirm_model_switch => '切换模型？';

  @override
  String get ng_switch => '切换';

  @override
  String get ng_model_confirmation_required => '选择此模型前需要确认。';

  @override
  String ng_model_switches_next_turn(String model) {
    return '将在下一轮切换到 $model。';
  }

  @override
  String get ng_model_switch_not_connected => '聊天尚未准备好切换模型。请重新打开后再试。';

  @override
  String ng_gateway_kept_default_model(String model) {
    return '网关在此聊天中保留了 $model。请在发送前重新选择模型。';
  }

  @override
  String get hands_free_title => '免提对话';

  @override
  String get hands_free_start => '开始免提';

  @override
  String get hands_free_stop => '停止免提';

  @override
  String get hands_free_preparing => '正在准备语音 — 请稍候';

  @override
  String get hands_free_listening => '请说 Hey Hermes';

  @override
  String get hands_free_recording => '已就绪 — 请说话';

  @override
  String get hands_free_waiting => '等待 Hermes 回复';

  @override
  String get hands_free_speaking => '正在朗读 — 麦克风已关闭';

  @override
  String hands_free_followup(int seconds) {
    return '最多聆听 $seconds 秒';
  }

  @override
  String get hands_free_error => '免提已停止';

  @override
  String get hands_free_setup => '免提设置';

  @override
  String hands_free_preview(String transcript) {
    return '语音预览：$transcript';
  }

  @override
  String get hands_free_short_disclosure =>
      '仅在此聊天于前台打开时运行。唤醒检测离线；语音可能使用网络。会消耗电量。';

  @override
  String get hands_free_error_action =>
      '请检查麦克风权限、语音服务、回复声音和连接，再点击停止并重新开始。不会自动重发。';

  @override
  String get hands_free_disclosure =>
      '唤醒检测在 CPU 上离线运行。Android 语音识别、所选声音和网关可能使用网络。聆听会消耗电量，也可能误触发。聊天被遮挡、关闭或离开前台时停止，返回后不会自动重启。手动听写仍是可编辑的草稿。';

  @override
  String get hands_free_ready_cue =>
      '说“Hey Hermes”，等待就绪提示后再说话。不支持一口气连续输入或预录音。如果授权对话框使应用离开前台，授权后请再次点击开始。';

  @override
  String get hands_free_settings_title => '免提语音';

  @override
  String get hands_free_settings_subtitle =>
      '在聊天中显示“Hey Hermes”启动控件。关闭会停止正在进行的免提会话。';

  @override
  String get hands_free_timing_limit =>
      '后续聆听时间是上限，不是下限。Android 可能提前结束。无语音时返回本地唤醒检测，不会反复重启识别。';

  @override
  String get hands_free_followup_off => '后续聆听已关闭 — 每次提问请说 Hey Hermes';

  @override
  String get hands_free_start_blocked =>
      '需要空草稿、无附件、空闲且已连接的聊天，并启用语音回复。请先结束手动语音操作。';

  @override
  String get hands_free_setup_complete => '麦克风设置完成。请再次点击开始。';

  @override
  String message_time_recorded(String time) {
    return 'Recorded by server: $time (local time)';
  }

  @override
  String message_time_sent(String time) {
    return 'Send observed on this device: $time (local time)';
  }

  @override
  String message_time_received(String time) {
    return 'First received on this device: $time (local time)';
  }

  @override
  String get stop_and_send => '停止并发送';

  @override
  String get message_queued_for_running_turn => '消息已加入当前运行的队列。';

  @override
  String get running_message_not_accepted =>
      'Hermes 无法接受此消息。草稿已保留；请停止回复或等待，然后重新发送。';

  @override
  String get running_message_delivery_unknown =>
      '无法确认消息是否送达。草稿已保留。请先检查聊天记录，再重试。';

  @override
  String get attachment_tap_to_preview => '点按以预览';

  @override
  String get attachment_save => '保存';

  @override
  String get attachment_share => '分享';

  @override
  String get attachment_saved => '文件已保存';

  @override
  String get attachment_save_cancelled => '已取消保存';

  @override
  String get attachment_save_failed => '无法保存此文件，请重试。';

  @override
  String get attachment_share_failed => '无法分享此文件，请重试。';

  @override
  String get attachment_download_failed => '无法加载此文件，请检查连接后重试。';

  @override
  String get attachment_no_inline_preview =>
      '此文件类型不支持内嵌预览。请保存或分享原始文件，以便在其他应用中打开。';

  @override
  String get attachment_image_failed => '无法解码此图片。您仍可保存或分享原始文件。';

  @override
  String get attachment_text_truncated => '预览内容已截短。请保存或分享文件以阅读完整内容。';

  @override
  String get attachment_text_unavailable => '无法将此文件显示为文本。请保存或分享原始文件。';

  @override
  String get attachment_pdf_failed => '无法预览此 PDF。请保存或分享原始文件。';

  @override
  String get attachment_pdf_unavailable => 'PDF 预览仅在 Android 上可用。您仍可保存或分享此文件。';

  @override
  String attachment_pdf_page(int page, int total) {
    return '第 $page 页，共 $total 页';
  }

  @override
  String get attachment_previous_page => '上一页';

  @override
  String get attachment_next_page => '下一页';

  @override
  String get attachment_loading => '正在加载预览…';

  @override
  String get attachment_document_text_notice => '文本预览。布局、图片和格式可能与原文件不同。';

  @override
  String get attachment_document_failed => '无法预览此文档。请保存或分享原始文件。';

  @override
  String get attachment_document_empty => '此文档中未找到可读文本。';

  @override
  String get attachment_video_failed => '无法播放此视频。其格式或编解码器可能不受支持。请保存或分享原始文件。';

  @override
  String get attachment_video_play => '播放';

  @override
  String get attachment_video_pause => '暂停';

  @override
  String get attachment_video_mute => '静音';

  @override
  String get attachment_video_unmute => '取消静音';

  @override
  String get attachment_video_seek => '视频进度';

  @override
  String get attachment_close => '关闭预览';

  @override
  String get attachment_retry => '重试';

  @override
  String get saved_history_heading => 'Saved history';

  @override
  String get received_output_heading =>
      'Received output — match to saved history unconfirmed';

  @override
  String get received_output_details => 'About received output';

  @override
  String get received_output_explanation =>
      'This may also appear in saved history. The app cannot confirm a match.';

  @override
  String get local_prompt_context => 'Local prompt context';

  @override
  String get received_output_badge => 'Received · match unconfirmed';

  @override
  String get received_output_lifetime =>
      'Received output is kept temporarily in this app session and may be shortened or removed as limits are reached. It may not be available after the app or connection is closed.';

  @override
  String get theme_palette => '颜色主题';

  @override
  String get theme_palette_gold => '金色';

  @override
  String get theme_palette_purple => '紫色';

  @override
  String get theme_palette_orange => '橙色';

  @override
  String get theme_palette_green => '绿色';

  @override
  String get theme_palette_blue => '蓝色';

  @override
  String get theme_palette_red => '红色';

  @override
  String get theme_palette_teal => '青绿色';

  @override
  String get theme_palette_pink => '粉色';

  @override
  String get theme_palette_indigo => '靛蓝色';

  @override
  String get theme_palette_cyan => '青色';

  @override
  String get assets_recent_subtitle => '查找 Hermes 在已保存的聊天中分享的文件';

  @override
  String get assets_scope_notice =>
      '仅显示 Hermes 在已保存的回复中明确分享的已生成文件。这里只展示部分聊天历史，并非完整的文件或附件目录。引用的文件可能已不存在。';

  @override
  String get assets_download_limit =>
      '文件仅在点按时加载。预览和下载的单个文件大小上限均为 25 MiB；更大的文件请通过仪表盘获取。';

  @override
  String get assets_search_hint => '搜索找到的文件或来源聊天';

  @override
  String get assets_all => '全部';

  @override
  String get assets_images => '图片';

  @override
  String get assets_audio => '音频';

  @override
  String get assets_video => '视频';

  @override
  String get assets_documents => '文档和其他文件';

  @override
  String get assets_empty => '在已扫描的消息中未找到资产';

  @override
  String get assets_empty_detail =>
      '扫描更多聊天或更早的消息，以查看更早的历史。普通附件和未链接的文件不会在此建立索引。';

  @override
  String get assets_no_matches => '未找到匹配的资产';

  @override
  String get assets_load_more_chats => '扫描更多聊天';

  @override
  String get assets_load_older_messages => '扫描更早的消息';

  @override
  String get assets_load_failed => '部分历史记录无法读取。结果不完整。请检查仪表盘连接并重试。';

  @override
  String get assets_retry_failed => '重试读取失败的历史记录';

  @override
  String get assets_partial => '服务器报告历史记录不完整。请检查仪表盘后刷新。';

  @override
  String assets_scan_summary(int files, int chats) {
    return '已扫描 $chats 个聊天，找到 $files 处文件引用';
  }

  @override
  String assets_open_chat(String title) {
    return '打开聊天：$title';
  }

  @override
  String get assets_file_too_large => '此文件超出下载大小上限。请打开仪表盘进行下载。';

  @override
  String get a_one_off_question_archives_itself_after_72_hours_anything =>
      '一次性问题。将在 72 小时后自动归档；任何值得保留的内容都会被记住。';

  @override
  String get archive_chat => '归档聊天';

  @override
  String get unarchive_chat => '取消归档聊天';

  @override
  String get chat_archived => '聊天已归档';

  @override
  String get chat_unarchived => '聊天已取消归档';

  @override
  String could_not_update_chat_archive(Object error) {
    return '无法更新聊天归档状态：$error';
  }

  @override
  String get quick_chat_description => '一次性问题。';

  @override
  String get ai_full_text => 'AI + 全文';

  @override
  String get ai_search_model => 'AI 搜索模型';

  @override
  String ai_searched_for(Object aiRewrittenQuery) {
    return 'AI 已搜索：$aiRewrittenQuery';
  }

  @override
  String get ai_assisted_filing => 'AI 辅助归档';

  @override
  String get api_key => 'API 密钥';

  @override
  String get api_server_key_from_hermes_env =>
      '来自 ~/.hermes/.env 的 API_SERVER_KEY';

  @override
  String get active => '活跃';

  @override
  String get activity => '活动';

  @override
  String get activity_reads_the_durable_turn_journal_to_know_what_hermes =>
      '活动功能会读取持久化轮次日志以了解 Hermes 正在执行的操作。请检查网关是否可访问，然后重试。';

  @override
  String get add => '添加';

  @override
  String get add_connection => '添加连接';

  @override
  String get add_cron_job => '添加 Cron 任务';

  @override
  String get add_gateway_connection => '添加网关连接';

  @override
  String get add_and_update_connections_from_the_backup_keep_the_rest =>
      '从备份中添加和更新连接，其余保持不变。';

  @override
  String get add_attachment => '添加附件';

  @override
  String get add_new_cron_job => '添加新 Cron 任务';

  @override
  String get add_to_chat => '添加到聊天';

  @override
  String get all_chats => '所有聊天';

  @override
  String get all_stored_message_content => '所有已存储的消息内容';

  @override
  String get allow_for_this_session => '本次会话允许';

  @override
  String get allow_matching_commands_until_this_hermes_session_ends =>
      '在此 Hermes 会话结束前允许匹配的命令。';

  @override
  String get allow_folder_until_sandbox_off =>
      'Allow this folder until the sandbox is switched off.';

  @override
  String get allow_once => '允许一次';

  @override
  String get allow_website_until_sandbox_off =>
      'Allow this website until the sandbox is switched off.';

  @override
  String get always_allow => '总是允许';

  @override
  String get apply_to_this_chat => '应用到此聊天';

  @override
  String get approval_needed => '需要审批';

  @override
  String get approval_needed_description => '有命令正在等待你的批准或拒绝。';

  @override
  String get approve => '批准';

  @override
  String get archive => '归档';

  @override
  String get archive_project => '归档项目';

  @override
  String archive_2(Object projectName) {
    return '归档 $projectName？';
  }

  @override
  String archive_3(Object name) {
    return '归档 $name？';
  }

  @override
  String get archived => '已归档';

  @override
  String get archived_conversations_appear_here =>
      '这里只显示已归档的对话。旧聊天仍保留在“所有聊天”中。';

  @override
  String get archived_quick_chats => '已归档的快速聊天';

  @override
  String get artifacts_attachments_and_generated_media => '构件、附件和生成的内容';

  @override
  String get ask_ai_to_find_a_conversation => '让 AI 查找对话';

  @override
  String get assets => '资产';

  @override
  String get assets_need_a_server_authoritative_assets_index_in_the_hermes =>
      '资产需要在 Hermes 网关中建立服务器权威资产索引，然后才能按项目显示。';

  @override
  String get assets_unavailable => '资产不可用';

  @override
  String get attach_image_or_file => '附加图片或文件';

  @override
  String get attachment_drafts => '附件草稿';

  @override
  String get recover_text_draft => '恢复文字草稿';

  @override
  String get undo_draft_recovery => '撤销';

  @override
  String get draft_session_exists => '此对话仍然存在。请打开它以继续编辑草稿。';

  @override
  String get draft_recovery_unavailable => '无法验证此草稿。未作任何更改。';

  @override
  String attachment_of(Object index, Object total) {
    return '附件 $index / $total';
  }

  @override
  String get auto_device_default => '自动（设备默认）';

  @override
  String get agent => '智能体';

  @override
  String get autonomous_agents => '自主智能体';

  @override
  String get background_recovery_unavailable_legacy_transport =>
      '后台恢复不可用 — 旧版传输';

  @override
  String get background_task_completed => '后台任务完成';

  @override
  String get background_task_completed_description => '后台终端命令已完成。';

  @override
  String get backup_restore => '备份与恢复';

  @override
  String backup_exported(Object destination) {
    return '备份已导出 — $destination';
  }

  @override
  String get base_url => '基础 URL';

  @override
  String get binary_preview_is_unavailable_download_the_file_to_open_it =>
      '二进制预览不可用。请下载文件后打开。';

  @override
  String get branch => '分支';

  @override
  String get branch_chat => '分支聊天';

  @override
  String get branch_created_in_hermes_history => '已在 Hermes 历史记录中创建分支。';

  @override
  String get browse_and_manage_your_hermes_agent_sessions_from_your_phone =>
      '通过手机浏览和管理你的 Hermes Agent 会话。连接至运行在本地网络上的 Hermes 仪表盘。';

  @override
  String get browse_server_files => '浏览服务器文件';

  @override
  String get browse_the_miniserver_folders_behind_your_projects =>
      '浏览项目背后的 miniserver 文件夹';

  @override
  String get cancel => '取消';

  @override
  String get cancel_voice_input => '取消语音输入';

  @override
  String cannot_reach(Object host, Object port) {
    return '无法连接至 $host:$port。';
  }

  @override
  String cannot_reach_check_the_host_and_port(Object host, Object port) {
    return '无法连接至 $host:$port。请检查主机和端口。';
  }

  @override
  String get change_ai_search_model => '更改 AI 搜索模型';

  @override
  String changes_the_default_for_use_the_selector_in_a_chat(Object label) {
    return '更改 $label 的默认值。在聊天中使用选择器可仅覆盖当前对话。';
  }

  @override
  String get chat_actions => '聊天操作';

  @override
  String get chats => '聊天';

  @override
  String get chats_from_this_gateway_are_not_grouped_yet_grouping_stays =>
      '此网关中的聊天尚未分组。分组状态将保留在此手机上，直到网关能够托管项目。';

  @override
  String get chats_in_this_project_will_show_their_state_and_last =>
      '此项目中的聊天将在此处显示其状态和最后活动。';

  @override
  String get chats_that_are_not_assigned_to_a_project => '未分配至项目的聊天';

  @override
  String get chats_you_start_in_this_project_will_appear_here_on =>
      '你在此项目中发起的聊天将显示在此处，并同步到登录此 Hermes 的所有设备上。';

  @override
  String get check_that_the_gateway_is_running_and_reachable_then_try =>
      '请检查网关是否正在运行且可达，然后重试。';

  @override
  String get check_the_dashboard_connection_and_try_again => '请检查仪表盘连接并重试。';

  @override
  String get check_the_connection_and_try_again => '请检查连接并重试。';

  @override
  String get choose_a_small_model_to_rewrite_queries => '选择一个小模型来重写查询';

  @override
  String get choose_an_ai_search_model_before_using_ai_search =>
      '请在使用 AI 搜索前选择一个 AI 搜索模型。';

  @override
  String get choose_an_active_project_next => '接下来选择一个活动项目';

  @override
  String get choose_chat_model => '选择聊天模型';

  @override
  String get choose_files => '选择文件';

  @override
  String get choose_image => '选择图片';

  @override
  String get choose_images => '选择图片';

  @override
  String get choose_its_destination_space => '选择其目标空间';

  @override
  String get clear_search => '清除搜索';

  @override
  String get close => '关闭';

  @override
  String get code_copied => '代码已复制';

  @override
  String get code_format => 'Code';

  @override
  String get coming_next => '敬请期待';

  @override
  String get command => '命令';

  @override
  String get command_palette => 'Command palette';

  @override
  String get command_palette_hint => 'Type a command';

  @override
  String get command_palette_no_results => 'No commands found';

  @override
  String get command_palette_new_chat => 'New chat';

  @override
  String get command_palette_search_chats => 'Search chats';

  @override
  String get command_palette_toggle_theme => 'Toggle theme';

  @override
  String get command_palette_copy_last_code => 'Copy last code block';

  @override
  String get command_line_chats => '命令行聊天';

  @override
  String get compatibility_mode => '兼容模式';

  @override
  String get configure_a_valid_desktop_gateway_url_before_attaching_files =>
      '在附加文件前，请先配置有效的 Desktop Gateway URL。';

  @override
  String get confirm_always_allow => '确认始终允许';

  @override
  String get confirm_passphrase => '确认密码短语';

  @override
  String connecting_to(Object baseUrl) {
    return '正在连接至 $baseUrl...';
  }

  @override
  String get connection_issue => '连接问题';

  @override
  String
  get connection_switched_the_running_reply_continues_on_the_server_and =>
      '连接已切换 — 正在进行的回复将在服务器上继续，并会自动重新附加。';

  @override
  String get connection_appearance_and_device_preferences => '连接、外观和设备偏好设置';

  @override
  String context_tokens(Object effectiveContextLength) {
    return '上下文：$effectiveContextLength Token';
  }

  @override
  String get continue_label => '继续';

  @override
  String get continue_working => '继续工作';

  @override
  String get conversations_in_this_project => '此项目中的对话';

  @override
  String get copy_code => '复制代码';

  @override
  String get copy_message => '复制消息';

  @override
  String could_not_branch_chat(Object error) {
    return '无法创建聊天分支：$error';
  }

  @override
  String could_not_delete_session(Object error) {
    return '无法删除会话：$error';
  }

  @override
  String could_not_deny_the_command(Object error) {
    return '无法拒绝该命令：$error';
  }

  @override
  String could_not_load_ai_search_models(Object error) {
    return '无法加载 AI 搜索模型：$error';
  }

  @override
  String get could_not_load_conversations => '无法加载对话';

  @override
  String get could_not_load_files => '无法加载文件';

  @override
  String could_not_load_models_for_this_profile(Object error) {
    return '无法为该配置档案加载模型：$error';
  }

  @override
  String could_not_load_more_chats(Object error) {
    return '无法加载更多聊天：$error';
  }

  @override
  String get could_not_open_link => '无法打开此链接。';

  @override
  String get could_not_open_the_hermes_dashboard => '无法打开 Hermes 仪表盘。';

  @override
  String get could_not_open_this_project => '无法打开此项目';

  @override
  String get could_not_preview_file => '无法预览文件';

  @override
  String get could_not_reach_hermes => '无法连接至 Hermes';

  @override
  String could_not_reach_authenticate_the_dashboard_at_check_the_port(
    Object dashboardPort,
    Object host,
  ) {
    return '无法连接/验证位于 $host:$dashboardPort 的仪表盘。请检查端口和凭据。';
  }

  @override
  String get could_not_read_activity => '无法读取活动';

  @override
  String could_not_rename_chat(Object error) {
    return '无法重命名聊天：$error';
  }

  @override
  String could_not_send_the_approval(Object error) {
    return '无法发送审批：$error';
  }

  @override
  String get could_not_skip_the_hermes_question => '无法跳过 Hermes 的问题。';

  @override
  String could_not_the_project(Object action, Object error) {
    return '无法 $action 该项目：$error';
  }

  @override
  String get couldn_t_delete_project => '无法删除项目';

  @override
  String couldn_t_load_runs(Object error) {
    return '无法加载运行记录：$error';
  }

  @override
  String get couldn_t_move_conversation => '无法移动对话';

  @override
  String couldn_t_move_to(Object label, Object reason) {
    return '无法移动至 $label：$reason';
  }

  @override
  String get couldn_t_prepare_the_shared_files => '无法准备共享文件。';

  @override
  String get couldn_t_promote_conversation => '无法提升会话';

  @override
  String couldn_t_project(Object action) {
    return '无法 $action 项目';
  }

  @override
  String get create => '创建';

  @override
  String get create_a_project => '创建项目';

  @override
  String get create_a_project_first_then_chats_can_live_inside_it =>
      '请先创建一个项目，聊天内容即可存放在其中。';

  @override
  String get create_a_space_to_separate_related_conversations =>
      '创建一个空间以区分相关的聊天。';

  @override
  String get create_branch => '创建分支';

  @override
  String get credit_notifications => '额度通知';

  @override
  String get credit_notifications_description => '额度使用已停止或恢复。';

  @override
  String get cron => 'Cron';

  @override
  String get crons => 'Crons';

  @override
  String get cron_conversations_empty =>
      'Conversations from scheduled jobs appear here, including older runs.';

  @override
  String get search_cron_conversations => 'Search cron conversations';

  @override
  String get cron_jobs => 'Cron 任务';

  @override
  String cron_schedule_timezone(Object zone) {
    return '排程时区：$zone';
  }

  @override
  String get crons_upcoming => '即将运行';

  @override
  String get crons_history => '运行历史';

  @override
  String cron_time_with_zone(Object time, Object zone) {
    return '$time（$zone）';
  }

  @override
  String cron_time_zone_unknown(Object time) {
    return '$time（时区未知）';
  }

  @override
  String get cron_no_next_run => '未安排下次运行';

  @override
  String get cron_status_scheduled => '已排程';

  @override
  String get cron_status_paused => '已暂停';

  @override
  String cron_delivers_to(Object target) {
    return '投递至 $target';
  }

  @override
  String get cron_upcoming_empty_title => '暂无已排程任务';

  @override
  String get cron_upcoming_empty_message =>
      '当前没有待运行的任务。请在 Cron 任务中创建，或让智能体安排一个。';

  @override
  String get cron_upcoming_unavailable => '无法显示已排程任务';

  @override
  String get cron_upcoming_needs_dashboard =>
      '已排程任务需要仪表盘连接。此地址不提供 Cron 排程。请检查仪表盘地址和主机支持情况。';

  @override
  String get cron_upcoming_needs_dashboard_auth =>
      '已排程任务需要仪表盘认证。请为此连接添加仪表盘用户名和密码，或启用代理模式。';

  @override
  String get cron_upcoming_dashboard_unreachable =>
      '无法连接到仪表盘。请检查主机、仪表盘端口和网络，然后重试。';

  @override
  String get cron_upcoming_load_failed => '无法读取已排程任务。请检查仪表盘连接并重试。';

  @override
  String get cron_upcoming_refresh_failed => '无法刷新排程。正在显示上次成功读取的结果。';

  @override
  String get cron_job_added => 'Cron 任务已添加';

  @override
  String get cron_job_updated => 'Cron 任务已更新';

  @override
  String get cron_run => 'Cron 运行';

  @override
  String get cross_device_ordering_and_reversible_bulk_organization =>
      '跨设备排序与可撤销的批量整理';

  @override
  String get current_profile_default => '当前配置档案默认值';

  @override
  String get custom_proxy_and_dashboard_details => '自定义代理与仪表盘详情';

  @override
  String get dark => '深色';

  @override
  String get dashboard_proxy_settings => '仪表盘 / 代理设置';

  @override
  String get dashboard_password_optional => '仪表盘密码（可选）';

  @override
  String get dashboard_port => '仪表盘端口';

  @override
  String get dashboard_username_optional => '仪表盘用户名（可选）';

  @override
  String get dashboard_behind_proxy => '位于代理后的仪表盘';

  @override
  String get dashboard_path_prefix => '仪表盘路径前缀';

  @override
  String delegated_task(Object goal) {
    return '委派任务：$goal';
  }

  @override
  String get delete => '删除';

  @override
  String delete_2(Object name) {
    return '删除“$name”？';
  }

  @override
  String delete_from_the_remote_hermes_history_this_cannot_be_undone(
    Object title,
  ) {
    return '从远程 Hermes 历史记录中删除“$title”？此操作不可撤销。';
  }

  @override
  String get delete_cron_job => '删除 Cron 任务';

  @override
  String get delete_connections_that_are_not_in_the_backup => '删除不在备份中的连接。';

  @override
  String delete_failed(Object error) {
    return '删除失败：$error';
  }

  @override
  String get delete_project => '删除项目';

  @override
  String get delete_session => '删除会话？';

  @override
  String delete_3(Object projectName) {
    return '删除 $projectName？';
  }

  @override
  String deleted(Object name) {
    return '已删除“$name”';
  }

  @override
  String get delivery_is_uncertain_recovering_without_resending =>
      '发送状态不确定；正在恢复且不重新发送……';

  @override
  String get desktop_gateway_url_optional => 'Desktop Gateway URL（可选）';

  @override
  String get desktop_gateway_is_not_configured_for_this_connection =>
      '此连接未配置 Desktop Gateway。';

  @override
  String get desktop_app => '桌面应用';

  @override
  String get developer_tool_calls => '开发者工具调用';

  @override
  String get discord_chats => 'Discord 聊天';

  @override
  String get dismiss => '忽略';

  @override
  String get do_not_run_this_command => '请勿运行此命令。';

  @override
  String get documents_archives_audio_video_or_data => '文档、压缩包、音频、视频或数据';

  @override
  String get download => '下载';

  @override
  String download_failed(Object error) {
    return '下载失败：$error';
  }

  @override
  String get durable_facts_hermes_keeps_about_you => 'Hermes 记录的关于你的持久事实';

  @override
  String get durable_work_inside_one_of_your_projects_shared_with_desktop =>
      '项目内的持久工作内容，已与 Desktop 共享。';

  @override
  String get edit => '编辑';

  @override
  String get edit_connection => '编辑连接';

  @override
  String get edit_cron_job => '编辑 Cron 任务';

  @override
  String get edit_gateway_connection => '编辑网关连接';

  @override
  String get edit_and_resend => '编辑并重发';

  @override
  String get enable_notifications => '启用通知';

  @override
  String get enable_notifications_description => '关闭后将禁用以下所有通知。';

  @override
  String get enables_file_attachments_through_the_desktop_remote_gateway =>
      '允许通过 Desktop 远程网关发送文件附件。';

  @override
  String get enter_a_name => '输入名称';

  @override
  String get enter_a_passphrase => '请输入密码短语。';

  @override
  String get enter_the_passphrase_for_this_backup => '请输入此备份的密码短语。';

  @override
  String get every_conversation_is_already_assigned_to_a_project =>
      '所有对话均已分配至某个项目。';

  @override
  String get everything_not_yet_native_in_the_authenticated_web_dashboard =>
      '所有尚未原生支持的功能，均可在已认证的 Web 仪表盘中查看';

  @override
  String get explain_the_attached_content_clearly => '清晰解释附件内容。';

  @override
  String explain_this_content_clearly(Object text) {
    return '清晰解释此内容：\n\n$text';
  }

  @override
  String
  get explicit_choices_adjust_android_accessibility_text_size_system_leaves_it =>
      '显式选择将调整 Android 无障碍文字大小；选择“系统”则保持不变。';

  @override
  String get export_label => '导出';

  @override
  String get export_share => '导出 / 分享';

  @override
  String get external_api_clients => '外部 API 客户端';

  @override
  String get extra_high => '极高';

  @override
  String get extract_tasks => '提取任务';

  @override
  String
  get extract_the_decisions_deadlines_owners_and_actionable_action_items_from =>
      '从附件内容中提取决策、截止日期、负责人以及可执行的操作项。';

  @override
  String
  extract_the_decisions_deadlines_owners_and_actionable_action_items_from_2(
    Object text,
  ) {
    return '从以下内容中提取决策、截止日期、负责人以及可执行的操作项：\n\n$text';
  }

  @override
  String failed_to_add_job(Object error) {
    return '添加任务失败：$error';
  }

  @override
  String get failed_to_load_cron_jobs => '加载 Cron 任务失败';

  @override
  String get failed_to_load_memory => '加载记忆失败';

  @override
  String get failed_to_load_messages => '加载消息失败';

  @override
  String get failed_to_load_settings => '加载设置失败';

  @override
  String get failed_to_load_skills => '加载技能失败';

  @override
  String failed_to_update_job(Object error) {
    return '更新任务失败：$error';
  }

  @override
  String failed(Object error) {
    return '失败：$error';
  }

  @override
  String get file_attached_document_catalog_registration_is_pending =>
      '已添加文件附件；文档目录注册正在等待处理。';

  @override
  String get file_reference_added_to_chat => '文件引用已添加至聊天';

  @override
  String get files => '文件';

  @override
  String get fill_from_document => '从文档填充';

  @override
  String get folder_is_empty => '文件夹为空';

  @override
  String get folders => '文件夹';

  @override
  String get full_text => '全文';

  @override
  String get gateway_api_access => '网关 API 访问';

  @override
  String get gateway_connected_but_the_dashboard_could_not_be_reached_or =>
      '网关已连接，但无法访问仪表盘或未能通过身份验证。请检查仪表盘详细信息，或清除它们以跳过。';

  @override
  String get gateway_path_prefix => '网关路径前缀';

  @override
  String get go_to_end => '转到末尾';

  @override
  String get hermes_agent => 'Ares - formerly Hermes Android';

  @override
  String get hermes_agent_for_android => 'Ares - formerly Hermes Android';

  @override
  String get hermes_could_not_accept_the_answer_please_try_again =>
      'Hermes 无法接受此回答，请重试。';

  @override
  String get hermes_could_not_load_your_saved_connections =>
      'Hermes 无法加载你保存的连接';

  @override
  String get hermes_did_not_accept_the_response_please_try_again =>
      'Hermes 未能接受此响应，请重试。';

  @override
  String get hermes_is_responding => 'Hermes 正在响应…';

  @override
  String get hermes_is_waiting_for_input => 'Hermes 正在等待输入…';

  @override
  String get hermes_keeps_android_accessibility_text_scaling_active =>
      'Ares 保持 Android 辅助功能文字缩放处于活动状态。';

  @override
  String get hermes_needs_your_input => 'Hermes 需要你的输入';

  @override
  String get hermes_profile_optional => 'Hermes 配置档案（可选）';

  @override
  String get hermes_profile_must_be_a_plain_profile_name_such_as =>
      'Hermes 配置档案必须是纯粹的档案名称（例如 “sol”），而不能是路径。';

  @override
  String get hermes_reasoning_details => 'Hermes 推理详情';

  @override
  String hermes_recovery_is_unavailable(Object error) {
    return 'Hermes 恢复不可用：$error';
  }

  @override
  String get hermes_stopped_recovery_safely_no_prompt_was_resent =>
      'Hermes 已安全停止恢复。未重新发送任何提示词。';

  @override
  String get hide_passphrase => '隐藏密码短语';

  @override
  String get home_needs_your_recent_chats_to_know_what_deserves_your =>
      '首页需要你最近的聊天记录来了解哪些内容值得你关注。请检查网关是否可达，然后重试。';

  @override
  String get host => '主机';

  @override
  String get image_selection_was_interrupted_try_again => '图片选择被中断，请重试。';

  @override
  String get import_label => '导入';

  @override
  String get inbox => '收件箱';

  @override
  String get inbox_is_clear => '收件箱为空';

  @override
  String get input_needed => '需要输入';

  @override
  String get input_needed_description => 'Hermes 提出了问题，或需要密码或密钥。';

  @override
  String get insert_a_remote_file_reference => '插入远程 @file 引用';

  @override
  String get invalid_port_number => '无效的端口号。';

  @override
  String get job_paused => '任务已暂停';

  @override
  String get job_resumed => '任务已恢复';

  @override
  String get job_triggered => '任务已触发';

  @override
  String get label => '标签';

  @override
  String last_activity(Object day, Object month, Object year) {
    return '最后活动于 $year年$month月$day日';
  }

  @override
  String last(Object lastRun) {
    return '最后运行：$lastRun';
  }

  @override
  String get leave_blank_for_default_8642_443_with_https =>
      '留空则使用默认值（8642；使用 https 时为 443）';

  @override
  String get leave_blank_for_default_9119 => '留空则使用默认值 (9119)';

  @override
  String get light => '浅色';

  @override
  String listening(Object elapsed) {
    return '正在聆听 • $elapsed';
  }

  @override
  String listening_elapsed(Object elapsed) {
    return '正在聆听，已耗时 $elapsed';
  }

  @override
  String get load_more => '加载更多…';

  @override
  String get loading => '正在加载';

  @override
  String get location => '位置';

  @override
  String get make_sure_the_gateway_api_server_is_running_hermes_gateway =>
      '请确保网关 API Server 正在运行\n(hermes gateway status)';

  @override
  String matches(Object assigned, Object name) {
    return '匹配项 $name · $assigned';
  }

  @override
  String get memory => '记忆';

  @override
  String get memory_about_you => '关于你';

  @override
  String get memory_agent_notes => '助手笔记';

  @override
  String get memory_builtin_scope =>
      '此配置档案的 USER.md 和 MEMORY.md 中保存的事实。这里不显示外部记忆服务（包括 MemPalace）的内容。';

  @override
  String get memory_read_only => '仅供查看。可在聊天中请 Hermes 更正或忘记某条事实。';

  @override
  String get memory_unavailable =>
      '此网关或配置档案无法提供已保存的事实。请检查所选配置档案，并在需要时更新 Hermes。';

  @override
  String get memory_load_error => '请检查仪表盘连接和身份验证，然后重试。';

  @override
  String get memory_read_full_fact => '阅读完整事实';

  @override
  String get memory_full_fact_requires_update =>
      '查看完整事实需要更新的 Hermes 网关。请更新 Hermes 并刷新列表。';

  @override
  String get memory_fact_detail_error => '无法加载完整事实。它可能已更改；请刷新列表后重试。';

  @override
  String get memory_entries_are_cross_session_facts_the_agent_remembers_they =>
      'Hermes 记住的事实会显示在这里。';

  @override
  String get merge => '合并';

  @override
  String get message => '消息';

  @override
  String get message_hermes => '给 Hermes 发消息…';

  @override
  String get message_actions => '消息操作';

  @override
  String get message_copied => '已复制消息';

  @override
  String get migrating => '正在迁移…';

  @override
  String get migration_complete => '迁移完成';

  @override
  String get migration_failed_local_spaces_were_kept_unchanged =>
      '迁移失败。本地空间保持不变。';

  @override
  String get migration_incomplete => '迁移未完成';

  @override
  String get migration_preview => '迁移预览';

  @override
  String get model => '模型';

  @override
  String get model_and_thinking_for_this_chat => '此聊天的模型和思考状态';

  @override
  String model_was_not_changed(Object error) {
    return '模型未更改：$error';
  }

  @override
  String get move_attachment_next => '将附件移至下一个';

  @override
  String get move_attachment_previous => '将附件移至上一个';

  @override
  String get move_chat => '移动聊天';

  @override
  String get move_conversation => '移动会话';

  @override
  String get move_to_project => '移动到项目';

  @override
  String get move_to_space => '移动到空间';

  @override
  String get moved_to_a_project => '已移动到项目';

  @override
  String moved_to(Object label) {
    return '已移动到 $label';
  }

  @override
  String get name => '名称';

  @override
  String get name_prompt_and_schedule_are_required => '名称、提示词和计划均为必填项';

  @override
  String get nav_activity => '活动';

  @override
  String get nav_projects => '项目';

  @override
  String get needs_a_correction_aware_filing_contract_in_the_hermes_gateway =>
      'Hermes 网关中需要具备支持纠错感知的文件归档契约。';

  @override
  String get needs_a_reachable_hermes_dashboard_check_the_host_port_and =>
      '需要可访问的 Hermes 仪表盘。请检查此连接的主机、端口和凭据。';

  @override
  String get needs_a_server_authoritative_assets_index_in_the_hermes_gateway =>
      'Hermes 网关中需要具备服务端权威的资产索引。';

  @override
  String get needs_durable_pin_ordering_batch_mutation_and_undo_contracts_in =>
      'Hermes 网关中需要具备持久化的置顶排序、批量变更和撤销契约。';

  @override
  String get needs_you => '需要你';

  @override
  String get new_label => '新';

  @override
  String get new_chat => '新聊天';

  @override
  String get new_chat_2 => '新聊天';

  @override
  String new_chat_3(Object projectName) {
    return '新聊天 · $projectName';
  }

  @override
  String get new_project => '新建项目';

  @override
  String get new_space => '新建空间';

  @override
  String next(Object nextRun) {
    return '下次运行：$nextRun';
  }

  @override
  String get nginx_injects_auth_app_sends_clean_requests =>
      'Nginx 注入认证 — 应用发送干净请求';

  @override
  String get no_tts_voices_found_ninstall_google_text_to_speech_and =>
      '未找到 TTS 语音。\n请安装 Google Text-to-Speech 并下载语音数据。';

  @override
  String get no_active_projects_on_this_gateway => '此网关上暂无活动项目';

  @override
  String get no_activity_yet => '暂无活动';

  @override
  String get no_chat_is_blocked_running_or_waiting_to_be_resumed =>
      '没有被阻塞、运行中或等待恢复的聊天。准备好后随时可以开始新聊天。';

  @override
  String no_chats_in_this_project_match(Object searchQuery) {
    return '此项目中没有与“$searchQuery”匹配的聊天。';
  }

  @override
  String get no_chats_in_this_space_yet_tap_to_start_one =>
      '此空间暂无聊天。轻点 + 开始聊天。';

  @override
  String get no_chats_yet => '暂无聊天';

  @override
  String get no_connections => '无连接';

  @override
  String get no_conversation_matches_this_view => '没有与此视图匹配的对话。';

  @override
  String get no_cron_jobs => '暂无 Cron 任务';

  @override
  String get no_folders_yet => '暂无文件夹';

  @override
  String get no_local_spaces_were_found_for_this_connection_so_projects =>
      '在此连接中未找到本地空间，因此项目已是此处的唯一组织方式。';

  @override
  String get no_matches => '无匹配项';

  @override
  String get no_memory_entries => '暂无记忆条目';

  @override
  String get no_message_content_matches => '无匹配的消息内容';

  @override
  String get no_new_messages => '暂无新消息';

  @override
  String get no_projects_yet => '暂无项目';

  @override
  String get no_runs_yet => '暂无运行记录。';

  @override
  String no_server_project_matches_this_name(Object assigned) {
    return '没有与此名称匹配的服务端项目 · $assigned';
  }

  @override
  String get no_sessions_yet => '暂无会话';

  @override
  String get no_skills_found => '未找到技能';

  @override
  String get no_spaces_on_this_device => '此设备上无空间';

  @override
  String get no_text_shared => '未共享文本';

  @override
  String get no_turn_is_blocked_in_flight_or_recently_finished_work =>
      '没有被阻塞、进行中或最近完成的轮次。你开始的工作会显示在这里。';

  @override
  String get no_turn_needs_your_input_or_has_failed => '没有需要你输入或失败的轮次。';

  @override
  String get no_unassigned_chats => '暂无未分配的聊天。';

  @override
  String get nothing_changed_in_the_last_seven_days => '最近七天无更改。';

  @override
  String get nothing_has_moved_yet_this_is_only_what_a_migration =>
      '尚未移动任何内容 — 这只是迁移将执行的操作。';

  @override
  String get nothing_here => '这里什么也没有';

  @override
  String get nothing_is_running => '没有正在运行的内容';

  @override
  String get nothing_needs_you => '一切正常，无需处理';

  @override
  String get nothing_to_migrate => '无需迁移';

  @override
  String get notifications => '通知';

  @override
  String get windows_notifications_blocked =>
      'Notifications are unavailable. Use the installed Ares app and check Settings → System → Notifications in Windows.';

  @override
  String get windows_notification_diagnostics =>
      'What Ares submitted to Windows';

  @override
  String get chat_activity_share => 'Share chat activity';

  @override
  String get chat_activity_share_hint =>
      'Tell a compatible connected gateway when you are using this chat, so its phone notification plugin can avoid duplicate alerts. No keys or message text are sent.';

  @override
  String get completion_sound => 'Completion sound';

  @override
  String get completion_sound_system => 'System default';

  @override
  String get completion_sound_mail => 'Mail';

  @override
  String get completion_sound_reminder => 'Reminder';

  @override
  String get completion_sound_silent => 'Silent';

  @override
  String get completion_sound_scope =>
      'Plays for finished replies, the test notification and inside the app. Approvals and other alerts keep their usual sound.';

  @override
  String get completion_sound_scope_android =>
      'Plays for finished replies, the test notification and inside the app. Approvals, other alerts, background notifications from the server and Android Auto messages keep their usual sound.';

  @override
  String get notification_open_action => 'Open';

  @override
  String get app_sounds_mute => 'Mute app sounds';

  @override
  String get app_sounds_mute_hint =>
      'Stops the completion sound Ares plays while it is open. Notifications keep their own sound.';

  @override
  String get notifications_permission_denied =>
      '系统已阻止通知。请在 Android 设置中允许此应用发送通知。';

  @override
  String get off_no_thinking => '关闭（无思考）';

  @override
  String get offline_showing_the_last_known_activity => '离线 — 显示最后已知的活动。';

  @override
  String get offline_showing_the_last_known_chats => '离线 — 显示最后已知的聊天';

  @override
  String get offline_showing_the_last_known_projects => '离线 — 正在显示最后已知的项目。';

  @override
  String get on_this_device => '此设备上';

  @override
  String get on_device => '端侧';

  @override
  String get open_inbox => '打开收件箱';

  @override
  String open_inbox_2(Object count) {
    return '打开收件箱（$count）';
  }

  @override
  String get open_the_hermes_dashboard => '打开 Hermes 仪表盘';

  @override
  String get optional_for_the_memory_cron_skills_settings_tabs_leave_blank =>
      '可选。用于“记忆”、“Cron”、“技能”、“设置”标签页。留空则使用默认仪表盘端口（9119）且无需登录。';

  @override
  String get organization => '组织';

  @override
  String get other_answer => '其他回答';

  @override
  String get overview => '概览';

  @override
  String get passphrase => '密码短语';

  @override
  String get password_optional => '密码（可选）';

  @override
  String get phone_or_tablet => '手机或平板电脑';

  @override
  String get pin_batch_and_undo => '置顶、批量操作与撤销';

  @override
  String get plugin_notifications => '插件通知';

  @override
  String get plugin_notifications_description => '应用在后台时，网关发来了通知。';

  @override
  String get port => '端口';

  @override
  String get preparing_attachments => '正在准备附件…';

  @override
  String get preview_truncated => '预览已截断';

  @override
  String get preview_unavailable => '预览不可用';

  @override
  String get profile => '配置档案';

  @override
  String get profile_default_model => '配置档案默认模型';

  @override
  String profile_default_set_to_chats_with_their_own_model_keep(
    Object selectedModel,
  ) {
    return '配置档案默认值已设为 $selectedModel。拥有独立模型的聊天将保留该覆盖设置。';
  }

  @override
  String
  get profile_this_connection_chats_as_when_the_dashboard_serves_several =>
      '当仪表盘服务于多个配置档案时，为此连接的聊天指定配置档案。留空则使用独立的单配置档案仪表盘。';

  @override
  String get project => '项目';

  @override
  String get project_actions => '项目操作';

  @override
  String get project_chat => '项目聊天';

  @override
  String get project_chats_unavailable => '项目聊天不可用';

  @override
  String get projects => '项目';

  @override
  String get projects_group_related_chats_files_and_activity_and_stay_in =>
      '项目将相关的聊天、文件和活动进行分组，并与你电脑上的 Hermes 保持同步。';

  @override
  String
  get projects_need_a_desktop_gateway_connection_add_the_desktop_gateway =>
      '项目需要 Desktop Gateway 连接。请将 Desktop Gateway URL 添加到此连接，以便跨设备管理聊天。';

  @override
  String get projects_unavailable => '项目不可用';

  @override
  String get projects_activity_new_navigation => '项目、活动 — 新导航';

  @override
  String get promote_to_project => '提升为项目';

  @override
  String get prompt => '提示词';

  @override
  String get protect_this_backup => '保护此备份';

  @override
  String get provider => '提供方';

  @override
  String get proxy_injects_auth_app_sends_clean_requests => '代理注入认证信息；应用发送纯净请求';

  @override
  String get quick_chat => '快速聊天';

  @override
  String get quick_chats_appear_here_after_their_retention_period =>
      '快速聊天将在保留期过后显示在此处。';

  @override
  String get read_aloud => '朗读';

  @override
  String get read_aloud_is_unavailable_on_this_device => '此设备不支持朗读功能';

  @override
  String get reading_response_aloud => '正在朗读回复';

  @override
  String get ready_to_upload => '准备上传';

  @override
  String get reasoning => '推理';

  @override
  String get recently_completed => '最近完成';

  @override
  String get recently_active => '最近活跃';

  @override
  String get recovering_hermes => '正在恢复 Hermes…';

  @override
  String get refresh => '刷新';

  @override
  String get regenerate_response => '重新生成回复';

  @override
  String get remove_attachment => '移除附件';

  @override
  String get rename => '重命名';

  @override
  String get rename_chat => '重命名聊天';

  @override
  String get rename_project => '重命名项目';

  @override
  String get rename_space => '重命名空间';

  @override
  String rename_2(Object projectName) {
    return '重命名 $projectName';
  }

  @override
  String rename_3(Object name) {
    return '重命名 $name';
  }

  @override
  String get replace => '替换';

  @override
  String get repositories => '代码库';

  @override
  String
  get research_the_attached_content_verify_the_important_claims_and_cite =>
      '研究附件内容，核实重要主张并引用来源。';

  @override
  String research_this_content_verify_the_important_claims_and_cite_sources(
    Object text,
  ) {
    return '研究此内容，核实重要主张并引用来源：\n\n$text';
  }

  @override
  String reset_failed_the_secure_storage_may_need_reinstall(Object retryError) {
    return '重置失败：$retryError。安全存储可能需要重新安装。';
  }

  @override
  String get reset_saved_connections => '重置已保存的连接';

  @override
  String get responding => '正在响应…';

  @override
  String response_closed_locally_gateway_stop_failed(Object error) {
    return '响应已在本地关闭；网关停止失败：$error';
  }

  @override
  String get response_closed_locally_no_active_gateway_turn_was_found =>
      '响应已在本地关闭；未找到活动的网关轮次。';

  @override
  String get response_complete => '响应完成';

  @override
  String get response_complete_description => '应用在后台时，一轮对话已完成。';

  @override
  String get response_ready => '回复就绪';

  @override
  String get response_stopped => '回复已停止。';

  @override
  String get restore => '恢复';

  @override
  String get restore_configuration => '恢复配置';

  @override
  String get restore_project => '恢复项目';

  @override
  String get retry => '重试';

  @override
  String retry_failed_for_the_draft_and_prompt_were_kept(Object name) {
    return '$name 重试失败。草稿和提示词已保留。';
  }

  @override
  String get retry_upload => '重试上传';

  @override
  String retrying(Object name) {
    return '正在重试 $name…';
  }

  @override
  String get review_local_spaces => '检查本地空间';

  @override
  String get review_or_promote_quick_chats_past_their_retention_period =>
      '查看或提升超出保留期限的快速聊天';

  @override
  String get review_the_attached_content => '查看附件内容。';

  @override
  String get run_only_this_command => '仅运行此命令。';

  @override
  String get running_now => '正在运行';

  @override
  String get save => '保存';

  @override
  String get save_changes => '保存更改';

  @override
  String get save_a_permanent_rule_in_the_hermes_configuration =>
      '在 Hermes 配置中保存永久规则。';

  @override
  String get save_the_durable_facts_from_the_attached_content_to_memory =>
      '将附件内容中的持久事实保存到记忆中，然后确认保留的内容。';

  @override
  String save_the_durable_facts_from_this_content_to_memory_then(Object text) {
    return '将此内容中的持久事实保存到记忆中，然后确认保留的内容：\n\n$text';
  }

  @override
  String get save_your_connections_and_settings_to_an_encrypted_file_then =>
      '将连接与设置保存到加密文件中，以便在重新安装或在其他设备上时恢复它们。';

  @override
  String save_2(Object filename) {
    return '保存 $filename';
  }

  @override
  String get schedule => '计划';

  @override
  String get scheduled_jobs_and_their_last_runs => '计划任务及其最近运行情况';

  @override
  String get scheduled_tasks => '计划任务';

  @override
  String get script_only_no_agent => '仅脚本（无 Agent）';

  @override
  String get scroll_horizontally => '水平滚动';

  @override
  String get search_all_chats => '搜索所有聊天';

  @override
  String get search_all_message_content => '搜索所有消息内容';

  @override
  String get search_chats => '搜索聊天';

  @override
  String get search_conversations => '搜索对话';

  @override
  String get search_loaded_chats => '搜索已加载的聊天';

  @override
  String get search_mode => '搜索模式';

  @override
  String get select_one_option_or_enter_another_answer => '选择一个选项，或输入其他答案。';

  @override
  String get select_one_or_more_options_then_continue => '选择一个或多个选项，然后继续。';

  @override
  String get select_text => '选择文本';

  @override
  String get send => '发送';

  @override
  String send_failed(Object error) {
    return '发送失败：$error';
  }

  @override
  String send_failed_api_only_permission_denied(Object error) {
    return '发送失败：$error。服务器拒绝了 API 密钥主体的此次写入。如果该会话归 Dashboard 所有，为此连接添加 Dashboard 用户名和密码可能即可发送；服务器也可能是有意拒绝。';
  }

  @override
  String get send_message => '发送消息';

  @override
  String get send_test_notification => '发送测试通知';

  @override
  String get session_sources => '会话来源';

  @override
  String get session_deleted_from_remote_hermes => '已从远程 Hermes 中删除会话。';

  @override
  String session_search_failed(Object error) {
    return '会话搜索失败：$error';
  }

  @override
  String get set_profile_default => '设为默认配置档案';

  @override
  String get settings => '设置';

  @override
  String get share_to_hermes => '分享到 Hermes';

  @override
  String get show_passphrase => '显示密码短语';

  @override
  String get show_tool_calls_thinking_and_message_metadata =>
      '显示工具调用、思考过程和消息元数据';

  @override
  String get signal_messages => 'Signal 消息';

  @override
  String get skills => '技能';

  @override
  String skills_2(Object count) {
    return '技能（$count）';
  }

  @override
  String get skills_and_tools => '技能与工具';

  @override
  String get skip => '跳过';

  @override
  String get slack_chats => 'Slack 聊天';

  @override
  String source(Object source) {
    return '来源：$source';
  }

  @override
  String get space_actions => '空间操作';

  @override
  String get spaces => '空间';

  @override
  String get speak_to_hermes => '对 Hermes 说话';

  @override
  String get speech_recognition_is_unavailable => '语音识别不可用';

  @override
  String get spoken_replies => '语音回复';

  @override
  String get spoken_replies_off => '语音回复已关闭';

  @override
  String get spoken_replies_on => '语音回复已开启';

  @override
  String get stalled_no_update_from_hermes => '已停滞 — 未收到来自 Hermes 的更新';

  @override
  String get start_something_new => '开启新任务';

  @override
  String get start_voice_input => '开始语音输入';

  @override
  String get starting_hermes => '正在启动 Hermes…';

  @override
  String get media_card_download => 'Download file';

  @override
  String get media_card_tap_to_download => 'Tap to download';

  @override
  String get still_loading_your_projects => '正在加载你的项目。';

  @override
  String get stop => '停止';

  @override
  String get stop_response => '停止响应';

  @override
  String get stop_voice_input => '停止语音输入';

  @override
  String get submitted_waiting_for_hermes => '已提交，等待 Hermes 响应';

  @override
  String get suggest_projects_and_learn_from_your_corrections =>
      '建议项目并从你的更正中学习';

  @override
  String get summarize_the_attached_content => '总结附件内容。';

  @override
  String summarize_this_content(Object text) {
    return '总结此内容：\n\n$text';
  }

  @override
  String get switch_profile => '切换配置档案';

  @override
  String get system => '系统';

  @override
  String get take_photo => '拍照';

  @override
  String get tap_to_add_a_remote_hermes_gateway_api_server_port =>
      '点击 + 添加远程 Hermes 网关\n(API Server，端口 8642)';

  @override
  String get tap_the_button_to_start_a_new_chat => '点击 + 按钮开始新的聊天';

  @override
  String get telegram_messages => 'Telegram 消息';

  @override
  String get terminal_sessions => '终端会话';

  @override
  String get test_notification_body => '如果你能看到这条通知，说明通知功能正常。';

  @override
  String get test_notification_sent => '已发送测试通知。';

  @override
  String get test_notification_title => 'Hermes 通知测试';

  @override
  String get test_notification_unsupported => '无法发送通知——请检查系统是否允许通知。';

  @override
  String get text_size => '文字大小';

  @override
  String get text_size_preview => '文字大小预览';

  @override
  String text_size_2(Object label) {
    return '文字大小：$label';
  }

  @override
  String get the_api_key_could_not_be_stored_securely => '无法安全存储 API 密钥。';

  @override
  String get the_project_will_move_to_archived_its_chats_and_files =>
      '该项目将移至“已归档”。其聊天和文件将保持完整，你可以随时恢复它。';

  @override
  String get the_project_will_move_to_archived_its_chats_and_files_2 =>
      '该项目将移至“已归档”。其聊天和文件将保持完整，你可以稍后恢复它。';

  @override
  String get the_active_profile_did_not_return_any_selectable_models =>
      '当前配置档案未返回任何可选模型。';

  @override
  String get the_backup_could_not_be_exported => '无法导出备份。';

  @override
  String get the_backup_could_not_be_restored => '无法恢复备份。';

  @override
  String get the_connection_could_not_be_deleted_safely => '无法安全删除连接。';

  @override
  String get the_connection_could_not_be_stored_securely => '无法安全存储连接。';

  @override
  String get the_dashboard_credentials_could_not_be_stored_securely =>
      '无法安全存储仪表盘凭据。';

  @override
  String get the_detached_reply_failed => '已分离的回复失败。';

  @override
  String the_detached_reply_failed_2(Object error) {
    return '已分离的回复失败：$error';
  }

  @override
  String get the_file_contains_your_api_keys_and_dashboard_password_so =>
      '该文件包含你的 API 密钥和仪表盘密码，因此已加密。没有此密码短语，备份将无法恢复。';

  @override
  String get the_last_turn_failed => '上一轮对话失败';

  @override
  String the_local_connection_store_looks_damaged_you_can_reset_the(
    Object errorType,
  ) {
    return '本地连接存储似乎已损坏 ($errorType)。你可以重置已保存的连接并重新开始。网关上的聊天记录不受影响。';
  }

  @override
  String get the_model_only_rewrites_your_question_into_a_short_full =>
      '该模型仅将你的问题重写为简短的全文查询。Hermes 使用已在主机上配置的提供方凭据。';

  @override
  String get the_server_has_not_reported_folders_for_this_project_yet =>
      '服务器尚未报告此项目的文件夹。全局文件仍可在“更多”中查看。';

  @override
  String get the_turn_failed => '本轮对话失败';

  @override
  String get the_two_passphrases_do_not_match => '两次输入的密码短语不匹配。';

  @override
  String get the_value_is_sent_directly_to_the_active_hermes_gateway =>
      '该值将直接发送至当前活动的 Hermes 网关，不会被此 Android 应用保存。';

  @override
  String get there_are_no_visible_files_in_this_server_folder =>
      '此服务器文件夹中没有可见文件。';

  @override
  String get thinking_effort => '思考强度';

  @override
  String get this_hermes_gateway_does_not_support_opening_a_project_yet =>
      '此 Hermes 网关尚不支持打开项目。请更新服务器上的 Hermes 以在手机上浏览项目。';

  @override
  String get this_hermes_gateway_is_older_than_server_side_projects_so =>
      '此 Hermes 网关版本旧于服务端项目功能，因此聊天仅在此设备上分组。请更新 Hermes 以在多台设备间共享相同项目。';

  @override
  String get this_project_has_no_folder_to_open_the_chat_in =>
      '此项目需要先添加文件夹才能在其中开始聊天。添加文件夹后请重试。';

  @override
  String get this_chat_has_no_messages_available_in_the_desktop_session =>
      '此聊天在 Desktop 会话中暂无可用消息。';

  @override
  String get this_creates_a_permanent_rule_in_hermes_review_the_full =>
      '这将在 Hermes 中创建永久规则。确认前请仔细检查完整命令。';

  @override
  String get this_gateway_does_not_host_projects_yet_update_the_gateway =>
      '此网关尚不支持托管项目。请更新网关以在各设备间整理聊天。';

  @override
  String get this_permanently_deletes_the_project_chats_will_not_be_deleted =>
      '这将永久删除该项目。聊天记录不会被删除；它们将返回至未分配状态。';

  @override
  String get this_server_doesn_t_offer_background_recovery_chats_run_live =>
      '此服务器不提供后台恢复功能 —— 聊天实时运行';

  @override
  String get this_week => '本周';

  @override
  String get titles_previews_and_models => '标题、预览与模型';

  @override
  String get tool_activity => '工具活动';

  @override
  String get trigger_now => '立即触发';

  @override
  String get received_outcome_unknown => '本轮对话已结束 — 结果未确认';

  @override
  String get turn_completed => '本轮对话已完成';

  @override
  String get turn_failed => '对话失败';

  @override
  String get turn_failed_description => '后台对话以错误结束。';

  @override
  String get turn_recovery_failed => '对话恢复失败';

  @override
  String get unable_to_prepare_this_file_try_another_one => '无法准备此文件，请尝试其他文件。';

  @override
  String get unable_to_prepare_this_image_try_another_one => '无法准备此图片，请尝试其他图片。';

  @override
  String unable_to_prepare(Object name) {
    return '无法准备 $name。';
  }

  @override
  String get unable_to_read_the_selected_image_the_selection_was_kept =>
      '无法读取所选图片，已保留当前选择。';

  @override
  String get unassigned => '未分配';

  @override
  String get unassigned_chats => '未分配的聊天';

  @override
  String get untitled_chat => '未命名聊天';

  @override
  String get untitled_session => '未命名会话';

  @override
  String get update_api_key => '更新 API 密钥';

  @override
  String get upload_failed => '上传失败';

  @override
  String get upload_failed_tap_retry => '上传失败 • 点击重试';

  @override
  String uploading(Object index, Object name, Object total) {
    return '正在上传 $index/$total：$name';
  }

  @override
  String get use_as_is => '直接使用';

  @override
  String get use_at_least_8_characters => '请使用至少 8 个字符。';

  @override
  String get use_for_cron_jobs_backed_by_scripts => '用于由脚本支持的 Cron 任务。';

  @override
  String get use_on_device => '使用设备端';

  @override
  String get use_the_attached_content_to_identify_and_fill_the_relevant =>
      '使用附件内容识别并填写相关文档或表单字段。提交任何内容前请先询问。';

  @override
  String use_this_content_to_identify_and_fill_the_relevant_document(
    Object text,
  ) {
    return '使用此内容识别并填写相关文档或表单字段。提交任何内容前请先询问：\n\n$text';
  }

  @override
  String get used_for_hosted_path_prefixes_and_for_the_settings_memory =>
      '用于托管路径前缀以及“设置”、“记忆”、“技能”和“Cron”标签页。若需开放仪表盘，可将用户名/密码留空；若反向代理已注入仪表盘认证，请启用代理模式。';

  @override
  String get username_optional => '用户名（可选）';

  @override
  String using(Object displayName) {
    return '正在使用 $displayName…';
  }

  @override
  String get verbose_mode => '详细模式';

  @override
  String get message_metadata => 'Message details';

  @override
  String get voice => '语音';

  @override
  String voice_setup_failed(Object error) {
    return '语音设置失败：$error';
  }

  @override
  String get waiting_for_your_input => '等待你的输入';

  @override
  String get what_hermes_knows_how_to_do => 'Hermes 能够做的事情';

  @override
  String get what_should_the_agent_do => '要让 Agent 做什么？';

  @override
  String get whatsapp_messages => 'WhatsApp 消息';

  @override
  String get which_project => '哪个项目？';

  @override
  String get workspace => '工作区';

  @override
  String get wrap_lines => '自动换行';

  @override
  String you_can_attach_up_to_items(Object maxRemoteAttachmentDrafts) {
    return '最多可附加 $maxRemoteAttachmentDrafts 个项目。';
  }

  @override
  String get your_answer => '你的回答';

  @override
  String get e_g_dashboard => '例如 /dashboard';

  @override
  String get e_g_dashboard_proxy_path_before_api =>
      '例如 /dashboard（/api/ 之前的代理路径）';

  @override
  String get e_g_profile_peter => '例如 /profile/peter';

  @override
  String get e_g_sol => '例如 sol';

  @override
  String get e_g_0_9_or_every_2h => '例如 0 9 * * * 或 every 2h';

  @override
  String get e_g_daily_backup => '例如每日备份';

  @override
  String downloaded(Object filename) {
    return '已下载 $filename';
  }

  @override
  String activity_name_status(Object displayName, Object statusLabel) {
    return '$displayName：$statusLabel';
  }

  @override
  String connection_status_label(Object connectionLabel, Object label) {
    return '$connectionLabel $label';
  }

  @override
  String get example_host_hint =>
      '192.168.1.50、100.x.y.z 或 hermes-machine.tailnet.ts.net';

  @override
  String get example_profile_prefix_hint_full =>
      '例如 /profile/peter（/api/ 和 /v1/ 之前的代理路径）';

  @override
  String and_more(Object count) {
    return '以及另外 $count 个';
  }

  @override
  String chats_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个聊天',
    );
    return '$_temp0';
  }

  @override
  String on_this_device_only(Object chats) {
    return '$chats · 仅在此设备上';
  }

  @override
  String spaces_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个空间',
    );
    return '$_temp0';
  }

  @override
  String get no_new_projects_needed => '无需创建新项目';

  @override
  String projects_to_create(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个项目待创建',
    );
    return '$_temp0';
  }

  @override
  String chats_migrated_projects_created(
    Object createdProjects,
    Object linkedSessions,
  ) {
    return '已迁移 $linkedSessions 个聊天 · 已创建 $createdProjects 个项目';
  }

  @override
  String chats_stayed_in_local_spaces(Object unlinkedSessions) {
    return '$unlinkedSessions 个聊天保留在本地空间中，可安全重试。';
  }

  @override
  String model_recommended(Object provider) {
    return '$provider • 推荐：小巧且经济';
  }

  @override
  String session_meta(Object count, Object model, Object time) {
    return '$count 条消息 • $model • $time';
  }

  @override
  String model_scope_label(Object model, Object scope) {
    return '$model • $scope';
  }

  @override
  String get this_chat => '此聊天';

  @override
  String get profile_default => '配置档案默认值';

  @override
  String minutes_ago(Object count) {
    return '$count 分钟前';
  }

  @override
  String hours_ago(Object count) {
    return '$count 小时前';
  }

  @override
  String days_ago(Object count) {
    return '$count 天前';
  }

  @override
  String get now_label => '刚刚';

  @override
  String get latest_label => '最新';

  @override
  String new_count_indicator(Object count) {
    return '$count 条新消息';
  }

  @override
  String new_messages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条新消息',
    );
    return '$_temp0';
  }

  @override
  String activity_failed_summary(Object failures, Object total) {
    return '$failures 个失败 • 共 $total 个';
  }

  @override
  String activity_completed_summary(Object count) {
    return '已完成 $count 个';
  }

  @override
  String tool_start_observed(Object time) {
    return '观察到开始 $time（本地时间）';
  }

  @override
  String tool_last_observed(Object time) {
    return '最后观察时间 $time（本地时间）';
  }

  @override
  String tool_result_recorded(Object time) {
    return '结果记录时间 $time（本地时间）';
  }

  @override
  String get tool_time_unavailable => '时间不可用';

  @override
  String get hermes_is_using_a_tool => 'Hermes 正在使用工具';

  @override
  String hermes_is_using_tools(Object count) {
    return 'Hermes 正在使用 $count 个工具';
  }

  @override
  String delegated_tasks_completed(Object count) {
    return '已完成 $count 个委派任务';
  }

  @override
  String delegated_tasks_active(Object count) {
    return '$count 个委派任务进行中';
  }

  @override
  String branch_main(Object label) {
    return '$label · main';
  }

  @override
  String get you_heading => '## 你';

  @override
  String get hermes_heading => '## Hermes';

  @override
  String get action_label => '操作';

  @override
  String get destination_label => '目标';

  @override
  String get markdown_source => '源文本';

  @override
  String get preview_label => '预览';

  @override
  String get share_action_summarize => '总结';

  @override
  String get share_action_explain => '解释';

  @override
  String get share_action_research => '研究';

  @override
  String get share_action_remember => '记住';

  @override
  String get text_size_small => '小';

  @override
  String get text_size_default => '默认';

  @override
  String get text_size_large => '大';

  @override
  String get text_size_extra_large => '特大';

  @override
  String get text_size_use_system_description => '完全使用 Android 辅助功能文字大小。';

  @override
  String text_size_percent_description(Object percent) {
    return 'Android 文字大小的 $percent%。';
  }

  @override
  String text_size_label_description(Object description, Object label) {
    return '$label — $description';
  }

  @override
  String files_skipped(Object count) {
    return '已跳过 $count 个文件：超出限制、大小超限、无法读取或文件名包含敏感信息。';
  }

  @override
  String model_scope_applied(Object effort, Object model) {
    return '$model • $effort 现仅应用于此聊天。';
  }

  @override
  String get reasoning_minimal => '极简';

  @override
  String get reasoning_low => '低';

  @override
  String get reasoning_medium => '中';

  @override
  String get reasoning_high => '高';

  @override
  String get reasoning_max => '最大';

  @override
  String get reasoning_ultra => '极致';

  @override
  String get status_running => '运行中';

  @override
  String get status_failed => '已失败';

  @override
  String get status_done => '完成';

  @override
  String get status_idle => '空闲';

  @override
  String get upload_status_uploading => '正在上传';

  @override
  String get upload_status_uploaded => '已上传';

  @override
  String attachment_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个附件',
    );
    return '$_temp0';
  }

  @override
  String get action_create => '创建';

  @override
  String get action_rename => '重命名';

  @override
  String get action_archive => '归档';

  @override
  String get action_restore => '恢复';

  @override
  String get action_delete => '删除';

  @override
  String get migrate => '迁移';

  @override
  String assigned_chats(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个已分配聊天',
    );
    return '$_temp0';
  }

  @override
  String get date_today => '今天';

  @override
  String get date_yesterday => '昨天';

  @override
  String get date_earlier => '更早';

  @override
  String get nav_home => '主页';

  @override
  String get nav_more => '更多';

  @override
  String get status_completed => '已完成';

  @override
  String get filter_all => '全部';

  @override
  String get filter_recent => '最近';

  @override
  String connection_address_key(Object address, Object status) {
    return '$address  •  密钥：$status';
  }

  @override
  String model_via_provider(Object model, Object provider) {
    return '$model  \n通过 `$provider`';
  }

  @override
  String get deny => '拒绝';

  @override
  String get connect => '连接';

  @override
  String get appearance => '外观';

  @override
  String get connection_section => '连接';

  @override
  String get about => '关于';

  @override
  String version_label(Object version) {
    return '版本 $version';
  }

  @override
  String get matched => '已匹配';

  @override
  String get search => '搜索';

  @override
  String get on => '开';

  @override
  String get off => '关';

  @override
  String get reasoning_off => '关';

  @override
  String get hermes_response_ready => 'Hermes 回复已就绪';

  @override
  String get admin_password_needed => '需要管理员密码';

  @override
  String get hermes_needs_a_sudo_password_for_the_pending_terminal_command =>
      'Hermes 需要 sudo 密码来执行挂起的终端命令。';

  @override
  String get sudo_password => 'sudo 密码';

  @override
  String get secret_needed => '需要密钥';

  @override
  String get hermes_needs_a_secret_for_the_pending_skill =>
      'Hermes 需要为待处理的技能提供一个密钥。';

  @override
  String get secret_value => '密钥值';

  @override
  String get attached_file => '已附加文件';

  @override
  String get pin_chat => '置顶聊天';

  @override
  String get unpin_chat => '取消置顶';

  @override
  String get pinned_chats => '已置顶';

  @override
  String could_not_update_chat_pin(Object error) {
    return '无法更新聊天置顶：$error';
  }

  @override
  String get could_not_save_chat_spaces => '无法在此设备上保存聊天空间';

  @override
  String get update_available => '有可用更新';

  @override
  String get update_now => 'Update now';

  @override
  String get update_install => 'Install update';

  @override
  String get update_downloading => 'Downloading and verifying update…';

  @override
  String get update_allow_install =>
      'Allow Hermes to install this update, then return here and tap Install update.';

  @override
  String get update_failed =>
      'The update could not be downloaded, verified, or opened. Try again or view the release page.';

  @override
  String get a_newer_hermes_android_build_is_available_on_github =>
      'GitHub 上已有更新的 Ares 版本。';

  @override
  String get release_notes => '发行说明';

  @override
  String get view_release => '查看发行版';

  @override
  String get skip_this_version => '跳过此版本';

  @override
  String get later => '稍后';

  @override
  String get check_for_updates => '检查更新';

  @override
  String get check_for_updates_on_launch => '启动时检查更新';

  @override
  String get you_re_on_the_latest_version => '已是最新版本。';

  @override
  String get couldn_t_check_for_updates => '无法检查更新。';

  @override
  String get chat_density => '聊天密度';

  @override
  String chat_density_2(Object label) {
    return '聊天密度：$label';
  }

  @override
  String get chat_density_comfortable => '舒适';

  @override
  String get chat_density_compact => '紧凑';

  @override
  String get chat_density_comfortable_description => '每条消息上方带有发送者标签的更宽松气泡。';

  @override
  String get chat_density_compact_description => '更紧凑的无标签气泡，屏幕上可以显示更多消息。';

  @override
  String chat_density_label_description(Object description, Object label) {
    return '$label — $description';
  }

  @override
  String
  get compact_removes_the_you_and_hermes_labels_and_trims_bubble_padding_spacing_and_side_margins =>
      '紧凑模式会去掉 You 和 Hermes 标签，并缩小气泡内边距、间距和两侧边距。';

  @override
  String get client_certificate_mtls => 'Client certificate (mTLS)';

  @override
  String get client_certificate_mtls_description =>
      'Present a certificate when an HTTPS proxy requires mutual TLS.';

  @override
  String get client_certificate_https_only =>
      'Client certificates are only used for HTTPS connections.';

  @override
  String get choose_certificate => 'Choose certificate';

  @override
  String get certificate_password => 'Certificate password';

  @override
  String get this_certificate_is_password_protected =>
      'This certificate is password-protected. It opens as you type.';

  @override
  String get enter_the_certificate_password_to_finish_loading_it =>
      'Enter the certificate password to finish loading the certificate you chose.';

  @override
  String get client_certificate_required =>
      'Load a client certificate or turn off the client certificate option.';

  @override
  String client_certificate_loaded(String label) {
    return 'Loaded: $label';
  }

  @override
  String get remove_certificate => 'Remove certificate';

  @override
  String get certificate_import_failed =>
      'That certificate could not be loaded.';

  @override
  String get background_work => '后台运行';

  @override
  String get keep_chats_active_in_background => '在后台保持聊天连接';

  @override
  String get background_work_description =>
      '应用在后台时，保持用户发起的聊天连接。空闲连接可能会断开。此功能会增加电量和流量消耗。关闭后不会停止服务器上的任务。';

  @override
  String get background_work_limits =>
      'Android 仍可能在 Doze 模式下暂停连接或结束应用进程。进程结束后的通知需要单独设置推送。不支持强行停止后的通知。';

  @override
  String get background_work_disclosure => '后台保护开启时，即使关闭了可选的聊天通知，仍会显示必需的服务通知。';

  @override
  String get battery_optimisation_settings => '电池优化设置';

  @override
  String get battery_optimisation_description =>
      '打开 Android 设置以查看电池限制。不会自动申请豁免，更改设置也不能保证通知送达。';

  @override
  String get battery_settings_unavailable => '无法在此设备上打开电池设置。';

  @override
  String get background_work_save_failed => '无法保存后台运行设置。';

  @override
  String get ongoing_chat_channel_name => '进行中的聊天';

  @override
  String get ongoing_chat_channel_description => '用户发起的未完成聊天的静默状态更新';

  @override
  String get task_timeline => 'Task timeline';

  @override
  String get task_refresh_history => 'Refresh task history';

  @override
  String get task_live_preview => 'Live preview from parent events';

  @override
  String get task_preview_explanation =>
      'Latest exposed preview only; not a recorded transcript row.';

  @override
  String get task_preview => 'Preview';

  @override
  String get task_recorded_history => 'Recorded task history';

  @override
  String get task_loading_history => 'Loading task history…';

  @override
  String get task_empty_history =>
      'No recorded messages yet. The task may not have flushed its history; this does not mean it produced no work.';

  @override
  String get task_load_older => 'Load older';

  @override
  String get task_default_goal => 'Delegated task';

  @override
  String task_status(Object status) {
    return 'Status: $status';
  }

  @override
  String task_identity(Object id) {
    return 'Task: $id';
  }

  @override
  String task_stored_session(Object id) {
    return 'Stored session: $id';
  }

  @override
  String task_delegation(Object id) {
    return 'Delegation: $id';
  }

  @override
  String get task_read_only_notice =>
      'Read-only · recorded history may appear after the task flushes. Refresh to check again.';

  @override
  String task_row_label(Object id, Object role) {
    return '$role · row $id';
  }

  @override
  String get task_role_assistant => 'Assistant';

  @override
  String get task_role_user => 'User';

  @override
  String get task_role_tool => 'Tool';

  @override
  String task_tool_call(Object name) {
    return 'Tool call · $name';
  }

  @override
  String task_tool_result(Object name) {
    return 'Tool result · $name';
  }

  @override
  String task_call_details(Object arguments, Object id) {
    return 'Call ID: $id\nArguments\n$arguments';
  }

  @override
  String task_result_details(Object id, Object result) {
    return 'Call ID: $id\nResult\n$result';
  }

  @override
  String get task_not_supplied => 'Not supplied';

  @override
  String get task_missing_arguments => 'Arguments not retained by the server.';

  @override
  String get task_image_placeholder => '[image]';

  @override
  String get task_invalid_reference =>
      'Task transcript unavailable: invalid stored session reference.';

  @override
  String get task_auth_required =>
      'Task transcript unavailable: configure Dashboard authentication for this gateway. The API-server key cannot read task reasoning.';

  @override
  String get task_auth_rejected =>
      'Task transcript unavailable: Dashboard authentication was rejected. Check this gateway’s Dashboard settings.';

  @override
  String get task_incompatible_history =>
      'Task transcript unavailable: this Dashboard does not provide compatible bounded raw history for the selected profile.';

  @override
  String get task_identity_unproven =>
      'Task transcript unavailable: the Dashboard could not prove the exact stored session or its compression lineage. No transcript from another session is shown.';

  @override
  String get task_partial_compression =>
      'Partial history: this task continued after compression, but this gateway has not exposed a verifiable newer reference. The final reply may be missing. Automatic refresh is paused; use Refresh to retry.';

  @override
  String get task_partial_ancestors =>
      'Partial history: this gateway omits compression ancestors for this task. Earlier task segments may be missing. Known rows are retained; use Refresh to retry.';

  @override
  String get task_missing_reference =>
      'Task transcript unavailable: this server did not retain its session reference.';

  @override
  String get task_missing_row_identity =>
      'Task transcript unavailable: this server did not supply durable message row identities.';

  @override
  String get task_history_not_ready =>
      'Task history is not available yet (HTTP 404). The task may not have flushed, or this Dashboard may not support task history. Retry to check again.';

  @override
  String get task_refresh_failed =>
      'Could not refresh task history. Check the connection and retry.';

  @override
  String get task_status_interrupted => 'Interrupted';

  @override
  String get task_status_cancelled => 'Cancelled';

  @override
  String get task_status_requested => 'Requested';

  @override
  String get task_status_thinking => 'Thinking';

  @override
  String get task_status_tool => 'Using a tool';

  @override
  String get task_status_pending => 'Pending';

  @override
  String get task_status_dispatched => 'Dispatched';

  @override
  String task_status_unknown(Object status) {
    return 'Unknown status: $status';
  }

  @override
  String task_tasks_finished(Object count) {
    return '$count delegated task(s) finished';
  }

  @override
  String get activity_status_unconfirmed => '状态未确认';

  @override
  String get activity_recently_updated => '最近更新';

  @override
  String get activity_reconnecting => '正在重新连接 — 正在检查轮次状态';

  @override
  String get activity_outcome_unknown => '无法确认本轮对话的结果。请打开聊天查看。';

  @override
  String get activity_chat_updated_detail => '网关已记录聊天活动；无法获取轮次的实时状态。';

  @override
  String get activity_updated => '已更新';

  @override
  String get activity_empty_title => '暂无近期活动';

  @override
  String get activity_empty_detail => '在此应用中启动的轮次，以及过去7天内更新的网关聊天都会显示在这里。';

  @override
  String get activity_read_error => '活动功能无法读取轮次记录或网关聊天。请检查连接后重试。';

  @override
  String get activity_chat_unavailable => '此聊天已不可用，或无法连接到网关。';

  @override
  String get activity_partial_title => '活动已部分加载';

  @override
  String get activity_partial_detail => '目前仅显示网关活动的有限范围。可能还有更多聊天，请下拉刷新。';

  @override
  String get provider_usage => '使用记录';

  @override
  String get provider_usage_notice =>
      'Hermes最近30天的使用量，并非账户余额或模型定价。请在Hermes服务器配置凭据；此应用不保存提供商API密钥。';

  @override
  String get provider_usage_failed => '无法加载使用记录。';

  @override
  String get provider_usage_empty => '此提供商暂无使用记录。';

  @override
  String provider_usage_counts(String sessions, String input, String output) {
    return '$sessions 个会话 · 输入：$input · 输出：$output';
  }

  @override
  String provider_usage_costs(String estimated, String actual) {
    return '估算：$estimated · 报告：$actual';
  }

  @override
  String get provider_quota_codex => 'OpenAI Codex 订阅';

  @override
  String get provider_quota_claude => 'Claude 订阅';

  @override
  String get provider_quota_openai_api => 'OpenAI API 已记录用量';

  @override
  String get provider_quota_notice =>
      '由提供商报告的订阅用量周期，与 Hermes 记录的用量及 API 计费分开显示。各账户单独列出；达到模型限额并不代表整个账户的配额已耗尽。';

  @override
  String get provider_quota_windows_notice =>
      'Codex 和 Claude 订阅设有五小时会话限额和每周限额。仅显示提供商报告的周期；未报告的限额和重置时间仍不可用。每周限额可能适用于整个账户或特定模型。';

  @override
  String get provider_quota_five_hour_session => '5小时会话';

  @override
  String get provider_quota_unavailable => '订阅配额不可用。';

  @override
  String get provider_quota_failed => '无法刷新订阅配额。保留的数值来自上次查询。';

  @override
  String get provider_quota_account => '账户';

  @override
  String get provider_quota_unknown => '未知';

  @override
  String provider_quota_state(String state) {
    return '账户状态：$state';
  }

  @override
  String provider_quota_scope(String scope) {
    return '适用范围：$scope';
  }

  @override
  String provider_quota_percent(String used, String remaining) {
    return '已用 $used% · 剩余 $remaining%';
  }

  @override
  String provider_quota_reset(String reset) {
    return '重置时间：$reset';
  }

  @override
  String get provider_quota_reset_unknown => '重置时间不可用。';

  @override
  String get auxiliary_models => '辅助模型';

  @override
  String get auxiliary_notice => '为各任务选择模型。自定义端点必须在服务器管理。自动模式遵循任务的继承规则。';

  @override
  String get auxiliary_inherit => '自动（继承）';

  @override
  String get auxiliary_unavailable => '辅助设置不可用。';

  @override
  String get provider_oauth_title => '提供商登录';

  @override
  String get provider_oauth_more_subtitle => '管理 Hermes 主机上的提供商登录';

  @override
  String get provider_oauth_settings_subtitle =>
      '在 Hermes 主机上登录；提供商令牌不会保存在此设备上';

  @override
  String get provider_oauth_intro =>
      '在外部浏览器中登录提供商。令牌仅存储在 Hermes 主机上，不会保存在此设备上。登录不会选择此应用中的聊天模型。';

  @override
  String get provider_oauth_defaults_notice =>
      '某些主机流程（包括替换 Nous 免费套餐账户）可能会更新主机默认设置。登录后请检查主机设置。';

  @override
  String get provider_oauth_transport_init_failed =>
      '无法初始化所选的安全仪表板连接。请检查其 TLS 身份和连接设置。';

  @override
  String get provider_oauth_https_required => '提供商登录需要通过 HTTPS 连接到 Hermes 仪表板。';

  @override
  String get provider_oauth_auth_required => '登录前请配置仪表板密码验证或可信代理。';

  @override
  String get provider_oauth_catalog_failed =>
      '此主机不支持提供商登录。请检查仪表板身份验证；如果主机不支持提供商 OAuth，请更新主机。';

  @override
  String get provider_oauth_expired => '登录已过期。请重新开始。';

  @override
  String get provider_oauth_start_failed => '无法启动安全的提供商登录。请重试。';

  @override
  String get provider_oauth_denied => '登录被拒绝。请重新开始。';

  @override
  String get provider_oauth_cancelled => '登录已取消。';

  @override
  String get provider_oauth_host_failed => '主机无法完成登录。请重新开始。';

  @override
  String get provider_oauth_poll_failed => '无法检查登录状态。请重新开始。';

  @override
  String provider_oauth_cancellation_unconfirmed(String message) {
    return '$message 无法确认取消；主机会话可能会持续到过期为止。';
  }

  @override
  String get provider_oauth_browser_failed => '无法打开外部浏览器。请重试或取消登录。';

  @override
  String get provider_oauth_retry => '重试';

  @override
  String provider_oauth_complete(String provider) {
    return '完成 $provider 的登录';
  }

  @override
  String get provider_oauth_code_instruction => '请在提供商页面输入此临时代码：';

  @override
  String get provider_oauth_waiting => '正在等待批准。此会话将自动过期。';

  @override
  String get provider_oauth_open_browser => '在浏览器中打开提供商';

  @override
  String get provider_oauth_cancel => '取消登录';

  @override
  String get provider_oauth_signed_out => '未在主机上登录';

  @override
  String get provider_oauth_sign_in_again => '重新登录';

  @override
  String get provider_oauth_sign_in => '登录';

  @override
  String get provider_oauth_cli_required =>
      '请在 Hermes 主机上使用提供商 CLI 登录。此主机不支持该提供商的应用内登录。';

  @override
  String get provider_oauth_checking_account => '已收到授权。正在检查主机账户…';

  @override
  String get provider_oauth_verification_unavailable =>
      '已收到授权；无法验证账户。请打开用量页面以刷新账户用量。';

  @override
  String provider_oauth_verified_account(String email) {
    return '已在 Hermes 主机上以 $email 登录。请打开用量页面以刷新账户用量。';
  }

  @override
  String get provider_oauth_credentials_unverified => '主机报告凭据可用；账户身份尚未验证。';

  @override
  String get provider_oauth_account_status_unknown => '无法获取主机账户状态。';

  @override
  String get app_language => 'App language';

  @override
  String get app_language_system => 'Same as phone';

  @override
  String get auto_archives_after_72_hours => 'Auto-archives after 72 hours';

  @override
  String get automation => 'Automation';

  @override
  String get voice_recording_start => 'Record voice message';

  @override
  String get voice_recording_pause => 'Pause recording';

  @override
  String get voice_recording_preview => 'Play recording';

  @override
  String get voice_recording_resume => 'Continue recording';

  @override
  String get voice_recording_send => 'Send voice message';

  @override
  String get voice_recording_discard => 'Discard recording';

  @override
  String get voice_recording_processing => 'Preparing voice message…';

  @override
  String voice_recording_elapsed(String time) {
    return 'Recording $time';
  }

  @override
  String voice_recording_draft(String time) {
    return 'Voice message $time';
  }

  @override
  String get voice_recording_permission =>
      'Allow microphone access to record a voice message.';

  @override
  String get voice_recording_limit =>
      'This recording has reached the ten-minute limit.';

  @override
  String get voice_recording_empty => 'No audio was recorded. Try again.';

  @override
  String get voice_recording_failed =>
      'Could not process the recording. Any saved fragments have been kept.';

  @override
  String get voice_recording_unconfirmed =>
      'Delivery was not confirmed. Your recording is saved. Check the chat before trying again.';

  @override
  String get voice_recording_submit_failed =>
      'Could not send the voice message. Your recording is saved. Check the connection, Dashboard access and server transcription settings.';

  @override
  String get voice_recording_pause_playback => 'Pause playback';

  @override
  String get projects_root_title => '服务器上的项目文件夹';

  @override
  String get projects_root_more_subtitle => '服务器上新建项目文件夹的位置';

  @override
  String get projects_root_description =>
      '在此手机上创建的项目会在这里获得文件夹。将其指向 Hermes 自身使用的文件夹，手机和服务器就能共享同一批项目。';

  @override
  String get projects_root_label => '项目根路径';

  @override
  String projects_root_default_hint(String path) {
    return '服务器默认值：$path';
  }

  @override
  String get projects_root_locked_title => '由服务器设定';

  @override
  String get projects_root_locked_explanation =>
      '此服务器将文件访问限制在单一根目录内，因此无法在应用中更改项目文件夹。';

  @override
  String get projects_root_saved => '已保存项目文件夹。';

  @override
  String get projects_root_reset => '使用服务器默认值';

  @override
  String get projects_root_invalid_empty => '请输入文件夹路径。';

  @override
  String get projects_root_invalid_absolute => '请输入以斜杠开头的绝对路径。';

  @override
  String get projects_root_invalid_segments => '请从路径中移除点号片段和控制字符。';

  @override
  String get projects_root_unsupported =>
      '此连接不支持。读取或更改服务器上的项目文件夹需要具有仪表板访问权限的 Desktop Gateway 连接。';

  @override
  String get projects_root_unavailable => '无法读取服务器上的项目文件夹。请检查仪表板连接后重试。';

  @override
  String get adopt_folder_action => '添加现有文件夹';

  @override
  String adopt_folder_description(String root) {
    return '$root 下尚未注册为项目的文件夹。';
  }

  @override
  String adopt_folder_registered(String name) {
    return '已是项目：$name';
  }

  @override
  String get adopt_folder_none => '此路径下的所有文件夹都已是项目。';

  @override
  String get adopt_folder_unsupported => '此连接无法列出服务器文件夹。请改为输入现有文件夹的绝对路径。';

  @override
  String adopt_folder_failed(String error) {
    return '无法列出服务器文件夹：$error';
  }

  @override
  String get adopt_folder_manual_label => '现有文件夹路径';

  @override
  String get adopt_folder_name_label => '项目名称';

  @override
  String get adopt_folder_add => '添加为项目';

  @override
  String adopt_folder_added(String name, String path) {
    return '$name 现在使用 $path';
  }

  @override
  String adopt_folder_error(String error) {
    return '无法添加该文件夹：$error';
  }

  @override
  String adopt_folder_folderless(String name) {
    return '已创建 $name，但未关联文件夹。请在服务器上的 Hermes 中关联。';
  }

  @override
  String get slash_commands => 'Slash commands';

  @override
  String get slash_commands_loading => 'Loading commands…';

  @override
  String get slash_commands_empty => 'No matching commands';

  @override
  String slash_command_info_alias(String alias, String command) {
    return '$alias 是 $command 的别名';
  }

  @override
  String get slash_command_info_no_description => '暂无说明。';

  @override
  String get slash_command_info_arguments_options => '接受固定选项中的一个。';

  @override
  String get slash_command_info_arguments_text => '在命令后接受文本。';

  @override
  String get slash_command_info_arguments_mixed => '在命令后接受选项或文本。';

  @override
  String get slash_command_output => 'Command output';

  @override
  String get slash_command_no_output => 'The command completed with no output.';

  @override
  String get slash_command_delivery_unknown =>
      'The command was sent but its reply never arrived. It may still be running on the gateway, so your draft was kept. Check the gateway before retrying.';

  @override
  String get slash_command_failed => 'The command could not be run.';

  @override
  String get slash_command_unsupported => '此命令在此服务器上不可用。';

  @override
  String get slash_sessions_inline => '请打开会话列表选择聊天。草稿已保留。';

  @override
  String get composer_snippets => 'Prompt snippets';

  @override
  String get composer_snippets_description =>
      'Pick a starter prompt to drop into the composer.';

  @override
  String get composer_snippet_review => 'Code review';

  @override
  String get composer_snippet_review_body =>
      'Audit the current change for regressions, dropped edge cases and missing tests.';

  @override
  String get composer_snippet_review_text =>
      'Please review this for bugs, regressions and missing tests.';

  @override
  String get composer_snippet_plan => 'Implementation plan';

  @override
  String get composer_snippet_plan_body =>
      'Outline an approach before touching code so the diff stays focused.';

  @override
  String get composer_snippet_plan_text =>
      'Please make a concise implementation plan before changing code.';

  @override
  String get composer_snippet_explain => 'Explain this';

  @override
  String get composer_snippet_explain_body =>
      'Walk through how the selected code works and point to the key files.';

  @override
  String get composer_snippet_explain_text =>
      'Please explain how this works and point me to the key files.';

  @override
  String get composer_status => 'Status';

  @override
  String get composer_status_context => 'Context';

  @override
  String get composer_status_cache => 'Cache hit';

  @override
  String get composer_status_throughput => 'Output tokens/sec';

  @override
  String get composer_status_running => 'Running';

  @override
  String get composer_status_session => 'Session';

  @override
  String get composer_status_not_reported => 'Not reported';

  @override
  String get composer_status_empty => 'No context breakdown was reported.';

  @override
  String get composer_status_loading => 'Loading context breakdown';

  @override
  String get composer_status_reset => 'Reset status bar';

  @override
  String get composer_resume_title => 'Resume a chat';

  @override
  String get composer_resume_search => 'Search titles and ids';

  @override
  String get composer_resume_empty => 'No chats match.';

  @override
  String get composer_resume_unavailable =>
      'This pane has no chat list to search.';

  @override
  String get composer_failure_retry => 'Retry';

  @override
  String composer_failure_retry_at(String time) {
    return 'Retry at $time';
  }

  @override
  String get composer_failure_compress => 'Compress';

  @override
  String get composer_failure_switch_model => 'Switch model';

  @override
  String composer_failure_switch_to(String model) {
    return 'Switch to $model';
  }

  @override
  String get composer_failure_new_chat => 'New chat';

  @override
  String get composer_failure_edit => 'Edit message';

  @override
  String get composer_failure_details => 'Details';

  @override
  String get composer_failure_hide_details => 'Hide details';

  @override
  String get composer_failure_copy => 'Copy diagnostics';

  @override
  String get composer_failure_account =>
      'The other fix is on the gateway account. This chat cannot do it.';

  @override
  String get composer_failure_account_only =>
      'This has to be fixed on the gateway account. This chat cannot do it.';

  @override
  String get composer_failure_confirm_compress =>
      'Compress this chat? The gateway will shorten the transcript.';

  @override
  String composer_failure_confirm_model(String model) {
    return 'Switch this chat to $model?';
  }

  @override
  String get composer_drop_attach => 'Drop to attach';

  @override
  String get composer_drop_folder_unsupported =>
      'Folders can\'t be attached. Drop the files instead.';

  @override
  String get composer_drop_reference => 'Drop to reference';

  @override
  String get composer_reference_copy => 'Copy reference';

  @override
  String get composer_reference_remove => 'Remove reference';

  @override
  String get composer_btw_usage =>
      'Usage: /btw <question> — answered from a snapshot of this conversation without interrupting it.';

  @override
  String get composer_background_usage =>
      'Usage: /background <prompt> — the task runs separately and the result comes back here.';

  @override
  String get composer_handoff_usage =>
      'Usage: /handoff <platform> — transfer this chat to that messaging platform.';

  @override
  String get composer_command_needs_session =>
      'This command needs an open chat.';

  @override
  String get composer_retry_not_found =>
      'This turn is not in the saved history, so Retry cannot replace it. Nothing was sent again. Edit the message and send it for another try.';

  @override
  String get composer_retry_unavailable =>
      'Retry cannot replace a turn on this connection, so nothing was sent again. Edit the message and send it for another try.';

  @override
  String get composer_failure_switch_no_retry =>
      '切换只会更改模型：此连接无法重新运行失败的轮次。切换后请重新发送。';

  @override
  String get composer_command_needs_gateway_session =>
      'This chat has no gateway session yet. Send a message first, then run the command again.';

  @override
  String get composer_side_question =>
      'btw — answering from a conversation snapshot';

  @override
  String composer_side_question_id(String id) {
    return 'btw $id — answering from a conversation snapshot';
  }

  @override
  String get composer_background_started =>
      'Background task started. You can keep chatting. The result will appear here.';

  @override
  String composer_background_started_id(String id) {
    return 'Background task $id started. You can keep chatting. The result will appear here.';
  }

  @override
  String composer_handoff_requested(String platform) {
    return 'Handoff to $platform requested.';
  }

  @override
  String composer_handoff_done(String platform) {
    return 'Handed this chat to $platform.';
  }

  @override
  String get composer_handoff_failed => 'Handoff failed.';

  @override
  String get composer_handoff_timeout =>
      'Handoff did not finish. It may still be running on the gateway.';

  @override
  String get composer_compress_done => 'Compressed this chat.';

  @override
  String get composer_file_missing => 'That file is not on this device.';

  @override
  String get composer_attach_busy =>
      'Attachments can be added when this reply finishes.';

  @override
  String get nextgen_toggle => 'NextGen 界面';

  @override
  String get nextgen_toggle_subtitle => '全新设计：一次登录、实时聊天和网络发现。你的网关和聊天与此界面共享。';

  @override
  String get nextgen_single_login => '使用单一登录';

  @override
  String get nextgen_single_login_subtitle => '只需仪表板地址和一次登录即可添加网关。';

  @override
  String get ng_allow_this_command => '允许执行此命令？';

  @override
  String ng_hermes_wants_to_run_this_with(Object tool) {
    return 'Hermes 想使用 $tool 执行此操作。';
  }

  @override
  String get ng_hermes_wants_to_run_this => 'Hermes 想执行此操作。';

  @override
  String get ng_hermes_has_a_question => 'Hermes 有一个问题';

  @override
  String get ng_hermes_has_questions => 'Hermes 有几个问题';

  @override
  String get ng_password_for_sudo => 'sudo 密码';

  @override
  String get ng_hermes_needs_your_sudo_password_to =>
      'Hermes 需要你的 sudo 密码来运行此命令。';

  @override
  String get ng_a_secret_value => '机密值';

  @override
  String ng_value_for(Object variable) {
    return '$variable 的值';
  }

  @override
  String get ng_your_password_manager => '你的密码管理器';

  @override
  String ng_unlock(Object name) {
    return '解锁 $name';
  }

  @override
  String ng_hermes_needs_unlocked_to_sign_in(Object name) {
    return 'Hermes 需要先解锁 $name，才能为你登录。';
  }

  @override
  String get ng_sign_in_code => '登录验证码';

  @override
  String get ng_enter_the_sign_in_code => '输入登录验证码。';

  @override
  String ng_enter_the_sign_in_code_for(Object site) {
    return '输入 $site 的登录验证码。';
  }

  @override
  String get ng_save_a_login => '保存登录信息？';

  @override
  String ng_save_your_login(Object site) {
    return '保存你的 $site 登录信息？';
  }

  @override
  String ng_couldn_t_load_this_chat(Object error) {
    return '无法加载此聊天：$error';
  }

  @override
  String ng_live_updates_are_unavailable(Object error) {
    return '实时更新不可用：$error';
  }

  @override
  String ng_preparing(Object name) {
    return '正在准备 $name…';
  }

  @override
  String get ng_the_turn_failed => '本轮对话失败。';

  @override
  String get ng_turn_changed => '该轮对话已结束或已开始新一轮';

  @override
  String get ng_steer_rejected => '正在进行的对话未接受此内容';

  @override
  String get ng_turn_not_known_yet => '尚不清楚正在进行的对话；请稍后再试';

  @override
  String ng_couldn_t_stop(Object error) {
    return '无法停止：$error';
  }

  @override
  String get ng_server_access => '服务器访问';

  @override
  String get ng_sign_in => '登录';

  @override
  String get ng_live_connection => '实时连接';

  @override
  String get ng_check_that_tailscale_is_on_on => '请确认此手机和服务器上的 Tailscale 均已开启。';

  @override
  String get ng_check_the_address_and_that_the => '请检查地址，并确认代理已转发到仪表盘。';

  @override
  String get ng_use_the_same_network_as_the =>
      '请使用与服务器相同的网络，并使用 --host 0.0.0.0 启动仪表盘，以便其他设备访问。';

  @override
  String get ng_check_the_address_vpn_or_tailscale =>
      '请检查地址、VPN 或 Tailscale 连接。';

  @override
  String get ng_not_checked_yet => '尚未检查。';

  @override
  String get ng_checking => '正在检查…';

  @override
  String ng_hermes_answers_at(Object version, Object address) {
    return 'Hermes $version 可通过 $address 访问。';
  }

  @override
  String get ng_something_answered_but_not_a_hermes => '有服务响应，但不是 Hermes 仪表盘。';

  @override
  String ng_something_answered_http_but_not_a(Object status) {
    return '有服务响应（HTTP $status），但不是 Hermes 仪表盘。';
  }

  @override
  String get ng_use_the_dashboard_s_address_and =>
      '请使用仪表盘的地址和端口（默认为 9119），而不是 API 服务器的地址和端口。';

  @override
  String get ng_cloudflare_access_turned_the_service_token =>
      'Cloudflare Access 拒绝了服务令牌。';

  @override
  String get ng_cloudflare_access_is_in_front_of =>
      '此地址前方配置了 Cloudflare Access。';

  @override
  String get ng_check_the_service_token_and_its => '请检查服务令牌及其 Service Auth 策略。';

  @override
  String get ng_add_a_cloudflare_access_service_token =>
      '为此地址添加 Cloudflare Access 服务令牌。';

  @override
  String get ng_the_server_asks_for_a_client => '服务器要求提供客户端证书。';

  @override
  String get ng_pick_the_client_certificate_for_this => '为此网关选择客户端证书，然后再次测试。';

  @override
  String get ng_needs_server_access_first => '请先连接服务器。';

  @override
  String get ng_needs_a_sign_in_first => '请先登录。';

  @override
  String ng_signed_in_as(Object name) {
    return '已登录为 $name。';
  }

  @override
  String get ng_this_dashboard_doesn_t_need_a => '此仪表盘无需登录。';

  @override
  String get ng_the_saved_sign_in_has_expired => '已保存的登录信息已过期。';

  @override
  String get ng_sign_in_again => '重新登录。';

  @override
  String get ng_too_many_sign_in_attempts => '登录尝试次数过多。';

  @override
  String get ng_wait_a_minute_then_check_again => '请稍等一分钟后再试。';

  @override
  String ng_the_gateway_answered(Object message) {
    return '网关返回：$message。';
  }

  @override
  String get ng_sign_in_again_or_update_hermes => '请重新登录，或更新 Hermes。';

  @override
  String ng_couldn_t_check_the_sign_in(Object error) {
    return '无法检查登录状态：$error';
  }

  @override
  String ng_the_gateway_wouldn_t_issue_a(Object message) {
    return '网关无法签发聊天凭证（$message）。';
  }

  @override
  String get ng_the_chat_connection_opened_and_the => '聊天连接已建立，网关已确认就绪。';

  @override
  String get ng_the_gateway_never_said_it_was => '网关始终未确认就绪。';

  @override
  String get ng_check_that_the_agent_is_running => '请确认服务器上的代理正在运行。';

  @override
  String get ng_the_gateway_refused_the_chat_connection =>
      '网关拒绝了聊天连接（HTTP 403）。';

  @override
  String get ng_this_dashboard_has_no_chat_endpoint => '此仪表盘没有聊天端点（/api/ws）。';

  @override
  String ng_the_chat_connection_failed(Object detail) {
    return '聊天连接失败：$detail';
  }

  @override
  String get ng_use_the_exact_address_the_dashboard => '请使用仪表盘配置的完整地址。';

  @override
  String get ng_update_hermes => '更新 Hermes。';

  @override
  String get ng_make_sure_the_proxy_allows_websocket =>
      '请确认代理允许在 /api/ws 上进行 WebSocket 升级。';

  @override
  String get ng_offline => '离线';

  @override
  String get ng_connecting => '正在连接…';

  @override
  String get ng_connected => '已连接';

  @override
  String get ng_reconnecting => '正在重新连接…';

  @override
  String get ng_signed_out => '已退出登录';

  @override
  String get ng_connection_failed => '连接失败';

  @override
  String get ng_rate_limited_by_gateway => '已触发网关限流';

  @override
  String ng_couldn_t_open_the_chat_connection(Object message) {
    return '无法建立聊天连接：$message';
  }

  @override
  String get ng_the_gateway_returned_no_websocket_ticket =>
      '网关未返回 WebSocket 票据。';

  @override
  String get ng_connection_lost => '连接已断开';

  @override
  String get ng_this_dashboard_has_no_chat_endpoint_2 =>
      '此仪表板没有聊天端点（/api/ws）。请更新 Hermes。';

  @override
  String get ng_the_gateway_refused_the_chat_connection_2 =>
      '网关拒绝了聊天连接。请检查地址是否与仪表板配置的主机匹配，并确认已启用嵌入式聊天。';

  @override
  String ng_the_gateway_refused(Object method) {
    return '网关拒绝了 $method。';
  }

  @override
  String ng_couldn_t_read_your_saved_gateways(Object error) {
    return '无法读取已保存的网关：$error';
  }

  @override
  String get ng_applies_to_new_chats => '仅应用于新聊天';

  @override
  String ng_couldn_t_change(Object label, Object error) {
    return '无法更改$label：$error';
  }

  @override
  String get ng_capabilities => '功能';

  @override
  String get ng_skills => '技能';

  @override
  String get ng_toolsets => '工具集';

  @override
  String get ng_search => '搜索';

  @override
  String get ng_couldn_t_load => '无法加载';

  @override
  String get ng_try_again => '重试';

  @override
  String get ng_no_skills => '没有技能';

  @override
  String get ng_no_toolsets => '没有工具集';

  @override
  String get ng_no_mcp_servers => '没有 MCP 服务器';

  @override
  String get ng_that_file_is_too_large_to => '该文件太大，无法作为证书使用。';

  @override
  String ng_the_certificate_couldn_t_be_imported(Object error) {
    return '无法导入证书：$error';
  }

  @override
  String get ng_now_pick_its_private_key => '现在选择对应的私钥。';

  @override
  String get ng_now_pick_its_certificate => '现在选择对应的证书。';

  @override
  String get ng_that_file_isn_t_a_certificate => '该文件不是证书或私钥。';

  @override
  String get ng_if_a_proxy_in_front_of =>
      '如果此地址前的代理要求客户端证书，请在此选择证书，以便测试、登录和聊天时都能出示。';

  @override
  String get ng_client_certificates_are_only_used_with =>
      '客户端证书仅用于 https:// 地址。';

  @override
  String get ng_remove => '移除';

  @override
  String get ng_certificate_password => '证书密码';

  @override
  String get ng_importing => '正在导入…';

  @override
  String get ng_pick_certificate => '选择证书';

  @override
  String get ng_pick_a_different_certificate => '选择其他证书';

  @override
  String get ng_accepts_p12_pfx_or_pem_certificate =>
      '支持 .p12/.pfx 文件，或 PEM 证书和密钥文件。密钥会保存在此应用的私有存储空间中。';

  @override
  String get ng_photos => '照片';

  @override
  String get ng_camera => '相机';

  @override
  String get ng_files => '文件';

  @override
  String ng_you_can_attach_up_to_files(Object count) {
    return '最多可附加 $count 个文件。';
  }

  @override
  String ng_couldn_t_read(Object name) {
    return '无法读取 $name。';
  }

  @override
  String ng_couldn_t_prepare_that_file(Object error) {
    return '无法处理该文件：$error';
  }

  @override
  String get ng_hermes_is_still_working => 'Hermes 仍在处理中';

  @override
  String get ng_steer => '引导';

  @override
  String get ng_adds_this_to_the_running_turn => '在当前轮次的下一步中添加此内容';

  @override
  String get ng_queue => '排队';

  @override
  String get ng_sends_it_when_the_turn_finishes => '当前轮次结束后发送';

  @override
  String get ng_stop_and_send => '停止并发送';

  @override
  String get ng_stops_the_turn_then_sends_this => '停止当前轮次，然后发送此内容';

  @override
  String ng_dictation_stopped(Object message) {
    return '听写已停止：$message';
  }

  @override
  String get ng_speech_recognition_isn_t_available => '语音识别不可用。';

  @override
  String get ng_working => '处理中';

  @override
  String get ng_ready => '就绪';

  @override
  String get ng_chats => '聊天';

  @override
  String get ng_new_chat => '新建聊天';

  @override
  String get ng_usage => '用量';

  @override
  String get ng_rename_chat => '重命名聊天';

  @override
  String ng_couldn_t_rename(Object error) {
    return '无法重命名：$error';
  }

  @override
  String get ng_this_chat => '此聊天';

  @override
  String get ng_input_tokens => '输入 Token';

  @override
  String get ng_output_tokens => '输出 Token';

  @override
  String get ng_reasoning_tokens => '推理 Token';

  @override
  String get ng_cache_reads => '缓存读取';

  @override
  String get ng_api_calls => 'API 调用';

  @override
  String get ng_cost => '费用';

  @override
  String get ng_context => '上下文';

  @override
  String get ng_your_sign_in_expired => '登录已过期。';

  @override
  String get ng_sign_in_2 => '登录';

  @override
  String get ng_retry => '重试';

  @override
  String get ng_project_home => '主页';

  @override
  String get ng_choose_project => '选择项目';

  @override
  String ng_project_cwd_fallback(String path) {
    return '项目文件夹不可用，因此此聊天在 $path 中运行。';
  }

  @override
  String get ng_project_create_uncertain =>
      '网关可能已创建此聊天，但未确认。开始新聊天前请检查聊天列表；此请求不会自动重试。';

  @override
  String get ng_what_should_we_work_on => '我们要做些什么？';

  @override
  String get ng_ask_hermes_anything_it_can_run =>
      '向 Hermes 提问。它可以运行工具、浏览网页，还能处理服务器上的文件。';

  @override
  String ng_working_2(Object frame) {
    return '正在处理 · $frame';
  }

  @override
  String get ng_default_model => '默认模型';

  @override
  String get ng_listening => '正在聆听…';

  @override
  String get ng_steer_or_queue_a_message => '发送指示或排队发送消息';

  @override
  String get ng_message_hermes => '给 Hermes 发消息';

  @override
  String get ng_attach => '添加附件';

  @override
  String get ng_stop_dictation => '停止听写';

  @override
  String get ng_dictate => '语音输入';

  @override
  String get ng_stop => '停止';

  @override
  String get ng_send => '发送';

  @override
  String ng_slash_command_alias(String alias, String command) {
    return '$alias 是 $command 的别名';
  }

  @override
  String get ng_slash_command_no_description => '暂无说明。';

  @override
  String get ng_slash_command_arguments_options => '接受固定选项中的一个。';

  @override
  String get ng_slash_command_arguments_text => '在命令后接受文本。';

  @override
  String get ng_slash_command_arguments_mixed => '在命令后接受选项或文本。';

  @override
  String get ng_slash_command_sent_as_message =>
      'NextGen 会将此作为普通消息发送给 Hermes，不会执行该命令。';

  @override
  String get ng_slash_command_output => '命令输出';

  @override
  String get ng_slash_command_running => '正在运行命令…';

  @override
  String get ng_slash_command_done => '完成。';

  @override
  String ng_slash_command_failed(Object error) {
    return '无法运行命令：$error';
  }

  @override
  String get ng_slash_command_refused => 'Hermes 无法在此运行此命令。';

  @override
  String get ng_slash_command_delivery_unknown =>
      '命令已发送，但未收到回复。它可能仍在网关上运行，因此没有重新发送，并保留了你的草稿。';

  @override
  String get ng_slash_command_nothing_running => '当前没有正在运行的任务。';

  @override
  String get ng_steered => '已调整指示';

  @override
  String get ng_copied => '已复制';

  @override
  String ng_not_sent(Object reason) {
    return '未发送：$reason';
  }

  @override
  String get ng_thinking => '正在思考…';

  @override
  String get ng_thought => '思考';

  @override
  String ng_used(Object name) {
    return '已使用 $name';
  }

  @override
  String ng_used_tools(Object count) {
    return '已使用 $count 个工具';
  }

  @override
  String get ng_copy => '复制';

  @override
  String get ng_read_aloud => '朗读';

  @override
  String get ng_the_gateway_connection_dropped_try_again => '网关连接已断开，请重试。';

  @override
  String get ng_allow_once => '允许一次';

  @override
  String get ng_allow_until_sandbox_off => '直到关闭沙盒';

  @override
  String get ng_folder_access => '文件夹访问';

  @override
  String get ng_folder_access_unspecified => '网关未说明是只读还是可读写。';

  @override
  String get ng_folder_read_only => '只读';

  @override
  String get ng_folder_read_write => '可读写';

  @override
  String get ng_website_access => '网站访问';

  @override
  String get ng_allow_for_this_chat => '在此聊天中允许';

  @override
  String get ng_always_allow => '始终允许';

  @override
  String get ng_deny => '拒绝';

  @override
  String get ng_your_answer => '你的回答';

  @override
  String get ng_or_type_an_answer => '或输入回答';

  @override
  String get ng_skip => '跳过';

  @override
  String get ng_answer => '回答';

  @override
  String get ng_cancel => '取消';

  @override
  String get ng_username_or_email => '用户名或邮箱';

  @override
  String get ng_password => '密码';

  @override
  String get ng_not_now => '暂不';

  @override
  String get ng_save => '保存';

  @override
  String get ng_enter_both_the_client_id_and =>
      '请同时填写 Client ID 和 Client Secret，或都留空。';

  @override
  String get ng_enter_your_username_and_password => '请输入用户名和密码。';

  @override
  String ng_couldn_t_save_the_sign_in(Object error) {
    return '无法保存登录信息：$error';
  }

  @override
  String get ng_wrong_username_or_password => '用户名或密码错误。';

  @override
  String get ng_too_many_attempts_wait_a_moment => '尝试次数过多，请稍等片刻再试。';

  @override
  String get ng_welcome_to_hermes => '欢迎使用 Ares';

  @override
  String get ng_add_a_gateway => '添加网关';

  @override
  String get ng_connect_to_your_hermes_agent_dashboard =>
      '连接到你的 Hermes Agent 控制面板。使用一个地址和一次登录，即可访问聊天、工具和设置。登录前不会发送任何内容。';

  @override
  String get ng_connect_to_another_hermes_agent_dashboard =>
      '连接到另一个 Hermes Agent 控制面板。你仍会登录已保存的控制面板。';

  @override
  String get ng_dashboard_address => '控制面板地址';

  @override
  String get ng_testing => '正在测试…';

  @override
  String get ng_test => '测试';

  @override
  String get ng_where_your_hermes_dashboard_runs_lan =>
      '你的 Hermes 控制面板所在的位置：局域网、Tailscale 或 HTTPS。';

  @override
  String get ng_find_on_my_network => '在我的网络中查找';

  @override
  String get ng_which_address_do_i_use => '我应该使用哪个地址？';

  @override
  String get ng_behind_cloudflare_access => '使用 Cloudflare Access 保护？';

  @override
  String get ng_need_a_client_certificate => '需要客户端证书？';

  @override
  String get ng_this_address_isn_t_private_and =>
      '此地址不是私有地址，且未使用 https://，因此你的密码和聊天内容会以未加密的形式通过互联网传输。请改用 https://、Tailscale 或你自己的网络。';

  @override
  String get ng_continue_to_sign_in => '继续登录';

  @override
  String get ng_use_the_classic_interface_instead => '改用经典界面';

  @override
  String get ng_if_cloudflare_access_protects_this_address =>
      '如果此地址受 Cloudflare Access 保护，请在 Cloudflare Zero Trust（Access，Service credentials）中创建服务令牌，并为对应的 Access 应用添加 Service Auth 策略。';

  @override
  String get ng_a_service_token_is_saved_for => '已为此地址保存服务令牌';

  @override
  String get ng_forget => '移除';

  @override
  String get ng_client_id => 'Client ID';

  @override
  String get ng_client_secret => 'Client Secret';

  @override
  String get ng_stored_encrypted_on_this_phone_and => '加密存储在此手机上，且只发送到此地址。';

  @override
  String get ng_hermes_is_reachable => '已连接到 Hermes';

  @override
  String ng_hermes_is_reachable_2(Object version) {
    return '已连接到 Hermes $version';
  }

  @override
  String get ng_sign_in_is_tested_next_then => '接下来测试登录，然后测试聊天';

  @override
  String get ng_agent_gateway => 'Agent 网关';

  @override
  String get ng_running => '运行中';

  @override
  String get ng_stopped => '已停止';

  @override
  String get ng_username_password => '用户名和密码';

  @override
  String get ng_browser => '浏览器';

  @override
  String get ng_in_the_browser_sso => '在浏览器中（SSO）';

  @override
  String get ng_profiles => '配置文件';

  @override
  String get ng_this_dashboard_offers_neither_a_username =>
      '此控制面板既未提供用户名和密码登录，也未提供浏览器登录。请更新 Hermes，或在服务器上配置用户名和密码登录。';

  @override
  String get ng_the_auth_gate_is_off_on =>
      '此控制面板未启用身份验证。任何能访问它的人都可以使用你的 Agent。';

  @override
  String get ng_couldn_t_reach_the_dashboard => '无法连接到控制面板';

  @override
  String ng_check_the_address_and_port_9119(Object reason) {
    return '$reason\n\n请检查地址和端口（默认为 9119）。如果控制面板尚未运行，请在服务器上执行：\nhermes dashboard --host 0.0.0.0';
  }

  @override
  String get ng_that_isn_t_a_hermes_dashboard => '这不是 Hermes 控制面板';

  @override
  String get ng_something_answered_but_not_a_hermes_2 =>
      '服务器有响应，但不是 Hermes 控制面板。请使用控制面板的地址，而不是 API 服务器的地址（端口 8642）。';

  @override
  String ng_something_answered_http_but_not_a_2(Object status) {
    return '服务器有响应（HTTP $status），但不是 Hermes 控制面板。请使用控制面板的地址，而不是 API 服务器的地址（端口 8642）。';
  }

  @override
  String get ng_cloudflare_access_stopped_the_request =>
      'Cloudflare Access 已拦截此请求';

  @override
  String ng_cloudflare_access_turned_down_the_service(Object status) {
    return 'Cloudflare Access 拒绝了服务令牌（HTTP $status）。请检查客户端 ID、密钥和 Service Auth 策略。';
  }

  @override
  String get ng_add_a_cloudflare_access_service_token_2 =>
      '请在下方添加 Cloudflare Access 服务令牌，然后重新测试。';

  @override
  String get ng_a_client_certificate_is_needed => '需要客户端证书';

  @override
  String get ng_this_server_asks_for_a_client =>
      '此服务器要求先提供客户端证书。请在下方选择服务器提供的证书，然后重新测试。';

  @override
  String get ng_this_dashboard_doesn_t_ask_for => '此控制面板不需要登录。';

  @override
  String ng_use_the_dashboard_username_and_password(Object address) {
    return '请使用 $address 上配置的控制面板用户名和密码，或在浏览器中登录。';
  }

  @override
  String ng_use_the_dashboard_username_and_password_2(Object address) {
    return '请使用 $address 上配置的控制面板用户名和密码。';
  }

  @override
  String ng_sign_in_to_in_your_browser(Object address) {
    return '请在浏览器中登录 $address，并使用该控制面板所用的账号。';
  }

  @override
  String ng_gateway(Object address) {
    return '网关 $address';
  }

  @override
  String get ng_profile => '配置文件';

  @override
  String get ng_server_default => '服务器默认设置';

  @override
  String get ng_continue => '继续';

  @override
  String get ng_username => '用户名';

  @override
  String get ng_signing_in => '正在登录…';

  @override
  String get ng_waiting_for_the_browser => '正在等待浏览器…';

  @override
  String get ng_sign_in_with_browser => '使用浏览器登录';

  @override
  String get ng_finish_signing_in_on_the_page =>
      '请在打开的页面上完成登录。完成后 Hermes 会自动返回。';

  @override
  String get ng_use_a_different_gateway => '使用其他网关';

  @override
  String get ng_same_wi_fi_or_local_network => '同一 Wi-Fi 或本地网络';

  @override
  String get ng_use_the_server_s_local_address =>
      '使用服务器的本地地址和端口，例如 192.168.1.20:9119。启动控制面板时请添加 --host 0.0.0.0，以便其他设备访问。';

  @override
  String get ng_tailscale => 'Tailscale';

  @override
  String get ng_turn_on_tailscale_on_this_phone =>
      '在这部手机上启用 Tailscale，然后使用服务器的 Tailscale 地址，例如 100.64.0.1:9119 或其 .ts.net 域名。离开家也能使用。';

  @override
  String get ng_use_your_https_address_when_the =>
      '如果控制面板位于带证书的代理后面，请使用你的 https:// 地址。代理还必须支持 /api/ws 上的 WebSocket 升级。';

  @override
  String get ng_start_the_dashboard_on_the_server => '在服务器上启动控制面板：';

  @override
  String get ng_enter_a_port_from_1_to => '请输入 1 到 65535 之间的端口。';

  @override
  String get ng_looks_for_hermes_dashboards_on_port =>
      '在此 Wi-Fi 网络上搜索端口 9119 的 Hermes 控制面板，并检查已保存的电脑。';

  @override
  String ng_looks_for_hermes_dashboards_on_ports(Object port) {
    return '在此 Wi-Fi 网络上搜索端口 9119 和 $port 的 Hermes 控制面板，并检查已保存的电脑。';
  }

  @override
  String get ng_other_port_optional => '其他端口（可选）';

  @override
  String get ng_no_dashboards_answered_start_one_with =>
      '没有控制面板响应。请运行 hermes dashboard --host 0.0.0.0 启动，或输入其地址。';

  @override
  String get ng_using_tailscale_or_a_vpn_those =>
      '正在使用 Tailscale 或 VPN？无法搜索这些网络。请改为输入电脑的 100.x 地址或 .ts.net 域名。';

  @override
  String get ng_search_again => '重新搜索';

  @override
  String get ng_insights => '数据洞察';

  @override
  String get ng_couldn_t_load_insights => '无法加载数据洞察';

  @override
  String get ng_sessions => '会话';

  @override
  String get ng_tokens => '令牌';

  @override
  String get ng_est_cost => '预估费用';

  @override
  String get ng_daily_tokens => '每日令牌用量';

  @override
  String get ng_models => '模型';

  @override
  String get ng_tools => '工具';

  @override
  String get ng_hermes_is_waiting_for_you => 'Hermes 正在等你。';

  @override
  String get ng_hermes_replied => 'Hermes 已回复';

  @override
  String get ng_the_turn_finished => '本轮已完成。';

  @override
  String get ng_off => '关闭';

  @override
  String get ng_minimal => '最低';

  @override
  String get ng_low => '低';

  @override
  String get ng_medium => '中';

  @override
  String get ng_high => '高';

  @override
  String get ng_extra_high => '极高';

  @override
  String get ng_max => '最高';

  @override
  String get ng_ultra => '超强';

  @override
  String get ng_default => '默认';

  @override
  String ng_couldn_t_switch_model(Object error) {
    return '无法切换模型：$error';
  }

  @override
  String get ng_model => '模型';

  @override
  String get ng_thinking_2 => '思考';

  @override
  String get ng_search_models => '搜索模型';

  @override
  String get ng_no_models_match => '没有符合这些筛选条件的模型。';

  @override
  String get privacy_policy => '隐私政策';

  @override
  String get report_ai_output => '举报 AI 输出';

  @override
  String ng_couldn_t_load_models(Object error) {
    return '无法加载模型：$error';
  }

  @override
  String get ng_no_providers_are_set_up_on => '此网关尚未设置任何提供商。';

  @override
  String get ng_starred => '已加星标';

  @override
  String get ng_recent => '最近';

  @override
  String get ng_more => '更多';

  @override
  String get ng_archived_chats => '已归档聊天';

  @override
  String get ng_projects => '项目';

  @override
  String get ng_chats_grouped_by_project_and_workspace => '按项目和工作区分组的聊天';

  @override
  String get ng_agent => '智能体';

  @override
  String get ng_memory => '记忆';

  @override
  String get ng_what_hermes_remembers_about_you => 'Hermes 对你的记忆';

  @override
  String get ng_skills_library => '技能库';

  @override
  String get ng_browse_and_read_installed_skills => '浏览并阅读已安装的技能';

  @override
  String get ng_cron_editor => 'Cron 编辑器';

  @override
  String get ng_edit_schedules_prompts_and_delivery => '编辑计划、提示词和发送方式';

  @override
  String get ng_config_file => '配置文件';

  @override
  String get ng_edit_config_yaml_on_the_gateway => '在网关上编辑 config.yaml';

  @override
  String get ng_models_and_providers => '模型和提供商';

  @override
  String get ng_model_management => '模型管理';

  @override
  String get ng_default_fallback_and_auxiliary_models => '默认、备用和辅助模型';

  @override
  String get ng_provider_sign_in => '提供商登录';

  @override
  String get ng_connect_provider_accounts_with_oauth => '通过 OAuth 连接提供商账号';

  @override
  String get ng_nous_portal => 'Nous Portal';

  @override
  String get ng_subscription_credits_and_usage => '订阅、额度和使用情况';

  @override
  String get ng_interface => '界面';

  @override
  String get ng_switch_to_the_classic_interface => '切换到经典界面';

  @override
  String get ng_turns_nextgen_off_you_can_turn => '关闭 NextGen。你可以在设置中重新开启。';

  @override
  String get ng_restored => '已恢复';

  @override
  String get ng_archived => '已归档';

  @override
  String get ng_couldn_t_load_archived_chats => '无法加载已归档的聊天';

  @override
  String get ng_nothing_archived => '没有已归档的内容';

  @override
  String get ng_restore => '恢复';

  @override
  String get ng_saved_new_chats_use_it => '已保存。新聊天将使用此设置。';

  @override
  String ng_couldn_t_save(Object error) {
    return '无法保存：$error';
  }

  @override
  String get ng_saving => '正在保存…';

  @override
  String ng_today(Object time) {
    return '今天 $time';
  }

  @override
  String get ng_mon => '周一';

  @override
  String get ng_tue => '周二';

  @override
  String get ng_wed => '周三';

  @override
  String get ng_thu => '周四';

  @override
  String get ng_fri => '周五';

  @override
  String get ng_sat => '周六';

  @override
  String get ng_sun => '周日';

  @override
  String get ng_scheduled => '计划任务';

  @override
  String get ng_new_job => '新建任务';

  @override
  String get ng_couldn_t_load_scheduled_jobs => '无法加载计划任务';

  @override
  String get ng_nothing_scheduled => '没有计划任务';

  @override
  String get ng_ask_hermes_to_do_something_on => '让 Hermes 按计划执行任务，或在此处添加任务。';

  @override
  String get ng_active => '运行中';

  @override
  String get ng_paused => '已暂停';

  @override
  String ng_next(Object when) {
    return '下次 $when';
  }

  @override
  String ng_last(Object when) {
    return '上次 $when';
  }

  @override
  String ng_last_2(Object when, Object result) {
    return '上次 $when · $result';
  }

  @override
  String ng_job(Object id) {
    return '任务 $id';
  }

  @override
  String get ng_delete => '删除';

  @override
  String get ng_delete_this_job => '删除此任务？';

  @override
  String get ng_it_stops_running_past_runs_stay => '删除后将停止运行。以往的运行记录仍会保留在聊天中。';

  @override
  String ng_next_run(Object when) {
    return '下次运行：$when';
  }

  @override
  String ng_delivers_to(Object target) {
    return '发送至 $target';
  }

  @override
  String get ng_run_now => '立即运行';

  @override
  String get ng_started => '已启动';

  @override
  String get ng_pause => '暂停';

  @override
  String get ng_resume => '继续';

  @override
  String get ng_resumed => '已继续';

  @override
  String get ng_prompt => '提示词';

  @override
  String get ng_runs => '运行记录';

  @override
  String get ng_no_runs_yet => '暂无运行记录。';

  @override
  String get ng_enter_a_schedule_and_a_prompt => '请填写计划和提示词。';

  @override
  String get ng_name_optional => '名称（可选）';

  @override
  String get ng_schedule => '计划';

  @override
  String get ng_every_1h_0_9_or_30m => 'every 1h, 0 9 * * *, or 30m';

  @override
  String get ng_create => '创建';

  @override
  String get ng_unpin => '取消置顶';

  @override
  String get ng_pin => '置顶';

  @override
  String get ng_rename => '重命名';

  @override
  String get ng_archive => '归档';

  @override
  String get ng_delete_this_chat => '删除此聊天？';

  @override
  String get ng_it_is_removed_from_the_gateway => '此聊天会从网关中删除，并从所有设备上移除。';

  @override
  String get ng_search_chats => '搜索聊天';

  @override
  String get ng_pinned => '已置顶';

  @override
  String get ng_no_chats_match => '没有匹配的聊天。';

  @override
  String get ng_no_chats_yet => '暂无聊天。';

  @override
  String get ng_nothing_is_running => '暂无运行中的任务。';

  @override
  String get ng_nothing_is_waiting_on_you => '暂无待你处理的事项。';

  @override
  String get ng_settings => '设置';

  @override
  String get ng_all => '全部';

  @override
  String ng_needs_you(Object count) {
    return '需要你处理 · $count';
  }

  @override
  String get ng_needs_you_2 => '需要你处理';

  @override
  String get ng_gateways => '网关';

  @override
  String ng_classic_connection(Object address) {
    return '$address · 经典连接';
  }

  @override
  String get ng_gateway_2 => '网关';

  @override
  String get ng_signed_in => '已登录';

  @override
  String get ng_classic_connection_2 => '经典连接';

  @override
  String get ng_in_the_browser => '在浏览器中';

  @override
  String ng_in_the_browser_as(Object name) {
    return '以 $name 身份在浏览器中';
  }

  @override
  String get ng_not_required => '无需操作';

  @override
  String get ng_test_connection => '测试连接';

  @override
  String get ng_sign_in_again_2 => '重新登录';

  @override
  String get ng_sign_out => '退出登录';

  @override
  String get ng_saved_gateways => '已保存的网关';

  @override
  String get ng_in_use => '使用中';

  @override
  String get ng_appearance => '外观';

  @override
  String get ng_theme => '主题';

  @override
  String get ng_system => '跟随系统';

  @override
  String get ng_light => '浅色';

  @override
  String get ng_dark => '深色';

  @override
  String get ng_accent => '强调色';

  @override
  String get ng_pure_black => '纯黑';

  @override
  String get ng_dark_theme_uses_true_black_oled => '深色主题使用纯黑（OLED）';

  @override
  String get ng_glow => '光晕';

  @override
  String get ng_soft_accent_light_behind_each_screen => '每个页面背后的柔和强调色光效';

  @override
  String get ng_the_new_interface_turn_off_to => '新版界面。关闭后可切回经典界面；网关和聊天记录会共用。';

  @override
  String get ng_more_settings => '更多设置';

  @override
  String get ng_voice_notifications_language_backups_and_the =>
      '语音、通知、语言、备份和网关配置';

  @override
  String get ng_licences => '许可证';

  @override
  String ng_sign_out_of(Object name) {
    return '要退出 $name 吗？';
  }

  @override
  String get ng_this_gateway_and_its_saved_sign =>
      '此网关及其已保存的登录信息会从这部手机的两个界面中移除。聊天记录仍保留在网关上。';

  @override
  String get ng_password_or_browser => '密码或浏览器';

  @override
  String get ng_unsupported => '不支持';

  @override
  String get ng_background_task_finished => '后台任务已完成';

  @override
  String get ng_background_process_finished => '后台进程已结束';

  @override
  String get ng_system_message => '系统消息';

  @override
  String get ng_summary => '摘要';

  @override
  String get classic_interface_only => '仅限经典界面';

  @override
  String get classic_only_settings_hint =>
      '标记为“仅限经典界面”的部分只会更改经典版的外观和聊天，不会影响 NextGen。NextGen 在其设置中有自己的外观选项。';

  @override
  String get attachment_preview_too_large =>
      '文件过大，无法在此预览。保存或分享即可将其下载到手机（最高 1 GB）。';

  @override
  String get attachment_over_phone_limit => '此文件超过 1 GB，超出下载限制。请打开控制面板下载。';

  @override
  String attachment_downloading_percent(int percent) {
    return '正在下载…$percent%';
  }

  @override
  String attachment_downloading_mb(int megabytes) {
    return '正在下载…$megabytes MB';
  }

  @override
  String ng_attachment_too_large_for_gateway(String name) {
    return '$name 超过 12 MB，超出此网关的文件大小限制。更新 Hermes 即可发送最大 100 MB 的文件。';
  }

  @override
  String ng_couldn_t_upload(String name) {
    return '无法上传 $name。';
  }

  @override
  String ng_uploading_percent(int percent) {
    return '正在上传…$percent%';
  }

  @override
  String get ng_show_tasks => '显示任务';

  @override
  String get ng_hide_tasks => '隐藏任务';

  @override
  String get ng_goal => '目标';

  @override
  String get ng_loop => '循环';

  @override
  String get ng_heartbeat => '定时触发';

  @override
  String get ng_goal_working => '进行中';

  @override
  String get ng_goal_waiting => '等待中';

  @override
  String get ng_goal_blocked => '已阻塞';

  @override
  String get ng_goal_done => '已完成';

  @override
  String ng_goal_turns_of(int used, int max) {
    return '已用 $used/$max 回合';
  }

  @override
  String ng_goal_turn(int used) {
    return '第 $used 回合';
  }

  @override
  String get ng_loop_held => '因目标暂缓';

  @override
  String get ng_loop_finished => '已结束';

  @override
  String get ng_loop_running => '运行中';

  @override
  String ng_loop_runs_of(int fired, int times) {
    return '已运行 $fired/$times 次';
  }

  @override
  String ng_loop_runs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '运行 $count 次',
      one: '运行 1 次',
    );
    return '$_temp0';
  }

  @override
  String ng_loop_next(String time) {
    return '下次 $time';
  }

  @override
  String get ng_loop_due_now => '现在触发';

  @override
  String ng_every_seconds(int seconds) {
    return '每 $seconds 秒';
  }

  @override
  String ng_every_minutes(int minutes) {
    return '每 $minutes 分钟';
  }

  @override
  String ng_every_hours(int hours) {
    return '每 $hours 小时';
  }

  @override
  String ng_every_hours_minutes(int hours, int minutes) {
    return '每 $hours 小时 $minutes 分钟';
  }

  @override
  String ng_heartbeat_fired(int count) {
    return '已触发 $count 次';
  }

  @override
  String ng_heartbeat_last_fired(String time) {
    return '上次触发时间：$time';
  }

  @override
  String ng_wait_until(String time) {
    return '等待至 $time';
  }

  @override
  String get ng_wait_resume => '等待恢复';

  @override
  String get ng_wait_other_chat => '等待另一个聊天';

  @override
  String ng_wait_process(String pid) {
    return '等待进程 $pid';
  }

  @override
  String get ng_control_open => '打开目标和自动化';

  @override
  String get ng_control_title => '目标和自动化';

  @override
  String get ng_control_subtitle => '此聊天正在努力实现的目标，以及自动运行的内容。';

  @override
  String get ng_contract_outcome => '预期结果';

  @override
  String get ng_contract_verification => '验证方式';

  @override
  String get ng_contract_constraints => '限制条件';

  @override
  String get ng_contract_boundaries => '边界';

  @override
  String get ng_contract_stop_when => '停止条件';

  @override
  String get ng_subgoals => '子目标';

  @override
  String get ng_subgoal_add_placeholder => '添加子目标';

  @override
  String get ng_add => '添加';

  @override
  String get ng_subgoal_remove => '移除子目标';

  @override
  String get ng_goal_checks => '检查项';

  @override
  String get ng_gate_not_run => '尚未运行';

  @override
  String ng_gate_attempts(int attempts, int tries) {
    return '已尝试 $attempts/$tries 次';
  }

  @override
  String ng_gate_exit(int code) {
    return '退出码 $code';
  }

  @override
  String get ng_resume_now => '立即恢复';

  @override
  String get ng_goal_clear => '清除目标';

  @override
  String get ng_goal_clear_title => '清除此目标？';

  @override
  String get ng_goal_clear_message => '智能体将停止朝此目标努力。其子目标和检查项也会一并删除。';

  @override
  String get ng_subgoal_remove_title => '移除此子目标？';

  @override
  String ng_subgoal_remove_message(String text) {
    return '“$text”将不再属于此目标。';
  }

  @override
  String get ng_subgoals_clear_title => '清除所有子目标？';

  @override
  String get ng_subgoals_clear_message => '目标标题会保留，但所有子目标都会被删除。';

  @override
  String get ng_clear_all => '全部清除';

  @override
  String get ng_clear => '清除';

  @override
  String get ng_dismiss => '关闭';

  @override
  String get ng_loop_stop_title => '停止此循环？';

  @override
  String get ng_heartbeat_clear_title => '清除此定时触发？';

  @override
  String get ng_wont_fire_again => '之后不会再触发。';

  @override
  String get ng_loop_self_paced => '按自身节奏运行';

  @override
  String ng_loop_until(String condition) {
    return '持续至：$condition';
  }

  @override
  String get ng_loop_waits_for_goal => '目标进行期间会暂停。';

  @override
  String get ng_loop_awaiting_reply => '等待智能体回复。';

  @override
  String ng_loop_stopped_reason(String reason) {
    return '已停止：$reason';
  }

  @override
  String get ng_hide_subagents => '隱藏子代理';

  @override
  String get ng_show_subagents => '顯示子代理';

  @override
  String get ng_subagent => '子代理';

  @override
  String get ng_subagent_queued => '已排入佇列';

  @override
  String get ng_subagent_starting => '啟動中…';

  @override
  String get ng_subagent_running => '執行中';

  @override
  String get ng_subagent_done => '已完成';

  @override
  String get ng_subagent_failed => '失敗';

  @override
  String get ng_subagent_stopped => '已停止';

  @override
  String get ng_subagent_stop => '停止子代理';

  @override
  String ng_subagent_tools(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個工具',
    );
    return '$_temp0';
  }

  @override
  String get ng_mark_as_read => '標記為已讀';

  @override
  String get ng_mark_as_unread => '標記為未讀';

  @override
  String ng_chats_unread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '聊天，$count 則未讀',
      one: '聊天，1 則未讀',
    );
    return '$_temp0';
  }

  @override
  String get ng_unread_finished => '已完成，有未讀回覆';

  @override
  String get ng_unread_updates => '執行中，有未讀更新';

  @override
  String get ng_notifications => '通知';

  @override
  String get ng_notifications_hint => 'Ares 在背景執行時收到回覆和請求通知';

  @override
  String get ng_notify_replies => '回覆';

  @override
  String get ng_notify_replies_hint => '目前開啟的聊天中的回合完成或失敗時通知';

  @override
  String get ng_notify_requests => '核准與提問';

  @override
  String get ng_notify_requests_hint => '代理程式等待您回應時提醒您，並提供「允許一次」和「拒絕」選項';

  @override
  String get ng_keep_running => '回覆執行期間保持連線';

  @override
  String get ng_keep_running_hint => '在背景保持連線，直到回覆完成，並顯示一則靜音通知';

  @override
  String get ng_battery_settings => '電池最佳化';

  @override
  String get ng_battery_settings_hint => '允許 Ares 在背景執行，讓通知準時送達';

  @override
  String get ng_send_test_notification => '傳送測試通知';

  @override
  String get ng_test_notification_title => 'Ares 通知運作正常';

  @override
  String get ng_test_notification_body => '回覆和請求通知會以這種方式顯示。';

  @override
  String get ng_test_notification_sent => '已傳送測試通知';

  @override
  String get ng_notifications_blocked => '通知已封鎖。請在 Android 設定中允許通知。';

  @override
  String get ng_notifications_off_hint => '通知已關閉，因此 Ares 在背景執行時不會顯示通知。';

  @override
  String get ng_insights_building => '正在建立報告。首次建立較長期間的報告可能需要最多一分鐘。';

  @override
  String get ng_insights_timed_out => '閘道建立此報告逾時。請再試一次，或選擇較短的期間。';

  @override
  String get ng_dock_goal_active => '目標進行中';

  @override
  String get ng_dock_goal_paused => '目標已暫停';

  @override
  String get ng_dock_goal_waiting => '目標等待中';

  @override
  String get ng_dock_goal_blocked => '目標受阻';

  @override
  String get ng_dock_goal_done => '目標已完成';

  @override
  String ng_dock_turn_of(int used, int max) {
    return '第 $used/$max 回合';
  }

  @override
  String ng_dock_turn(int used) {
    return '第 $used 回合';
  }

  @override
  String ng_dock_subagents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個子代理',
      one: '1 個子代理',
    );
    return '$_temp0';
  }

  @override
  String ng_dock_subagents_done(int count) {
    return '已完成 $count 個';
  }

  @override
  String ng_dock_tasks(int done, int total) {
    return '任務 $done/$total';
  }

  @override
  String ng_dock_previous_tasks(int done, int total) {
    return '上一輪任務 $done/$total';
  }

  @override
  String get ng_dock_manage => '管理';

  @override
  String get ng_recent_notifications => '最近通知';

  @override
  String get ng_recent_notifications_hint => 'Ares 嘗試發布的內容，以及 Android 是否顯示了通知';

  @override
  String get ng_recent_notifications_empty =>
      '目前還沒有。當回覆、問題或失敗事件會觸發通知時，相關嘗試就會顯示在這裡。';

  @override
  String get ng_notify_permission_granted => '已授予權限';

  @override
  String get ng_notify_permission_denied => '權限遭拒';

  @override
  String get ng_notify_master_on => '通知已開啟';

  @override
  String get ng_notify_master_off => '通知已關閉';

  @override
  String get ng_models_default => '默认模型';

  @override
  String get ng_models_change => '更改';

  @override
  String get ng_models_custom_endpoint => '使用自定义端点。请在网关上更改。';

  @override
  String get ng_models_context_window => '上下文窗口';

  @override
  String ng_models_token_count(String count) {
    return '$count Token';
  }

  @override
  String ng_models_context_override(String count) {
    return '已在网关上设置。自动检测：$count Token。';
  }

  @override
  String get ng_models_max_output => '最大输出';

  @override
  String get ng_models_input_price => '输入价格';

  @override
  String get ng_models_output_price => '输出价格';

  @override
  String get ng_models_cache_price => '缓存输入价格';

  @override
  String ng_models_per_million(String price) {
    return '每百万 Token $price';
  }

  @override
  String ng_models_price_pair(String input, String output) {
    return '每百万 Token：输入 $input · 输出 $output';
  }

  @override
  String get ng_models_free => '免费';

  @override
  String get ng_models_vision => '视觉';

  @override
  String get ng_models_reasoning => '推理';

  @override
  String get ng_models_fast => '快速模式';

  @override
  String get ng_models_in_use => '使用中';

  @override
  String ng_models_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个模型',
    );
    return '$_temp0';
  }

  @override
  String get ng_models_rate_limited => '已限流';

  @override
  String get ng_models_plan_locked => '当前套餐不可用';

  @override
  String get ng_models_unsaved => '未保存的更改';

  @override
  String get ng_models_discard => '放弃';

  @override
  String get ng_models_aux_hint => '辅助任务使用默认模型，除非你为其单独指定。';

  @override
  String get ng_models_uses_default => '使用默认模型';

  @override
  String get ng_models_thinking_level => '思考级别';

  @override
  String get ng_models_providers => '提供方';

  @override
  String get ng_models_saved => '已保存';

  @override
  String get ng_aux_vision => '视觉';

  @override
  String get ng_aux_vision_hint => '读取图片和截图';

  @override
  String get ng_aux_compression => '压缩';

  @override
  String get ng_aux_compression_hint => '压缩较长的聊天，使其适应上下文窗口';

  @override
  String get ng_aux_approval => '审批';

  @override
  String get ng_aux_approval_hint => '判断命令是否可以不经询问安全执行';

  @override
  String get ng_aux_mcp => 'MCP';

  @override
  String get ng_aux_mcp_hint => '选择要使用的 MCP 工具';

  @override
  String get ng_aux_title_generation => '聊天标题';

  @override
  String get ng_aux_title_generation_hint => '为新聊天命名';

  @override
  String get ng_aux_review => '评审';

  @override
  String get ng_aux_review_hint => '运行 /review 时检查工作成果';

  @override
  String get ng_aux_voice_chat => '语音聊天';

  @override
  String get ng_aux_voice_chat_hint => '在语音模式下回复';

  @override
  String get ng_aux_triage_specifier => '任务分类';

  @override
  String get ng_aux_triage_specifier_hint => '将一行的看板卡片扩展为规格说明';

  @override
  String get ng_aux_kanban_decomposer => '看板拆解';

  @override
  String get ng_aux_kanban_decomposer_hint => '将看板卡片拆分为更小的任务';

  @override
  String get ng_aux_profile_describer => '配置档案描述';

  @override
  String get ng_aux_profile_describer_hint => '为每个配置档案撰写简短描述';

  @override
  String get ng_aux_curator => '维护器';

  @override
  String get ng_aux_curator_hint => '审查技能的使用情况';

  @override
  String get appearance_save_failed => 'Could not save this change.';

  @override
  String get appearance_keep_which_theme => 'Keep which theme?';

  @override
  String get appearance_tour_back => 'Back';

  @override
  String get appearance_tour_finish => 'Finish';

  @override
  String get appearance_tour_next => 'Next';

  @override
  String get appearance_tour_close => 'Close tour';

  @override
  String get appearance_dismiss_tip => 'Dismiss tip';

  @override
  String get appearance_search_settings => 'Search settings';

  @override
  String get appearance_search_show => 'Show';

  @override
  String get appearance_no_matching_setting => 'No matching setting.';

  @override
  String get appearance_replay_tour => 'Replay tour';

  @override
  String get appearance_show_tips_again => 'Show tips again';

  @override
  String get appearance_window_translucency_unavailable =>
      'Window translucency is not available on this host. Linux cannot provide it, and the Apple and Windows runners paint an opaque Flutter view.';

  @override
  String get appearance_imported_themes => 'Imported themes';

  @override
  String get appearance_import_theme_file => 'Import theme file';

  @override
  String get appearance_remove_theme => 'Remove theme';

  @override
  String get appearance_chat_font => 'Chat font';

  @override
  String get appearance_terminal_font => 'Terminal font';

  @override
  String get appearance_font_platform => 'Platform';

  @override
  String get appearance_automatic => 'Automatic';

  @override
  String get appearance_force_left_to_right => 'Force left to right';

  @override
  String get appearance_force_right_to_left => 'Force right to left';

  @override
  String get appearance_user_bubble_opacity => 'User bubble opacity';

  @override
  String get appearance_inline_embeds => '内嵌内容';

  @override
  String get appearance_inline_embeds_hint =>
      '丰富预览会从第三方网站加载（YouTube、X 等）。“询问”会先显示占位符，直到你逐一允许；“始终”会自动加载；“关闭”只保留普通链接。';

  @override
  String get appearance_embeds_ask => '询问';

  @override
  String get appearance_embeds_always => '始终';

  @override
  String get appearance_embeds_off => '关闭';

  @override
  String appearance_embeds_reset(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '重置 $count 个已允许的服务',
      one: '重置 1 个已允许的服务',
    );
    return '$_temp0';
  }

  @override
  String get appearance_embed_load => '加载';

  @override
  String appearance_embed_always_allow(String service) {
    return '始终允许 $service';
  }

  @override
  String get appearance_embed_loading => '正在加载预览…';

  @override
  String appearance_embed_image_failed(String host) {
    return '无法从 $host 加载图片。轻触即可打开。';
  }

  @override
  String get appearance_embed_preview_unavailable => '无法预览';

  @override
  String get appearance_emoji_reactions => 'Emoji reactions';

  @override
  String get appearance_celebration_hearts => 'Celebration hearts';

  @override
  String get appearance_celebration_hearts_hint =>
      'A heart plays when a reply arrives while you were away.';

  @override
  String get appearance_pop_out_companion => 'Pop out companion';

  @override
  String get appearance_mosskip => 'Mosskip';

  @override
  String get appearance_emberbun => 'Emberbun';

  @override
  String get appearance_tideling => 'Tideling';

  @override
  String get appearance_my_hatchling => 'My hatchling';

  @override
  String get appearance_at_rest => 'At rest';

  @override
  String get appearance_working => 'Working';

  @override
  String get appearance_thinking => 'Thinking';

  @override
  String get appearance_waiting_for_you => 'Waiting for you';

  @override
  String get appearance_reply_ready => 'Reply ready';

  @override
  String get appearance_turn_failed => 'Turn failed';

  @override
  String get appearance_small => 'Small';

  @override
  String get appearance_medium => 'Medium';

  @override
  String get appearance_large => 'Large';

  @override
  String get appearance_hello => 'Hello!';

  @override
  String get appearance_unread_reply => 'Unread reply';

  @override
  String get appearance_compose => 'Compose';

  @override
  String get appearance_say_hello => 'Say hello';

  @override
  String get appearance_pet_image_failed =>
      'Could not open that image. Choose a smaller PNG or JPEG.';

  @override
  String get appearance_pet_companion => 'Pet companion';

  @override
  String get appearance_pet_companion_hint =>
      'Show a companion while you chat.';

  @override
  String get appearance_adopt_a_companion => 'Adopt a companion';

  @override
  String get appearance_roam_when_idle => 'Roam when idle';

  @override
  String get appearance_pet_size => 'Pet size';

  @override
  String get appearance_hatch_from_a_local_picture =>
      'Hatch from a local picture';

  @override
  String get appearance_pet_image_limits =>
      'Choose a PNG or JPEG (up to 4 MiB, 4096 px per side and 8 MP). Preview it first. Hatching saves one 24 × 24 pixel portrait and replaces your previous hatchling.';

  @override
  String get appearance_choose_picture => 'Choose picture';

  @override
  String get appearance_hatchling_preview => 'Hatchling preview';

  @override
  String get appearance_hatch_and_adopt => 'Hatch and adopt';

  @override
  String get appearance_discard_draft => 'Discard draft';

  @override
  String get appearance_forget_saved_hatchling => 'Forget saved hatchling';

  @override
  String get appearance_radio => 'Radio';

  @override
  String appearance_radio_hint(String stations) {
    return 'Streams come straight from $stations and start only when you press Play. Station search stays on this device.';
  }

  @override
  String get appearance_radio_save_failed =>
      'Radio settings could not be saved.';

  @override
  String get appearance_choose_a_station => 'Choose a station';

  @override
  String get appearance_pause_radio => 'Pause radio';

  @override
  String get appearance_play_radio => 'Play radio';

  @override
  String get appearance_next_station => 'Next station';

  @override
  String get appearance_radio_trace_semantics =>
      'Stream activity. Audio levels are unavailable, so this line stays flat.';

  @override
  String get appearance_radio_is_off => 'Radio is off';

  @override
  String get appearance_paused => 'Paused';

  @override
  String get appearance_connecting => 'Connecting…';

  @override
  String get appearance_live => 'Live';

  @override
  String get appearance_stream_unavailable => 'Stream unavailable';

  @override
  String appearance_now_playing(String credit) {
    return 'Now playing: $credit';
  }

  @override
  String get appearance_audio_only_waveform_unavailable =>
      'Audio only · waveform unavailable';

  @override
  String get appearance_volume => 'Volume';

  @override
  String get appearance_search_presets => 'Search presets';

  @override
  String get appearance_no_stations_found => 'No stations found';

  @override
  String appearance_unpin_station(String station) {
    return 'Unpin station: $station';
  }

  @override
  String appearance_pin_station(String station) {
    return 'Pin station: $station';
  }

  @override
  String get appearance_radio_picker_metadata_notice =>
      'While this picker is open, playing stations may share track details directly from the broadcaster.';

  @override
  String get appearance_message_from_your_companion =>
      'Message from your companion';

  @override
  String get appearance_send_to_the_open_chat => 'Send to the open chat';

  @override
  String get appearance_tour_theme_body =>
      'Import a VS Code colour theme from a file on this device, then choose which variant to keep.';

  @override
  String get appearance_tour_fonts_title => 'Reading fonts';

  @override
  String get appearance_tour_fonts_body =>
      'Chat prose and terminal code use separate faces shipped with Ares.';

  @override
  String get appearance_tour_direction_title => 'Transcript direction';

  @override
  String get appearance_tour_direction_body =>
      'Leave this on automatic, or force the transcript left to right or right to left.';

  @override
  String get appearance_tour_pet_title => 'Companion';

  @override
  String get appearance_tour_pet_body =>
      'The companion is off until you adopt one. Pop-out adds a small composer.';

  @override
  String get appearance_tour_radio_body =>
      'Radio stays off until you enable it. Play is what opens a stream.';

  @override
  String get appearance_tip_theme =>
      'Imported themes replace the built-in palette until you clear the selection. Only the colours are kept.';

  @override
  String get appearance_tip_pet =>
      'The companion stores one small portrait on this device. It does not upload the picture you hatch from.';

  @override
  String get appearance_theme_import_failed =>
      'Could not import that theme. Choose a VS Code colour theme saved as a .vsix, .json or .jsonc file.';

  @override
  String get render_widget_file_truncated => '只读取了此文件的开头部分，因此小组件可能不完整。';

  @override
  String get setup_beat_title => '设置';

  @override
  String setup_beat_use_name(String name) {
    return '使用 $name';
  }

  @override
  String get setup_beat_name_hint => 'Hermes 应该怎么称呼你？';

  @override
  String get setup_beat_on_computer => '此步骤在运行 Hermes 的电脑上完成。选择“继续”将保留那里已有的设置。';

  @override
  String get setup_beat_not_waiting => '此设置卡片已不再等待回答。';

  @override
  String get catalog_kind_plugin => '插件';

  @override
  String get catalog_kind_skill => '技能';

  @override
  String get catalog_tier_official => '官方';

  @override
  String get catalog_tier_verified => '已验证';

  @override
  String get catalog_tier_community => '社区';

  @override
  String get catalog_install => '安装';

  @override
  String get catalog_waiting => '等待你的选择';

  @override
  String get catalog_installed => '已安装';

  @override
  String get catalog_installed_off => '已安装，未启用';

  @override
  String get catalog_skipped => '已跳过';

  @override
  String get catalog_not_installed => '未安装';

  @override
  String catalog_target_profile(String profile) {
    return '安装到 $profile 配置文件';
  }

  @override
  String catalog_source(String repo, String sha) {
    return '$repo（$sha）';
  }

  @override
  String catalog_scan(String status, String summary) {
    return '安全扫描：$status。$summary';
  }

  @override
  String catalog_requires_hermes(String range) {
    return '需要 Hermes $range';
  }

  @override
  String catalog_skill_ready(String name) {
    return '技能 $name 已可使用';
  }

  @override
  String catalog_missing_env(String names) {
    return '仍需要：$names';
  }

  @override
  String catalog_server_error(String name, String error) {
    return '$name 未能连接：$error';
  }

  @override
  String get catalog_send_failed => '你的选择未发送，请重试。';

  @override
  String get attachment_video_speed => '播放速度';

  @override
  String get catalog_installing => '正在安装…';

  @override
  String get catalog_phase_downloading => '正在下载…';

  @override
  String get catalog_phase_python_packages => '正在安装 Python 包…';

  @override
  String get catalog_phase_loading_tools => '正在加载工具…';

  @override
  String get setup_beat_send_failed => '你的回答未发送，请重试。';

  @override
  String catalog_tool_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个工具',
    );
    return '$_temp0';
  }

  @override
  String get render_svg_not_drawn => '此 SVG 未绘制。';

  @override
  String get render_notes_directive => '笔记指令';

  @override
  String get render_maths_source => '数学公式源码';

  @override
  String get render_inline_maths_source => '行内数学公式源码';

  @override
  String get render_sequence_outline => '时序图大纲';

  @override
  String get render_diagram_outline => '图表大纲';

  @override
  String render_revision_of(int index, int count) {
    return '修订版 $index/$count';
  }

  @override
  String get render_previous_revision => '上一修订版';

  @override
  String get render_next_revision => '下一修订版';

  @override
  String get render_show_rendered => '渲染视图';

  @override
  String get render_show_source => '源码';

  @override
  String render_copied_file(String name) {
    return '已复制 $name';
  }

  @override
  String render_copy_file(String name) {
    return '复制 $name';
  }

  @override
  String get render_artifact_too_long => '此产物太长，无法在此处以页面显示。';

  @override
  String get render_active_content_removed => '已移除脚本、框架和外部地址。';

  @override
  String render_widget_file(String file) {
    return '小组件 $file';
  }

  @override
  String get render_widget_runs_as_text => '在此聊天中以文本形式运行。脚本和外部框架会被移除。';

  @override
  String get render_load_widget => '加载小组件';

  @override
  String get render_not_html_widget => '此文件不是 HTML 小组件。';

  @override
  String get render_widget_sent => '已发送到此聊天';

  @override
  String get render_widget_not_sent => '未发送到此聊天';

  @override
  String get render_widget_throttled => '请稍候再发送';

  @override
  String get render_widget_too_long => '此请求太长，无法发送';

  @override
  String get render_widget_no_gesture => '点按小组件中的控件以发送';

  @override
  String get render_widget_invalid => '无法发送此请求';

  @override
  String get render_inspected_image => '已检查的图片';

  @override
  String get render_contributions => '扩展项';

  @override
  String get render_contributions_intro =>
      '只有内置在 Ares 中的扩展项才能为回复添加内容。聊天文本无法注册扩展项，授权仅适用于此连接。';

  @override
  String render_grant_plugin(String name) {
    return '授权 $name';
  }

  @override
  String render_revoke_plugin(String name) {
    return '撤销 $name';
  }

  @override
  String render_plugin_slots(String directive) {
    return '::$directive 的回复卡片';
  }

  @override
  String get render_plugin_notes => '笔记';

  @override
  String get catalog_scan_passed => '已通过';

  @override
  String get catalog_scan_warnings => '发现警告';

  @override
  String get catalog_scan_failed => '未通过';

  @override
  String get deployment_token_label => '部署令牌（可选）';

  @override
  String get deployment_token_helper =>
      '用于以 X-Hermes-Session-Token 发送的 Hermes Dashboard 会话令牌。不会以明文保存在偏好设置中。';

  @override
  String get deployment_token_hint => '仪表板会话令牌';

  @override
  String get custom_headers_label => '自定义标头（可选）';

  @override
  String get custom_headers_helper => '每行一个，例如 X-Custom: 值。禁止的标头会被拒绝。';

  @override
  String get custom_headers_hint => '例如 X-Custom-Header: 值';

  @override
  String get desktop_tray_open => '打开 Ares';

  @override
  String get desktop_tray_new_chat => '新聊天';

  @override
  String get desktop_tray_quick_entry => '快速输入…';

  @override
  String get desktop_tray_pause_notifications => '暂停通知';

  @override
  String get desktop_tray_quit => '退出 Ares';

  @override
  String get desktop_integration_title => '桌面集成';

  @override
  String get desktop_tray_setting => '在系统托盘或菜单栏中显示 Ares';

  @override
  String get desktop_tray_setting_help => '可通过图标打开 Ares、开始聊天、打开快速输入、暂停通知或退出。';

  @override
  String get desktop_close_to_tray_setting => '关闭窗口后继续在托盘中运行';

  @override
  String get desktop_tray_unsupported => '此桌面没有可供 Ares 使用的系统托盘。';

  @override
  String get quick_entry_title => '快速输入';

  @override
  String get quick_entry_hint => '输入给 Ares 的提示…';

  @override
  String get quick_entry_submit => '放入输入框';

  @override
  String get quick_entry_never_sends => '按 Enter 会将文本放入聊天输入框。在你按下发送之前不会发送任何内容。';

  @override
  String get quick_entry_unavailable => '无法打开快速输入。请重试。';

  @override
  String get desktop_hotkey_setting => '快速输入快捷键';

  @override
  String desktop_hotkey_help(String shortcut) {
    return '在任意位置按 $shortcut 即可打开快速输入。';
  }

  @override
  String desktop_hotkey_conflict(String shortcut) {
    return '其他应用已在使用 $shortcut。请选择其他快捷键。';
  }

  @override
  String get desktop_hotkey_unsupported => '此桌面不允许应用注册全局快捷键（例如 Wayland）。';

  @override
  String get desktop_hotkey_no_modifier => '请包含 Cmd、Ctrl 或 Alt。';

  @override
  String get desktop_hotkey_super_key => 'Windows 键或 Super 键为系统保留。';

  @override
  String get desktop_hotkey_reserved => '系统已在使用此快捷键。';

  @override
  String desktop_hotkey_in_app(String action) {
    return 'Ares 已将此快捷键用于$action。';
  }

  @override
  String get desktop_hotkey_change => '更改';

  @override
  String get desktop_hotkey_reset => '使用默认值';

  @override
  String get capture_screen_action => '截取屏幕';

  @override
  String get capture_screen_help => '将截图作为草稿添加到消息中。在你按下发送之前不会发送任何内容。';

  @override
  String get capture_screen_unavailable => '此桌面无法使用屏幕截取。';

  @override
  String get capture_screen_failed => '无法截取屏幕。请重试。';

  @override
  String get capture_permission_title => '允许录屏';

  @override
  String get capture_permission_body =>
      '要截取窗口，Ares 需要录屏权限。请在“系统设置” > “隐私与安全性” > “录屏”中打开 Ares，然后重试。';

  @override
  String get capture_open_settings => '打开系统设置';

  @override
  String get keep_awake_title => '保持电脑唤醒';

  @override
  String get keep_awake_title_mobile => '保持屏幕常亮';

  @override
  String get keep_awake_mode_off => '关闭';

  @override
  String get keep_awake_mode_while_working => '工作时';

  @override
  String get keep_awake_mode_always => '始终';

  @override
  String get keep_awake_off_help => '从不阻止系统睡眠（默认）。';

  @override
  String get keep_awake_while_working_help => '仅在代理回合运行时阻止空闲睡眠。';

  @override
  String get keep_awake_always_help => '在此设备上打开 Ares 期间阻止空闲睡眠。';

  @override
  String get keep_awake_off_help_mobile => '让屏幕照常关闭（默认）。';

  @override
  String get keep_awake_while_working_help_mobile =>
      '在代理回合运行且 Ares 打开期间保持屏幕常亮。';

  @override
  String get keep_awake_always_help_mobile => '在 Ares 打开期间保持屏幕常亮。';

  @override
  String get ng_token_gateway_has_no_sign_in =>
      '此网关没有登录功能，因此无法验证部署令牌。请在主机上启用仪表板身份验证（或更新 Hermes），然后重试。';

  @override
  String get palette_open => '应用命令面板';

  @override
  String get palette_no_matches => '没有匹配的操作';

  @override
  String get palette_filter_hint => '输入以筛选操作…';

  @override
  String get palette_keys_move => '↑↓ 移动';

  @override
  String get palette_keys_run => 'Enter 运行';

  @override
  String get palette_keys_close => 'Esc 关闭';

  @override
  String get palette_search_sessions => '搜索会话';

  @override
  String get palette_scheduled_crons => '计划任务 / Cron';

  @override
  String get palette_capabilities_skills => '能力与技能';

  @override
  String get palette_insights_usage => '洞察与用量';

  @override
  String get palette_more_projects => '更多与项目';

  @override
  String get deeplink_chat_not_found => '列表中找不到该聊天，可能尚未加载。';

  @override
  String get keyboard_shortcuts_title => '键盘快捷键';

  @override
  String get shortcuts_reset_all => '全部重置';

  @override
  String get shortcuts_reset_to_default => '恢复默认';

  @override
  String get shortcut_action_command_palette => '命令面板';

  @override
  String get shortcut_action_new_chat => '新建聊天';

  @override
  String get shortcut_action_search => '搜索';

  @override
  String get shortcut_action_settings => '设置';

  @override
  String shortcut_action_go_to_tab(int number) {
    return '转到标签页 $number';
  }

  @override
  String shortcuts_conflict(String first, String second, String chord) {
    return '冲突：“$first”和“$second”都使用 $chord。在你更改其中一个之前，自定义快捷键保持默认值。';
  }

  @override
  String shortcuts_editor_title(String action) {
    return '快捷键：$action';
  }

  @override
  String get shortcuts_editor_help => '按下组合键，或在下方选择修饰键和按键：';

  @override
  String get shortcuts_editor_needs_modifier =>
      '请至少选择 Cmd/Meta、Ctrl 或 Alt，以免影响在输入框中打字。';

  @override
  String shortcuts_text_editing_warning(String chord) {
    return '$chord 是文本编辑快捷键（复制、粘贴、剪切、撤销、重做或全选）。在此绑定后，文本框将无法使用它。';
  }

  @override
  String shortcuts_text_editing_in_use(String action, String chord) {
    return '“$action”使用了文本编辑快捷键 $chord。在此绑定期间，文本框无法使用它。';
  }

  @override
  String custom_headers_problem_format(int line) {
    return '第 $line 行：应为“名称: 值”';
  }

  @override
  String custom_headers_problem_missing_name(int line) {
    return '第 $line 行：缺少标头名称';
  }

  @override
  String custom_headers_problem_invalid_name(int line, String name) {
    return '第 $line 行：标头名称“$name”无效';
  }

  @override
  String custom_headers_problem_reserved(int line, String name) {
    return '第 $line 行：“$name”为保留标头，不能传递';
  }

  @override
  String custom_headers_problem_empty_value(int line) {
    return '第 $line 行：标头值为空';
  }

  @override
  String get ng_enter_a_deployment_token => '请输入部署会话令牌。';

  @override
  String get ng_custom_headers => '自定义标头';

  @override
  String get ng_custom_headers_help =>
      '此网关的额外 HTTP 标头（名称: 值，每行一个），随其 REST 和 WebSocket 调用发送，保存在安全凭据存储中。身份验证标头和逐跳标头会被拒绝。';

  @override
  String get ng_use_a_deployment_token => '使用部署会话令牌';

  @override
  String get ng_sign_in_with_deployment_token => '使用部署令牌登录';

  @override
  String get ng_signed_in_with_deployment_token => '已使用部署令牌登录。';

  @override
  String get auto_speak_replies_title => '自动朗读回复';

  @override
  String get auto_speak_replies_subtitle => '每回合结束后自动朗读新回复。默认关闭；聊天内的已朗读开关仍然生效。';

  @override
  String get ng_auto_read_replies_title => '自动朗读回复';

  @override
  String get ng_auto_read_replies_subtitle => '每回合结束后自动朗读新回复。默认关闭。';

  @override
  String get barge_in_title => '插话';

  @override
  String get barge_in_subtitle => '朗读回复时开口说话即可提前停止。朗读回复期间麦克风保持开启。';

  @override
  String get barge_in_mic_live => '麦克风已开启：说话即可打断回复';

  @override
  String get ng_barge_in_title => '插话';

  @override
  String get ng_barge_in_subtitle => '朗读回复时开口说话即可提前停止。朗读回复期间麦克风保持开启。';

  @override
  String get ng_barge_in_mic_live => '麦克风已开启：说话即可打断回复';

  @override
  String get wake_word_title => '唤醒词';

  @override
  String get wake_word_subtitle => '由网关提供免提唤醒检测。默认关闭；仅在启用设备麦克风采集时发送音频。';

  @override
  String wake_word_listening(String phrase) {
    return '正在监听唤醒词“$phrase”';
  }

  @override
  String wake_word_paused(String phrase) {
    return '唤醒词“$phrase” — 已暂停';
  }

  @override
  String wake_word_off(String phrase) {
    return '唤醒词“$phrase” — 已关闭';
  }

  @override
  String get wake_word_arming => '正在启用唤醒词…';

  @override
  String get wake_word_stop => '停止唤醒词';

  @override
  String get wake_word_rearm => '重新启用';

  @override
  String get wake_word_capture_mode => '采集模式';

  @override
  String get wake_word_capture_auto => '自动';

  @override
  String get wake_word_capture_client => '此设备麦克风';

  @override
  String get wake_word_capture_local => '网关主机麦克风';

  @override
  String get wake_word_input_device => '输入麦克风';

  @override
  String get wake_word_default_device => '系统默认';

  @override
  String get ng_wake_word_title => '唤醒词';

  @override
  String get ng_wake_word_subtitle => '由网关提供免提唤醒检测。默认关闭。';

  @override
  String get voice_engine_title => '语音对话引擎';

  @override
  String get voice_engine_subtitle => '选择此网关配置文件中免提语音对话的运行方式。';

  @override
  String get voice_engine_chained => '串联（语音转文字 → Hermes → 语音）';

  @override
  String get voice_engine_chained_short => '串联';

  @override
  String get voice_engine_live => 'GPT-Live（实时语音）';

  @override
  String get voice_engine_live_short => 'GPT-Live';

  @override
  String get voice_engine_live_needs_key =>
      '请在网关主机上配置 OpenAI API 密钥以启用 GPT-Live。';

  @override
  String voice_engine_fallback_chained(String reason) {
    return 'GPT-Live 不可用（$reason）— 改用串联语音。';
  }

  @override
  String get voice_live_start => '开始语音对话';

  @override
  String get voice_live_stop => '结束语音对话';

  @override
  String get voice_live_mute => '麦克风静音';

  @override
  String get voice_live_unmute => '取消麦克风静音';

  @override
  String get voice_live_interrupt => '打断或立即回应';

  @override
  String get voice_live_listening => '正在聆听';

  @override
  String get voice_live_speaking => '正在说话';

  @override
  String get voice_live_thinking => '正在思考';

  @override
  String get voice_live_muted => '已静音';

  @override
  String get voice_live_ended_connection_lost => '实时语音会话的连接已断开。';

  @override
  String get voice_live_ended_closed => '实时语音会话已被服务关闭。';

  @override
  String wake_word_other_profile(String profile) {
    return '该唤醒词属于配置文件“$profile”。请打开到该配置文件的连接以应答。';
  }

  @override
  String get wake_word_reason_disabled => '已关闭 — 点按以启用';

  @override
  String get wake_word_reason_surface => '仅限其他界面使用（配置 wake_word.surface）';

  @override
  String get wake_word_reason_owned => '唤醒词监听由其他界面占用';

  @override
  String wake_word_reason_owned_by(String surface) {
    return '唤醒词监听由其他界面（$surface）占用';
  }

  @override
  String get wake_word_reason_unavailable => '此网关不支持唤醒词';

  @override
  String get wake_word_reason_permission_denied => '麦克风权限被拒绝';

  @override
  String get wake_word_reason_permission_required => '需要麦克风权限 — 点按以启用';

  @override
  String get voice_live_not_enabled => '此配置文件未启用 GPT-Live。';

  @override
  String get voice_live_not_available => 'GPT-Live 不可用';

  @override
  String voice_live_start_failed(String error) {
    return '无法启动 GPT-Live：$error';
  }

  @override
  String voice_direct_stt_timeout(String seconds, String provider) {
    return '转写在 $seconds 秒后超时（$provider 未响应）';
  }

  @override
  String voice_direct_stt_error(String provider, String status) {
    return '$provider 语音转文字错误（HTTP $status）';
  }

  @override
  String voice_direct_tts_failed(String provider) {
    return '$provider 文字转语音请求失败';
  }

  @override
  String voice_direct_tts_error(String provider, String status) {
    return '$provider 文字转语音错误（HTTP $status）';
  }

  @override
  String ng_wake_status_listening(String phrase) {
    return '正在监听（“$phrase”）';
  }

  @override
  String ng_wake_status_off(String phrase) {
    return '已关闭（“$phrase”）';
  }

  @override
  String ng_wire_setting_unavailable(Object setting) {
    return '共享网关暂不支持更改 $setting';
  }

  @override
  String ng_wire_method_unavailable(Object method) {
    return '共享网关暂不支持 $method';
  }

  @override
  String ng_wire_session_options_unsupported(Object options) {
    return '规范网关不支持以下显式会话选项：$options';
  }

  @override
  String get ng_wire_prompt_stale => '该请求已过期或不可用；请重新连接后再回复';

  @override
  String get ng_wire_revision_unavailable => '会话修订版本不可用；请重新打开会话后再编辑元数据';

  @override
  String get ng_wire_generation_unavailable => '会话执行标识不可用；请重新连接后再使用此命令';

  @override
  String get ng_wire_message_not_saved => '此消息尚未保存；请等待其完成后再从它创建分支';

  @override
  String get ng_wire_not_available => '共享网关暂不支持';

  @override
  String get edit_turn_title => '编辑此提示？';

  @override
  String get edit_turn_body => '将从此处重新运行该提示，后续轮次会被归档。';

  @override
  String get edit_turn_send => '发送';

  @override
  String get restore_turn_title => '恢复到此检查点？';

  @override
  String get restore_turn_body => '此提示之后的所有内容将从对话中移除，并从此处重新运行该提示。';

  @override
  String get restore_turn_confirm => '恢复并重跑';

  @override
  String get edit_turn_later_turns_body => '这会将对话中的后续轮次归档。要继续吗？';

  @override
  String get session_history => '会话历史';

  @override
  String get import_claude_or_codex => '导入 Claude 或 Codex';

  @override
  String get ng_session_history => '会话历史';

  @override
  String get ng_import_claude_or_codex => '导入 Claude 或 Codex';

  @override
  String get ng_edit_and_resend => '编辑并重发';

  @override
  String get ng_restore_turn_confirm => '恢复并重跑';

  @override
  String get rewind_target_unsaved => '此消息尚未保存。请等待其完成后再编辑。';

  @override
  String get rewind_turn_busy => '当前回复尚未停止，因此未发送任何内容。请稍后再试。';

  @override
  String get rewind_session_changed => '此聊天自在此处打开后已发生变化，因此未移除或发送任何内容。请重新打开后再试。';

  @override
  String get history_lineage => '相关聊天';

  @override
  String get history_lineage_none => '此聊天没有分支或同级分支。';

  @override
  String get history_lineage_unavailable => '无法从此网关读取相关聊天。';

  @override
  String get history_lineage_parent => '父级';

  @override
  String get history_lineage_sibling => '同级';

  @override
  String get history_lineage_fork => '分支';

  @override
  String get history_messages => '消息';

  @override
  String get history_messages_hint => '选择一条已保存的消息，从那里分支或回退。';

  @override
  String get history_messages_none => '尚无已保存的消息。';

  @override
  String get history_messages_unavailable => '无法读取已保存的消息。请打开此聊天后刷新。';

  @override
  String get history_role_user => '你';

  @override
  String get history_role_assistant => 'Hermes';

  @override
  String get history_branch_here => '从这里分支';

  @override
  String get history_rewind_here => '回退到这里';

  @override
  String get history_branch_title => '从此消息分支';

  @override
  String get history_branch_body => '这会创建一个包含到所选消息为止历史的新聊天。当前聊天保持不变。';

  @override
  String get history_rewind_title => '回退到此消息';

  @override
  String get history_rewind_body =>
      '从所选消息起的消息将从此聊天中移除。电脑上的文件不会更改。恢复文件是单独的检查点操作。';

  @override
  String history_branched(String id) {
    return '已分支为 $id';
  }

  @override
  String get history_open_chat => '打开聊天';

  @override
  String get history_mutate_unsupported => '分支和回退需要此网关运行 Hermes 0.23 或更高版本。';

  @override
  String get history_checkpoints => '检查点';

  @override
  String get history_checkpoints_none => '此会话没有文件检查点。';

  @override
  String get history_checkpoints_unavailable => '此网关不提供检查点。';

  @override
  String get history_diff_none => '没有差异。';

  @override
  String get history_diff_loading => '正在加载更改…';

  @override
  String get history_diff_failed => '无法加载更改，因此暂时不能恢复此检查点。';

  @override
  String get history_restore_checkpoint => '恢复检查点';

  @override
  String get history_restore_title => '恢复此检查点';

  @override
  String get history_restore_body =>
      '代理自此检查点以来更改的文件将恢复到当时的状态。你自己的更改会保留。之后的聊天消息也可能被移除。对话不会分支。';

  @override
  String get history_restore_body_all =>
      '会话文件夹中的所有文件都将恢复到此检查点，包括你自己的更改。之后的聊天消息也可能被移除。对话不会分支。';

  @override
  String get history_restore_own_edits => '同时还原我自己的更改';

  @override
  String get history_restored => '检查点已恢复。';

  @override
  String history_restored_removed(int count) {
    return '检查点已恢复。已移除 $count 条聊天消息。';
  }

  @override
  String get history_export => '导出';

  @override
  String get history_export_redact => '隐去令牌';

  @override
  String get history_export_action => '导出对话记录';

  @override
  String get history_export_saved => '对话记录已保存。';

  @override
  String get history_export_unsupported => '导出需要此网关运行 Hermes 0.23 或更高版本。';

  @override
  String get history_import_unsupported => '此网关不支持导入 Claude 和 Codex。';

  @override
  String history_import_destination(String profile) {
    return '目标配置文件：$profile。';
  }

  @override
  String history_import_reading(String host, String profile, int count) {
    return '正在从 $host 读取 · 目标配置文件：$profile。有 $count 个日志无法读取。';
  }

  @override
  String get history_import_all => '全部';

  @override
  String history_import_scan_failed(String reason) {
    return '无法扫描主机会话：$reason';
  }

  @override
  String get history_import_none => '在此主机上未找到 Claude Code 或 Codex 会话。';

  @override
  String get history_import_no_match => '没有匹配的主机会话。';

  @override
  String history_import_preview_failed(String reason) {
    return '无法预览会话：$reason';
  }

  @override
  String get history_import_open => '打开已导入的会话';

  @override
  String get history_import_action => '导入所选会话';

  @override
  String get history_import_title => '导入此会话';

  @override
  String history_import_body(String profile) {
    return '将此 Claude 或 Codex 会话复制到此网关上的配置文件“$profile”。';
  }

  @override
  String history_import_body_existing(String profile) {
    return '此会话已导入到“$profile”。将继续使用现有副本。';
  }

  @override
  String history_imported(String id) {
    return '已导入为 $id';
  }

  @override
  String history_imported_already(String id) {
    return '已导入过，名称为 $id';
  }

  @override
  String history_import_directory(String path) {
    return '目录：$path';
  }

  @override
  String history_import_preview_partial(int shown, int total) {
    return '预览显示 $total 条中的 $shown 条。';
  }

  @override
  String history_failed(String reason) {
    return '无法完成：$reason';
  }

  @override
  String get history_error_unavailable => '网关暂时无法执行此操作。请重试。';

  @override
  String get history_error_unsupported => '此网关不支持此操作。';

  @override
  String get history_error_denied => '此网关拒绝了该请求。';

  @override
  String get history_error_changed => '此页面打开期间聊天已发生变化。请刷新后重试。';

  @override
  String get history_error_unbound => '此聊天未在网关上打开。请打开后重试。';

  @override
  String get history_error_invalid => '网关返回了此应用无法读取的响应。';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get workspace_workers => '运行中的子代理';

  @override
  String get workers_unattached => '仅显示数量。要向子代理发送指令，请在已连接的上级对话中选择“运行中的子代理”。';

  @override
  String get slash_local_arguments => '此处的快捷命令不支持参数。请使用应用中的控件；草稿已保留。';

  @override
  String get fallback_title => '备用模型';

  @override
  String get fallback_notice => '主模型不可用时按顺序尝试。更改仅适用于此配置；请明确保存完整列表。';

  @override
  String get fallback_unavailable => '备用设置不可用或无效。请检查连接、所选配置和主机版本，然后重试。';

  @override
  String get fallback_discovery_unavailable =>
      '无法获取提供商列表。现有条目会保留；重试后可选择提供商和模型。';

  @override
  String get fallback_empty => '此备用列表中没有条目。';

  @override
  String get fallback_incomplete => '保存前，请为每个条目选择提供商和模型，或删除未完成的条目。';

  @override
  String get fallback_add => '添加备用模型';

  @override
  String get fallback_save => '保存备用列表';

  @override
  String get fallback_save_failed => '无法验证已保存的备用列表。草稿已保留。请重新保存，或刷新以重新加载主机设置。';

  @override
  String get fallback_saved => '备用列表已保存并验证。';

  @override
  String get fallback_legacy_title => '旧版备用设置（只读）';

  @override
  String get fallback_legacy_notice =>
      '主机还会在此列表之后使用 fallback_model，并跳过重复路由。即使上方列表为空，这些旧版条目也会保留。请在主机上编辑。';

  @override
  String fallback_priority(String position) {
    return '优先级 $position';
  }

  @override
  String get fallback_move_up => '上移';

  @override
  String get fallback_move_down => '下移';

  @override
  String get fallback_routing_read_only =>
      '路由详情或未列出的提供商已保留。请在主机上编辑此提供商／模型；此处仍可调整顺序或删除条目。';

  @override
  String get cron_model_default => '使用默认设置';

  @override
  String get cron_model_notice =>
      '仅适用于此 cron 任务。未固定模型时，Hermes 先使用 cron 默认模型，再使用主模型。请在主机上管理自定义模型。';

  @override
  String get model_management_unavailable => '无法加载或保存模型设置。请刷新后重试。';

  @override
  String get model_management_subtitle => '此配置的主模型、备用模型和辅助模型';

  @override
  String get usage => '用量';

  @override
  String get nous_portal => 'Nous Portal';

  @override
  String get portal_menu_subtitle => '网关状态和已记录用量';

  @override
  String get portal_read_only =>
      '网关只读数据。请在 Hermes 主机上管理 Nous 身份验证。这些端点不提供订阅余额或积分。';

  @override
  String get portal_status => '网关 Portal 状态';

  @override
  String get portal_free_tier => '免费层访问（未登录账户）';

  @override
  String get portal_signed_in => '已登录';

  @override
  String get portal_signed_out => '未登录';

  @override
  String get portal_account_tier => '账户等级';

  @override
  String get portal_recorded_usage => '已记录用量';

  @override
  String get portal_all_providers => '所选网关配置中的所有提供商。记录费用为零并不表示模型免费。';

  @override
  String portal_period(String days) {
    return '最近 $days 天';
  }

  @override
  String get portal_sessions => '会话';

  @override
  String get portal_input => '输入令牌';

  @override
  String get portal_output => '输出令牌';

  @override
  String get portal_estimated => '已记录的预估费用';

  @override
  String get portal_actual => '已记录的实际费用';

  @override
  String get portal_recorded_models => '已记录模型';

  @override
  String get portal_no_models => '没有已记录模型。';

  @override
  String get portal_unavailable => '不可用。请检查连接、所选配置和网关版本，然后重试。';

  @override
  String get paste_attachment_failed_text_kept => '无法将粘贴的文本添加为附件。文本已保留在消息中。';

  @override
  String get background_task_report => '后台任务';

  @override
  String get background_process_report => '后台进程';

  @override
  String get background_report_issues => '已报告问题，展开查看详情。';

  @override
  String get background_report_expand => '展开报告';

  @override
  String get background_report_collapse => '收起报告';

  @override
  String get copy_session_id => '复制会话 ID';

  @override
  String get copy_session_id_failed => '无法复制会话 ID。';

  @override
  String get setup_interface_title => '选择界面';

  @override
  String get setup_interface_classic => 'Classic';

  @override
  String get setup_interface_nextgen => 'NextGen';

  @override
  String get setup_interface_classic_description =>
      '原有的 Ares 工作区，提供完整的连接控制和所有 Classic 设置。';

  @override
  String get setup_interface_nextgen_description =>
      '全新界面，只需登录仪表盘一次，并提供实时计划、子代理和通知。';

  @override
  String get setup_interface_switch_later => '你可以随时在“设置”中切换。';

  @override
  String get ng_confirm_model_switch => '切换模型？';

  @override
  String get ng_switch => '切换';

  @override
  String get ng_model_confirmation_required => '选择此模型前需要确认。';

  @override
  String ng_model_switches_next_turn(String model) {
    return '将在下一轮切换到 $model。';
  }

  @override
  String get ng_model_switch_not_connected => '聊天尚未准备好切换模型。请重新打开后再试。';

  @override
  String ng_gateway_kept_default_model(String model) {
    return '网关在此聊天中保留了 $model。请在发送前重新选择模型。';
  }

  @override
  String get hands_free_title => '免提对话';

  @override
  String get hands_free_start => '开始免提';

  @override
  String get hands_free_stop => '停止免提';

  @override
  String get hands_free_preparing => '正在准备语音 — 请稍候';

  @override
  String get hands_free_listening => '请说 Hey Hermes';

  @override
  String get hands_free_recording => '已就绪 — 请说话';

  @override
  String get hands_free_waiting => '等待 Hermes 回复';

  @override
  String get hands_free_speaking => '正在朗读 — 麦克风已关闭';

  @override
  String hands_free_followup(int seconds) {
    return '最多聆听 $seconds 秒';
  }

  @override
  String get hands_free_error => '免提已停止';

  @override
  String get hands_free_setup => '免提设置';

  @override
  String hands_free_preview(String transcript) {
    return '语音预览：$transcript';
  }

  @override
  String get hands_free_short_disclosure =>
      '仅在此聊天于前台打开时运行。唤醒检测离线；语音可能使用网络。会消耗电量。';

  @override
  String get hands_free_error_action =>
      '请检查麦克风权限、语音服务、回复声音和连接，再点击停止并重新开始。不会自动重发。';

  @override
  String get hands_free_disclosure =>
      '唤醒检测在 CPU 上离线运行。Android 语音识别、所选声音和网关可能使用网络。聆听会消耗电量，也可能误触发。聊天被遮挡、关闭或离开前台时停止，返回后不会自动重启。手动听写仍是可编辑的草稿。';

  @override
  String get hands_free_ready_cue =>
      '说“Hey Hermes”，等待就绪提示后再说话。不支持一口气连续输入或预录音。如果授权对话框使应用离开前台，授权后请再次点击开始。';

  @override
  String get hands_free_settings_title => '免提语音';

  @override
  String get hands_free_settings_subtitle =>
      '在聊天中显示“Hey Hermes”启动控件。关闭会停止正在进行的免提会话。';

  @override
  String get hands_free_timing_limit =>
      '后续聆听时间是上限，不是下限。Android 可能提前结束。无语音时返回本地唤醒检测，不会反复重启识别。';

  @override
  String get hands_free_followup_off => '后续聆听已关闭 — 每次提问请说 Hey Hermes';

  @override
  String get hands_free_start_blocked =>
      '需要空草稿、无附件、空闲且已连接的聊天，并启用语音回复。请先结束手动语音操作。';

  @override
  String get hands_free_setup_complete => '麦克风设置完成。请再次点击开始。';

  @override
  String get stop_and_send => '停止并发送';

  @override
  String get message_queued_for_running_turn => '消息已加入当前运行的队列。';

  @override
  String get running_message_not_accepted =>
      'Hermes 无法接受此消息。草稿已保留；请停止回复或等待，然后重新发送。';

  @override
  String get running_message_delivery_unknown =>
      '无法确认消息是否送达。草稿已保留。请先检查聊天记录，再重试。';

  @override
  String get attachment_tap_to_preview => '点按以预览';

  @override
  String get attachment_save => '保存';

  @override
  String get attachment_share => '分享';

  @override
  String get attachment_saved => '文件已保存';

  @override
  String get attachment_save_cancelled => '已取消保存';

  @override
  String get attachment_save_failed => '无法保存此文件，请重试。';

  @override
  String get attachment_share_failed => '无法分享此文件，请重试。';

  @override
  String get attachment_download_failed => '无法加载此文件，请检查连接后重试。';

  @override
  String get attachment_no_inline_preview =>
      '此文件类型不支持内嵌预览。请保存或分享原始文件，以便在其他应用中打开。';

  @override
  String get attachment_image_failed => '无法解码此图片。您仍可保存或分享原始文件。';

  @override
  String get attachment_text_truncated => '预览内容已截短。请保存或分享文件以阅读完整内容。';

  @override
  String get attachment_text_unavailable => '无法将此文件显示为文本。请保存或分享原始文件。';

  @override
  String get attachment_pdf_failed => '无法预览此 PDF。请保存或分享原始文件。';

  @override
  String get attachment_pdf_unavailable => 'PDF 预览仅在 Android 上可用。您仍可保存或分享此文件。';

  @override
  String attachment_pdf_page(int page, int total) {
    return '第 $page 页，共 $total 页';
  }

  @override
  String get attachment_previous_page => '上一页';

  @override
  String get attachment_next_page => '下一页';

  @override
  String get attachment_loading => '正在加载预览…';

  @override
  String get attachment_document_text_notice => '文本预览。布局、图片和格式可能与原文件不同。';

  @override
  String get attachment_document_failed => '无法预览此文档。请保存或分享原始文件。';

  @override
  String get attachment_document_empty => '此文档中未找到可读文本。';

  @override
  String get attachment_video_failed => '无法播放此视频。其格式或编解码器可能不受支持。请保存或分享原始文件。';

  @override
  String get attachment_video_play => '播放';

  @override
  String get attachment_video_pause => '暂停';

  @override
  String get attachment_video_mute => '静音';

  @override
  String get attachment_video_unmute => '取消静音';

  @override
  String get attachment_video_seek => '视频进度';

  @override
  String get attachment_close => '关闭预览';

  @override
  String get attachment_retry => '重试';

  @override
  String get theme_palette => '颜色主题';

  @override
  String get theme_palette_gold => '金色';

  @override
  String get theme_palette_purple => '紫色';

  @override
  String get theme_palette_orange => '橙色';

  @override
  String get theme_palette_green => '绿色';

  @override
  String get theme_palette_blue => '蓝色';

  @override
  String get theme_palette_red => '红色';

  @override
  String get theme_palette_teal => '青绿色';

  @override
  String get theme_palette_pink => '粉色';

  @override
  String get theme_palette_indigo => '靛蓝色';

  @override
  String get theme_palette_cyan => '青色';

  @override
  String get assets_recent_subtitle => '查找 Hermes 在已保存的聊天中分享的文件';

  @override
  String get assets_scope_notice =>
      '仅显示 Hermes 在已保存的回复中明确分享的已生成文件。这里只展示部分聊天历史，并非完整的文件或附件目录。引用的文件可能已不存在。';

  @override
  String get assets_download_limit =>
      '文件仅在点按时加载。预览和下载的单个文件大小上限均为 25 MiB；更大的文件请通过仪表盘获取。';

  @override
  String get assets_search_hint => '搜索找到的文件或来源聊天';

  @override
  String get assets_all => '全部';

  @override
  String get assets_images => '图片';

  @override
  String get assets_audio => '音频';

  @override
  String get assets_video => '视频';

  @override
  String get assets_documents => '文档和其他文件';

  @override
  String get assets_empty => '在已扫描的消息中未找到资产';

  @override
  String get assets_empty_detail =>
      '扫描更多聊天或更早的消息，以查看更早的历史。普通附件和未链接的文件不会在此建立索引。';

  @override
  String get assets_no_matches => '未找到匹配的资产';

  @override
  String get assets_load_more_chats => '扫描更多聊天';

  @override
  String get assets_load_older_messages => '扫描更早的消息';

  @override
  String get assets_load_failed => '部分历史记录无法读取。结果不完整。请检查仪表盘连接并重试。';

  @override
  String get assets_retry_failed => '重试读取失败的历史记录';

  @override
  String get assets_partial => '服务器报告历史记录不完整。请检查仪表盘后刷新。';

  @override
  String assets_scan_summary(int files, int chats) {
    return '已扫描 $chats 个聊天，找到 $files 处文件引用';
  }

  @override
  String assets_open_chat(String title) {
    return '打开聊天：$title';
  }

  @override
  String get assets_file_too_large => '此文件超出下载大小上限。请打开仪表盘进行下载。';

  @override
  String get a_one_off_question_archives_itself_after_72_hours_anything =>
      '一次性问题。将在 72 小时后自动归档；任何值得保留的内容都会被记住。';

  @override
  String get archive_chat => '归档聊天';

  @override
  String get unarchive_chat => '取消归档聊天';

  @override
  String get chat_archived => '聊天已归档';

  @override
  String get chat_unarchived => '聊天已取消归档';

  @override
  String could_not_update_chat_archive(Object error) {
    return '无法更新聊天归档状态：$error';
  }

  @override
  String get quick_chat_description => '一次性问题。';

  @override
  String get ai_full_text => 'AI + 全文';

  @override
  String get ai_search_model => 'AI 搜索模型';

  @override
  String ai_searched_for(Object aiRewrittenQuery) {
    return 'AI 已搜索：$aiRewrittenQuery';
  }

  @override
  String get ai_assisted_filing => 'AI 辅助归档';

  @override
  String get api_key => 'API 密钥';

  @override
  String get api_server_key_from_hermes_env =>
      '来自 ~/.hermes/.env 的 API_SERVER_KEY';

  @override
  String get active => '活跃';

  @override
  String get activity => '活动';

  @override
  String get activity_reads_the_durable_turn_journal_to_know_what_hermes =>
      '活动功能会读取持久化轮次日志以了解 Hermes 正在执行的操作。请检查网关是否可访问，然后重试。';

  @override
  String get add => '添加';

  @override
  String get add_connection => '添加连接';

  @override
  String get add_cron_job => '添加 Cron 任务';

  @override
  String get add_gateway_connection => '添加网关连接';

  @override
  String get add_and_update_connections_from_the_backup_keep_the_rest =>
      '从备份中添加和更新连接，其余保持不变。';

  @override
  String get add_attachment => '添加附件';

  @override
  String get add_new_cron_job => '添加新 Cron 任务';

  @override
  String get add_to_chat => '添加到聊天';

  @override
  String get all_chats => '所有聊天';

  @override
  String get all_stored_message_content => '所有已存储的消息内容';

  @override
  String get allow_for_this_session => '本次会话允许';

  @override
  String get allow_matching_commands_until_this_hermes_session_ends =>
      '在此 Hermes 会话结束前允许匹配的命令。';

  @override
  String get allow_once => '允许一次';

  @override
  String get always_allow => '总是允许';

  @override
  String get apply_to_this_chat => '应用到此聊天';

  @override
  String get approval_needed => '需要审批';

  @override
  String get approval_needed_description => '有命令正在等待你的批准或拒绝。';

  @override
  String get approve => '批准';

  @override
  String get archive => '归档';

  @override
  String get archive_project => '归档项目';

  @override
  String archive_2(Object projectName) {
    return '归档 $projectName？';
  }

  @override
  String archive_3(Object name) {
    return '归档 $name？';
  }

  @override
  String get archived => '已归档';

  @override
  String get archived_conversations_appear_here =>
      '这里只显示已归档的对话。旧聊天仍保留在“所有聊天”中。';

  @override
  String get archived_quick_chats => '已归档的快速聊天';

  @override
  String get artifacts_attachments_and_generated_media => '构件、附件和生成的内容';

  @override
  String get ask_ai_to_find_a_conversation => '让 AI 查找对话';

  @override
  String get assets => '资产';

  @override
  String get assets_need_a_server_authoritative_assets_index_in_the_hermes =>
      '资产需要在 Hermes 网关中建立服务器权威资产索引，然后才能按项目显示。';

  @override
  String get assets_unavailable => '资产不可用';

  @override
  String get attach_image_or_file => '附加图片或文件';

  @override
  String get attachment_drafts => '附件草稿';

  @override
  String get recover_text_draft => '恢复文字草稿';

  @override
  String get undo_draft_recovery => '撤销';

  @override
  String get draft_session_exists => '此对话仍然存在。请打开它以继续编辑草稿。';

  @override
  String get draft_recovery_unavailable => '无法验证此草稿。未作任何更改。';

  @override
  String attachment_of(Object index, Object total) {
    return '附件 $index / $total';
  }

  @override
  String get auto_device_default => '自动（设备默认）';

  @override
  String get agent => '智能体';

  @override
  String get autonomous_agents => '自主智能体';

  @override
  String get background_recovery_unavailable_legacy_transport =>
      '后台恢复不可用 — 旧版传输';

  @override
  String get background_task_completed => '后台任务完成';

  @override
  String get background_task_completed_description => '后台终端命令已完成。';

  @override
  String get backup_restore => '备份与恢复';

  @override
  String backup_exported(Object destination) {
    return '备份已导出 — $destination';
  }

  @override
  String get base_url => '基础 URL';

  @override
  String get binary_preview_is_unavailable_download_the_file_to_open_it =>
      '二进制预览不可用。请下载文件后打开。';

  @override
  String get branch => '分支';

  @override
  String get branch_chat => '分支聊天';

  @override
  String get branch_created_in_hermes_history => '已在 Hermes 历史记录中创建分支。';

  @override
  String get browse_and_manage_your_hermes_agent_sessions_from_your_phone =>
      '通过手机浏览和管理你的 Hermes Agent 会话。连接至运行在本地网络上的 Hermes 仪表盘。';

  @override
  String get browse_server_files => '浏览服务器文件';

  @override
  String get browse_the_miniserver_folders_behind_your_projects =>
      '浏览项目背后的 miniserver 文件夹';

  @override
  String get cancel => '取消';

  @override
  String get cancel_voice_input => '取消语音输入';

  @override
  String cannot_reach(Object host, Object port) {
    return '无法连接至 $host:$port。';
  }

  @override
  String cannot_reach_check_the_host_and_port(Object host, Object port) {
    return '无法连接至 $host:$port。请检查主机和端口。';
  }

  @override
  String get change_ai_search_model => '更改 AI 搜索模型';

  @override
  String changes_the_default_for_use_the_selector_in_a_chat(Object label) {
    return '更改 $label 的默认值。在聊天中使用选择器可仅覆盖当前对话。';
  }

  @override
  String get chat_actions => '聊天操作';

  @override
  String get chats => '聊天';

  @override
  String get chats_from_this_gateway_are_not_grouped_yet_grouping_stays =>
      '此网关中的聊天尚未分组。分组状态将保留在此手机上，直到网关能够托管项目。';

  @override
  String get chats_in_this_project_will_show_their_state_and_last =>
      '此项目中的聊天将在此处显示其状态和最后活动。';

  @override
  String get chats_that_are_not_assigned_to_a_project => '未分配至项目的聊天';

  @override
  String get chats_you_start_in_this_project_will_appear_here_on =>
      '你在此项目中发起的聊天将显示在此处，并同步到登录此 Hermes 的所有设备上。';

  @override
  String get check_that_the_gateway_is_running_and_reachable_then_try =>
      '请检查网关是否正在运行且可达，然后重试。';

  @override
  String get check_the_dashboard_connection_and_try_again => '请检查仪表盘连接并重试。';

  @override
  String get check_the_connection_and_try_again => '请检查连接并重试。';

  @override
  String get choose_a_small_model_to_rewrite_queries => '选择一个小模型来重写查询';

  @override
  String get choose_an_ai_search_model_before_using_ai_search =>
      '请在使用 AI 搜索前选择一个 AI 搜索模型。';

  @override
  String get choose_an_active_project_next => '接下来选择一个活动项目';

  @override
  String get choose_chat_model => '选择聊天模型';

  @override
  String get choose_files => '选择文件';

  @override
  String get choose_image => '选择图片';

  @override
  String get choose_images => '选择图片';

  @override
  String get choose_its_destination_space => '选择其目标空间';

  @override
  String get clear_search => '清除搜索';

  @override
  String get close => '关闭';

  @override
  String get code_copied => '代码已复制';

  @override
  String get coming_next => '敬请期待';

  @override
  String get command => '命令';

  @override
  String get command_line_chats => '命令行聊天';

  @override
  String get compatibility_mode => '兼容模式';

  @override
  String get configure_a_valid_desktop_gateway_url_before_attaching_files =>
      '在附加文件前，请先配置有效的 Desktop Gateway URL。';

  @override
  String get confirm_always_allow => '确认始终允许';

  @override
  String get confirm_passphrase => '确认密码短语';

  @override
  String connecting_to(Object baseUrl) {
    return '正在连接至 $baseUrl...';
  }

  @override
  String get connection_issue => '连接问题';

  @override
  String
  get connection_switched_the_running_reply_continues_on_the_server_and =>
      '连接已切换 — 正在进行的回复将在服务器上继续，并会自动重新附加。';

  @override
  String get connection_appearance_and_device_preferences => '连接、外观和设备偏好设置';

  @override
  String context_tokens(Object effectiveContextLength) {
    return '上下文：$effectiveContextLength Token';
  }

  @override
  String get continue_label => '继续';

  @override
  String get continue_working => '继续工作';

  @override
  String get conversations_in_this_project => '此项目中的对话';

  @override
  String get copy_code => '复制代码';

  @override
  String get copy_message => '复制消息';

  @override
  String could_not_branch_chat(Object error) {
    return '无法创建聊天分支：$error';
  }

  @override
  String could_not_delete_session(Object error) {
    return '无法删除会话：$error';
  }

  @override
  String could_not_deny_the_command(Object error) {
    return '无法拒绝该命令：$error';
  }

  @override
  String could_not_load_ai_search_models(Object error) {
    return '无法加载 AI 搜索模型：$error';
  }

  @override
  String get could_not_load_conversations => '无法加载对话';

  @override
  String get could_not_load_files => '无法加载文件';

  @override
  String could_not_load_models_for_this_profile(Object error) {
    return '无法为该配置档案加载模型：$error';
  }

  @override
  String could_not_load_more_chats(Object error) {
    return '无法加载更多聊天：$error';
  }

  @override
  String get could_not_open_link => '无法打开此链接。';

  @override
  String get could_not_open_the_hermes_dashboard => '无法打开 Hermes 仪表盘。';

  @override
  String get could_not_open_this_project => '无法打开此项目';

  @override
  String get could_not_preview_file => '无法预览文件';

  @override
  String get could_not_reach_hermes => '无法连接至 Hermes';

  @override
  String could_not_reach_authenticate_the_dashboard_at_check_the_port(
    Object dashboardPort,
    Object host,
  ) {
    return '无法连接/验证位于 $host:$dashboardPort 的仪表盘。请检查端口和凭据。';
  }

  @override
  String get could_not_read_activity => '无法读取活动';

  @override
  String could_not_rename_chat(Object error) {
    return '无法重命名聊天：$error';
  }

  @override
  String could_not_send_the_approval(Object error) {
    return '无法发送审批：$error';
  }

  @override
  String get could_not_skip_the_hermes_question => '无法跳过 Hermes 的问题。';

  @override
  String could_not_the_project(Object action, Object error) {
    return '无法 $action 该项目：$error';
  }

  @override
  String get couldn_t_delete_project => '无法删除项目';

  @override
  String couldn_t_load_runs(Object error) {
    return '无法加载运行记录：$error';
  }

  @override
  String get couldn_t_move_conversation => '无法移动对话';

  @override
  String couldn_t_move_to(Object label, Object reason) {
    return '无法移动至 $label：$reason';
  }

  @override
  String get couldn_t_prepare_the_shared_files => '无法准备共享文件。';

  @override
  String get couldn_t_promote_conversation => '无法提升会话';

  @override
  String couldn_t_project(Object action) {
    return '无法 $action 项目';
  }

  @override
  String get create => '创建';

  @override
  String get create_a_project => '创建项目';

  @override
  String get create_a_project_first_then_chats_can_live_inside_it =>
      '请先创建一个项目，聊天内容即可存放在其中。';

  @override
  String get create_a_space_to_separate_related_conversations =>
      '创建一个空间以区分相关的聊天。';

  @override
  String get create_branch => '创建分支';

  @override
  String get credit_notifications => '额度通知';

  @override
  String get credit_notifications_description => '额度使用已停止或恢复。';

  @override
  String get cron => 'Cron';

  @override
  String get cron_jobs => 'Cron 任务';

  @override
  String cron_schedule_timezone(Object zone) {
    return '排程时区：$zone';
  }

  @override
  String get crons_upcoming => '即将运行';

  @override
  String get crons_history => '运行历史';

  @override
  String cron_time_with_zone(Object time, Object zone) {
    return '$time（$zone）';
  }

  @override
  String cron_time_zone_unknown(Object time) {
    return '$time（时区未知）';
  }

  @override
  String get cron_no_next_run => '未安排下次运行';

  @override
  String get cron_status_scheduled => '已排程';

  @override
  String get cron_status_paused => '已暂停';

  @override
  String cron_delivers_to(Object target) {
    return '投递至 $target';
  }

  @override
  String get cron_upcoming_empty_title => '暂无已排程任务';

  @override
  String get cron_upcoming_empty_message =>
      '当前没有待运行的任务。请在 Cron 任务中创建，或让智能体安排一个。';

  @override
  String get cron_upcoming_unavailable => '无法显示已排程任务';

  @override
  String get cron_upcoming_needs_dashboard =>
      '已排程任务需要仪表盘连接。此地址不提供 Cron 排程。请检查仪表盘地址和主机支持情况。';

  @override
  String get cron_upcoming_needs_dashboard_auth =>
      '已排程任务需要仪表盘认证。请为此连接添加仪表盘用户名和密码，或启用代理模式。';

  @override
  String get cron_upcoming_dashboard_unreachable =>
      '无法连接到仪表盘。请检查主机、仪表盘端口和网络，然后重试。';

  @override
  String get cron_upcoming_load_failed => '无法读取已排程任务。请检查仪表盘连接并重试。';

  @override
  String get cron_upcoming_refresh_failed => '无法刷新排程。正在显示上次成功读取的结果。';

  @override
  String get cron_job_added => 'Cron 任务已添加';

  @override
  String get cron_job_updated => 'Cron 任务已更新';

  @override
  String get cron_run => 'Cron 运行';

  @override
  String get cross_device_ordering_and_reversible_bulk_organization =>
      '跨设备排序与可撤销的批量整理';

  @override
  String get current_profile_default => '当前配置档案默认值';

  @override
  String get custom_proxy_and_dashboard_details => '自定义代理与仪表盘详情';

  @override
  String get dark => '深色';

  @override
  String get dashboard_proxy_settings => '仪表盘 / 代理设置';

  @override
  String get dashboard_password_optional => '仪表盘密码（可选）';

  @override
  String get dashboard_port => '仪表盘端口';

  @override
  String get dashboard_username_optional => '仪表盘用户名（可选）';

  @override
  String get dashboard_behind_proxy => '位于代理后的仪表盘';

  @override
  String get dashboard_path_prefix => '仪表盘路径前缀';

  @override
  String delegated_task(Object goal) {
    return '委派任务：$goal';
  }

  @override
  String get delete => '删除';

  @override
  String delete_2(Object name) {
    return '删除“$name”？';
  }

  @override
  String delete_from_the_remote_hermes_history_this_cannot_be_undone(
    Object title,
  ) {
    return '从远程 Hermes 历史记录中删除“$title”？此操作不可撤销。';
  }

  @override
  String get delete_cron_job => '删除 Cron 任务';

  @override
  String get delete_connections_that_are_not_in_the_backup => '删除不在备份中的连接。';

  @override
  String delete_failed(Object error) {
    return '删除失败：$error';
  }

  @override
  String get delete_project => '删除项目';

  @override
  String get delete_session => '删除会话？';

  @override
  String delete_3(Object projectName) {
    return '删除 $projectName？';
  }

  @override
  String deleted(Object name) {
    return '已删除“$name”';
  }

  @override
  String get delivery_is_uncertain_recovering_without_resending =>
      '发送状态不确定；正在恢复且不重新发送……';

  @override
  String get desktop_gateway_url_optional => 'Desktop Gateway URL（可选）';

  @override
  String get desktop_gateway_is_not_configured_for_this_connection =>
      '此连接未配置 Desktop Gateway。';

  @override
  String get desktop_app => '桌面应用';

  @override
  String get developer_tool_calls => '开发者工具调用';

  @override
  String get discord_chats => 'Discord 聊天';

  @override
  String get dismiss => '忽略';

  @override
  String get do_not_run_this_command => '请勿运行此命令。';

  @override
  String get documents_archives_audio_video_or_data => '文档、压缩包、音频、视频或数据';

  @override
  String get download => '下载';

  @override
  String download_failed(Object error) {
    return '下载失败：$error';
  }

  @override
  String get durable_facts_hermes_keeps_about_you => 'Hermes 记录的关于你的持久事实';

  @override
  String get durable_work_inside_one_of_your_projects_shared_with_desktop =>
      '项目内的持久工作内容，已与 Desktop 共享。';

  @override
  String get edit => '编辑';

  @override
  String get edit_connection => '编辑连接';

  @override
  String get edit_cron_job => '编辑 Cron 任务';

  @override
  String get edit_gateway_connection => '编辑网关连接';

  @override
  String get edit_and_resend => '编辑并重发';

  @override
  String get enable_notifications => '启用通知';

  @override
  String get enable_notifications_description => '关闭后将禁用以下所有通知。';

  @override
  String get enables_file_attachments_through_the_desktop_remote_gateway =>
      '允许通过 Desktop 远程网关发送文件附件。';

  @override
  String get enter_a_name => '输入名称';

  @override
  String get enter_a_passphrase => '请输入密码短语。';

  @override
  String get enter_the_passphrase_for_this_backup => '请输入此备份的密码短语。';

  @override
  String get every_conversation_is_already_assigned_to_a_project =>
      '所有对话均已分配至某个项目。';

  @override
  String get everything_not_yet_native_in_the_authenticated_web_dashboard =>
      '所有尚未原生支持的功能，均可在已认证的 Web 仪表盘中查看';

  @override
  String get explain_the_attached_content_clearly => '清晰解释附件内容。';

  @override
  String explain_this_content_clearly(Object text) {
    return '清晰解释此内容：\n\n$text';
  }

  @override
  String
  get explicit_choices_adjust_android_accessibility_text_size_system_leaves_it =>
      '显式选择将调整 Android 无障碍文字大小；选择“系统”则保持不变。';

  @override
  String get export_label => '导出';

  @override
  String get export_share => '导出 / 分享';

  @override
  String get external_api_clients => '外部 API 客户端';

  @override
  String get extra_high => '极高';

  @override
  String get extract_tasks => '提取任务';

  @override
  String
  get extract_the_decisions_deadlines_owners_and_actionable_action_items_from =>
      '从附件内容中提取决策、截止日期、负责人以及可执行的操作项。';

  @override
  String
  extract_the_decisions_deadlines_owners_and_actionable_action_items_from_2(
    Object text,
  ) {
    return '从以下内容中提取决策、截止日期、负责人以及可执行的操作项：\n\n$text';
  }

  @override
  String failed_to_add_job(Object error) {
    return '添加任务失败：$error';
  }

  @override
  String get failed_to_load_cron_jobs => '加载 Cron 任务失败';

  @override
  String get failed_to_load_memory => '加载记忆失败';

  @override
  String get failed_to_load_messages => '加载消息失败';

  @override
  String get failed_to_load_settings => '加载设置失败';

  @override
  String get failed_to_load_skills => '加载技能失败';

  @override
  String failed_to_update_job(Object error) {
    return '更新任务失败：$error';
  }

  @override
  String failed(Object error) {
    return '失败：$error';
  }

  @override
  String get file_attached_document_catalog_registration_is_pending =>
      '已添加文件附件；文档目录注册正在等待处理。';

  @override
  String get file_reference_added_to_chat => '文件引用已添加至聊天';

  @override
  String get files => '文件';

  @override
  String get fill_from_document => '从文档填充';

  @override
  String get folder_is_empty => '文件夹为空';

  @override
  String get folders => '文件夹';

  @override
  String get full_text => '全文';

  @override
  String get gateway_api_access => '网关 API 访问';

  @override
  String get gateway_connected_but_the_dashboard_could_not_be_reached_or =>
      '网关已连接，但无法访问仪表盘或未能通过身份验证。请检查仪表盘详细信息，或清除它们以跳过。';

  @override
  String get gateway_path_prefix => '网关路径前缀';

  @override
  String get go_to_end => '转到末尾';

  @override
  String get hermes_agent => 'Ares - formerly Hermes Android';

  @override
  String get hermes_agent_for_android => 'Ares - formerly Hermes Android';

  @override
  String get hermes_could_not_accept_the_answer_please_try_again =>
      'Hermes 无法接受此回答，请重试。';

  @override
  String get hermes_could_not_load_your_saved_connections =>
      'Hermes 无法加载你保存的连接';

  @override
  String get hermes_did_not_accept_the_response_please_try_again =>
      'Hermes 未能接受此响应，请重试。';

  @override
  String get hermes_is_responding => 'Hermes 正在响应…';

  @override
  String get hermes_is_waiting_for_input => 'Hermes 正在等待输入…';

  @override
  String get hermes_keeps_android_accessibility_text_scaling_active =>
      'Ares 保持 Android 辅助功能文字缩放处于活动状态。';

  @override
  String get hermes_needs_your_input => 'Hermes 需要你的输入';

  @override
  String get hermes_profile_optional => 'Hermes 配置档案（可选）';

  @override
  String get hermes_profile_must_be_a_plain_profile_name_such_as =>
      'Hermes 配置档案必须是纯粹的档案名称（例如 “sol”），而不能是路径。';

  @override
  String get hermes_reasoning_details => 'Hermes 推理详情';

  @override
  String hermes_recovery_is_unavailable(Object error) {
    return 'Hermes 恢复不可用：$error';
  }

  @override
  String get hermes_stopped_recovery_safely_no_prompt_was_resent =>
      'Hermes 已安全停止恢复。未重新发送任何提示词。';

  @override
  String get hide_passphrase => '隐藏密码短语';

  @override
  String get home_needs_your_recent_chats_to_know_what_deserves_your =>
      '首页需要你最近的聊天记录来了解哪些内容值得你关注。请检查网关是否可达，然后重试。';

  @override
  String get host => '主机';

  @override
  String get image_selection_was_interrupted_try_again => '图片选择被中断，请重试。';

  @override
  String get import_label => '导入';

  @override
  String get inbox => '收件箱';

  @override
  String get inbox_is_clear => '收件箱为空';

  @override
  String get input_needed => '需要输入';

  @override
  String get input_needed_description => 'Hermes 提出了问题，或需要密码或密钥。';

  @override
  String get insert_a_remote_file_reference => '插入远程 @file 引用';

  @override
  String get invalid_port_number => '无效的端口号。';

  @override
  String get job_paused => '任务已暂停';

  @override
  String get job_resumed => '任务已恢复';

  @override
  String get job_triggered => '任务已触发';

  @override
  String get label => '标签';

  @override
  String last_activity(Object day, Object month, Object year) {
    return '最后活动于 $year年$month月$day日';
  }

  @override
  String last(Object lastRun) {
    return '最后运行：$lastRun';
  }

  @override
  String get leave_blank_for_default_8642_443_with_https =>
      '留空则使用默认值（8642；使用 https 时为 443）';

  @override
  String get leave_blank_for_default_9119 => '留空则使用默认值 (9119)';

  @override
  String get light => '浅色';

  @override
  String listening(Object elapsed) {
    return '正在聆听 • $elapsed';
  }

  @override
  String listening_elapsed(Object elapsed) {
    return '正在聆听，已耗时 $elapsed';
  }

  @override
  String get load_more => '加载更多…';

  @override
  String get loading => '正在加载';

  @override
  String get location => '位置';

  @override
  String get make_sure_the_gateway_api_server_is_running_hermes_gateway =>
      '请确保网关 API Server 正在运行\n(hermes gateway status)';

  @override
  String matches(Object assigned, Object name) {
    return '匹配项 $name · $assigned';
  }

  @override
  String get memory => '记忆';

  @override
  String get memory_about_you => '关于你';

  @override
  String get memory_agent_notes => '助手笔记';

  @override
  String get memory_builtin_scope =>
      '此配置档案的 USER.md 和 MEMORY.md 中保存的事实。这里不显示外部记忆服务（包括 MemPalace）的内容。';

  @override
  String get memory_read_only => '仅供查看。可在聊天中请 Hermes 更正或忘记某条事实。';

  @override
  String get memory_unavailable =>
      '此网关或配置档案无法提供已保存的事实。请检查所选配置档案，并在需要时更新 Hermes。';

  @override
  String get memory_load_error => '请检查仪表盘连接和身份验证，然后重试。';

  @override
  String get memory_read_full_fact => '阅读完整事实';

  @override
  String get memory_full_fact_requires_update =>
      '查看完整事实需要更新的 Hermes 网关。请更新 Hermes 并刷新列表。';

  @override
  String get memory_fact_detail_error => '无法加载完整事实。它可能已更改；请刷新列表后重试。';

  @override
  String get memory_entries_are_cross_session_facts_the_agent_remembers_they =>
      'Hermes 记住的事实会显示在这里。';

  @override
  String get merge => '合并';

  @override
  String get message => '消息';

  @override
  String get message_hermes => '给 Hermes 发消息…';

  @override
  String get message_actions => '消息操作';

  @override
  String get message_copied => '已复制消息';

  @override
  String get migrating => '正在迁移…';

  @override
  String get migration_complete => '迁移完成';

  @override
  String get migration_failed_local_spaces_were_kept_unchanged =>
      '迁移失败。本地空间保持不变。';

  @override
  String get migration_incomplete => '迁移未完成';

  @override
  String get migration_preview => '迁移预览';

  @override
  String get model => '模型';

  @override
  String get model_and_thinking_for_this_chat => '此聊天的模型和思考状态';

  @override
  String model_was_not_changed(Object error) {
    return '模型未更改：$error';
  }

  @override
  String get move_attachment_next => '将附件移至下一个';

  @override
  String get move_attachment_previous => '将附件移至上一个';

  @override
  String get move_chat => '移动聊天';

  @override
  String get move_conversation => '移动会话';

  @override
  String get move_to_project => '移动到项目';

  @override
  String get move_to_space => '移动到空间';

  @override
  String get moved_to_a_project => '已移动到项目';

  @override
  String moved_to(Object label) {
    return '已移动到 $label';
  }

  @override
  String get name => '名称';

  @override
  String get name_prompt_and_schedule_are_required => '名称、提示词和计划均为必填项';

  @override
  String get nav_activity => '活动';

  @override
  String get nav_projects => '项目';

  @override
  String get needs_a_correction_aware_filing_contract_in_the_hermes_gateway =>
      'Hermes 网关中需要具备支持纠错感知的文件归档契约。';

  @override
  String get needs_a_reachable_hermes_dashboard_check_the_host_port_and =>
      '需要可访问的 Hermes 仪表盘。请检查此连接的主机、端口和凭据。';

  @override
  String get needs_a_server_authoritative_assets_index_in_the_hermes_gateway =>
      'Hermes 网关中需要具备服务端权威的资产索引。';

  @override
  String get needs_durable_pin_ordering_batch_mutation_and_undo_contracts_in =>
      'Hermes 网关中需要具备持久化的置顶排序、批量变更和撤销契约。';

  @override
  String get needs_you => '需要你';

  @override
  String get new_label => '新';

  @override
  String get new_chat => '新聊天';

  @override
  String get new_chat_2 => '新聊天';

  @override
  String new_chat_3(Object projectName) {
    return '新聊天 · $projectName';
  }

  @override
  String get new_project => '新建项目';

  @override
  String get new_space => '新建空间';

  @override
  String next(Object nextRun) {
    return '下次运行：$nextRun';
  }

  @override
  String get nginx_injects_auth_app_sends_clean_requests =>
      'Nginx 注入认证 — 应用发送干净请求';

  @override
  String get no_tts_voices_found_ninstall_google_text_to_speech_and =>
      '未找到 TTS 语音。\n请安装 Google Text-to-Speech 并下载语音数据。';

  @override
  String get no_active_projects_on_this_gateway => '此网关上暂无活动项目';

  @override
  String get no_activity_yet => '暂无活动';

  @override
  String get no_chat_is_blocked_running_or_waiting_to_be_resumed =>
      '没有被阻塞、运行中或等待恢复的聊天。准备好后随时可以开始新聊天。';

  @override
  String no_chats_in_this_project_match(Object searchQuery) {
    return '此项目中没有与“$searchQuery”匹配的聊天。';
  }

  @override
  String get no_chats_in_this_space_yet_tap_to_start_one =>
      '此空间暂无聊天。轻点 + 开始聊天。';

  @override
  String get no_chats_yet => '暂无聊天';

  @override
  String get no_connections => '无连接';

  @override
  String get no_conversation_matches_this_view => '没有与此视图匹配的对话。';

  @override
  String get no_cron_jobs => '暂无 Cron 任务';

  @override
  String get no_folders_yet => '暂无文件夹';

  @override
  String get no_local_spaces_were_found_for_this_connection_so_projects =>
      '在此连接中未找到本地空间，因此项目已是此处的唯一组织方式。';

  @override
  String get no_matches => '无匹配项';

  @override
  String get no_memory_entries => '暂无记忆条目';

  @override
  String get no_message_content_matches => '无匹配的消息内容';

  @override
  String get no_new_messages => '暂无新消息';

  @override
  String get no_projects_yet => '暂无项目';

  @override
  String get no_runs_yet => '暂无运行记录。';

  @override
  String no_server_project_matches_this_name(Object assigned) {
    return '没有与此名称匹配的服务端项目 · $assigned';
  }

  @override
  String get no_sessions_yet => '暂无会话';

  @override
  String get no_skills_found => '未找到技能';

  @override
  String get no_spaces_on_this_device => '此设备上无空间';

  @override
  String get no_text_shared => '未共享文本';

  @override
  String get no_turn_is_blocked_in_flight_or_recently_finished_work =>
      '没有被阻塞、进行中或最近完成的轮次。你开始的工作会显示在这里。';

  @override
  String get no_turn_needs_your_input_or_has_failed => '没有需要你输入或失败的轮次。';

  @override
  String get no_unassigned_chats => '暂无未分配的聊天。';

  @override
  String get nothing_changed_in_the_last_seven_days => '最近七天无更改。';

  @override
  String get nothing_has_moved_yet_this_is_only_what_a_migration =>
      '尚未移动任何内容 — 这只是迁移将执行的操作。';

  @override
  String get nothing_here => '这里什么也没有';

  @override
  String get nothing_is_running => '没有正在运行的内容';

  @override
  String get nothing_needs_you => '一切正常，无需处理';

  @override
  String get nothing_to_migrate => '无需迁移';

  @override
  String get notifications => '通知';

  @override
  String get notifications_permission_denied =>
      '系统已阻止通知。请在 Android 设置中允许此应用发送通知。';

  @override
  String get off_no_thinking => '关闭（无思考）';

  @override
  String get offline_showing_the_last_known_activity => '离线 — 显示最后已知的活动。';

  @override
  String get offline_showing_the_last_known_chats => '离线 — 显示最后已知的聊天';

  @override
  String get offline_showing_the_last_known_projects => '离线 — 正在显示最后已知的项目。';

  @override
  String get on_this_device => '此设备上';

  @override
  String get on_device => '端侧';

  @override
  String get open_inbox => '打开收件箱';

  @override
  String open_inbox_2(Object count) {
    return '打开收件箱（$count）';
  }

  @override
  String get open_the_hermes_dashboard => '打开 Hermes 仪表盘';

  @override
  String get optional_for_the_memory_cron_skills_settings_tabs_leave_blank =>
      '可选。用于“记忆”、“Cron”、“技能”、“设置”标签页。留空则使用默认仪表盘端口（9119）且无需登录。';

  @override
  String get organization => '组织';

  @override
  String get other_answer => '其他回答';

  @override
  String get overview => '概览';

  @override
  String get passphrase => '密码短语';

  @override
  String get password_optional => '密码（可选）';

  @override
  String get phone_or_tablet => '手机或平板电脑';

  @override
  String get pin_batch_and_undo => '置顶、批量操作与撤销';

  @override
  String get plugin_notifications => '插件通知';

  @override
  String get plugin_notifications_description => '应用在后台时，网关发来了通知。';

  @override
  String get port => '端口';

  @override
  String get preparing_attachments => '正在准备附件…';

  @override
  String get preview_truncated => '预览已截断';

  @override
  String get preview_unavailable => '预览不可用';

  @override
  String get profile => '配置档案';

  @override
  String get profile_default_model => '配置档案默认模型';

  @override
  String profile_default_set_to_chats_with_their_own_model_keep(
    Object selectedModel,
  ) {
    return '配置档案默认值已设为 $selectedModel。拥有独立模型的聊天将保留该覆盖设置。';
  }

  @override
  String
  get profile_this_connection_chats_as_when_the_dashboard_serves_several =>
      '当仪表盘服务于多个配置档案时，为此连接的聊天指定配置档案。留空则使用独立的单配置档案仪表盘。';

  @override
  String get project => '项目';

  @override
  String get project_actions => '项目操作';

  @override
  String get project_chat => '项目聊天';

  @override
  String get project_chats_unavailable => '项目聊天不可用';

  @override
  String get projects => '项目';

  @override
  String get projects_group_related_chats_files_and_activity_and_stay_in =>
      '项目将相关的聊天、文件和活动进行分组，并与你电脑上的 Hermes 保持同步。';

  @override
  String
  get projects_need_a_desktop_gateway_connection_add_the_desktop_gateway =>
      '项目需要 Desktop Gateway 连接。请将 Desktop Gateway URL 添加到此连接，以便跨设备管理聊天。';

  @override
  String get projects_unavailable => '项目不可用';

  @override
  String get projects_activity_new_navigation => '项目、活动 — 新导航';

  @override
  String get promote_to_project => '提升为项目';

  @override
  String get prompt => '提示词';

  @override
  String get protect_this_backup => '保护此备份';

  @override
  String get provider => '提供方';

  @override
  String get proxy_injects_auth_app_sends_clean_requests => '代理注入认证信息；应用发送纯净请求';

  @override
  String get quick_chat => '快速聊天';

  @override
  String get quick_chats_appear_here_after_their_retention_period =>
      '快速聊天将在保留期过后显示在此处。';

  @override
  String get read_aloud => '朗读';

  @override
  String get read_aloud_is_unavailable_on_this_device => '此设备不支持朗读功能';

  @override
  String get reading_response_aloud => '正在朗读回复';

  @override
  String get ready_to_upload => '准备上传';

  @override
  String get reasoning => '推理';

  @override
  String get recently_completed => '最近完成';

  @override
  String get recently_active => '最近活跃';

  @override
  String get recovering_hermes => '正在恢复 Hermes…';

  @override
  String get refresh => '刷新';

  @override
  String get regenerate_response => '重新生成回复';

  @override
  String get remove_attachment => '移除附件';

  @override
  String get rename => '重命名';

  @override
  String get rename_chat => '重命名聊天';

  @override
  String get rename_project => '重命名项目';

  @override
  String get rename_space => '重命名空间';

  @override
  String rename_2(Object projectName) {
    return '重命名 $projectName';
  }

  @override
  String rename_3(Object name) {
    return '重命名 $name';
  }

  @override
  String get replace => '替换';

  @override
  String get repositories => '代码库';

  @override
  String
  get research_the_attached_content_verify_the_important_claims_and_cite =>
      '研究附件内容，核实重要主张并引用来源。';

  @override
  String research_this_content_verify_the_important_claims_and_cite_sources(
    Object text,
  ) {
    return '研究此内容，核实重要主张并引用来源：\n\n$text';
  }

  @override
  String reset_failed_the_secure_storage_may_need_reinstall(Object retryError) {
    return '重置失败：$retryError。安全存储可能需要重新安装。';
  }

  @override
  String get reset_saved_connections => '重置已保存的连接';

  @override
  String get responding => '正在响应…';

  @override
  String response_closed_locally_gateway_stop_failed(Object error) {
    return '响应已在本地关闭；网关停止失败：$error';
  }

  @override
  String get response_closed_locally_no_active_gateway_turn_was_found =>
      '响应已在本地关闭；未找到活动的网关轮次。';

  @override
  String get response_complete => '响应完成';

  @override
  String get response_complete_description => '应用在后台时，一轮对话已完成。';

  @override
  String get response_ready => '回复就绪';

  @override
  String get response_stopped => '回复已停止。';

  @override
  String get restore => '恢复';

  @override
  String get restore_configuration => '恢复配置';

  @override
  String get restore_project => '恢复项目';

  @override
  String get retry => '重试';

  @override
  String retry_failed_for_the_draft_and_prompt_were_kept(Object name) {
    return '$name 重试失败。草稿和提示词已保留。';
  }

  @override
  String get retry_upload => '重试上传';

  @override
  String retrying(Object name) {
    return '正在重试 $name…';
  }

  @override
  String get review_local_spaces => '检查本地空间';

  @override
  String get review_or_promote_quick_chats_past_their_retention_period =>
      '查看或提升超出保留期限的快速聊天';

  @override
  String get review_the_attached_content => '查看附件内容。';

  @override
  String get run_only_this_command => '仅运行此命令。';

  @override
  String get running_now => '正在运行';

  @override
  String get save => '保存';

  @override
  String get save_changes => '保存更改';

  @override
  String get save_a_permanent_rule_in_the_hermes_configuration =>
      '在 Hermes 配置中保存永久规则。';

  @override
  String get save_the_durable_facts_from_the_attached_content_to_memory =>
      '将附件内容中的持久事实保存到记忆中，然后确认保留的内容。';

  @override
  String save_the_durable_facts_from_this_content_to_memory_then(Object text) {
    return '将此内容中的持久事实保存到记忆中，然后确认保留的内容：\n\n$text';
  }

  @override
  String get save_your_connections_and_settings_to_an_encrypted_file_then =>
      '将连接与设置保存到加密文件中，以便在重新安装或在其他设备上时恢复它们。';

  @override
  String save_2(Object filename) {
    return '保存 $filename';
  }

  @override
  String get schedule => '计划';

  @override
  String get scheduled_jobs_and_their_last_runs => '计划任务及其最近运行情况';

  @override
  String get scheduled_tasks => '计划任务';

  @override
  String get script_only_no_agent => '仅脚本（无 Agent）';

  @override
  String get scroll_horizontally => '水平滚动';

  @override
  String get search_all_chats => '搜索所有聊天';

  @override
  String get search_all_message_content => '搜索所有消息内容';

  @override
  String get search_chats => '搜索聊天';

  @override
  String get search_conversations => '搜索对话';

  @override
  String get search_loaded_chats => '搜索已加载的聊天';

  @override
  String get search_mode => '搜索模式';

  @override
  String get select_one_option_or_enter_another_answer => '选择一个选项，或输入其他答案。';

  @override
  String get select_one_or_more_options_then_continue => '选择一个或多个选项，然后继续。';

  @override
  String get select_text => '选择文本';

  @override
  String get send => '发送';

  @override
  String send_failed(Object error) {
    return '发送失败：$error';
  }

  @override
  String send_failed_api_only_permission_denied(Object error) {
    return '发送失败：$error。服务器拒绝了 API 密钥主体的此次写入。如果该会话归 Dashboard 所有，为此连接添加 Dashboard 用户名和密码可能即可发送；服务器也可能是有意拒绝。';
  }

  @override
  String get send_message => '发送消息';

  @override
  String get send_test_notification => '发送测试通知';

  @override
  String get session_sources => '会话来源';

  @override
  String get session_deleted_from_remote_hermes => '已从远程 Hermes 中删除会话。';

  @override
  String session_search_failed(Object error) {
    return '会话搜索失败：$error';
  }

  @override
  String get set_profile_default => '设为默认配置档案';

  @override
  String get settings => '设置';

  @override
  String get share_to_hermes => '分享到 Hermes';

  @override
  String get show_passphrase => '显示密码短语';

  @override
  String get show_tool_calls_thinking_and_message_metadata =>
      '显示工具调用、思考过程和消息元数据';

  @override
  String get signal_messages => 'Signal 消息';

  @override
  String get skills => '技能';

  @override
  String skills_2(Object count) {
    return '技能（$count）';
  }

  @override
  String get skills_and_tools => '技能与工具';

  @override
  String get skip => '跳过';

  @override
  String get slack_chats => 'Slack 聊天';

  @override
  String source(Object source) {
    return '来源：$source';
  }

  @override
  String get space_actions => '空间操作';

  @override
  String get spaces => '空间';

  @override
  String get speak_to_hermes => '对 Hermes 说话';

  @override
  String get speech_recognition_is_unavailable => '语音识别不可用';

  @override
  String get spoken_replies => '语音回复';

  @override
  String get spoken_replies_off => '语音回复已关闭';

  @override
  String get spoken_replies_on => '语音回复已开启';

  @override
  String get stalled_no_update_from_hermes => '已停滞 — 未收到来自 Hermes 的更新';

  @override
  String get start_something_new => '开启新任务';

  @override
  String get start_voice_input => '开始语音输入';

  @override
  String get starting_hermes => '正在启动 Hermes…';

  @override
  String get still_loading_your_projects => '正在加载你的项目。';

  @override
  String get stop => '停止';

  @override
  String get stop_response => '停止响应';

  @override
  String get stop_voice_input => '停止语音输入';

  @override
  String get submitted_waiting_for_hermes => '已提交，等待 Hermes 响应';

  @override
  String get suggest_projects_and_learn_from_your_corrections =>
      '建议项目并从你的更正中学习';

  @override
  String get summarize_the_attached_content => '总结附件内容。';

  @override
  String summarize_this_content(Object text) {
    return '总结此内容：\n\n$text';
  }

  @override
  String get switch_profile => '切换配置档案';

  @override
  String get system => '系统';

  @override
  String get take_photo => '拍照';

  @override
  String get tap_to_add_a_remote_hermes_gateway_api_server_port =>
      '点击 + 添加远程 Hermes 网关\n(API Server，端口 8642)';

  @override
  String get tap_the_button_to_start_a_new_chat => '点击 + 按钮开始新的聊天';

  @override
  String get telegram_messages => 'Telegram 消息';

  @override
  String get terminal_sessions => '终端会话';

  @override
  String get test_notification_body => '如果你能看到这条通知，说明通知功能正常。';

  @override
  String get test_notification_sent => '已发送测试通知。';

  @override
  String get test_notification_title => 'Hermes 通知测试';

  @override
  String get test_notification_unsupported => '无法发送通知——请检查系统是否允许通知。';

  @override
  String get text_size => '文字大小';

  @override
  String get text_size_preview => '文字大小预览';

  @override
  String text_size_2(Object label) {
    return '文字大小：$label';
  }

  @override
  String get the_api_key_could_not_be_stored_securely => '无法安全存储 API 密钥。';

  @override
  String get the_project_will_move_to_archived_its_chats_and_files =>
      '该项目将移至“已归档”。其聊天和文件将保持完整，你可以随时恢复它。';

  @override
  String get the_project_will_move_to_archived_its_chats_and_files_2 =>
      '该项目将移至“已归档”。其聊天和文件将保持完整，你可以稍后恢复它。';

  @override
  String get the_active_profile_did_not_return_any_selectable_models =>
      '当前配置档案未返回任何可选模型。';

  @override
  String get the_backup_could_not_be_exported => '无法导出备份。';

  @override
  String get the_backup_could_not_be_restored => '无法恢复备份。';

  @override
  String get the_connection_could_not_be_deleted_safely => '无法安全删除连接。';

  @override
  String get the_connection_could_not_be_stored_securely => '无法安全存储连接。';

  @override
  String get the_dashboard_credentials_could_not_be_stored_securely =>
      '无法安全存储仪表盘凭据。';

  @override
  String get the_detached_reply_failed => '已分离的回复失败。';

  @override
  String the_detached_reply_failed_2(Object error) {
    return '已分离的回复失败：$error';
  }

  @override
  String get the_file_contains_your_api_keys_and_dashboard_password_so =>
      '该文件包含你的 API 密钥和仪表盘密码，因此已加密。没有此密码短语，备份将无法恢复。';

  @override
  String get the_last_turn_failed => '上一轮对话失败';

  @override
  String the_local_connection_store_looks_damaged_you_can_reset_the(
    Object errorType,
  ) {
    return '本地连接存储似乎已损坏 ($errorType)。你可以重置已保存的连接并重新开始。网关上的聊天记录不受影响。';
  }

  @override
  String get the_model_only_rewrites_your_question_into_a_short_full =>
      '该模型仅将你的问题重写为简短的全文查询。Hermes 使用已在主机上配置的提供方凭据。';

  @override
  String get the_server_has_not_reported_folders_for_this_project_yet =>
      '服务器尚未报告此项目的文件夹。全局文件仍可在“更多”中查看。';

  @override
  String get the_turn_failed => '本轮对话失败';

  @override
  String get the_two_passphrases_do_not_match => '两次输入的密码短语不匹配。';

  @override
  String get the_value_is_sent_directly_to_the_active_hermes_gateway =>
      '该值将直接发送至当前活动的 Hermes 网关，不会被此 Android 应用保存。';

  @override
  String get there_are_no_visible_files_in_this_server_folder =>
      '此服务器文件夹中没有可见文件。';

  @override
  String get thinking_effort => '思考强度';

  @override
  String get this_hermes_gateway_does_not_support_opening_a_project_yet =>
      '此 Hermes 网关尚不支持打开项目。请更新服务器上的 Hermes 以在手机上浏览项目。';

  @override
  String get this_hermes_gateway_is_older_than_server_side_projects_so =>
      '此 Hermes 网关版本旧于服务端项目功能，因此聊天仅在此设备上分组。请更新 Hermes 以在多台设备间共享相同项目。';

  @override
  String get this_project_has_no_folder_to_open_the_chat_in =>
      '此项目需要先添加文件夹才能在其中开始聊天。添加文件夹后请重试。';

  @override
  String get this_chat_has_no_messages_available_in_the_desktop_session =>
      '此聊天在 Desktop 会话中暂无可用消息。';

  @override
  String get this_creates_a_permanent_rule_in_hermes_review_the_full =>
      '这将在 Hermes 中创建永久规则。确认前请仔细检查完整命令。';

  @override
  String get this_gateway_does_not_host_projects_yet_update_the_gateway =>
      '此网关尚不支持托管项目。请更新网关以在各设备间整理聊天。';

  @override
  String get this_permanently_deletes_the_project_chats_will_not_be_deleted =>
      '这将永久删除该项目。聊天记录不会被删除；它们将返回至未分配状态。';

  @override
  String get this_server_doesn_t_offer_background_recovery_chats_run_live =>
      '此服务器不提供后台恢复功能 —— 聊天实时运行';

  @override
  String get this_week => '本周';

  @override
  String get titles_previews_and_models => '标题、预览与模型';

  @override
  String get tool_activity => '工具活动';

  @override
  String get trigger_now => '立即触发';

  @override
  String get received_outcome_unknown => '本轮对话已结束 — 结果未确认';

  @override
  String get turn_completed => '本轮对话已完成';

  @override
  String get turn_failed => '对话失败';

  @override
  String get turn_failed_description => '后台对话以错误结束。';

  @override
  String get turn_recovery_failed => '对话恢复失败';

  @override
  String get unable_to_prepare_this_file_try_another_one => '无法准备此文件，请尝试其他文件。';

  @override
  String get unable_to_prepare_this_image_try_another_one => '无法准备此图片，请尝试其他图片。';

  @override
  String unable_to_prepare(Object name) {
    return '无法准备 $name。';
  }

  @override
  String get unable_to_read_the_selected_image_the_selection_was_kept =>
      '无法读取所选图片，已保留当前选择。';

  @override
  String get unassigned => '未分配';

  @override
  String get unassigned_chats => '未分配的聊天';

  @override
  String get untitled_chat => '未命名聊天';

  @override
  String get untitled_session => '未命名会话';

  @override
  String get update_api_key => '更新 API 密钥';

  @override
  String get upload_failed => '上传失败';

  @override
  String get upload_failed_tap_retry => '上传失败 • 点击重试';

  @override
  String uploading(Object index, Object name, Object total) {
    return '正在上传 $index/$total：$name';
  }

  @override
  String get use_as_is => '直接使用';

  @override
  String get use_at_least_8_characters => '请使用至少 8 个字符。';

  @override
  String get use_for_cron_jobs_backed_by_scripts => '用于由脚本支持的 Cron 任务。';

  @override
  String get use_on_device => '使用设备端';

  @override
  String get use_the_attached_content_to_identify_and_fill_the_relevant =>
      '使用附件内容识别并填写相关文档或表单字段。提交任何内容前请先询问。';

  @override
  String use_this_content_to_identify_and_fill_the_relevant_document(
    Object text,
  ) {
    return '使用此内容识别并填写相关文档或表单字段。提交任何内容前请先询问：\n\n$text';
  }

  @override
  String get used_for_hosted_path_prefixes_and_for_the_settings_memory =>
      '用于托管路径前缀以及“设置”、“记忆”、“技能”和“Cron”标签页。若需开放仪表盘，可将用户名/密码留空；若反向代理已注入仪表盘认证，请启用代理模式。';

  @override
  String get username_optional => '用户名（可选）';

  @override
  String using(Object displayName) {
    return '正在使用 $displayName…';
  }

  @override
  String get verbose_mode => '详细模式';

  @override
  String get voice => '语音';

  @override
  String voice_setup_failed(Object error) {
    return '语音设置失败：$error';
  }

  @override
  String get waiting_for_your_input => '等待你的输入';

  @override
  String get what_hermes_knows_how_to_do => 'Hermes 能够做的事情';

  @override
  String get what_should_the_agent_do => '要让 Agent 做什么？';

  @override
  String get whatsapp_messages => 'WhatsApp 消息';

  @override
  String get which_project => '哪个项目？';

  @override
  String get workspace => '工作区';

  @override
  String get wrap_lines => '自动换行';

  @override
  String you_can_attach_up_to_items(Object maxRemoteAttachmentDrafts) {
    return '最多可附加 $maxRemoteAttachmentDrafts 个项目。';
  }

  @override
  String get your_answer => '你的回答';

  @override
  String get e_g_dashboard => '例如 /dashboard';

  @override
  String get e_g_dashboard_proxy_path_before_api =>
      '例如 /dashboard（/api/ 之前的代理路径）';

  @override
  String get e_g_profile_peter => '例如 /profile/peter';

  @override
  String get e_g_sol => '例如 sol';

  @override
  String get e_g_0_9_or_every_2h => '例如 0 9 * * * 或 every 2h';

  @override
  String get e_g_daily_backup => '例如每日备份';

  @override
  String downloaded(Object filename) {
    return '已下载 $filename';
  }

  @override
  String activity_name_status(Object displayName, Object statusLabel) {
    return '$displayName：$statusLabel';
  }

  @override
  String connection_status_label(Object connectionLabel, Object label) {
    return '$connectionLabel $label';
  }

  @override
  String get example_host_hint =>
      '192.168.1.50、100.x.y.z 或 hermes-machine.tailnet.ts.net';

  @override
  String get example_profile_prefix_hint_full =>
      '例如 /profile/peter（/api/ 和 /v1/ 之前的代理路径）';

  @override
  String and_more(Object count) {
    return '以及另外 $count 个';
  }

  @override
  String chats_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个聊天',
    );
    return '$_temp0';
  }

  @override
  String on_this_device_only(Object chats) {
    return '$chats · 仅在此设备上';
  }

  @override
  String spaces_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个空间',
    );
    return '$_temp0';
  }

  @override
  String get no_new_projects_needed => '无需创建新项目';

  @override
  String projects_to_create(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个项目待创建',
    );
    return '$_temp0';
  }

  @override
  String chats_migrated_projects_created(
    Object createdProjects,
    Object linkedSessions,
  ) {
    return '已迁移 $linkedSessions 个聊天 · 已创建 $createdProjects 个项目';
  }

  @override
  String chats_stayed_in_local_spaces(Object unlinkedSessions) {
    return '$unlinkedSessions 个聊天保留在本地空间中，可安全重试。';
  }

  @override
  String model_recommended(Object provider) {
    return '$provider • 推荐：小巧且经济';
  }

  @override
  String session_meta(Object count, Object model, Object time) {
    return '$count 条消息 • $model • $time';
  }

  @override
  String model_scope_label(Object model, Object scope) {
    return '$model • $scope';
  }

  @override
  String get this_chat => '此聊天';

  @override
  String get profile_default => '配置档案默认值';

  @override
  String minutes_ago(Object count) {
    return '$count 分钟前';
  }

  @override
  String hours_ago(Object count) {
    return '$count 小时前';
  }

  @override
  String days_ago(Object count) {
    return '$count 天前';
  }

  @override
  String get now_label => '刚刚';

  @override
  String get latest_label => '最新';

  @override
  String new_count_indicator(Object count) {
    return '$count 条新消息';
  }

  @override
  String new_messages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条新消息',
    );
    return '$_temp0';
  }

  @override
  String activity_failed_summary(Object failures, Object total) {
    return '$failures 个失败 • 共 $total 个';
  }

  @override
  String activity_completed_summary(Object count) {
    return '已完成 $count 个';
  }

  @override
  String tool_start_observed(Object time) {
    return '观察到开始 $time（本地时间）';
  }

  @override
  String tool_last_observed(Object time) {
    return '最后观察时间 $time（本地时间）';
  }

  @override
  String tool_result_recorded(Object time) {
    return '结果记录时间 $time（本地时间）';
  }

  @override
  String get tool_time_unavailable => '时间不可用';

  @override
  String get hermes_is_using_a_tool => 'Hermes 正在使用工具';

  @override
  String hermes_is_using_tools(Object count) {
    return 'Hermes 正在使用 $count 个工具';
  }

  @override
  String delegated_tasks_completed(Object count) {
    return '已完成 $count 个委派任务';
  }

  @override
  String delegated_tasks_active(Object count) {
    return '$count 个委派任务进行中';
  }

  @override
  String branch_main(Object label) {
    return '$label · main';
  }

  @override
  String get you_heading => '## 你';

  @override
  String get hermes_heading => '## Hermes';

  @override
  String get action_label => '操作';

  @override
  String get destination_label => '目标';

  @override
  String get markdown_source => '源文本';

  @override
  String get preview_label => '预览';

  @override
  String get share_action_summarize => '总结';

  @override
  String get share_action_explain => '解释';

  @override
  String get share_action_research => '研究';

  @override
  String get share_action_remember => '记住';

  @override
  String get text_size_small => '小';

  @override
  String get text_size_default => '默认';

  @override
  String get text_size_large => '大';

  @override
  String get text_size_extra_large => '特大';

  @override
  String get text_size_use_system_description => '完全使用 Android 辅助功能文字大小。';

  @override
  String text_size_percent_description(Object percent) {
    return 'Android 文字大小的 $percent%。';
  }

  @override
  String text_size_label_description(Object description, Object label) {
    return '$label — $description';
  }

  @override
  String files_skipped(Object count) {
    return '已跳过 $count 个文件：超出限制、大小超限、无法读取或文件名包含敏感信息。';
  }

  @override
  String model_scope_applied(Object effort, Object model) {
    return '$model • $effort 现仅应用于此聊天。';
  }

  @override
  String get reasoning_minimal => '极简';

  @override
  String get reasoning_low => '低';

  @override
  String get reasoning_medium => '中';

  @override
  String get reasoning_high => '高';

  @override
  String get reasoning_max => '最大';

  @override
  String get reasoning_ultra => '极致';

  @override
  String get status_running => '运行中';

  @override
  String get status_failed => '已失败';

  @override
  String get status_done => '完成';

  @override
  String get status_idle => '空闲';

  @override
  String get upload_status_uploading => '正在上传';

  @override
  String get upload_status_uploaded => '已上传';

  @override
  String attachment_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个附件',
    );
    return '$_temp0';
  }

  @override
  String get action_create => '创建';

  @override
  String get action_rename => '重命名';

  @override
  String get action_archive => '归档';

  @override
  String get action_restore => '恢复';

  @override
  String get action_delete => '删除';

  @override
  String get migrate => '迁移';

  @override
  String assigned_chats(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个已分配聊天',
    );
    return '$_temp0';
  }

  @override
  String get date_today => '今天';

  @override
  String get date_yesterday => '昨天';

  @override
  String get date_earlier => '更早';

  @override
  String get nav_home => '主页';

  @override
  String get nav_more => '更多';

  @override
  String get status_completed => '已完成';

  @override
  String get filter_all => '全部';

  @override
  String get filter_recent => '最近';

  @override
  String connection_address_key(Object address, Object status) {
    return '$address  •  密钥：$status';
  }

  @override
  String model_via_provider(Object model, Object provider) {
    return '$model  \n通过 `$provider`';
  }

  @override
  String get deny => '拒绝';

  @override
  String get connect => '连接';

  @override
  String get appearance => '外观';

  @override
  String get connection_section => '连接';

  @override
  String get about => '关于';

  @override
  String version_label(Object version) {
    return '版本 $version';
  }

  @override
  String get matched => '已匹配';

  @override
  String get search => '搜索';

  @override
  String get on => '开';

  @override
  String get off => '关';

  @override
  String get reasoning_off => '关';

  @override
  String get hermes_response_ready => 'Hermes 回复已就绪';

  @override
  String get admin_password_needed => '需要管理员密码';

  @override
  String get hermes_needs_a_sudo_password_for_the_pending_terminal_command =>
      'Hermes 需要 sudo 密码来执行挂起的终端命令。';

  @override
  String get sudo_password => 'sudo 密码';

  @override
  String get secret_needed => '需要密钥';

  @override
  String get hermes_needs_a_secret_for_the_pending_skill =>
      'Hermes 需要为待处理的技能提供一个密钥。';

  @override
  String get secret_value => '密钥值';

  @override
  String get attached_file => '已附加文件';

  @override
  String get pin_chat => '置顶聊天';

  @override
  String get unpin_chat => '取消置顶';

  @override
  String get pinned_chats => '已置顶';

  @override
  String could_not_update_chat_pin(Object error) {
    return '无法更新聊天置顶：$error';
  }

  @override
  String get could_not_save_chat_spaces => '无法在此设备上保存聊天空间';

  @override
  String get update_available => '有可用更新';

  @override
  String get update_now => 'Update now';

  @override
  String get update_install => 'Install update';

  @override
  String get update_downloading => 'Downloading and verifying update…';

  @override
  String get update_allow_install =>
      'Allow Hermes to install this update, then return here and tap Install update.';

  @override
  String get update_failed =>
      'The update could not be downloaded, verified, or opened. Try again or view the release page.';

  @override
  String get a_newer_hermes_android_build_is_available_on_github =>
      'GitHub 上已有更新的 Ares 版本。';

  @override
  String get release_notes => '发行说明';

  @override
  String get view_release => '查看发行版';

  @override
  String get skip_this_version => '跳过此版本';

  @override
  String get later => '稍后';

  @override
  String get check_for_updates => '检查更新';

  @override
  String get check_for_updates_on_launch => '启动时检查更新';

  @override
  String get you_re_on_the_latest_version => '已是最新版本。';

  @override
  String get couldn_t_check_for_updates => '无法检查更新。';

  @override
  String get chat_density => '聊天密度';

  @override
  String chat_density_2(Object label) {
    return '聊天密度：$label';
  }

  @override
  String get chat_density_comfortable => '舒适';

  @override
  String get chat_density_compact => '紧凑';

  @override
  String get chat_density_comfortable_description => '每条消息上方带有发送者标签的更宽松气泡。';

  @override
  String get chat_density_compact_description => '更紧凑的无标签气泡，屏幕上可以显示更多消息。';

  @override
  String chat_density_label_description(Object description, Object label) {
    return '$label — $description';
  }

  @override
  String
  get compact_removes_the_you_and_hermes_labels_and_trims_bubble_padding_spacing_and_side_margins =>
      '紧凑模式会去掉 You 和 Hermes 标签，并缩小气泡内边距、间距和两侧边距。';

  @override
  String get background_work => '后台运行';

  @override
  String get keep_chats_active_in_background => '在后台保持聊天连接';

  @override
  String get background_work_description =>
      '应用在后台时，保持用户发起的聊天连接。空闲连接可能会断开。此功能会增加电量和流量消耗。关闭后不会停止服务器上的任务。';

  @override
  String get background_work_limits =>
      'Android 仍可能在 Doze 模式下暂停连接或结束应用进程。进程结束后的通知需要单独设置推送。不支持强行停止后的通知。';

  @override
  String get background_work_disclosure => '后台保护开启时，即使关闭了可选的聊天通知，仍会显示必需的服务通知。';

  @override
  String get battery_optimisation_settings => '电池优化设置';

  @override
  String get battery_optimisation_description =>
      '打开 Android 设置以查看电池限制。不会自动申请豁免，更改设置也不能保证通知送达。';

  @override
  String get battery_settings_unavailable => '无法在此设备上打开电池设置。';

  @override
  String get background_work_save_failed => '无法保存后台运行设置。';

  @override
  String get ongoing_chat_channel_name => '进行中的聊天';

  @override
  String get ongoing_chat_channel_description => '用户发起的未完成聊天的静默状态更新';

  @override
  String get task_timeline => 'Task timeline';

  @override
  String get task_refresh_history => 'Refresh task history';

  @override
  String get task_live_preview => 'Live preview from parent events';

  @override
  String get task_preview_explanation =>
      'Latest exposed preview only; not a recorded transcript row.';

  @override
  String get task_preview => 'Preview';

  @override
  String get task_recorded_history => 'Recorded task history';

  @override
  String get task_loading_history => 'Loading task history…';

  @override
  String get task_empty_history =>
      'No recorded messages yet. The task may not have flushed its history; this does not mean it produced no work.';

  @override
  String get task_load_older => 'Load older';

  @override
  String get task_default_goal => 'Delegated task';

  @override
  String task_status(Object status) {
    return 'Status: $status';
  }

  @override
  String task_identity(Object id) {
    return 'Task: $id';
  }

  @override
  String task_stored_session(Object id) {
    return 'Stored session: $id';
  }

  @override
  String task_delegation(Object id) {
    return 'Delegation: $id';
  }

  @override
  String get task_read_only_notice =>
      'Read-only · recorded history may appear after the task flushes. Refresh to check again.';

  @override
  String task_row_label(Object id, Object role) {
    return '$role · row $id';
  }

  @override
  String get task_role_assistant => 'Assistant';

  @override
  String get task_role_user => 'User';

  @override
  String get task_role_tool => 'Tool';

  @override
  String task_tool_call(Object name) {
    return 'Tool call · $name';
  }

  @override
  String task_tool_result(Object name) {
    return 'Tool result · $name';
  }

  @override
  String task_call_details(Object arguments, Object id) {
    return 'Call ID: $id\nArguments\n$arguments';
  }

  @override
  String task_result_details(Object id, Object result) {
    return 'Call ID: $id\nResult\n$result';
  }

  @override
  String get task_not_supplied => 'Not supplied';

  @override
  String get task_missing_arguments => 'Arguments not retained by the server.';

  @override
  String get task_image_placeholder => '[image]';

  @override
  String get task_invalid_reference =>
      'Task transcript unavailable: invalid stored session reference.';

  @override
  String get task_auth_required =>
      'Task transcript unavailable: configure Dashboard authentication for this gateway. The API-server key cannot read task reasoning.';

  @override
  String get task_auth_rejected =>
      'Task transcript unavailable: Dashboard authentication was rejected. Check this gateway’s Dashboard settings.';

  @override
  String get task_incompatible_history =>
      'Task transcript unavailable: this Dashboard does not provide compatible bounded raw history for the selected profile.';

  @override
  String get task_identity_unproven =>
      'Task transcript unavailable: the Dashboard could not prove the exact stored session or its compression lineage. No transcript from another session is shown.';

  @override
  String get task_partial_compression =>
      'Partial history: this task continued after compression, but this gateway has not exposed a verifiable newer reference. The final reply may be missing. Automatic refresh is paused; use Refresh to retry.';

  @override
  String get task_partial_ancestors =>
      'Partial history: this gateway omits compression ancestors for this task. Earlier task segments may be missing. Known rows are retained; use Refresh to retry.';

  @override
  String get task_missing_reference =>
      'Task transcript unavailable: this server did not retain its session reference.';

  @override
  String get task_missing_row_identity =>
      'Task transcript unavailable: this server did not supply durable message row identities.';

  @override
  String get task_history_not_ready =>
      'Task history is not available yet (HTTP 404). The task may not have flushed, or this Dashboard may not support task history. Retry to check again.';

  @override
  String get task_refresh_failed =>
      'Could not refresh task history. Check the connection and retry.';

  @override
  String get task_status_interrupted => 'Interrupted';

  @override
  String get task_status_cancelled => 'Cancelled';

  @override
  String get task_status_requested => 'Requested';

  @override
  String get task_status_thinking => 'Thinking';

  @override
  String get task_status_tool => 'Using a tool';

  @override
  String get task_status_pending => 'Pending';

  @override
  String get task_status_dispatched => 'Dispatched';

  @override
  String task_status_unknown(Object status) {
    return 'Unknown status: $status';
  }

  @override
  String task_tasks_finished(Object count) {
    return '$count delegated task(s) finished';
  }

  @override
  String get activity_status_unconfirmed => '状态未确认';

  @override
  String get activity_recently_updated => '最近更新';

  @override
  String get activity_reconnecting => '正在重新连接 — 正在检查轮次状态';

  @override
  String get activity_outcome_unknown => '无法确认本轮对话的结果。请打开聊天查看。';

  @override
  String get activity_chat_updated_detail => '网关已记录聊天活动；无法获取轮次的实时状态。';

  @override
  String get activity_updated => '已更新';

  @override
  String get activity_empty_title => '暂无近期活动';

  @override
  String get activity_empty_detail => '在此应用中启动的轮次，以及过去7天内更新的网关聊天都会显示在这里。';

  @override
  String get activity_read_error => '活动功能无法读取轮次记录或网关聊天。请检查连接后重试。';

  @override
  String get activity_chat_unavailable => '此聊天已不可用，或无法连接到网关。';

  @override
  String get activity_partial_title => '活动已部分加载';

  @override
  String get activity_partial_detail => '目前仅显示网关活动的有限范围。可能还有更多聊天，请下拉刷新。';

  @override
  String get provider_usage => '使用记录';

  @override
  String get provider_usage_notice =>
      'Hermes最近30天的使用量，并非账户余额或模型定价。请在Hermes服务器配置凭据；此应用不保存提供商API密钥。';

  @override
  String get provider_usage_failed => '无法加载使用记录。';

  @override
  String get provider_usage_empty => '此提供商暂无使用记录。';

  @override
  String provider_usage_counts(String sessions, String input, String output) {
    return '$sessions 个会话 · 输入：$input · 输出：$output';
  }

  @override
  String provider_usage_costs(String estimated, String actual) {
    return '估算：$estimated · 报告：$actual';
  }

  @override
  String get provider_quota_codex => 'OpenAI Codex 订阅';

  @override
  String get provider_quota_claude => 'Claude 订阅';

  @override
  String get provider_quota_openai_api => 'OpenAI API 已记录用量';

  @override
  String get provider_quota_notice =>
      '由提供商报告的订阅用量周期，与 Hermes 记录的用量及 API 计费分开显示。各账户单独列出；达到模型限额并不代表整个账户的配额已耗尽。';

  @override
  String get provider_quota_windows_notice =>
      'Codex 和 Claude 订阅设有五小时会话限额和每周限额。仅显示提供商报告的周期；未报告的限额和重置时间仍不可用。每周限额可能适用于整个账户或特定模型。';

  @override
  String get provider_quota_five_hour_session => '5小时会话';

  @override
  String get provider_quota_unavailable => '订阅配额不可用。';

  @override
  String get provider_quota_failed => '无法刷新订阅配额。保留的数值来自上次查询。';

  @override
  String get provider_quota_account => '账户';

  @override
  String get provider_quota_unknown => '未知';

  @override
  String provider_quota_state(String state) {
    return '账户状态：$state';
  }

  @override
  String provider_quota_scope(String scope) {
    return '适用范围：$scope';
  }

  @override
  String provider_quota_percent(String used, String remaining) {
    return '已用 $used% · 剩余 $remaining%';
  }

  @override
  String provider_quota_reset(String reset) {
    return '重置时间：$reset';
  }

  @override
  String get provider_quota_reset_unknown => '重置时间不可用。';

  @override
  String get auxiliary_models => '辅助模型';

  @override
  String get auxiliary_notice => '为各任务选择模型。自定义端点必须在服务器管理。自动模式遵循任务的继承规则。';

  @override
  String get auxiliary_inherit => '自动（继承）';

  @override
  String get auxiliary_unavailable => '辅助设置不可用。';

  @override
  String get provider_oauth_title => '提供商登录';

  @override
  String get provider_oauth_more_subtitle => '管理 Hermes 主机上的提供商登录';

  @override
  String get provider_oauth_settings_subtitle =>
      '在 Hermes 主机上登录；提供商令牌不会保存在此设备上';

  @override
  String get provider_oauth_intro =>
      '在外部浏览器中登录提供商。令牌仅存储在 Hermes 主机上，不会保存在此设备上。登录不会选择此应用中的聊天模型。';

  @override
  String get provider_oauth_defaults_notice =>
      '某些主机流程（包括替换 Nous 免费套餐账户）可能会更新主机默认设置。登录后请检查主机设置。';

  @override
  String get provider_oauth_transport_init_failed =>
      '无法初始化所选的安全仪表板连接。请检查其 TLS 身份和连接设置。';

  @override
  String get provider_oauth_https_required => '提供商登录需要通过 HTTPS 连接到 Hermes 仪表板。';

  @override
  String get provider_oauth_auth_required => '登录前请配置仪表板密码验证或可信代理。';

  @override
  String get provider_oauth_catalog_failed =>
      '此主机不支持提供商登录。请检查仪表板身份验证；如果主机不支持提供商 OAuth，请更新主机。';

  @override
  String get provider_oauth_expired => '登录已过期。请重新开始。';

  @override
  String get provider_oauth_start_failed => '无法启动安全的提供商登录。请重试。';

  @override
  String get provider_oauth_denied => '登录被拒绝。请重新开始。';

  @override
  String get provider_oauth_cancelled => '登录已取消。';

  @override
  String get provider_oauth_host_failed => '主机无法完成登录。请重新开始。';

  @override
  String get provider_oauth_poll_failed => '无法检查登录状态。请重新开始。';

  @override
  String provider_oauth_cancellation_unconfirmed(String message) {
    return '$message 无法确认取消；主机会话可能会持续到过期为止。';
  }

  @override
  String get provider_oauth_browser_failed => '无法打开外部浏览器。请重试或取消登录。';

  @override
  String get provider_oauth_retry => '重试';

  @override
  String provider_oauth_complete(String provider) {
    return '完成 $provider 的登录';
  }

  @override
  String get provider_oauth_code_instruction => '请在提供商页面输入此临时代码：';

  @override
  String get provider_oauth_waiting => '正在等待批准。此会话将自动过期。';

  @override
  String get provider_oauth_open_browser => '在浏览器中打开提供商';

  @override
  String get provider_oauth_cancel => '取消登录';

  @override
  String get provider_oauth_signed_out => '未在主机上登录';

  @override
  String get provider_oauth_sign_in_again => '重新登录';

  @override
  String get provider_oauth_sign_in => '登录';

  @override
  String get provider_oauth_cli_required =>
      '请在 Hermes 主机上使用提供商 CLI 登录。此主机不支持该提供商的应用内登录。';

  @override
  String get provider_oauth_checking_account => '已收到授权。正在检查主机账户…';

  @override
  String get provider_oauth_verification_unavailable =>
      '已收到授权；无法验证账户。请打开用量页面以刷新账户用量。';

  @override
  String provider_oauth_verified_account(String email) {
    return '已在 Hermes 主机上以 $email 登录。请打开用量页面以刷新账户用量。';
  }

  @override
  String get provider_oauth_credentials_unverified => '主机报告凭据可用；账户身份尚未验证。';

  @override
  String get provider_oauth_account_status_unknown => '无法获取主机账户状态。';

  @override
  String get projects_root_title => '服务器上的项目文件夹';

  @override
  String get projects_root_more_subtitle => '服务器上新建项目文件夹的位置';

  @override
  String get projects_root_description =>
      '在此手机上创建的项目会在这里获得文件夹。将其指向 Hermes 自身使用的文件夹，手机和服务器就能共享同一批项目。';

  @override
  String get projects_root_label => '项目根路径';

  @override
  String projects_root_default_hint(String path) {
    return '服务器默认值：$path';
  }

  @override
  String get projects_root_locked_title => '由服务器设定';

  @override
  String get projects_root_locked_explanation =>
      '此服务器将文件访问限制在单一根目录内，因此无法在应用中更改项目文件夹。';

  @override
  String get projects_root_saved => '已保存项目文件夹。';

  @override
  String get projects_root_reset => '使用服务器默认值';

  @override
  String get projects_root_invalid_empty => '请输入文件夹路径。';

  @override
  String get projects_root_invalid_absolute => '请输入以斜杠开头的绝对路径。';

  @override
  String get projects_root_invalid_segments => '请从路径中移除点号片段和控制字符。';

  @override
  String get projects_root_unsupported =>
      '此连接不支持。读取或更改服务器上的项目文件夹需要具有仪表板访问权限的 Desktop Gateway 连接。';

  @override
  String get projects_root_unavailable => '无法读取服务器上的项目文件夹。请检查仪表板连接后重试。';

  @override
  String get adopt_folder_action => '添加现有文件夹';

  @override
  String adopt_folder_description(String root) {
    return '$root 下尚未注册为项目的文件夹。';
  }

  @override
  String adopt_folder_registered(String name) {
    return '已是项目：$name';
  }

  @override
  String get adopt_folder_none => '此路径下的所有文件夹都已是项目。';

  @override
  String get adopt_folder_unsupported => '此连接无法列出服务器文件夹。请改为输入现有文件夹的绝对路径。';

  @override
  String adopt_folder_failed(String error) {
    return '无法列出服务器文件夹：$error';
  }

  @override
  String get adopt_folder_manual_label => '现有文件夹路径';

  @override
  String get adopt_folder_name_label => '项目名称';

  @override
  String get adopt_folder_add => '添加为项目';

  @override
  String adopt_folder_added(String name, String path) {
    return '$name 现在使用 $path';
  }

  @override
  String adopt_folder_error(String error) {
    return '无法添加该文件夹：$error';
  }

  @override
  String adopt_folder_folderless(String name) {
    return '已创建 $name，但未关联文件夹。请在服务器上的 Hermes 中关联。';
  }

  @override
  String get slash_commands => 'Slash commands';

  @override
  String get slash_commands_loading => 'Loading commands…';

  @override
  String get slash_commands_empty => 'No matching commands';

  @override
  String slash_command_info_alias(String alias, String command) {
    return '$alias 是 $command 的别名';
  }

  @override
  String get slash_command_info_no_description => '暂无说明。';

  @override
  String get slash_command_info_arguments_options => '接受固定选项中的一个。';

  @override
  String get slash_command_info_arguments_text => '在命令后接受文本。';

  @override
  String get slash_command_info_arguments_mixed => '在命令后接受选项或文本。';

  @override
  String get slash_command_output => 'Command output';

  @override
  String get slash_command_no_output => 'The command completed with no output.';

  @override
  String get slash_command_delivery_unknown =>
      'The command was sent but its reply never arrived. It may still be running on the gateway, so your draft was kept. Check the gateway before retrying.';

  @override
  String get slash_command_failed => 'The command could not be run.';

  @override
  String get slash_command_unsupported => '此命令在此服务器上不可用。';

  @override
  String get slash_sessions_inline => '请打开会话列表选择聊天。草稿已保留。';

  @override
  String get composer_failure_switch_no_retry =>
      '切换只会更改模型：此连接无法重新运行失败的轮次。切换后请重新发送。';

  @override
  String get nextgen_toggle => 'NextGen 界面';

  @override
  String get nextgen_toggle_subtitle => '全新设计：一次登录、实时聊天和网络发现。你的网关和聊天与此界面共享。';

  @override
  String get nextgen_single_login => '使用单一登录';

  @override
  String get nextgen_single_login_subtitle => '只需仪表板地址和一次登录即可添加网关。';

  @override
  String get ng_allow_this_command => '允许执行此命令？';

  @override
  String ng_hermes_wants_to_run_this_with(Object tool) {
    return 'Hermes 想使用 $tool 执行此操作。';
  }

  @override
  String get ng_hermes_wants_to_run_this => 'Hermes 想执行此操作。';

  @override
  String get ng_hermes_has_a_question => 'Hermes 有一个问题';

  @override
  String get ng_hermes_has_questions => 'Hermes 有几个问题';

  @override
  String get ng_password_for_sudo => 'sudo 密码';

  @override
  String get ng_hermes_needs_your_sudo_password_to =>
      'Hermes 需要你的 sudo 密码来运行此命令。';

  @override
  String get ng_a_secret_value => '机密值';

  @override
  String ng_value_for(Object variable) {
    return '$variable 的值';
  }

  @override
  String get ng_your_password_manager => '你的密码管理器';

  @override
  String ng_unlock(Object name) {
    return '解锁 $name';
  }

  @override
  String ng_hermes_needs_unlocked_to_sign_in(Object name) {
    return 'Hermes 需要先解锁 $name，才能为你登录。';
  }

  @override
  String get ng_sign_in_code => '登录验证码';

  @override
  String get ng_enter_the_sign_in_code => '输入登录验证码。';

  @override
  String ng_enter_the_sign_in_code_for(Object site) {
    return '输入 $site 的登录验证码。';
  }

  @override
  String get ng_save_a_login => '保存登录信息？';

  @override
  String ng_save_your_login(Object site) {
    return '保存你的 $site 登录信息？';
  }

  @override
  String ng_couldn_t_load_this_chat(Object error) {
    return '无法加载此聊天：$error';
  }

  @override
  String ng_live_updates_are_unavailable(Object error) {
    return '实时更新不可用：$error';
  }

  @override
  String ng_preparing(Object name) {
    return '正在准备 $name…';
  }

  @override
  String get ng_the_turn_failed => '本轮对话失败。';

  @override
  String get ng_turn_changed => '该轮对话已结束或已开始新一轮';

  @override
  String get ng_steer_rejected => '正在进行的对话未接受此内容';

  @override
  String get ng_turn_not_known_yet => '尚不清楚正在进行的对话；请稍后再试';

  @override
  String ng_couldn_t_stop(Object error) {
    return '无法停止：$error';
  }

  @override
  String get ng_server_access => '服务器访问';

  @override
  String get ng_sign_in => '登录';

  @override
  String get ng_live_connection => '实时连接';

  @override
  String get ng_check_that_tailscale_is_on_on => '请确认此手机和服务器上的 Tailscale 均已开启。';

  @override
  String get ng_check_the_address_and_that_the => '请检查地址，并确认代理已转发到仪表盘。';

  @override
  String get ng_use_the_same_network_as_the =>
      '请使用与服务器相同的网络，并使用 --host 0.0.0.0 启动仪表盘，以便其他设备访问。';

  @override
  String get ng_check_the_address_vpn_or_tailscale =>
      '请检查地址、VPN 或 Tailscale 连接。';

  @override
  String get ng_not_checked_yet => '尚未检查。';

  @override
  String get ng_checking => '正在检查…';

  @override
  String ng_hermes_answers_at(Object version, Object address) {
    return 'Hermes $version 可通过 $address 访问。';
  }

  @override
  String get ng_something_answered_but_not_a_hermes => '有服务响应，但不是 Hermes 仪表盘。';

  @override
  String ng_something_answered_http_but_not_a(Object status) {
    return '有服务响应（HTTP $status），但不是 Hermes 仪表盘。';
  }

  @override
  String get ng_use_the_dashboard_s_address_and =>
      '请使用仪表盘的地址和端口（默认为 9119），而不是 API 服务器的地址和端口。';

  @override
  String get ng_cloudflare_access_turned_the_service_token =>
      'Cloudflare Access 拒绝了服务令牌。';

  @override
  String get ng_cloudflare_access_is_in_front_of =>
      '此地址前方配置了 Cloudflare Access。';

  @override
  String get ng_check_the_service_token_and_its => '请检查服务令牌及其 Service Auth 策略。';

  @override
  String get ng_add_a_cloudflare_access_service_token =>
      '为此地址添加 Cloudflare Access 服务令牌。';

  @override
  String get ng_the_server_asks_for_a_client => '服务器要求提供客户端证书。';

  @override
  String get ng_pick_the_client_certificate_for_this => '为此网关选择客户端证书，然后再次测试。';

  @override
  String get ng_needs_server_access_first => '请先连接服务器。';

  @override
  String get ng_needs_a_sign_in_first => '请先登录。';

  @override
  String ng_signed_in_as(Object name) {
    return '已登录为 $name。';
  }

  @override
  String get ng_this_dashboard_doesn_t_need_a => '此仪表盘无需登录。';

  @override
  String get ng_the_saved_sign_in_has_expired => '已保存的登录信息已过期。';

  @override
  String get ng_sign_in_again => '重新登录。';

  @override
  String get ng_too_many_sign_in_attempts => '登录尝试次数过多。';

  @override
  String get ng_wait_a_minute_then_check_again => '请稍等一分钟后再试。';

  @override
  String ng_the_gateway_answered(Object message) {
    return '网关返回：$message。';
  }

  @override
  String get ng_sign_in_again_or_update_hermes => '请重新登录，或更新 Hermes。';

  @override
  String ng_couldn_t_check_the_sign_in(Object error) {
    return '无法检查登录状态：$error';
  }

  @override
  String ng_the_gateway_wouldn_t_issue_a(Object message) {
    return '网关无法签发聊天凭证（$message）。';
  }

  @override
  String get ng_the_chat_connection_opened_and_the => '聊天连接已建立，网关已确认就绪。';

  @override
  String get ng_the_gateway_never_said_it_was => '网关始终未确认就绪。';

  @override
  String get ng_check_that_the_agent_is_running => '请确认服务器上的代理正在运行。';

  @override
  String get ng_the_gateway_refused_the_chat_connection =>
      '网关拒绝了聊天连接（HTTP 403）。';

  @override
  String get ng_this_dashboard_has_no_chat_endpoint => '此仪表盘没有聊天端点（/api/ws）。';

  @override
  String ng_the_chat_connection_failed(Object detail) {
    return '聊天连接失败：$detail';
  }

  @override
  String get ng_use_the_exact_address_the_dashboard => '请使用仪表盘配置的完整地址。';

  @override
  String get ng_update_hermes => '更新 Hermes。';

  @override
  String get ng_make_sure_the_proxy_allows_websocket =>
      '请确认代理允许在 /api/ws 上进行 WebSocket 升级。';

  @override
  String get ng_offline => '离线';

  @override
  String get ng_connecting => '正在连接…';

  @override
  String get ng_connected => '已连接';

  @override
  String get ng_reconnecting => '正在重新连接…';

  @override
  String get ng_signed_out => '已退出登录';

  @override
  String get ng_connection_failed => '连接失败';

  @override
  String get ng_rate_limited_by_gateway => '已触发网关限流';

  @override
  String ng_couldn_t_open_the_chat_connection(Object message) {
    return '无法建立聊天连接：$message';
  }

  @override
  String get ng_the_gateway_returned_no_websocket_ticket =>
      '网关未返回 WebSocket 票据。';

  @override
  String get ng_connection_lost => '连接已断开';

  @override
  String get ng_this_dashboard_has_no_chat_endpoint_2 =>
      '此仪表板没有聊天端点（/api/ws）。请更新 Hermes。';

  @override
  String get ng_the_gateway_refused_the_chat_connection_2 =>
      '网关拒绝了聊天连接。请检查地址是否与仪表板配置的主机匹配，并确认已启用嵌入式聊天。';

  @override
  String ng_the_gateway_refused(Object method) {
    return '网关拒绝了 $method。';
  }

  @override
  String ng_couldn_t_read_your_saved_gateways(Object error) {
    return '无法读取已保存的网关：$error';
  }

  @override
  String get ng_applies_to_new_chats => '仅应用于新聊天';

  @override
  String ng_couldn_t_change(Object label, Object error) {
    return '无法更改$label：$error';
  }

  @override
  String get ng_capabilities => '功能';

  @override
  String get ng_skills => '技能';

  @override
  String get ng_toolsets => '工具集';

  @override
  String get ng_search => '搜索';

  @override
  String get ng_couldn_t_load => '无法加载';

  @override
  String get ng_try_again => '重试';

  @override
  String get ng_no_skills => '没有技能';

  @override
  String get ng_no_toolsets => '没有工具集';

  @override
  String get ng_no_mcp_servers => '没有 MCP 服务器';

  @override
  String get ng_that_file_is_too_large_to => '该文件太大，无法作为证书使用。';

  @override
  String ng_the_certificate_couldn_t_be_imported(Object error) {
    return '无法导入证书：$error';
  }

  @override
  String get ng_now_pick_its_private_key => '现在选择对应的私钥。';

  @override
  String get ng_now_pick_its_certificate => '现在选择对应的证书。';

  @override
  String get ng_that_file_isn_t_a_certificate => '该文件不是证书或私钥。';

  @override
  String get ng_if_a_proxy_in_front_of =>
      '如果此地址前的代理要求客户端证书，请在此选择证书，以便测试、登录和聊天时都能出示。';

  @override
  String get ng_client_certificates_are_only_used_with =>
      '客户端证书仅用于 https:// 地址。';

  @override
  String get ng_remove => '移除';

  @override
  String get ng_certificate_password => '证书密码';

  @override
  String get ng_importing => '正在导入…';

  @override
  String get ng_pick_certificate => '选择证书';

  @override
  String get ng_pick_a_different_certificate => '选择其他证书';

  @override
  String get ng_accepts_p12_pfx_or_pem_certificate =>
      '支持 .p12/.pfx 文件，或 PEM 证书和密钥文件。密钥会保存在此应用的私有存储空间中。';

  @override
  String get ng_photos => '照片';

  @override
  String get ng_camera => '相机';

  @override
  String get ng_files => '文件';

  @override
  String ng_you_can_attach_up_to_files(Object count) {
    return '最多可附加 $count 个文件。';
  }

  @override
  String ng_couldn_t_read(Object name) {
    return '无法读取 $name。';
  }

  @override
  String ng_couldn_t_prepare_that_file(Object error) {
    return '无法处理该文件：$error';
  }

  @override
  String get ng_hermes_is_still_working => 'Hermes 仍在处理中';

  @override
  String get ng_steer => '引导';

  @override
  String get ng_adds_this_to_the_running_turn => '在当前轮次的下一步中添加此内容';

  @override
  String get ng_queue => '排队';

  @override
  String get ng_sends_it_when_the_turn_finishes => '当前轮次结束后发送';

  @override
  String get ng_stop_and_send => '停止并发送';

  @override
  String get ng_stops_the_turn_then_sends_this => '停止当前轮次，然后发送此内容';

  @override
  String ng_dictation_stopped(Object message) {
    return '听写已停止：$message';
  }

  @override
  String get ng_speech_recognition_isn_t_available => '语音识别不可用。';

  @override
  String get ng_working => '处理中';

  @override
  String get ng_ready => '就绪';

  @override
  String get ng_chats => '聊天';

  @override
  String get ng_new_chat => '新建聊天';

  @override
  String get ng_usage => '用量';

  @override
  String get ng_rename_chat => '重命名聊天';

  @override
  String ng_couldn_t_rename(Object error) {
    return '无法重命名：$error';
  }

  @override
  String get ng_this_chat => '此聊天';

  @override
  String get ng_input_tokens => '输入 Token';

  @override
  String get ng_output_tokens => '输出 Token';

  @override
  String get ng_reasoning_tokens => '推理 Token';

  @override
  String get ng_cache_reads => '缓存读取';

  @override
  String get ng_api_calls => 'API 调用';

  @override
  String get ng_cost => '费用';

  @override
  String get ng_context => '上下文';

  @override
  String get ng_your_sign_in_expired => '登录已过期。';

  @override
  String get ng_sign_in_2 => '登录';

  @override
  String get ng_retry => '重试';

  @override
  String get ng_project_home => '主页';

  @override
  String get ng_choose_project => '选择项目';

  @override
  String ng_project_cwd_fallback(String path) {
    return '项目文件夹不可用，因此此聊天在 $path 中运行。';
  }

  @override
  String get ng_project_create_uncertain =>
      '网关可能已创建此聊天，但未确认。开始新聊天前请检查聊天列表；此请求不会自动重试。';

  @override
  String get ng_what_should_we_work_on => '我们要做些什么？';

  @override
  String get ng_ask_hermes_anything_it_can_run =>
      '向 Hermes 提问。它可以运行工具、浏览网页，还能处理服务器上的文件。';

  @override
  String ng_working_2(Object frame) {
    return '正在处理 · $frame';
  }

  @override
  String get ng_default_model => '默认模型';

  @override
  String get ng_listening => '正在聆听…';

  @override
  String get ng_steer_or_queue_a_message => '发送指示或排队发送消息';

  @override
  String get ng_message_hermes => '给 Hermes 发消息';

  @override
  String get ng_attach => '添加附件';

  @override
  String get ng_stop_dictation => '停止听写';

  @override
  String get ng_dictate => '语音输入';

  @override
  String get ng_stop => '停止';

  @override
  String get ng_send => '发送';

  @override
  String ng_slash_command_alias(String alias, String command) {
    return '$alias 是 $command 的别名';
  }

  @override
  String get ng_slash_command_no_description => '暂无说明。';

  @override
  String get ng_slash_command_arguments_options => '接受固定选项中的一个。';

  @override
  String get ng_slash_command_arguments_text => '在命令后接受文本。';

  @override
  String get ng_slash_command_arguments_mixed => '在命令后接受选项或文本。';

  @override
  String get ng_slash_command_sent_as_message =>
      'NextGen 会将此作为普通消息发送给 Hermes，不会执行该命令。';

  @override
  String get ng_slash_command_output => '命令输出';

  @override
  String get ng_slash_command_running => '正在运行命令…';

  @override
  String get ng_slash_command_done => '完成。';

  @override
  String ng_slash_command_failed(Object error) {
    return '无法运行命令：$error';
  }

  @override
  String get ng_slash_command_refused => 'Hermes 无法在此运行此命令。';

  @override
  String get ng_slash_command_delivery_unknown =>
      '命令已发送，但未收到回复。它可能仍在网关上运行，因此没有重新发送，并保留了你的草稿。';

  @override
  String get ng_slash_command_nothing_running => '当前没有正在运行的任务。';

  @override
  String get ng_steered => '已调整指示';

  @override
  String get ng_copied => '已复制';

  @override
  String ng_not_sent(Object reason) {
    return '未发送：$reason';
  }

  @override
  String get ng_thinking => '正在思考…';

  @override
  String get ng_thought => '思考';

  @override
  String ng_used(Object name) {
    return '已使用 $name';
  }

  @override
  String ng_used_tools(Object count) {
    return '已使用 $count 个工具';
  }

  @override
  String get ng_copy => '复制';

  @override
  String get ng_read_aloud => '朗读';

  @override
  String get ng_the_gateway_connection_dropped_try_again => '网关连接已断开，请重试。';

  @override
  String get ng_allow_once => '允许一次';

  @override
  String get ng_allow_until_sandbox_off => '直到关闭沙盒';

  @override
  String get ng_folder_access => '文件夹访问';

  @override
  String get ng_folder_access_unspecified => '网关未说明是只读还是可读写。';

  @override
  String get ng_folder_read_only => '只读';

  @override
  String get ng_folder_read_write => '可读写';

  @override
  String get ng_website_access => '网站访问';

  @override
  String get ng_allow_for_this_chat => '在此聊天中允许';

  @override
  String get ng_always_allow => '始终允许';

  @override
  String get ng_deny => '拒绝';

  @override
  String get ng_your_answer => '你的回答';

  @override
  String get ng_or_type_an_answer => '或输入回答';

  @override
  String get ng_skip => '跳过';

  @override
  String get ng_answer => '回答';

  @override
  String get ng_cancel => '取消';

  @override
  String get ng_username_or_email => '用户名或邮箱';

  @override
  String get ng_password => '密码';

  @override
  String get ng_not_now => '暂不';

  @override
  String get ng_save => '保存';

  @override
  String get ng_enter_both_the_client_id_and =>
      '请同时填写 Client ID 和 Client Secret，或都留空。';

  @override
  String get ng_enter_your_username_and_password => '请输入用户名和密码。';

  @override
  String ng_couldn_t_save_the_sign_in(Object error) {
    return '无法保存登录信息：$error';
  }

  @override
  String get ng_wrong_username_or_password => '用户名或密码错误。';

  @override
  String get ng_too_many_attempts_wait_a_moment => '尝试次数过多，请稍等片刻再试。';

  @override
  String get ng_welcome_to_hermes => '欢迎使用 Ares';

  @override
  String get ng_add_a_gateway => '添加网关';

  @override
  String get ng_connect_to_your_hermes_agent_dashboard =>
      '连接到你的 Hermes Agent 控制面板。使用一个地址和一次登录，即可访问聊天、工具和设置。登录前不会发送任何内容。';

  @override
  String get ng_connect_to_another_hermes_agent_dashboard =>
      '连接到另一个 Hermes Agent 控制面板。你仍会登录已保存的控制面板。';

  @override
  String get ng_dashboard_address => '控制面板地址';

  @override
  String get ng_testing => '正在测试…';

  @override
  String get ng_test => '测试';

  @override
  String get ng_where_your_hermes_dashboard_runs_lan =>
      '你的 Hermes 控制面板所在的位置：局域网、Tailscale 或 HTTPS。';

  @override
  String get ng_find_on_my_network => '在我的网络中查找';

  @override
  String get ng_which_address_do_i_use => '我应该使用哪个地址？';

  @override
  String get ng_behind_cloudflare_access => '使用 Cloudflare Access 保护？';

  @override
  String get ng_need_a_client_certificate => '需要客户端证书？';

  @override
  String get ng_this_address_isn_t_private_and =>
      '此地址不是私有地址，且未使用 https://，因此你的密码和聊天内容会以未加密的形式通过互联网传输。请改用 https://、Tailscale 或你自己的网络。';

  @override
  String get ng_continue_to_sign_in => '继续登录';

  @override
  String get ng_use_the_classic_interface_instead => '改用经典界面';

  @override
  String get ng_if_cloudflare_access_protects_this_address =>
      '如果此地址受 Cloudflare Access 保护，请在 Cloudflare Zero Trust（Access，Service credentials）中创建服务令牌，并为对应的 Access 应用添加 Service Auth 策略。';

  @override
  String get ng_a_service_token_is_saved_for => '已为此地址保存服务令牌';

  @override
  String get ng_forget => '移除';

  @override
  String get ng_client_id => 'Client ID';

  @override
  String get ng_client_secret => 'Client Secret';

  @override
  String get ng_stored_encrypted_on_this_phone_and => '加密存储在此手机上，且只发送到此地址。';

  @override
  String get ng_hermes_is_reachable => '已连接到 Hermes';

  @override
  String ng_hermes_is_reachable_2(Object version) {
    return '已连接到 Hermes $version';
  }

  @override
  String get ng_sign_in_is_tested_next_then => '接下来测试登录，然后测试聊天';

  @override
  String get ng_agent_gateway => 'Agent 网关';

  @override
  String get ng_running => '运行中';

  @override
  String get ng_stopped => '已停止';

  @override
  String get ng_username_password => '用户名和密码';

  @override
  String get ng_browser => '浏览器';

  @override
  String get ng_in_the_browser_sso => '在浏览器中（SSO）';

  @override
  String get ng_profiles => '配置文件';

  @override
  String get ng_this_dashboard_offers_neither_a_username =>
      '此控制面板既未提供用户名和密码登录，也未提供浏览器登录。请更新 Hermes，或在服务器上配置用户名和密码登录。';

  @override
  String get ng_the_auth_gate_is_off_on =>
      '此控制面板未启用身份验证。任何能访问它的人都可以使用你的 Agent。';

  @override
  String get ng_couldn_t_reach_the_dashboard => '无法连接到控制面板';

  @override
  String ng_check_the_address_and_port_9119(Object reason) {
    return '$reason\n\n请检查地址和端口（默认为 9119）。如果控制面板尚未运行，请在服务器上执行：\nhermes dashboard --host 0.0.0.0';
  }

  @override
  String get ng_that_isn_t_a_hermes_dashboard => '这不是 Hermes 控制面板';

  @override
  String get ng_something_answered_but_not_a_hermes_2 =>
      '服务器有响应，但不是 Hermes 控制面板。请使用控制面板的地址，而不是 API 服务器的地址（端口 8642）。';

  @override
  String ng_something_answered_http_but_not_a_2(Object status) {
    return '服务器有响应（HTTP $status），但不是 Hermes 控制面板。请使用控制面板的地址，而不是 API 服务器的地址（端口 8642）。';
  }

  @override
  String get ng_cloudflare_access_stopped_the_request =>
      'Cloudflare Access 已拦截此请求';

  @override
  String ng_cloudflare_access_turned_down_the_service(Object status) {
    return 'Cloudflare Access 拒绝了服务令牌（HTTP $status）。请检查客户端 ID、密钥和 Service Auth 策略。';
  }

  @override
  String get ng_add_a_cloudflare_access_service_token_2 =>
      '请在下方添加 Cloudflare Access 服务令牌，然后重新测试。';

  @override
  String get ng_a_client_certificate_is_needed => '需要客户端证书';

  @override
  String get ng_this_server_asks_for_a_client =>
      '此服务器要求先提供客户端证书。请在下方选择服务器提供的证书，然后重新测试。';

  @override
  String get ng_this_dashboard_doesn_t_ask_for => '此控制面板不需要登录。';

  @override
  String ng_use_the_dashboard_username_and_password(Object address) {
    return '请使用 $address 上配置的控制面板用户名和密码，或在浏览器中登录。';
  }

  @override
  String ng_use_the_dashboard_username_and_password_2(Object address) {
    return '请使用 $address 上配置的控制面板用户名和密码。';
  }

  @override
  String ng_sign_in_to_in_your_browser(Object address) {
    return '请在浏览器中登录 $address，并使用该控制面板所用的账号。';
  }

  @override
  String ng_gateway(Object address) {
    return '网关 $address';
  }

  @override
  String get ng_profile => '配置文件';

  @override
  String get ng_server_default => '服务器默认设置';

  @override
  String get ng_continue => '继续';

  @override
  String get ng_username => '用户名';

  @override
  String get ng_signing_in => '正在登录…';

  @override
  String get ng_waiting_for_the_browser => '正在等待浏览器…';

  @override
  String get ng_sign_in_with_browser => '使用浏览器登录';

  @override
  String get ng_finish_signing_in_on_the_page =>
      '请在打开的页面上完成登录。完成后 Hermes 会自动返回。';

  @override
  String get ng_use_a_different_gateway => '使用其他网关';

  @override
  String get ng_same_wi_fi_or_local_network => '同一 Wi-Fi 或本地网络';

  @override
  String get ng_use_the_server_s_local_address =>
      '使用服务器的本地地址和端口，例如 192.168.1.20:9119。启动控制面板时请添加 --host 0.0.0.0，以便其他设备访问。';

  @override
  String get ng_tailscale => 'Tailscale';

  @override
  String get ng_turn_on_tailscale_on_this_phone =>
      '在这部手机上启用 Tailscale，然后使用服务器的 Tailscale 地址，例如 100.64.0.1:9119 或其 .ts.net 域名。离开家也能使用。';

  @override
  String get ng_use_your_https_address_when_the =>
      '如果控制面板位于带证书的代理后面，请使用你的 https:// 地址。代理还必须支持 /api/ws 上的 WebSocket 升级。';

  @override
  String get ng_start_the_dashboard_on_the_server => '在服务器上启动控制面板：';

  @override
  String get ng_enter_a_port_from_1_to => '请输入 1 到 65535 之间的端口。';

  @override
  String get ng_looks_for_hermes_dashboards_on_port =>
      '在此 Wi-Fi 网络上搜索端口 9119 的 Hermes 控制面板，并检查已保存的电脑。';

  @override
  String ng_looks_for_hermes_dashboards_on_ports(Object port) {
    return '在此 Wi-Fi 网络上搜索端口 9119 和 $port 的 Hermes 控制面板，并检查已保存的电脑。';
  }

  @override
  String get ng_other_port_optional => '其他端口（可选）';

  @override
  String get ng_no_dashboards_answered_start_one_with =>
      '没有控制面板响应。请运行 hermes dashboard --host 0.0.0.0 启动，或输入其地址。';

  @override
  String get ng_using_tailscale_or_a_vpn_those =>
      '正在使用 Tailscale 或 VPN？无法搜索这些网络。请改为输入电脑的 100.x 地址或 .ts.net 域名。';

  @override
  String get ng_search_again => '重新搜索';

  @override
  String get ng_insights => '数据洞察';

  @override
  String get ng_couldn_t_load_insights => '无法加载数据洞察';

  @override
  String get ng_sessions => '会话';

  @override
  String get ng_tokens => '令牌';

  @override
  String get ng_est_cost => '预估费用';

  @override
  String get ng_daily_tokens => '每日令牌用量';

  @override
  String get ng_models => '模型';

  @override
  String get ng_tools => '工具';

  @override
  String get ng_hermes_is_waiting_for_you => 'Hermes 正在等你。';

  @override
  String get ng_hermes_replied => 'Hermes 已回复';

  @override
  String get ng_the_turn_finished => '本轮已完成。';

  @override
  String get ng_off => '关闭';

  @override
  String get ng_minimal => '最低';

  @override
  String get ng_low => '低';

  @override
  String get ng_medium => '中';

  @override
  String get ng_high => '高';

  @override
  String get ng_extra_high => '极高';

  @override
  String get ng_max => '最高';

  @override
  String get ng_ultra => '超强';

  @override
  String get ng_default => '默认';

  @override
  String ng_couldn_t_switch_model(Object error) {
    return '无法切换模型：$error';
  }

  @override
  String get ng_model => '模型';

  @override
  String get ng_thinking_2 => '思考';

  @override
  String get ng_search_models => '搜索模型';

  @override
  String get ng_no_models_match => '没有符合这些筛选条件的模型。';

  @override
  String get privacy_policy => '隐私政策';

  @override
  String get report_ai_output => '举报 AI 输出';

  @override
  String ng_couldn_t_load_models(Object error) {
    return '无法加载模型：$error';
  }

  @override
  String get ng_no_providers_are_set_up_on => '此网关尚未设置任何提供商。';

  @override
  String get ng_starred => '已加星标';

  @override
  String get ng_recent => '最近';

  @override
  String get ng_more => '更多';

  @override
  String get ng_archived_chats => '已归档聊天';

  @override
  String get ng_projects => '项目';

  @override
  String get ng_chats_grouped_by_project_and_workspace => '按项目和工作区分组的聊天';

  @override
  String get ng_agent => '智能体';

  @override
  String get ng_memory => '记忆';

  @override
  String get ng_what_hermes_remembers_about_you => 'Hermes 对你的记忆';

  @override
  String get ng_skills_library => '技能库';

  @override
  String get ng_browse_and_read_installed_skills => '浏览并阅读已安装的技能';

  @override
  String get ng_cron_editor => 'Cron 编辑器';

  @override
  String get ng_edit_schedules_prompts_and_delivery => '编辑计划、提示词和发送方式';

  @override
  String get ng_config_file => '配置文件';

  @override
  String get ng_edit_config_yaml_on_the_gateway => '在网关上编辑 config.yaml';

  @override
  String get ng_models_and_providers => '模型和提供商';

  @override
  String get ng_model_management => '模型管理';

  @override
  String get ng_default_fallback_and_auxiliary_models => '默认、备用和辅助模型';

  @override
  String get ng_provider_sign_in => '提供商登录';

  @override
  String get ng_connect_provider_accounts_with_oauth => '通过 OAuth 连接提供商账号';

  @override
  String get ng_nous_portal => 'Nous Portal';

  @override
  String get ng_subscription_credits_and_usage => '订阅、额度和使用情况';

  @override
  String get ng_interface => '界面';

  @override
  String get ng_switch_to_the_classic_interface => '切换到经典界面';

  @override
  String get ng_turns_nextgen_off_you_can_turn => '关闭 NextGen。你可以在设置中重新开启。';

  @override
  String get ng_restored => '已恢复';

  @override
  String get ng_archived => '已归档';

  @override
  String get ng_couldn_t_load_archived_chats => '无法加载已归档的聊天';

  @override
  String get ng_nothing_archived => '没有已归档的内容';

  @override
  String get ng_restore => '恢复';

  @override
  String get ng_saved_new_chats_use_it => '已保存。新聊天将使用此设置。';

  @override
  String ng_couldn_t_save(Object error) {
    return '无法保存：$error';
  }

  @override
  String get ng_saving => '正在保存…';

  @override
  String ng_today(Object time) {
    return '今天 $time';
  }

  @override
  String get ng_mon => '周一';

  @override
  String get ng_tue => '周二';

  @override
  String get ng_wed => '周三';

  @override
  String get ng_thu => '周四';

  @override
  String get ng_fri => '周五';

  @override
  String get ng_sat => '周六';

  @override
  String get ng_sun => '周日';

  @override
  String get ng_scheduled => '计划任务';

  @override
  String get ng_new_job => '新建任务';

  @override
  String get ng_couldn_t_load_scheduled_jobs => '无法加载计划任务';

  @override
  String get ng_nothing_scheduled => '没有计划任务';

  @override
  String get ng_ask_hermes_to_do_something_on => '让 Hermes 按计划执行任务，或在此处添加任务。';

  @override
  String get ng_active => '运行中';

  @override
  String get ng_paused => '已暂停';

  @override
  String ng_next(Object when) {
    return '下次 $when';
  }

  @override
  String ng_last(Object when) {
    return '上次 $when';
  }

  @override
  String ng_last_2(Object when, Object result) {
    return '上次 $when · $result';
  }

  @override
  String ng_job(Object id) {
    return '任务 $id';
  }

  @override
  String get ng_delete => '删除';

  @override
  String get ng_delete_this_job => '删除此任务？';

  @override
  String get ng_it_stops_running_past_runs_stay => '删除后将停止运行。以往的运行记录仍会保留在聊天中。';

  @override
  String ng_next_run(Object when) {
    return '下次运行：$when';
  }

  @override
  String ng_delivers_to(Object target) {
    return '发送至 $target';
  }

  @override
  String get ng_run_now => '立即运行';

  @override
  String get ng_started => '已启动';

  @override
  String get ng_pause => '暂停';

  @override
  String get ng_resume => '继续';

  @override
  String get ng_resumed => '已继续';

  @override
  String get ng_prompt => '提示词';

  @override
  String get ng_runs => '运行记录';

  @override
  String get ng_no_runs_yet => '暂无运行记录。';

  @override
  String get ng_enter_a_schedule_and_a_prompt => '请填写计划和提示词。';

  @override
  String get ng_name_optional => '名称（可选）';

  @override
  String get ng_schedule => '计划';

  @override
  String get ng_every_1h_0_9_or_30m => 'every 1h, 0 9 * * *, or 30m';

  @override
  String get ng_create => '创建';

  @override
  String get ng_unpin => '取消置顶';

  @override
  String get ng_pin => '置顶';

  @override
  String get ng_rename => '重命名';

  @override
  String get ng_archive => '归档';

  @override
  String get ng_delete_this_chat => '删除此聊天？';

  @override
  String get ng_it_is_removed_from_the_gateway => '此聊天会从网关中删除，并从所有设备上移除。';

  @override
  String get ng_search_chats => '搜索聊天';

  @override
  String get ng_pinned => '已置顶';

  @override
  String get ng_no_chats_match => '没有匹配的聊天。';

  @override
  String get ng_no_chats_yet => '暂无聊天。';

  @override
  String get ng_nothing_is_running => '暂无运行中的任务。';

  @override
  String get ng_nothing_is_waiting_on_you => '暂无待你处理的事项。';

  @override
  String get ng_settings => '设置';

  @override
  String get ng_all => '全部';

  @override
  String ng_needs_you(Object count) {
    return '需要你处理 · $count';
  }

  @override
  String get ng_needs_you_2 => '需要你处理';

  @override
  String get ng_gateways => '网关';

  @override
  String ng_classic_connection(Object address) {
    return '$address · 经典连接';
  }

  @override
  String get ng_gateway_2 => '网关';

  @override
  String get ng_signed_in => '已登录';

  @override
  String get ng_classic_connection_2 => '经典连接';

  @override
  String get ng_in_the_browser => '在浏览器中';

  @override
  String ng_in_the_browser_as(Object name) {
    return '以 $name 身份在浏览器中';
  }

  @override
  String get ng_not_required => '无需操作';

  @override
  String get ng_test_connection => '测试连接';

  @override
  String get ng_sign_in_again_2 => '重新登录';

  @override
  String get ng_sign_out => '退出登录';

  @override
  String get ng_saved_gateways => '已保存的网关';

  @override
  String get ng_in_use => '使用中';

  @override
  String get ng_appearance => '外观';

  @override
  String get ng_theme => '主题';

  @override
  String get ng_system => '跟随系统';

  @override
  String get ng_light => '浅色';

  @override
  String get ng_dark => '深色';

  @override
  String get ng_accent => '强调色';

  @override
  String get ng_pure_black => '纯黑';

  @override
  String get ng_dark_theme_uses_true_black_oled => '深色主题使用纯黑（OLED）';

  @override
  String get ng_glow => '光晕';

  @override
  String get ng_soft_accent_light_behind_each_screen => '每个页面背后的柔和强调色光效';

  @override
  String get ng_the_new_interface_turn_off_to => '新版界面。关闭后可切回经典界面；网关和聊天记录会共用。';

  @override
  String get ng_more_settings => '更多设置';

  @override
  String get ng_voice_notifications_language_backups_and_the =>
      '语音、通知、语言、备份和网关配置';

  @override
  String get ng_licences => '许可证';

  @override
  String ng_sign_out_of(Object name) {
    return '要退出 $name 吗？';
  }

  @override
  String get ng_this_gateway_and_its_saved_sign =>
      '此网关及其已保存的登录信息会从这部手机的两个界面中移除。聊天记录仍保留在网关上。';

  @override
  String get ng_password_or_browser => '密码或浏览器';

  @override
  String get ng_unsupported => '不支持';

  @override
  String get ng_background_task_finished => '后台任务已完成';

  @override
  String get ng_background_process_finished => '后台进程已结束';

  @override
  String get ng_system_message => '系统消息';

  @override
  String get ng_summary => '摘要';

  @override
  String get classic_interface_only => '仅限经典界面';

  @override
  String get classic_only_settings_hint =>
      '标记为“仅限经典界面”的部分只会更改经典界面的外观和聊天设置，不会影响 NextGen。NextGen 在其“设置”中有自己的外观选项。';

  @override
  String get attachment_preview_too_large =>
      '文件太大，无法在此预览。保存或分享即可将其下载到手机（最大 1 GB）。';

  @override
  String get attachment_over_phone_limit => '此文件超过 1 GB，超出下载限制。请打开控制面板下载。';

  @override
  String attachment_downloading_percent(int percent) {
    return '正在下载…$percent%';
  }

  @override
  String attachment_downloading_mb(int megabytes) {
    return '正在下载…$megabytes MB';
  }

  @override
  String ng_attachment_too_large_for_gateway(String name) {
    return '$name 超过 12 MB，超出此网关的接收上限。更新 Hermes 后即可发送最大 100 MB 的文件。';
  }

  @override
  String ng_couldn_t_upload(String name) {
    return '无法上传 $name。';
  }

  @override
  String ng_uploading_percent(int percent) {
    return '正在上传…$percent%';
  }

  @override
  String get ng_show_tasks => '显示任务';

  @override
  String get ng_hide_tasks => '隐藏任务';

  @override
  String get ng_goal => '目标';

  @override
  String get ng_loop => '循环';

  @override
  String get ng_heartbeat => '心跳';

  @override
  String get ng_goal_working => '进行中';

  @override
  String get ng_goal_waiting => '等待中';

  @override
  String get ng_goal_blocked => '已阻塞';

  @override
  String get ng_goal_done => '已完成';

  @override
  String ng_goal_turns_of(int used, int max) {
    return '第 $used 轮，共 $max 轮';
  }

  @override
  String ng_goal_turn(int used) {
    return '第 $used 轮';
  }

  @override
  String get ng_loop_held => '因目标暂停';

  @override
  String get ng_loop_finished => '已结束';

  @override
  String get ng_loop_running => '运行中';

  @override
  String ng_loop_runs_of(int fired, int times) {
    return '已运行 $fired 次，共 $times 次';
  }

  @override
  String ng_loop_runs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '运行 $count 次',
      one: '运行 1 次',
    );
    return '$_temp0';
  }

  @override
  String ng_loop_next(String time) {
    return '下次 $time';
  }

  @override
  String get ng_loop_due_now => '现在执行';

  @override
  String ng_every_seconds(int seconds) {
    return '每 $seconds 秒';
  }

  @override
  String ng_every_minutes(int minutes) {
    return '每 $minutes 分钟';
  }

  @override
  String ng_every_hours(int hours) {
    return '每 $hours 小时';
  }

  @override
  String ng_every_hours_minutes(int hours, int minutes) {
    return '每 $hours 小时 $minutes 分钟';
  }

  @override
  String ng_heartbeat_fired(int count) {
    return '已触发 $count 次';
  }

  @override
  String ng_heartbeat_last_fired(String time) {
    return '上次触发时间：$time';
  }

  @override
  String ng_wait_until(String time) {
    return '等待至 $time';
  }

  @override
  String get ng_wait_resume => '等待恢复';

  @override
  String get ng_wait_other_chat => '等待另一个聊天';

  @override
  String ng_wait_process(String pid) {
    return '等待进程 $pid';
  }

  @override
  String get ng_control_open => '打开目标与自动化';

  @override
  String get ng_control_title => '目标与自动化';

  @override
  String get ng_control_subtitle => '此聊天正在努力实现的目标，以及自动运行的内容。';

  @override
  String get ng_contract_outcome => '预期结果';

  @override
  String get ng_contract_verification => '验证方式';

  @override
  String get ng_contract_constraints => '约束条件';

  @override
  String get ng_contract_boundaries => '边界';

  @override
  String get ng_contract_stop_when => '停止条件';

  @override
  String get ng_subgoals => '子目标';

  @override
  String get ng_subgoal_add_placeholder => '添加子目标';

  @override
  String get ng_add => '添加';

  @override
  String get ng_subgoal_remove => '移除子目标';

  @override
  String get ng_goal_checks => '检查项';

  @override
  String get ng_gate_not_run => '尚未运行';

  @override
  String ng_gate_attempts(int attempts, int tries) {
    return '已尝试 $attempts 次，共 $tries 次';
  }

  @override
  String ng_gate_exit(int code) {
    return '退出码 $code';
  }

  @override
  String get ng_resume_now => '立即恢复';

  @override
  String get ng_goal_clear => '清除目标';

  @override
  String get ng_goal_clear_title => '清除此目标？';

  @override
  String get ng_goal_clear_message => '智能体将停止为此目标而努力。其子目标和检查项也会一并清除。';

  @override
  String get ng_subgoal_remove_title => '移除此子目标？';

  @override
  String ng_subgoal_remove_message(String text) {
    return '“$text”将不再属于此目标。';
  }

  @override
  String get ng_subgoals_clear_title => '清除所有子目标？';

  @override
  String get ng_subgoals_clear_message => '目标标题将保留，但所有子目标都会被清除。';

  @override
  String get ng_clear_all => '全部清除';

  @override
  String get ng_clear => '清除';

  @override
  String get ng_dismiss => '关闭';

  @override
  String get ng_loop_stop_title => '停止此循环？';

  @override
  String get ng_heartbeat_clear_title => '清除此心跳？';

  @override
  String get ng_wont_fire_again => '此后将不再触发。';

  @override
  String get ng_loop_self_paced => '自主节奏';

  @override
  String ng_loop_until(String condition) {
    return '持续至：$condition';
  }

  @override
  String get ng_loop_waits_for_goal => '目标进行期间会等待。';

  @override
  String get ng_loop_awaiting_reply => '正在等待智能体回复。';

  @override
  String ng_loop_stopped_reason(String reason) {
    return '已停止：$reason';
  }

  @override
  String get ng_hide_subagents => '隐藏子代理';

  @override
  String get ng_show_subagents => '显示子代理';

  @override
  String get ng_subagent => '子代理';

  @override
  String get ng_subagent_queued => '排队中';

  @override
  String get ng_subagent_starting => '启动中…';

  @override
  String get ng_subagent_running => '运行中';

  @override
  String get ng_subagent_done => '已完成';

  @override
  String get ng_subagent_failed => '失败';

  @override
  String get ng_subagent_stopped => '已停止';

  @override
  String get ng_subagent_stop => '停止子代理';

  @override
  String ng_subagent_tools(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个工具',
    );
    return '$_temp0';
  }

  @override
  String get ng_mark_as_read => '标记为已读';

  @override
  String get ng_mark_as_unread => '标记为未读';

  @override
  String ng_chats_unread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '聊天，$count 条未读',
      one: '聊天，1 条未读',
    );
    return '$_temp0';
  }

  @override
  String get ng_unread_finished => '已完成，回复未读';

  @override
  String get ng_unread_updates => '正在运行，有未读更新';

  @override
  String get ng_notifications => '通知';

  @override
  String get ng_notifications_hint => 'Ares 在后台运行时接收回复和请求通知';

  @override
  String get ng_notify_replies => '回复';

  @override
  String get ng_notify_replies_hint => '当前打开的聊天中，一轮对话完成或失败时通知';

  @override
  String get ng_notify_requests => '审批和问题';

  @override
  String get ng_notify_requests_hint => '智能体等待你处理时提醒你，并提供“允许一次”和“拒绝”选项';

  @override
  String get ng_keep_running => '回复生成期间保持连接';

  @override
  String get ng_keep_running_hint => '在后台保持连接，直到回复完成，并显示一条静默通知';

  @override
  String get ng_battery_settings => '电池优化';

  @override
  String get ng_battery_settings_hint => '允许 Ares 在后台运行，以便及时收到通知';

  @override
  String get ng_send_test_notification => '发送测试通知';

  @override
  String get ng_test_notification_title => 'Ares 通知功能正常';

  @override
  String get ng_test_notification_body => '回复和请求通知会以这种形式显示。';

  @override
  String get ng_test_notification_sent => '测试通知已发送';

  @override
  String get ng_notifications_blocked => '通知已被禁止。请在 Android 设置中允许通知。';

  @override
  String get ng_notifications_off_hint => '通知已关闭，因此 Ares 在后台运行时不会发送通知。';

  @override
  String get ng_insights_building => '正在生成报告。首次生成较长时间段的报告可能需要最多一分钟。';

  @override
  String get ng_insights_timed_out => '网关生成此报告超时。请重试，或选择更短的时间段。';

  @override
  String get ng_dock_goal_active => '目标进行中';

  @override
  String get ng_dock_goal_paused => '目标已暂停';

  @override
  String get ng_dock_goal_waiting => '目标等待中';

  @override
  String get ng_dock_goal_blocked => '目标受阻';

  @override
  String get ng_dock_goal_done => '目标已完成';

  @override
  String ng_dock_turn_of(int used, int max) {
    return '第 $used/$max 轮';
  }

  @override
  String ng_dock_turn(int used) {
    return '第 $used 轮';
  }

  @override
  String ng_dock_subagents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个子代理',
      one: '1 个子代理',
    );
    return '$_temp0';
  }

  @override
  String ng_dock_subagents_done(int count) {
    return '$count 个已完成';
  }

  @override
  String ng_dock_tasks(int done, int total) {
    return '任务 $done/$total';
  }

  @override
  String ng_dock_previous_tasks(int done, int total) {
    return '上轮任务 $done/$total';
  }

  @override
  String get ng_dock_manage => '管理';

  @override
  String get ng_recent_notifications => '最近通知';

  @override
  String get ng_recent_notifications_hint => 'Ares 尝试发布的内容，以及 Android 是否显示了通知';

  @override
  String get ng_recent_notifications_empty =>
      '目前还没有。当回复、问题或失败会触发通知时，相关尝试会显示在这里。';

  @override
  String get ng_notify_permission_granted => '已获得通知权限';

  @override
  String get ng_notify_permission_denied => '通知权限已被拒绝';

  @override
  String get ng_notify_master_on => '通知已开启';

  @override
  String get ng_notify_master_off => '通知已关闭';

  @override
  String get ng_models_default => '默认模型';

  @override
  String get ng_models_change => '更改';

  @override
  String get ng_models_custom_endpoint => '使用自定义端点。请在网关上更改。';

  @override
  String get ng_models_context_window => '上下文窗口';

  @override
  String ng_models_token_count(String count) {
    return '$count Token';
  }

  @override
  String ng_models_context_override(String count) {
    return '已在网关上设置。自动检测：$count Token。';
  }

  @override
  String get ng_models_max_output => '最大输出';

  @override
  String get ng_models_input_price => '输入价格';

  @override
  String get ng_models_output_price => '输出价格';

  @override
  String get ng_models_cache_price => '缓存输入价格';

  @override
  String ng_models_per_million(String price) {
    return '每百万 Token $price';
  }

  @override
  String ng_models_price_pair(String input, String output) {
    return '每百万 Token：输入 $input · 输出 $output';
  }

  @override
  String get ng_models_free => '免费';

  @override
  String get ng_models_vision => '视觉';

  @override
  String get ng_models_reasoning => '推理';

  @override
  String get ng_models_fast => '快速模式';

  @override
  String get ng_models_in_use => '使用中';

  @override
  String ng_models_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个模型',
    );
    return '$_temp0';
  }

  @override
  String get ng_models_rate_limited => '已限流';

  @override
  String get ng_models_plan_locked => '当前套餐不可用';

  @override
  String get ng_models_unsaved => '未保存的更改';

  @override
  String get ng_models_discard => '放弃';

  @override
  String get ng_models_aux_hint => '辅助任务使用默认模型，除非你为其单独指定。';

  @override
  String get ng_models_uses_default => '使用默认模型';

  @override
  String get ng_models_thinking_level => '思考级别';

  @override
  String get ng_models_providers => '提供方';

  @override
  String get ng_models_saved => '已保存';

  @override
  String get ng_aux_vision => '视觉';

  @override
  String get ng_aux_vision_hint => '读取图片和截图';

  @override
  String get ng_aux_compression => '压缩';

  @override
  String get ng_aux_compression_hint => '压缩较长的聊天，使其适应上下文窗口';

  @override
  String get ng_aux_approval => '审批';

  @override
  String get ng_aux_approval_hint => '判断命令是否可以不经询问安全执行';

  @override
  String get ng_aux_mcp => 'MCP';

  @override
  String get ng_aux_mcp_hint => '选择要使用的 MCP 工具';

  @override
  String get ng_aux_title_generation => '聊天标题';

  @override
  String get ng_aux_title_generation_hint => '为新聊天命名';

  @override
  String get ng_aux_review => '评审';

  @override
  String get ng_aux_review_hint => '运行 /review 时检查工作成果';

  @override
  String get ng_aux_voice_chat => '语音聊天';

  @override
  String get ng_aux_voice_chat_hint => '在语音模式下回复';

  @override
  String get ng_aux_triage_specifier => '任务分类';

  @override
  String get ng_aux_triage_specifier_hint => '将一行的看板卡片扩展为规格说明';

  @override
  String get ng_aux_kanban_decomposer => '看板拆解';

  @override
  String get ng_aux_kanban_decomposer_hint => '将看板卡片拆分为更小的任务';

  @override
  String get ng_aux_profile_describer => '配置档案描述';

  @override
  String get ng_aux_profile_describer_hint => '为每个配置档案撰写简短描述';

  @override
  String get ng_aux_curator => '维护器';

  @override
  String get ng_aux_curator_hint => '审查技能的使用情况';

  @override
  String get appearance_inline_embeds => '内嵌内容';

  @override
  String get appearance_inline_embeds_hint =>
      '丰富预览会从第三方网站加载（YouTube、X 等）。“询问”会先显示占位符，直到你逐一允许；“始终”会自动加载；“关闭”只保留普通链接。';

  @override
  String get appearance_embeds_ask => '询问';

  @override
  String get appearance_embeds_always => '始终';

  @override
  String get appearance_embeds_off => '关闭';

  @override
  String appearance_embeds_reset(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '重置 $count 个已允许的服务',
      one: '重置 1 个已允许的服务',
    );
    return '$_temp0';
  }

  @override
  String get appearance_embed_load => '加载';

  @override
  String appearance_embed_always_allow(String service) {
    return '始终允许 $service';
  }

  @override
  String get appearance_embed_loading => '正在加载预览…';

  @override
  String appearance_embed_image_failed(String host) {
    return '无法从 $host 加载图片。轻触即可打开。';
  }

  @override
  String get appearance_embed_preview_unavailable => '无法预览';

  @override
  String get render_widget_file_truncated => '只读取了此文件的开头部分，因此小组件可能不完整。';

  @override
  String get setup_beat_title => '设置';

  @override
  String setup_beat_use_name(String name) {
    return '使用 $name';
  }

  @override
  String get setup_beat_name_hint => 'Hermes 应该怎么称呼你？';

  @override
  String get setup_beat_on_computer => '此步骤在运行 Hermes 的电脑上完成。选择“继续”将保留那里已有的设置。';

  @override
  String get setup_beat_not_waiting => '此设置卡片已不再等待回答。';

  @override
  String get catalog_kind_plugin => '插件';

  @override
  String get catalog_kind_skill => '技能';

  @override
  String get catalog_tier_official => '官方';

  @override
  String get catalog_tier_verified => '已验证';

  @override
  String get catalog_tier_community => '社区';

  @override
  String get catalog_install => '安装';

  @override
  String get catalog_waiting => '等待你的选择';

  @override
  String get catalog_installed => '已安装';

  @override
  String get catalog_installed_off => '已安装，未启用';

  @override
  String get catalog_skipped => '已跳过';

  @override
  String get catalog_not_installed => '未安装';

  @override
  String catalog_target_profile(String profile) {
    return '安装到 $profile 配置文件';
  }

  @override
  String catalog_source(String repo, String sha) {
    return '$repo（$sha）';
  }

  @override
  String catalog_scan(String status, String summary) {
    return '安全扫描：$status。$summary';
  }

  @override
  String catalog_requires_hermes(String range) {
    return '需要 Hermes $range';
  }

  @override
  String catalog_skill_ready(String name) {
    return '技能 $name 已可使用';
  }

  @override
  String catalog_missing_env(String names) {
    return '仍需要：$names';
  }

  @override
  String catalog_server_error(String name, String error) {
    return '$name 未能连接：$error';
  }

  @override
  String get catalog_send_failed => '你的选择未发送，请重试。';

  @override
  String get attachment_video_speed => '播放速度';

  @override
  String get catalog_installing => '正在安装…';

  @override
  String get catalog_phase_downloading => '正在下载…';

  @override
  String get catalog_phase_python_packages => '正在安装 Python 包…';

  @override
  String get catalog_phase_loading_tools => '正在加载工具…';

  @override
  String get setup_beat_send_failed => '你的回答未发送，请重试。';

  @override
  String catalog_tool_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个工具',
    );
    return '$_temp0';
  }

  @override
  String get render_svg_not_drawn => '此 SVG 未绘制。';

  @override
  String get render_notes_directive => '笔记指令';

  @override
  String get render_maths_source => '数学公式源码';

  @override
  String get render_inline_maths_source => '行内数学公式源码';

  @override
  String get render_sequence_outline => '时序图大纲';

  @override
  String get render_diagram_outline => '图表大纲';

  @override
  String render_revision_of(int index, int count) {
    return '修订版 $index/$count';
  }

  @override
  String get render_previous_revision => '上一修订版';

  @override
  String get render_next_revision => '下一修订版';

  @override
  String get render_show_rendered => '渲染视图';

  @override
  String get render_show_source => '源码';

  @override
  String render_copied_file(String name) {
    return '已复制 $name';
  }

  @override
  String render_copy_file(String name) {
    return '复制 $name';
  }

  @override
  String get render_artifact_too_long => '此产物太长，无法在此处以页面显示。';

  @override
  String get render_active_content_removed => '已移除脚本、框架和外部地址。';

  @override
  String render_widget_file(String file) {
    return '小组件 $file';
  }

  @override
  String get render_widget_runs_as_text => '在此聊天中以文本形式运行。脚本和外部框架会被移除。';

  @override
  String get render_load_widget => '加载小组件';

  @override
  String get render_not_html_widget => '此文件不是 HTML 小组件。';

  @override
  String get render_widget_sent => '已发送到此聊天';

  @override
  String get render_widget_not_sent => '未发送到此聊天';

  @override
  String get render_widget_throttled => '请稍候再发送';

  @override
  String get render_widget_too_long => '此请求太长，无法发送';

  @override
  String get render_widget_no_gesture => '点按小组件中的控件以发送';

  @override
  String get render_widget_invalid => '无法发送此请求';

  @override
  String get render_inspected_image => '已检查的图片';

  @override
  String get render_contributions => '扩展项';

  @override
  String get render_contributions_intro =>
      '只有内置在 Ares 中的扩展项才能为回复添加内容。聊天文本无法注册扩展项，授权仅适用于此连接。';

  @override
  String render_grant_plugin(String name) {
    return '授权 $name';
  }

  @override
  String render_revoke_plugin(String name) {
    return '撤销 $name';
  }

  @override
  String render_plugin_slots(String directive) {
    return '::$directive 的回复卡片';
  }

  @override
  String get render_plugin_notes => '笔记';

  @override
  String get catalog_scan_passed => '已通过';

  @override
  String get catalog_scan_warnings => '发现警告';

  @override
  String get catalog_scan_failed => '未通过';

  @override
  String get deployment_token_label => '部署令牌（可选）';

  @override
  String get deployment_token_helper =>
      '用于以 X-Hermes-Session-Token 发送的 Hermes Dashboard 会话令牌。不会以明文保存在偏好设置中。';

  @override
  String get deployment_token_hint => '仪表板会话令牌';

  @override
  String get custom_headers_label => '自定义标头（可选）';

  @override
  String get custom_headers_helper => '每行一个，例如 X-Custom: 值。禁止的标头会被拒绝。';

  @override
  String get custom_headers_hint => '例如 X-Custom-Header: 值';

  @override
  String get desktop_tray_open => '打开 Ares';

  @override
  String get desktop_tray_new_chat => '新聊天';

  @override
  String get desktop_tray_quick_entry => '快速输入…';

  @override
  String get desktop_tray_pause_notifications => '暂停通知';

  @override
  String get desktop_tray_quit => '退出 Ares';

  @override
  String get desktop_integration_title => '桌面集成';

  @override
  String get desktop_tray_setting => '在系统托盘或菜单栏中显示 Ares';

  @override
  String get desktop_tray_setting_help => '可通过图标打开 Ares、开始聊天、打开快速输入、暂停通知或退出。';

  @override
  String get desktop_close_to_tray_setting => '关闭窗口后继续在托盘中运行';

  @override
  String get desktop_tray_unsupported => '此桌面没有可供 Ares 使用的系统托盘。';

  @override
  String get quick_entry_title => '快速输入';

  @override
  String get quick_entry_hint => '输入给 Ares 的提示…';

  @override
  String get quick_entry_submit => '放入输入框';

  @override
  String get quick_entry_never_sends => '按 Enter 会将文本放入聊天输入框。在你按下发送之前不会发送任何内容。';

  @override
  String get quick_entry_unavailable => '无法打开快速输入。请重试。';

  @override
  String get desktop_hotkey_setting => '快速输入快捷键';

  @override
  String desktop_hotkey_help(String shortcut) {
    return '在任意位置按 $shortcut 即可打开快速输入。';
  }

  @override
  String desktop_hotkey_conflict(String shortcut) {
    return '其他应用已在使用 $shortcut。请选择其他快捷键。';
  }

  @override
  String get desktop_hotkey_unsupported => '此桌面不允许应用注册全局快捷键（例如 Wayland）。';

  @override
  String get desktop_hotkey_no_modifier => '请包含 Cmd、Ctrl 或 Alt。';

  @override
  String get desktop_hotkey_super_key => 'Windows 键或 Super 键为系统保留。';

  @override
  String get desktop_hotkey_reserved => '系统已在使用此快捷键。';

  @override
  String desktop_hotkey_in_app(String action) {
    return 'Ares 已将此快捷键用于$action。';
  }

  @override
  String get desktop_hotkey_change => '更改';

  @override
  String get desktop_hotkey_reset => '使用默认值';

  @override
  String get capture_screen_action => '截取屏幕';

  @override
  String get capture_screen_help => '将截图作为草稿添加到消息中。在你按下发送之前不会发送任何内容。';

  @override
  String get capture_screen_unavailable => '此桌面无法使用屏幕截取。';

  @override
  String get capture_screen_failed => '无法截取屏幕。请重试。';

  @override
  String get capture_permission_title => '允许录屏';

  @override
  String get capture_permission_body =>
      '要截取窗口，Ares 需要录屏权限。请在“系统设置” > “隐私与安全性” > “录屏”中打开 Ares，然后重试。';

  @override
  String get capture_open_settings => '打开系统设置';

  @override
  String get keep_awake_title => '保持电脑唤醒';

  @override
  String get keep_awake_title_mobile => '保持屏幕常亮';

  @override
  String get keep_awake_mode_off => '关闭';

  @override
  String get keep_awake_mode_while_working => '工作时';

  @override
  String get keep_awake_mode_always => '始终';

  @override
  String get keep_awake_off_help => '从不阻止系统睡眠（默认）。';

  @override
  String get keep_awake_while_working_help => '仅在代理回合运行时阻止空闲睡眠。';

  @override
  String get keep_awake_always_help => '在此设备上打开 Ares 期间阻止空闲睡眠。';

  @override
  String get keep_awake_off_help_mobile => '让屏幕照常关闭（默认）。';

  @override
  String get keep_awake_while_working_help_mobile =>
      '在代理回合运行且 Ares 打开期间保持屏幕常亮。';

  @override
  String get keep_awake_always_help_mobile => '在 Ares 打开期间保持屏幕常亮。';

  @override
  String get ng_token_gateway_has_no_sign_in =>
      '此网关没有登录功能，因此无法验证部署令牌。请在主机上启用仪表板身份验证（或更新 Hermes），然后重试。';

  @override
  String get palette_open => '应用命令面板';

  @override
  String get palette_no_matches => '没有匹配的操作';

  @override
  String get palette_filter_hint => '输入以筛选操作…';

  @override
  String get palette_keys_move => '↑↓ 移动';

  @override
  String get palette_keys_run => 'Enter 运行';

  @override
  String get palette_keys_close => 'Esc 关闭';

  @override
  String get palette_search_sessions => '搜索会话';

  @override
  String get palette_scheduled_crons => '计划任务 / Cron';

  @override
  String get palette_capabilities_skills => '能力与技能';

  @override
  String get palette_insights_usage => '洞察与用量';

  @override
  String get palette_more_projects => '更多与项目';

  @override
  String get deeplink_chat_not_found => '列表中找不到该聊天，可能尚未加载。';

  @override
  String get keyboard_shortcuts_title => '键盘快捷键';

  @override
  String get shortcuts_reset_all => '全部重置';

  @override
  String get shortcuts_reset_to_default => '恢复默认';

  @override
  String get shortcut_action_command_palette => '命令面板';

  @override
  String get shortcut_action_new_chat => '新建聊天';

  @override
  String get shortcut_action_search => '搜索';

  @override
  String get shortcut_action_settings => '设置';

  @override
  String shortcut_action_go_to_tab(int number) {
    return '转到标签页 $number';
  }

  @override
  String shortcuts_conflict(String first, String second, String chord) {
    return '冲突：“$first”和“$second”都使用 $chord。在你更改其中一个之前，自定义快捷键保持默认值。';
  }

  @override
  String shortcuts_editor_title(String action) {
    return '快捷键：$action';
  }

  @override
  String get shortcuts_editor_help => '按下组合键，或在下方选择修饰键和按键：';

  @override
  String get shortcuts_editor_needs_modifier =>
      '请至少选择 Cmd/Meta、Ctrl 或 Alt，以免影响在输入框中打字。';

  @override
  String shortcuts_text_editing_warning(String chord) {
    return '$chord 是文本编辑快捷键（复制、粘贴、剪切、撤销、重做或全选）。在此绑定后，文本框将无法使用它。';
  }

  @override
  String shortcuts_text_editing_in_use(String action, String chord) {
    return '“$action”使用了文本编辑快捷键 $chord。在此绑定期间，文本框无法使用它。';
  }

  @override
  String custom_headers_problem_format(int line) {
    return '第 $line 行：应为“名称: 值”';
  }

  @override
  String custom_headers_problem_missing_name(int line) {
    return '第 $line 行：缺少标头名称';
  }

  @override
  String custom_headers_problem_invalid_name(int line, String name) {
    return '第 $line 行：标头名称“$name”无效';
  }

  @override
  String custom_headers_problem_reserved(int line, String name) {
    return '第 $line 行：“$name”为保留标头，不能传递';
  }

  @override
  String custom_headers_problem_empty_value(int line) {
    return '第 $line 行：标头值为空';
  }

  @override
  String get ng_enter_a_deployment_token => '请输入部署会话令牌。';

  @override
  String get ng_custom_headers => '自定义标头';

  @override
  String get ng_custom_headers_help =>
      '此网关的额外 HTTP 标头（名称: 值，每行一个），随其 REST 和 WebSocket 调用发送，保存在安全凭据存储中。身份验证标头和逐跳标头会被拒绝。';

  @override
  String get ng_use_a_deployment_token => '使用部署会话令牌';

  @override
  String get ng_sign_in_with_deployment_token => '使用部署令牌登录';

  @override
  String get ng_signed_in_with_deployment_token => '已使用部署令牌登录。';

  @override
  String get auto_speak_replies_title => '自动朗读回复';

  @override
  String get auto_speak_replies_subtitle => '每回合结束后自动朗读新回复。默认关闭；聊天内的已朗读开关仍然生效。';

  @override
  String get ng_auto_read_replies_title => '自动朗读回复';

  @override
  String get ng_auto_read_replies_subtitle => '每回合结束后自动朗读新回复。默认关闭。';

  @override
  String get barge_in_title => '插话';

  @override
  String get barge_in_subtitle => '朗读回复时开口说话即可提前停止。朗读回复期间麦克风保持开启。';

  @override
  String get barge_in_mic_live => '麦克风已开启：说话即可打断回复';

  @override
  String get ng_barge_in_title => '插话';

  @override
  String get ng_barge_in_subtitle => '朗读回复时开口说话即可提前停止。朗读回复期间麦克风保持开启。';

  @override
  String get ng_barge_in_mic_live => '麦克风已开启：说话即可打断回复';

  @override
  String get wake_word_title => '唤醒词';

  @override
  String get wake_word_subtitle => '由网关提供免提唤醒检测。默认关闭；仅在启用设备麦克风采集时发送音频。';

  @override
  String wake_word_listening(String phrase) {
    return '正在监听唤醒词“$phrase”';
  }

  @override
  String wake_word_paused(String phrase) {
    return '唤醒词“$phrase” — 已暂停';
  }

  @override
  String wake_word_off(String phrase) {
    return '唤醒词“$phrase” — 已关闭';
  }

  @override
  String get wake_word_arming => '正在启用唤醒词…';

  @override
  String get wake_word_stop => '停止唤醒词';

  @override
  String get wake_word_rearm => '重新启用';

  @override
  String get wake_word_capture_mode => '采集模式';

  @override
  String get wake_word_capture_auto => '自动';

  @override
  String get wake_word_capture_client => '此设备麦克风';

  @override
  String get wake_word_capture_local => '网关主机麦克风';

  @override
  String get wake_word_input_device => '输入麦克风';

  @override
  String get wake_word_default_device => '系统默认';

  @override
  String get ng_wake_word_title => '唤醒词';

  @override
  String get ng_wake_word_subtitle => '由网关提供免提唤醒检测。默认关闭。';

  @override
  String get voice_engine_title => '语音对话引擎';

  @override
  String get voice_engine_subtitle => '选择此网关配置文件中免提语音对话的运行方式。';

  @override
  String get voice_engine_chained => '串联（语音转文字 → Hermes → 语音）';

  @override
  String get voice_engine_chained_short => '串联';

  @override
  String get voice_engine_live => 'GPT-Live（实时语音）';

  @override
  String get voice_engine_live_short => 'GPT-Live';

  @override
  String get voice_engine_live_needs_key =>
      '请在网关主机上配置 OpenAI API 密钥以启用 GPT-Live。';

  @override
  String voice_engine_fallback_chained(String reason) {
    return 'GPT-Live 不可用（$reason）— 改用串联语音。';
  }

  @override
  String get voice_live_start => '开始语音对话';

  @override
  String get voice_live_stop => '结束语音对话';

  @override
  String get voice_live_mute => '麦克风静音';

  @override
  String get voice_live_unmute => '取消麦克风静音';

  @override
  String get voice_live_interrupt => '打断或立即回应';

  @override
  String get voice_live_listening => '正在聆听';

  @override
  String get voice_live_speaking => '正在说话';

  @override
  String get voice_live_thinking => '正在思考';

  @override
  String get voice_live_muted => '已静音';

  @override
  String get voice_live_ended_connection_lost => '实时语音会话的连接已断开。';

  @override
  String get voice_live_ended_closed => '实时语音会话已被服务关闭。';

  @override
  String wake_word_other_profile(String profile) {
    return '该唤醒词属于配置文件“$profile”。请打开到该配置文件的连接以应答。';
  }

  @override
  String get wake_word_reason_disabled => '已关闭 — 点按以启用';

  @override
  String get wake_word_reason_surface => '仅限其他界面使用（配置 wake_word.surface）';

  @override
  String get wake_word_reason_owned => '唤醒词监听由其他界面占用';

  @override
  String wake_word_reason_owned_by(String surface) {
    return '唤醒词监听由其他界面（$surface）占用';
  }

  @override
  String get wake_word_reason_unavailable => '此网关不支持唤醒词';

  @override
  String get wake_word_reason_permission_denied => '麦克风权限被拒绝';

  @override
  String get wake_word_reason_permission_required => '需要麦克风权限 — 点按以启用';

  @override
  String get voice_live_not_enabled => '此配置文件未启用 GPT-Live。';

  @override
  String get voice_live_not_available => 'GPT-Live 不可用';

  @override
  String voice_live_start_failed(String error) {
    return '无法启动 GPT-Live：$error';
  }

  @override
  String voice_direct_stt_timeout(String seconds, String provider) {
    return '转写在 $seconds 秒后超时（$provider 未响应）';
  }

  @override
  String voice_direct_stt_error(String provider, String status) {
    return '$provider 语音转文字错误（HTTP $status）';
  }

  @override
  String voice_direct_tts_failed(String provider) {
    return '$provider 文字转语音请求失败';
  }

  @override
  String voice_direct_tts_error(String provider, String status) {
    return '$provider 文字转语音错误（HTTP $status）';
  }

  @override
  String ng_wake_status_listening(String phrase) {
    return '正在监听（“$phrase”）';
  }

  @override
  String ng_wake_status_off(String phrase) {
    return '已关闭（“$phrase”）';
  }

  @override
  String ng_wire_setting_unavailable(Object setting) {
    return '共享网关暂不支持更改 $setting';
  }

  @override
  String ng_wire_method_unavailable(Object method) {
    return '共享网关暂不支持 $method';
  }

  @override
  String ng_wire_session_options_unsupported(Object options) {
    return '规范网关不支持以下显式会话选项：$options';
  }

  @override
  String get ng_wire_prompt_stale => '该请求已过期或不可用；请重新连接后再回复';

  @override
  String get ng_wire_revision_unavailable => '会话修订版本不可用；请重新打开会话后再编辑元数据';

  @override
  String get ng_wire_generation_unavailable => '会话执行标识不可用；请重新连接后再使用此命令';

  @override
  String get ng_wire_message_not_saved => '此消息尚未保存；请等待其完成后再从它创建分支';

  @override
  String get ng_wire_not_available => '共享网关暂不支持';

  @override
  String get edit_turn_title => '编辑此提示？';

  @override
  String get edit_turn_body => '将从此处重新运行该提示，后续轮次会被归档。';

  @override
  String get edit_turn_send => '发送';

  @override
  String get restore_turn_title => '恢复到此检查点？';

  @override
  String get restore_turn_body => '此提示之后的所有内容将从对话中移除，并从此处重新运行该提示。';

  @override
  String get restore_turn_confirm => '恢复并重跑';

  @override
  String get edit_turn_later_turns_body => '这会将对话中的后续轮次归档。要继续吗？';

  @override
  String get session_history => '会话历史';

  @override
  String get import_claude_or_codex => '导入 Claude 或 Codex';

  @override
  String get ng_session_history => '会话历史';

  @override
  String get ng_import_claude_or_codex => '导入 Claude 或 Codex';

  @override
  String get ng_edit_and_resend => '编辑并重发';

  @override
  String get ng_restore_turn_confirm => '恢复并重跑';

  @override
  String get rewind_target_unsaved => '此消息尚未保存。请等待其完成后再编辑。';

  @override
  String get rewind_turn_busy => '当前回复尚未停止，因此未发送任何内容。请稍后再试。';

  @override
  String get rewind_session_changed => '此聊天自在此处打开后已发生变化，因此未移除或发送任何内容。请重新打开后再试。';

  @override
  String get history_lineage => '相关聊天';

  @override
  String get history_lineage_none => '此聊天没有分支或同级分支。';

  @override
  String get history_lineage_unavailable => '无法从此网关读取相关聊天。';

  @override
  String get history_lineage_parent => '父级';

  @override
  String get history_lineage_sibling => '同级';

  @override
  String get history_lineage_fork => '分支';

  @override
  String get history_messages => '消息';

  @override
  String get history_messages_hint => '选择一条已保存的消息，从那里分支或回退。';

  @override
  String get history_messages_none => '尚无已保存的消息。';

  @override
  String get history_messages_unavailable => '无法读取已保存的消息。请打开此聊天后刷新。';

  @override
  String get history_role_user => '你';

  @override
  String get history_role_assistant => 'Hermes';

  @override
  String get history_branch_here => '从这里分支';

  @override
  String get history_rewind_here => '回退到这里';

  @override
  String get history_branch_title => '从此消息分支';

  @override
  String get history_branch_body => '这会创建一个包含到所选消息为止历史的新聊天。当前聊天保持不变。';

  @override
  String get history_rewind_title => '回退到此消息';

  @override
  String get history_rewind_body =>
      '从所选消息起的消息将从此聊天中移除。电脑上的文件不会更改。恢复文件是单独的检查点操作。';

  @override
  String history_branched(String id) {
    return '已分支为 $id';
  }

  @override
  String get history_open_chat => '打开聊天';

  @override
  String get history_mutate_unsupported => '分支和回退需要此网关运行 Hermes 0.23 或更高版本。';

  @override
  String get history_checkpoints => '检查点';

  @override
  String get history_checkpoints_none => '此会话没有文件检查点。';

  @override
  String get history_checkpoints_unavailable => '此网关不提供检查点。';

  @override
  String get history_diff_none => '没有差异。';

  @override
  String get history_diff_loading => '正在加载更改…';

  @override
  String get history_diff_failed => '无法加载更改，因此暂时不能恢复此检查点。';

  @override
  String get history_restore_checkpoint => '恢复检查点';

  @override
  String get history_restore_title => '恢复此检查点';

  @override
  String get history_restore_body =>
      '代理自此检查点以来更改的文件将恢复到当时的状态。你自己的更改会保留。之后的聊天消息也可能被移除。对话不会分支。';

  @override
  String get history_restore_body_all =>
      '会话文件夹中的所有文件都将恢复到此检查点，包括你自己的更改。之后的聊天消息也可能被移除。对话不会分支。';

  @override
  String get history_restore_own_edits => '同时还原我自己的更改';

  @override
  String get history_restored => '检查点已恢复。';

  @override
  String history_restored_removed(int count) {
    return '检查点已恢复。已移除 $count 条聊天消息。';
  }

  @override
  String get history_export => '导出';

  @override
  String get history_export_redact => '隐去令牌';

  @override
  String get history_export_action => '导出对话记录';

  @override
  String get history_export_saved => '对话记录已保存。';

  @override
  String get history_export_unsupported => '导出需要此网关运行 Hermes 0.23 或更高版本。';

  @override
  String get history_import_unsupported => '此网关不支持导入 Claude 和 Codex。';

  @override
  String history_import_destination(String profile) {
    return '目标配置文件：$profile。';
  }

  @override
  String history_import_reading(String host, String profile, int count) {
    return '正在从 $host 读取 · 目标配置文件：$profile。有 $count 个日志无法读取。';
  }

  @override
  String get history_import_all => '全部';

  @override
  String history_import_scan_failed(String reason) {
    return '无法扫描主机会话：$reason';
  }

  @override
  String get history_import_none => '在此主机上未找到 Claude Code 或 Codex 会话。';

  @override
  String get history_import_no_match => '没有匹配的主机会话。';

  @override
  String history_import_preview_failed(String reason) {
    return '无法预览会话：$reason';
  }

  @override
  String get history_import_open => '打开已导入的会话';

  @override
  String get history_import_action => '导入所选会话';

  @override
  String get history_import_title => '导入此会话';

  @override
  String history_import_body(String profile) {
    return '将此 Claude 或 Codex 会话复制到此网关上的配置文件“$profile”。';
  }

  @override
  String history_import_body_existing(String profile) {
    return '此会话已导入到“$profile”。将继续使用现有副本。';
  }

  @override
  String history_imported(String id) {
    return '已导入为 $id';
  }

  @override
  String history_imported_already(String id) {
    return '已导入过，名称为 $id';
  }

  @override
  String history_import_directory(String path) {
    return '目录：$path';
  }

  @override
  String history_import_preview_partial(int shown, int total) {
    return '预览显示 $total 条中的 $shown 条。';
  }

  @override
  String history_failed(String reason) {
    return '无法完成：$reason';
  }

  @override
  String get history_error_unavailable => '网关暂时无法执行此操作。请重试。';

  @override
  String get history_error_unsupported => '此网关不支持此操作。';

  @override
  String get history_error_denied => '此网关拒绝了该请求。';

  @override
  String get history_error_changed => '此页面打开期间聊天已发生变化。请刷新后重试。';

  @override
  String get history_error_unbound => '此聊天未在网关上打开。请打开后重试。';

  @override
  String get history_error_invalid => '网关返回了此应用无法读取的响应。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get workspace_workers => '即時工作者';

  @override
  String get workers_unattached => '僅顯示數量。若要引導工作者，請在其所屬的上層聊天中選擇「即時工作者」。';

  @override
  String get slash_local_arguments => '此處的快捷指令不支援參數。請使用應用程式中的控制項；草稿已保留。';

  @override
  String get fallback_title => '備用模型';

  @override
  String get fallback_notice => '主模型無法使用時，會依序嘗試清單中的模型。變更只適用於此設定檔；編輯後請儲存整份清單。';

  @override
  String get fallback_unavailable => '無法使用備用模型設定，或設定無效。請檢查連線、所選設定檔和主機版本後重試。';

  @override
  String get fallback_discovery_unavailable =>
      '無法取得供應商清單。現有項目會保留；重試後可選擇供應商和模型。';

  @override
  String get fallback_empty => '尚未設定備用模型。';

  @override
  String get fallback_incomplete => '儲存前，請為每個項目選擇供應商和模型，或移除尚未填完的項目。';

  @override
  String get fallback_add => '新增備用模型';

  @override
  String get fallback_save => '儲存備用清單';

  @override
  String get fallback_save_failed => '無法驗證已儲存的備用清單。草稿已保留。請重新儲存，或重新整理以重新載入主機設定。';

  @override
  String get fallback_saved => '備用模型清單已儲存並通過驗證。';

  @override
  String get fallback_legacy_title => '舊版備用設定（唯讀）';

  @override
  String get fallback_legacy_notice =>
      '嘗試完清單中的模型後，主機還會使用 fallback_model，並略過重複的路由。即使上方清單是空的，這些舊版項目仍會保留。請在主機上編輯。';

  @override
  String fallback_priority(String position) {
    return '優先順序 $position';
  }

  @override
  String get fallback_move_up => '上移';

  @override
  String get fallback_move_down => '下移';

  @override
  String get fallback_routing_read_only =>
      '路由詳細資料或未列出的供應商已保留。請在主機上編輯此供應商／模型；此處仍可調整順序或刪除項目。';

  @override
  String get cron_model_default => '使用預設設定';

  @override
  String get cron_model_notice =>
      '僅適用於此 cron 任務。未固定模型時，Hermes 先使用 cron 預設模型，再使用主模型。請在主機上管理自訂模型。';

  @override
  String get model_management_unavailable => '無法載入或儲存模型設定。請重新整理後重試。';

  @override
  String get model_management_subtitle => '此設定檔的主模型、備用模型和輔助模型';

  @override
  String get usage => '用量';

  @override
  String get nous_portal => 'Nous Portal';

  @override
  String get portal_menu_subtitle => '閘道狀態和已記錄用量';

  @override
  String get portal_read_only =>
      '這些閘道資料僅供檢視。請在 Hermes 主機上管理 Nous 身分驗證。這些端點不提供訂閱餘額或點數。';

  @override
  String get portal_status => '閘道的 Nous Portal 狀態';

  @override
  String get portal_free_tier => '免費方案（未登入帳戶）';

  @override
  String get portal_signed_in => '已登入';

  @override
  String get portal_signed_out => '未登入';

  @override
  String get portal_account_tier => '帳戶等級';

  @override
  String get portal_recorded_usage => '已記錄用量';

  @override
  String get portal_all_providers => '涵蓋所選閘道設定檔中的所有供應商。記錄的費用為零，不代表模型免費。';

  @override
  String portal_period(String days) {
    return '最近 $days 天';
  }

  @override
  String get portal_sessions => '工作階段';

  @override
  String get portal_input => '輸入令牌';

  @override
  String get portal_output => '輸出令牌';

  @override
  String get portal_estimated => '已記錄的預估費用';

  @override
  String get portal_actual => '已記錄的實際費用';

  @override
  String get portal_recorded_models => '已記錄模型';

  @override
  String get portal_no_models => '沒有已記錄模型。';

  @override
  String get portal_unavailable => '無法取得資料。請檢查連線、所選設定檔和閘道版本後重試。';

  @override
  String get paste_attachment_failed_text_kept => '無法將貼上的文字加為附件，文字已保留在訊息中。';

  @override
  String get background_task_report => '背景任務';

  @override
  String get background_process_report => '背景程序';

  @override
  String get background_report_issues => '已報告問題，展開查看詳細資料。';

  @override
  String get background_report_expand => '展開報告';

  @override
  String get background_report_collapse => '收合報告';

  @override
  String get copy_session_id => '複製工作階段 ID';

  @override
  String get copy_session_id_failed => '無法複製工作階段 ID。';

  @override
  String get setup_interface_title => '選擇介面';

  @override
  String get setup_interface_classic => '經典版';

  @override
  String get setup_interface_nextgen => 'NextGen';

  @override
  String get setup_interface_classic_description =>
      '原有的 Ares 工作區，提供完整的連線控制選項和所有經典版設定。';

  @override
  String get setup_interface_nextgen_description =>
      '全新介面，只需登入儀表板一次，即可查看即時計畫、子代理和通知。';

  @override
  String get setup_interface_switch_later => '你可以隨時在「設定」中切換。';

  @override
  String get ng_confirm_model_switch => '切換模型？';

  @override
  String get ng_switch => '切換';

  @override
  String get ng_model_confirmation_required => '選擇此模型前需要確認。';

  @override
  String ng_model_switches_next_turn(String model) {
    return '將在下一輪切換到 $model。';
  }

  @override
  String get ng_model_switch_not_connected => '聊天尚未準備好切換模型。請重新開啟後再試。';

  @override
  String ng_gateway_kept_default_model(String model) {
    return '閘道在此聊天中保留了 $model。請在傳送前重新選擇模型。';
  }

  @override
  String get hands_free_title => '免持對話';

  @override
  String get hands_free_start => '開始免持';

  @override
  String get hands_free_stop => '停止免持';

  @override
  String get hands_free_preparing => '正在準備語音功能，請等候就緒提示';

  @override
  String get hands_free_listening => '請說「Hey Hermes」';

  @override
  String get hands_free_recording => '已就緒，請說話';

  @override
  String get hands_free_waiting => '等待 Hermes 回覆';

  @override
  String get hands_free_speaking => '正在朗讀 — 麥克風已關閉';

  @override
  String hands_free_followup(int seconds) {
    return '最多聆聽 $seconds 秒';
  }

  @override
  String get hands_free_error => '免持已停止';

  @override
  String get hands_free_setup => '免持設定';

  @override
  String hands_free_preview(String transcript) {
    return '語音預覽：$transcript';
  }

  @override
  String get hands_free_short_disclosure =>
      '只有在前景開啟此聊天時才會聆聽。喚醒詞偵測不需連網，但語音功能可能會使用網路。聆聽會消耗電力。';

  @override
  String get hands_free_error_action =>
      '請檢查麥克風權限、語音服務、朗讀聲音和連線，先點選「停止」，再點選「開始」重試。先前的內容不會重新傳送。';

  @override
  String get hands_free_disclosure =>
      '喚醒詞由 CPU 離線偵測。Android 語音辨識、所選的朗讀聲音和閘道可能會使用網路。持續聆聽會耗電，也可能誤觸發。聊天畫面遭遮住、關閉或離開前景時，聆聽就會停止；重新開啟聊天也不會自動恢復。手動語音輸入的內容仍可在草稿中編輯。';

  @override
  String get hands_free_ready_cue =>
      '請說「Hey Hermes」，等到「已就緒，請說話」再開口。緊接在喚醒詞後的話，以及就緒前的聲音，都不會錄下。如果設定權限時離開了應用程式，請在授權後再點選「開始」。';

  @override
  String get hands_free_settings_title => '免持語音';

  @override
  String get hands_free_settings_subtitle =>
      '在聊天中顯示「Hey Hermes」啟動控制項。關閉會停止正在進行的免持工作階段。';

  @override
  String get hands_free_timing_limit =>
      '後續聆聽時間是上限，Android 可能提早停止。若未偵測到聲音，就會回到本機喚醒詞偵測，不會反覆重新啟動語音辨識。';

  @override
  String get hands_free_followup_off => '後續聆聽已關閉 — 每次提問請說 Hey Hermes';

  @override
  String get hands_free_start_blocked =>
      '請先清空草稿、移除附件並結束手動語音操作。聊天必須已連線、沒有正在處理的回覆，且已開啟語音回覆，才能開始免持對話。';

  @override
  String get hands_free_setup_complete => '麥克風設定完成。請再次點選開始。';

  @override
  String message_time_recorded(String time) {
    return '伺服器記錄的時間：$time（當地時間）';
  }

  @override
  String message_time_sent(String time) {
    return '此裝置偵測到送出的時間：$time（當地時間）';
  }

  @override
  String message_time_received(String time) {
    return '此裝置首次收到的時間：$time（當地時間）';
  }

  @override
  String get stop_and_send => '停止並傳送';

  @override
  String get message_queued_for_running_turn => '訊息已加入目前回合的佇列。';

  @override
  String get running_message_not_accepted =>
      'Hermes 無法接受這則訊息。草稿已保留；請停止回覆或等候回覆結束，再重新傳送。';

  @override
  String get running_message_delivery_unknown =>
      '無法確認訊息是否送達。草稿已保留。請先檢查聊天記錄，再重試。';

  @override
  String get attachment_tap_to_preview => '點選以預覽';

  @override
  String get attachment_save => '儲存';

  @override
  String get attachment_share => '分享';

  @override
  String get attachment_saved => '檔案已儲存';

  @override
  String get attachment_save_cancelled => '已取消儲存';

  @override
  String get attachment_save_failed => '無法儲存此檔案，請重試。';

  @override
  String get attachment_share_failed => '無法分享此檔案，請重試。';

  @override
  String get attachment_download_failed => '無法載入此檔案，請檢查連線後重試。';

  @override
  String get attachment_no_inline_preview =>
      '此檔案類型不支援內嵌預覽。請儲存或分享原始檔案，以便在其他應用程式中開啟。';

  @override
  String get attachment_image_failed => '無法解碼這張圖片。你仍可儲存或分享原始檔案。';

  @override
  String get attachment_text_truncated => '預覽內容已截短。請儲存或分享檔案以閱讀完整內容。';

  @override
  String get attachment_text_unavailable => '無法將此檔案顯示為文字。請儲存或分享原始檔案。';

  @override
  String get attachment_pdf_failed => '無法預覽此 PDF。請儲存或分享原始檔案。';

  @override
  String get attachment_pdf_unavailable => 'PDF 預覽只在 Android 上可用。你仍可儲存或分享這個檔案。';

  @override
  String attachment_pdf_page(int page, int total) {
    return '第 $page 頁，共 $total 頁';
  }

  @override
  String get attachment_previous_page => '上一頁';

  @override
  String get attachment_next_page => '下一頁';

  @override
  String get attachment_loading => '正在載入預覽…';

  @override
  String get attachment_document_text_notice => '這是純文字預覽，版面配置、圖片和格式可能與原始檔案不同。';

  @override
  String get attachment_document_failed => '無法預覽此文件。請儲存或分享原始檔案。';

  @override
  String get attachment_document_empty => '這份文件中沒有可讀取的文字。';

  @override
  String get attachment_video_failed => '無法播放此影片。其格式或編解碼器可能不受支援。請儲存或分享原始檔案。';

  @override
  String get attachment_video_play => '播放';

  @override
  String get attachment_video_pause => '暫停';

  @override
  String get attachment_video_mute => '靜音';

  @override
  String get attachment_video_unmute => '取消靜音';

  @override
  String get attachment_video_seek => '影片進度';

  @override
  String get attachment_close => '關閉預覽';

  @override
  String get attachment_retry => '重試';

  @override
  String get saved_history_heading => '已儲存的記錄';

  @override
  String get received_output_heading => '已收到的輸出（尚未確認是否與已儲存的記錄相符）';

  @override
  String get received_output_details => '關於已收到的輸出';

  @override
  String get received_output_explanation => '已儲存的記錄中可能也有這段內容，但應用程式無法確認兩者是否相符。';

  @override
  String get local_prompt_context => '本機提示詞上下文';

  @override
  String get received_output_badge => '已收到 · 尚未確認是否相符';

  @override
  String get received_output_lifetime =>
      '這些輸出只會暫存在本次使用期間。達到上限時，內容可能會縮短或移除。關閉應用程式或中斷連線後，可能無法再查看。';

  @override
  String get theme_palette => '顏色主題';

  @override
  String get theme_palette_gold => '金色';

  @override
  String get theme_palette_purple => '紫色';

  @override
  String get theme_palette_orange => '橙色';

  @override
  String get theme_palette_green => '綠色';

  @override
  String get theme_palette_blue => '藍色';

  @override
  String get theme_palette_red => '紅色';

  @override
  String get theme_palette_teal => '青綠色';

  @override
  String get theme_palette_pink => '粉色';

  @override
  String get theme_palette_indigo => '靛藍色';

  @override
  String get theme_palette_cyan => '青色';

  @override
  String get assets_recent_subtitle => '尋找 Hermes 在已儲存的聊天中分享的檔案';

  @override
  String get assets_scope_notice =>
      '這裡只顯示 Hermes 在已儲存的回覆中明確分享的生成檔案。內容取自部分聊天記錄，不是完整的檔案或附件目錄。參照的檔案可能已不存在。';

  @override
  String get assets_download_limit =>
      '點選檔案才會載入。預覽和下載的單檔上限均為 25 MiB；較大的檔案請從儀表板下載。';

  @override
  String get assets_search_hint => '搜尋找到的檔案或來源聊天';

  @override
  String get assets_all => '全部';

  @override
  String get assets_images => '圖片';

  @override
  String get assets_audio => '音訊';

  @override
  String get assets_video => '影片';

  @override
  String get assets_documents => '文件和其他檔案';

  @override
  String get assets_empty => '在已掃描的訊息中未找到資產';

  @override
  String get assets_empty_detail =>
      '掃描更多聊天或更早的訊息，以查看更早的記錄。一般附件和未連結的檔案不會在這裡建立索引。';

  @override
  String get assets_no_matches => '找不到相符的資產';

  @override
  String get assets_load_more_chats => '掃描更多聊天';

  @override
  String get assets_load_older_messages => '掃描更早的訊息';

  @override
  String get assets_load_failed => '部分歷史記錄無法讀取。結果不完整。請檢查儀表板連線並重試。';

  @override
  String get assets_retry_failed => '重試讀取失敗的歷史記錄';

  @override
  String get assets_partial => '伺服器報告歷史記錄不完整。請檢查儀表板後重新整理。';

  @override
  String assets_scan_summary(int files, int chats) {
    return '已掃描 $chats 個聊天，找到 $files 筆檔案參照';
  }

  @override
  String assets_open_chat(String title) {
    return '開啟聊天：$title';
  }

  @override
  String get assets_file_too_large => '此檔案超出下載容量上限。請開啟儀表板進行下載。';

  @override
  String get a_one_off_question_archives_itself_after_72_hours_anything =>
      '適合只問一次的問題。聊天會在 72 小時後自動封存，值得保留的內容仍會記住。';

  @override
  String get archive_chat => '封存聊天';

  @override
  String get unarchive_chat => '取消封存聊天';

  @override
  String get chat_archived => '聊天已封存';

  @override
  String get chat_unarchived => '聊天已取消封存';

  @override
  String could_not_update_chat_archive(Object error) {
    return '無法更新聊天封存狀態：$error';
  }

  @override
  String get quick_chat_description => '只想問一個問題時使用。';

  @override
  String get ai_full_text => 'AI + 全文';

  @override
  String get ai_search_model => 'AI 搜尋模型';

  @override
  String ai_searched_for(Object aiRewrittenQuery) {
    return 'AI 已搜尋：$aiRewrittenQuery';
  }

  @override
  String get ai_assisted_filing => 'AI 輔助封存';

  @override
  String get api_key => 'API 金鑰';

  @override
  String get api_server_key_from_hermes_env =>
      '來自 ~/.hermes/.env 的 API_SERVER_KEY';

  @override
  String get active => '活躍';

  @override
  String get activity => '活動';

  @override
  String get activity_reads_the_durable_turn_journal_to_know_what_hermes =>
      '「活動」會讀取已儲存的回合記錄，顯示 Hermes 正在做什麼。請確認閘道可連線後再試一次。';

  @override
  String get add => '新增';

  @override
  String get add_connection => '新增連線';

  @override
  String get add_cron_job => '新增 Cron 任務';

  @override
  String get add_gateway_connection => '新增閘道連線';

  @override
  String get add_and_update_connections_from_the_backup_keep_the_rest =>
      '從備份中新增和更新連線，其餘保持不變。';

  @override
  String get add_attachment => '新增附件';

  @override
  String get add_new_cron_job => '新增新 Cron 任務';

  @override
  String get add_to_chat => '新增到聊天';

  @override
  String get all_chats => '所有聊天';

  @override
  String get all_stored_message_content => '所有已儲存的訊息內容';

  @override
  String get allow_for_this_session => '本次工作階段允許';

  @override
  String get allow_matching_commands_until_this_hermes_session_ends =>
      '允許符合此規則的指令，直到本次 Hermes 工作階段結束。';

  @override
  String get allow_folder_until_sandbox_off => '允許此資料夾，直到關閉沙箱為止。';

  @override
  String get allow_once => '允許一次';

  @override
  String get allow_website_until_sandbox_off => '允許此網站，直到關閉沙箱為止。';

  @override
  String get always_allow => '一律允許';

  @override
  String get apply_to_this_chat => '套用至此聊天';

  @override
  String get approval_needed => '需要核准';

  @override
  String get approval_needed_description => '有指令正在等候你核准或拒絕。';

  @override
  String get approve => '核准';

  @override
  String get archive => '封存';

  @override
  String get archive_project => '封存專案';

  @override
  String archive_2(Object projectName) {
    return '封存 $projectName？';
  }

  @override
  String archive_3(Object name) {
    return '封存 $name？';
  }

  @override
  String get archived => '已封存';

  @override
  String get archived_conversations_appear_here =>
      '這裡只顯示已封存的對話。舊聊天仍保留在「所有聊天」中。';

  @override
  String get archived_quick_chats => '已封存的快速聊天';

  @override
  String get artifacts_attachments_and_generated_media => '工作成果、附件及產生的媒體檔案';

  @override
  String get ask_ai_to_find_a_conversation => '讓 AI 尋找對話';

  @override
  String get assets => '資產';

  @override
  String get assets_need_a_server_authoritative_assets_index_in_the_hermes =>
      'Hermes 閘道必須提供由伺服器統一維護的資產索引，才能依專案顯示資產。';

  @override
  String get assets_unavailable => '資產不可用';

  @override
  String get attach_image_or_file => '附加圖片或檔案';

  @override
  String get attachment_drafts => '附件草稿';

  @override
  String get recover_text_draft => '找回文字草稿';

  @override
  String get undo_draft_recovery => '復原';

  @override
  String get draft_session_exists => '此聊天仍然存在。開啟後即可繼續編輯草稿。';

  @override
  String get draft_recovery_unavailable => '無法驗證此草稿，未做任何變更。';

  @override
  String attachment_of(Object index, Object total) {
    return '附件 $index / $total';
  }

  @override
  String get auto_device_default => '自動（裝置預設）';

  @override
  String get agent => '代理程式';

  @override
  String get autonomous_agents => '自主代理程式';

  @override
  String get background_recovery_unavailable_legacy_transport =>
      '無法使用背景復原 — 舊版傳輸';

  @override
  String get background_task_completed => '背景任務完成';

  @override
  String get background_task_completed_description => '背景終端機指令已完成。';

  @override
  String get backup_restore => '備份與還原';

  @override
  String backup_exported(Object destination) {
    return '備份已匯出 — $destination';
  }

  @override
  String get base_url => '基礎 URL';

  @override
  String get binary_preview_is_unavailable_download_the_file_to_open_it =>
      '二進位預覽不可用。請下載檔案後開啟。';

  @override
  String get branch => '分支';

  @override
  String get branch_chat => '從聊天建立分支';

  @override
  String get branch_created_in_hermes_history => '已在 Hermes 歷史記錄中建立分支。';

  @override
  String get browse_and_manage_your_hermes_agent_sessions_from_your_phone =>
      '透過手機瀏覽和管理你的 Hermes Agent 工作階段。連線至在區域網路上執行的 Hermes 儀表板。';

  @override
  String get browse_server_files => '瀏覽伺服器檔案';

  @override
  String get browse_the_miniserver_folders_behind_your_projects =>
      '瀏覽各專案使用的 miniserver 資料夾';

  @override
  String get cancel => '取消';

  @override
  String get cancel_voice_input => '取消語音輸入';

  @override
  String cannot_reach(Object host, Object port) {
    return '無法連線至 $host:$port。';
  }

  @override
  String cannot_reach_check_the_host_and_port(Object host, Object port) {
    return '無法連線至 $host:$port。請檢查主機和連接埠。';
  }

  @override
  String get change_ai_search_model => '更改 AI 搜尋模型';

  @override
  String changes_the_default_for_use_the_selector_in_a_chat(Object label) {
    return '更改 $label 的預設值。在聊天中使用選擇器可僅覆寫目前對話。';
  }

  @override
  String get chat_actions => '聊天操作';

  @override
  String get chats => '聊天';

  @override
  String get chats_from_this_gateway_are_not_grouped_yet_grouping_stays =>
      '此閘道中的聊天尚未分組。分組狀態將保留在此手機上，直到閘道能夠代管專案。';

  @override
  String get chats_in_this_project_will_show_their_state_and_last =>
      '此專案中的聊天將在此處顯示其狀態和最後活動。';

  @override
  String get chats_that_are_not_assigned_to_a_project => '未分配至專案的聊天';

  @override
  String get chats_you_start_in_this_project_will_appear_here_on =>
      '你在此專案中發起的聊天將顯示在此處，並同步到登入此 Hermes 的所有裝置上。';

  @override
  String get check_that_the_gateway_is_running_and_reachable_then_try =>
      '請檢查閘道是否正在執行且可達，然後重試。';

  @override
  String get check_the_dashboard_connection_and_try_again => '請檢查儀表板連線並重試。';

  @override
  String get check_the_connection_and_try_again => '請檢查連線並重試。';

  @override
  String get choose_a_small_model_to_rewrite_queries => '選擇一個小模型來重寫查詢';

  @override
  String get choose_an_ai_search_model_before_using_ai_search =>
      '請在使用 AI 搜尋前選擇一個 AI 搜尋模型。';

  @override
  String get choose_an_active_project_next => '接下來請選擇使用中的專案';

  @override
  String get choose_chat_model => '選擇聊天模型';

  @override
  String get choose_files => '選擇檔案';

  @override
  String get choose_image => '選擇圖片';

  @override
  String get choose_images => '選擇圖片';

  @override
  String get choose_its_destination_space => '選擇其目標空間';

  @override
  String get clear_search => '清除搜尋';

  @override
  String get close => '關閉';

  @override
  String get code_copied => '程式碼已複製';

  @override
  String get code_format => '程式碼';

  @override
  String get coming_next => '敬請期待';

  @override
  String get command => '指令';

  @override
  String get command_palette => '指令面板';

  @override
  String get command_palette_hint => '輸入指令';

  @override
  String get command_palette_no_results => '找不到符合的指令';

  @override
  String get command_palette_new_chat => '新增聊天';

  @override
  String get command_palette_search_chats => '搜尋聊天';

  @override
  String get command_palette_toggle_theme => '切換主題';

  @override
  String get command_palette_copy_last_code => '複製最後一個程式碼區塊';

  @override
  String get command_line_chats => '命令列聊天';

  @override
  String get compatibility_mode => '相容模式';

  @override
  String get configure_a_valid_desktop_gateway_url_before_attaching_files =>
      '在附加檔案前，請先設定有效的 Desktop Gateway URL。';

  @override
  String get confirm_always_allow => '確認一律允許';

  @override
  String get confirm_passphrase => '確認密碼片語';

  @override
  String connecting_to(Object baseUrl) {
    return '正在連線至 $baseUrl...';
  }

  @override
  String get connection_issue => '連線問題';

  @override
  String
  get connection_switched_the_running_reply_continues_on_the_server_and =>
      '已切換連線。伺服器仍在產生回覆，應用程式會自動重新接上。';

  @override
  String get connection_appearance_and_device_preferences => '連線、外觀和裝置偏好設定';

  @override
  String context_tokens(Object effectiveContextLength) {
    return '上下文：$effectiveContextLength 令牌';
  }

  @override
  String get continue_label => '繼續';

  @override
  String get continue_working => '繼續工作';

  @override
  String get conversations_in_this_project => '此專案中的對話';

  @override
  String get copy_code => '複製程式碼';

  @override
  String get copy_message => '複製訊息';

  @override
  String could_not_branch_chat(Object error) {
    return '無法建立聊天分支：$error';
  }

  @override
  String could_not_delete_session(Object error) {
    return '無法刪除工作階段：$error';
  }

  @override
  String could_not_deny_the_command(Object error) {
    return '無法拒絕該指令：$error';
  }

  @override
  String could_not_load_ai_search_models(Object error) {
    return '無法載入 AI 搜尋模型：$error';
  }

  @override
  String get could_not_load_conversations => '無法載入對話';

  @override
  String get could_not_load_files => '無法載入檔案';

  @override
  String could_not_load_models_for_this_profile(Object error) {
    return '無法為該設定檔載入模型：$error';
  }

  @override
  String could_not_load_more_chats(Object error) {
    return '無法載入更多聊天：$error';
  }

  @override
  String get could_not_open_link => '無法開啟這個連結。';

  @override
  String get could_not_open_the_hermes_dashboard => '無法開啟 Hermes 儀表板。';

  @override
  String get could_not_open_this_project => '無法開啟此專案';

  @override
  String get could_not_preview_file => '無法預覽檔案';

  @override
  String get could_not_reach_hermes => '無法連線至 Hermes';

  @override
  String could_not_reach_authenticate_the_dashboard_at_check_the_port(
    Object dashboardPort,
    Object host,
  ) {
    return '無法連線至 $host:$dashboardPort 的儀表板，或未通過驗證。請檢查連接埠和登入資訊。';
  }

  @override
  String get could_not_read_activity => '無法讀取活動';

  @override
  String could_not_rename_chat(Object error) {
    return '無法重新命名聊天：$error';
  }

  @override
  String could_not_send_the_approval(Object error) {
    return '無法傳送核准：$error';
  }

  @override
  String get could_not_skip_the_hermes_question => '無法跳過 Hermes 的問題。';

  @override
  String could_not_the_project(Object action, Object error) {
    return '無法$action此專案：$error';
  }

  @override
  String get couldn_t_delete_project => '無法刪除專案';

  @override
  String couldn_t_load_runs(Object error) {
    return '無法載入執行記錄：$error';
  }

  @override
  String get couldn_t_move_conversation => '無法移動對話';

  @override
  String couldn_t_move_to(Object label, Object reason) {
    return '無法移動至 $label：$reason';
  }

  @override
  String get couldn_t_prepare_the_shared_files => '無法準備共用檔案。';

  @override
  String get couldn_t_promote_conversation => '無法提升工作階段';

  @override
  String couldn_t_project(Object action) {
    return '無法$action專案';
  }

  @override
  String get create => '建立';

  @override
  String get create_a_project => '建立專案';

  @override
  String get create_a_project_first_then_chats_can_live_inside_it =>
      '請先建立一個專案，聊天內容即可存放在其中。';

  @override
  String get create_a_space_to_separate_related_conversations =>
      '建立一個空間以區分相關的聊天。';

  @override
  String get create_branch => '建立分支';

  @override
  String get credit_notifications => '額度通知';

  @override
  String get credit_notifications_description => '額度使用已停止或恢復。';

  @override
  String get cron => 'Cron';

  @override
  String get crons => '排程任務';

  @override
  String get cron_conversations_empty => '排程任務的對話會顯示在這裡，包括先前執行時的對話。';

  @override
  String get search_cron_conversations => '搜尋排程任務的對話';

  @override
  String get cron_jobs => 'Cron 任務';

  @override
  String cron_schedule_timezone(Object zone) {
    return '排程時區：$zone';
  }

  @override
  String get crons_upcoming => '即將執行';

  @override
  String get crons_history => '執行歷史';

  @override
  String cron_time_with_zone(Object time, Object zone) {
    return '$time（$zone）';
  }

  @override
  String cron_time_zone_unknown(Object time) {
    return '$time（時區未知）';
  }

  @override
  String get cron_no_next_run => '未安排下次執行';

  @override
  String get cron_status_scheduled => '已排程';

  @override
  String get cron_status_paused => '已暫停';

  @override
  String cron_delivers_to(Object target) {
    return '投遞至 $target';
  }

  @override
  String get cron_upcoming_empty_title => '目前沒有已排程任務';

  @override
  String get cron_upcoming_empty_message =>
      '目前沒有待執行的排程。你可以前往「Cron 任務」新增，或請代理程式安排。';

  @override
  String get cron_upcoming_unavailable => '無法顯示已排程任務';

  @override
  String get cron_upcoming_needs_dashboard =>
      '排程任務需要連線至儀表板。此位址未提供 Cron 排程；請檢查儀表板位址，並確認主機支援這項功能。';

  @override
  String get cron_upcoming_needs_dashboard_auth =>
      '排程任務需要通過儀表板驗證。請在此連線中填寫儀表板使用者名稱和密碼，或啟用代理伺服器模式。';

  @override
  String get cron_upcoming_dashboard_unreachable =>
      '無法連線至儀表板。請檢查主機、儀表板連接埠和網路，然後重試。';

  @override
  String get cron_upcoming_load_failed => '無法讀取已排程任務。請檢查儀表板連線並重試。';

  @override
  String get cron_upcoming_refresh_failed => '無法重新整理排程。正在顯示上次成功讀取的結果。';

  @override
  String get cron_job_added => 'Cron 任務已新增';

  @override
  String get cron_job_updated => 'Cron 任務已更新';

  @override
  String get cron_run => 'Cron 執行';

  @override
  String get cross_device_ordering_and_reversible_bulk_organization =>
      '跨裝置排序與可復原的批次整理';

  @override
  String get current_profile_default => '目前設定檔預設值';

  @override
  String get custom_proxy_and_dashboard_details => '自訂代理伺服器與儀表板詳細資料';

  @override
  String get dark => '深色';

  @override
  String get dashboard_proxy_settings => '儀表板 / 代理伺服器設定';

  @override
  String get dashboard_password_optional => '儀表板密碼（選填）';

  @override
  String get dashboard_port => '儀表板連接埠';

  @override
  String get dashboard_username_optional => '儀表板使用者名稱（選填）';

  @override
  String get dashboard_behind_proxy => '位於代理伺服器後的儀表板';

  @override
  String get dashboard_path_prefix => '儀表板路徑前置字串';

  @override
  String delegated_task(Object goal) {
    return '委派任務：$goal';
  }

  @override
  String get delete => '刪除';

  @override
  String delete_2(Object name) {
    return '刪除「$name」？';
  }

  @override
  String delete_from_the_remote_hermes_history_this_cannot_be_undone(
    Object title,
  ) {
    return '從遠端 Hermes 歷史記錄中刪除「$title」？此操作不可復原。';
  }

  @override
  String get delete_cron_job => '刪除 Cron 任務';

  @override
  String get delete_connections_that_are_not_in_the_backup => '刪除不在備份中的連線。';

  @override
  String delete_failed(Object error) {
    return '刪除失敗：$error';
  }

  @override
  String get delete_project => '刪除專案';

  @override
  String get delete_session => '刪除工作階段？';

  @override
  String delete_3(Object projectName) {
    return '刪除 $projectName？';
  }

  @override
  String deleted(Object name) {
    return '已刪除「$name」';
  }

  @override
  String get delivery_is_uncertain_recovering_without_resending =>
      '尚無法確認是否送達。正在復原連線，不會重新傳送…';

  @override
  String get desktop_gateway_url_optional => 'Desktop Gateway URL（選填）';

  @override
  String get desktop_gateway_is_not_configured_for_this_connection =>
      '此連線未設定 Desktop Gateway。';

  @override
  String get desktop_app => '桌面應用程式';

  @override
  String get developer_tool_calls => '開發者工具呼叫';

  @override
  String get discord_chats => 'Discord 聊天';

  @override
  String get dismiss => '忽略';

  @override
  String get do_not_run_this_command => '請勿執行此指令。';

  @override
  String get documents_archives_audio_video_or_data => '文件、壓縮檔、音訊、影片或資料';

  @override
  String get download => '下載';

  @override
  String download_failed(Object error) {
    return '下載失敗：$error';
  }

  @override
  String get durable_facts_hermes_keeps_about_you => 'Hermes 長期記得的關於你的事';

  @override
  String get durable_work_inside_one_of_your_projects_shared_with_desktop =>
      '將工作內容長期保留在專案中，並與桌面版共用。';

  @override
  String get edit => '編輯';

  @override
  String get edit_connection => '編輯連線';

  @override
  String get edit_cron_job => '編輯 Cron 任務';

  @override
  String get edit_gateway_connection => '編輯閘道連線';

  @override
  String get edit_and_resend => '編輯並重發';

  @override
  String get enable_notifications => '啟用通知';

  @override
  String get enable_notifications_description => '關閉後將停用以下所有通知。';

  @override
  String get enables_file_attachments_through_the_desktop_remote_gateway =>
      '允許透過 Desktop 遠端閘道傳送檔案附件。';

  @override
  String get enter_a_name => '輸入名稱';

  @override
  String get enter_a_passphrase => '請輸入密碼片語。';

  @override
  String get enter_the_passphrase_for_this_backup => '請輸入此備份的密碼片語。';

  @override
  String get every_conversation_is_already_assigned_to_a_project =>
      '所有對話均已分配至某個專案。';

  @override
  String get everything_not_yet_native_in_the_authenticated_web_dashboard =>
      '應用程式尚未內建的功能，可登入網頁版儀表板使用';

  @override
  String get explain_the_attached_content_clearly => '清晰解釋附件內容。';

  @override
  String explain_this_content_clearly(Object text) {
    return '清晰解釋此內容：\n\n$text';
  }

  @override
  String
  get explicit_choices_adjust_android_accessibility_text_size_system_leaves_it =>
      '選擇指定大小會調整 Android 的無障礙文字大小；選擇「系統」則維持原有大小。';

  @override
  String get export_label => '匯出';

  @override
  String get export_share => '匯出 / 分享';

  @override
  String get external_api_clients => '外部 API 用戶端';

  @override
  String get extra_high => '極高';

  @override
  String get extract_tasks => '提取任務';

  @override
  String
  get extract_the_decisions_deadlines_owners_and_actionable_action_items_from =>
      '從附件內容中提取決策、截止日期、負責人以及可執行的待辦事項。';

  @override
  String
  extract_the_decisions_deadlines_owners_and_actionable_action_items_from_2(
    Object text,
  ) {
    return '從以下內容中提取決策、截止日期、負責人以及可執行的待辦事項：\n\n$text';
  }

  @override
  String failed_to_add_job(Object error) {
    return '新增任務失敗：$error';
  }

  @override
  String get failed_to_load_cron_jobs => '載入 Cron 任務失敗';

  @override
  String get failed_to_load_memory => '載入記憶失敗';

  @override
  String get failed_to_load_messages => '載入訊息失敗';

  @override
  String get failed_to_load_settings => '載入設定失敗';

  @override
  String get failed_to_load_skills => '載入技能失敗';

  @override
  String failed_to_update_job(Object error) {
    return '更新任務失敗：$error';
  }

  @override
  String failed(Object error) {
    return '失敗：$error';
  }

  @override
  String get file_attached_document_catalog_registration_is_pending =>
      '已附加檔案，文件目錄尚未登記完成。';

  @override
  String get file_reference_added_to_chat => '檔案參照已新增至聊天';

  @override
  String get files => '檔案';

  @override
  String get fill_from_document => '從文件填入';

  @override
  String get folder_is_empty => '這個資料夾是空的';

  @override
  String get folders => '資料夾';

  @override
  String get full_text => '全文';

  @override
  String get gateway_api_access => '閘道 API 存取';

  @override
  String get gateway_connected_but_the_dashboard_could_not_be_reached_or =>
      '閘道已連線，但無法存取儀表板或未能通過身分驗證。請檢查儀表板詳細資訊，或清除它們以跳過。';

  @override
  String get gateway_path_prefix => '閘道路徑前置字串';

  @override
  String get go_to_end => '轉到末尾';

  @override
  String get hermes_agent => 'Ares（原名 Hermes Android）';

  @override
  String get hermes_agent_for_android => 'Ares（原名 Hermes Android）';

  @override
  String get hermes_could_not_accept_the_answer_please_try_again =>
      'Hermes 無法接受此回答，請重試。';

  @override
  String get hermes_could_not_load_your_saved_connections =>
      'Hermes 無法載入你儲存的連線';

  @override
  String get hermes_did_not_accept_the_response_please_try_again =>
      'Hermes 未能接受此回應，請重試。';

  @override
  String get hermes_is_responding => 'Hermes 正在回應…';

  @override
  String get hermes_is_waiting_for_input => 'Hermes 正在等待輸入…';

  @override
  String get hermes_keeps_android_accessibility_text_scaling_active =>
      'Ares 會保留 Android 無障礙設定中的文字縮放比例。';

  @override
  String get hermes_needs_your_input => 'Hermes 需要你的輸入';

  @override
  String get hermes_profile_optional => 'Hermes 設定檔（選填）';

  @override
  String get hermes_profile_must_be_a_plain_profile_name_such_as =>
      '請輸入 Hermes 設定檔名稱（例如 sol），而不是路徑。';

  @override
  String get hermes_reasoning_details => 'Hermes 推理詳細資料';

  @override
  String hermes_recovery_is_unavailable(Object error) {
    return '無法復原 Hermes：$error';
  }

  @override
  String get hermes_stopped_recovery_safely_no_prompt_was_resent =>
      'Hermes 已安全停止復原。沒有重新傳送任何提示詞。';

  @override
  String get hide_passphrase => '隱藏密碼片語';

  @override
  String get home_needs_your_recent_chats_to_know_what_deserves_your =>
      '首頁需要你最近的聊天記錄來瞭解哪些內容值得你關注。請檢查閘道是否可達，然後重試。';

  @override
  String get host => '主機';

  @override
  String get image_selection_was_interrupted_try_again => '圖片選擇被中斷，請重試。';

  @override
  String get import_label => '匯入';

  @override
  String get inbox => '收件匣';

  @override
  String get inbox_is_clear => '沒有待處理項目';

  @override
  String get input_needed => '需要輸入';

  @override
  String get input_needed_description => 'Hermes 提出了問題，或需要密碼或金鑰。';

  @override
  String get insert_a_remote_file_reference => '插入遠端 @file 引用';

  @override
  String get invalid_port_number => '無效的連接埠號碼。';

  @override
  String get job_paused => '任務已暫停';

  @override
  String get job_resumed => '任務已繼續';

  @override
  String get job_triggered => '任務已觸發';

  @override
  String get label => '標籤';

  @override
  String last_activity(Object day, Object month, Object year) {
    return '最後活動於 $year年$month月$day日';
  }

  @override
  String last(Object lastRun) {
    return '最後執行：$lastRun';
  }

  @override
  String get leave_blank_for_default_8642_443_with_https =>
      '留空則使用預設值（8642；使用 https 時為 443）';

  @override
  String get leave_blank_for_default_9119 => '留空則使用預設值 (9119)';

  @override
  String get light => '淺色';

  @override
  String listening(Object elapsed) {
    return '正在聆聽 • $elapsed';
  }

  @override
  String listening_elapsed(Object elapsed) {
    return '正在聆聽，已耗時 $elapsed';
  }

  @override
  String get load_more => '載入更多…';

  @override
  String get loading => '正在載入';

  @override
  String get location => '位置';

  @override
  String get make_sure_the_gateway_api_server_is_running_hermes_gateway =>
      '請確認閘道的 API 伺服器正在執行\n(hermes gateway status)';

  @override
  String matches(Object assigned, Object name) {
    return '符合 $name · $assigned';
  }

  @override
  String get memory => '記憶';

  @override
  String get memory_about_you => '關於你';

  @override
  String get memory_agent_notes => '助手筆記';

  @override
  String get memory_builtin_scope =>
      '此設定檔的 USER.md 和 MEMORY.md 中儲存的事實。這裡不顯示外部記憶服務（包括 MemPalace）的內容。';

  @override
  String get memory_read_only => '僅供查看。可在聊天中請 Hermes 更正或忘記某條事實。';

  @override
  String get memory_unavailable => '此閘道或設定檔無法提供已儲存的事實。請檢查所選設定檔，並在需要時更新 Hermes。';

  @override
  String get memory_load_error => '請檢查儀表板連線和身分驗證，然後重試。';

  @override
  String get memory_read_full_fact => '閱讀完整事實';

  @override
  String get memory_full_fact_requires_update =>
      '查看完整事實需要更新的 Hermes 閘道。請更新 Hermes 並重新整理清單。';

  @override
  String get memory_fact_detail_error => '無法載入完整事實。它可能已更改；請重新整理清單後重試。';

  @override
  String get memory_entries_are_cross_session_facts_the_agent_remembers_they =>
      'Hermes 記住的事實會顯示在這裡。';

  @override
  String get merge => '合併';

  @override
  String get message => '訊息';

  @override
  String get message_hermes => '給 Hermes 傳送訊息…';

  @override
  String get message_actions => '訊息操作';

  @override
  String get message_copied => '已複製訊息';

  @override
  String get migrating => '正在遷移…';

  @override
  String get migration_complete => '遷移完成';

  @override
  String get migration_failed_local_spaces_were_kept_unchanged =>
      '遷移失敗。本機空間保持不變。';

  @override
  String get migration_incomplete => '遷移未完成';

  @override
  String get migration_preview => '遷移預覽';

  @override
  String get model => '模型';

  @override
  String get model_and_thinking_for_this_chat => '此聊天的模型和思考狀態';

  @override
  String model_was_not_changed(Object error) {
    return '模型未更改：$error';
  }

  @override
  String get move_attachment_next => '將附件往後移一位';

  @override
  String get move_attachment_previous => '將附件往前移一位';

  @override
  String get move_chat => '移動聊天';

  @override
  String get move_conversation => '移動工作階段';

  @override
  String get move_to_project => '移動到專案';

  @override
  String get move_to_space => '移動到空間';

  @override
  String get moved_to_a_project => '已移動到專案';

  @override
  String moved_to(Object label) {
    return '已移動到 $label';
  }

  @override
  String get name => '名稱';

  @override
  String get name_prompt_and_schedule_are_required => '名稱、提示詞和排程均為必填項';

  @override
  String get nav_activity => '活動';

  @override
  String get nav_projects => '專案';

  @override
  String get needs_a_correction_aware_filing_contract_in_the_hermes_gateway =>
      'Hermes 閘道必須支援可依使用者更正來調整的歸類機制。';

  @override
  String get needs_a_reachable_hermes_dashboard_check_the_host_port_and =>
      '需要可存取的 Hermes 儀表板。請檢查此連線的主機、連接埠和驗證資訊。';

  @override
  String get needs_a_server_authoritative_assets_index_in_the_hermes_gateway =>
      'Hermes 閘道必須提供由伺服器統一維護的資產索引。';

  @override
  String get needs_durable_pin_ordering_batch_mutation_and_undo_contracts_in =>
      'Hermes 閘道必須能儲存置頂順序，並支援批次變更與復原。';

  @override
  String get needs_you => '需要你';

  @override
  String get new_label => '新';

  @override
  String get new_chat => '新增聊天';

  @override
  String get new_chat_2 => '新增聊天';

  @override
  String new_chat_3(Object projectName) {
    return '新增聊天 · $projectName';
  }

  @override
  String get new_project => '新增專案';

  @override
  String get new_space => '新增空間';

  @override
  String next(Object nextRun) {
    return '下次執行：$nextRun';
  }

  @override
  String get nginx_injects_auth_app_sends_clean_requests =>
      '由 Nginx 加入驗證資訊，應用程式送出要求時不附驗證資訊';

  @override
  String get no_tts_voices_found_ninstall_google_text_to_speech_and =>
      '未找到 TTS 語音。\n請安裝 Google Text-to-Speech 並下載語音資料。';

  @override
  String get no_active_projects_on_this_gateway => '此閘道目前沒有使用中的專案';

  @override
  String get no_activity_yet => '目前沒有活動';

  @override
  String get no_chat_is_blocked_running_or_waiting_to_be_resumed =>
      '沒有受阻、正在執行或等待繼續的聊天。準備好後可以開始新的聊天。';

  @override
  String no_chats_in_this_project_match(Object searchQuery) {
    return '此專案中找不到符合「$searchQuery」的聊天。';
  }

  @override
  String get no_chats_in_this_space_yet_tap_to_start_one =>
      '此空間目前沒有聊天。點選 + 開始聊天。';

  @override
  String get no_chats_yet => '目前沒有聊天';

  @override
  String get no_connections => '無連線';

  @override
  String get no_conversation_matches_this_view => '沒有符合目前篩選條件的對話。';

  @override
  String get no_cron_jobs => '目前沒有 Cron 任務';

  @override
  String get no_folders_yet => '目前沒有資料夾';

  @override
  String get no_local_spaces_were_found_for_this_connection_so_projects =>
      '在此連線中未找到本機空間，因此專案已是此處的唯一組織方式。';

  @override
  String get no_matches => '無相符項目';

  @override
  String get no_memory_entries => '目前沒有記憶項目';

  @override
  String get no_message_content_matches => '無符合的訊息內容';

  @override
  String get no_new_messages => '目前沒有新訊息';

  @override
  String get no_projects_yet => '目前沒有專案';

  @override
  String get no_runs_yet => '目前沒有執行記錄。';

  @override
  String no_server_project_matches_this_name(Object assigned) {
    return '伺服器上沒有同名的專案 · $assigned';
  }

  @override
  String get no_sessions_yet => '目前沒有工作階段';

  @override
  String get no_skills_found => '未找到技能';

  @override
  String get no_spaces_on_this_device => '此裝置上無空間';

  @override
  String get no_text_shared => '未共用文字';

  @override
  String get no_turn_is_blocked_in_flight_or_recently_finished_work =>
      '沒有受阻、進行中或最近完成的回合。你開始的工作會顯示在這裡。';

  @override
  String get no_turn_needs_your_input_or_has_failed => '沒有需要你輸入或失敗的回合。';

  @override
  String get no_unassigned_chats => '目前沒有未分配的聊天。';

  @override
  String get nothing_changed_in_the_last_seven_days => '最近七天無更改。';

  @override
  String get nothing_has_moved_yet_this_is_only_what_a_migration =>
      '尚未移動任何內容 — 這只是遷移將執行的操作。';

  @override
  String get nothing_here => '這裡什麼也沒有';

  @override
  String get nothing_is_running => '沒有正在執行的內容';

  @override
  String get nothing_needs_you => '一切正常，不必處理';

  @override
  String get nothing_to_migrate => '不必遷移';

  @override
  String get notifications => '通知';

  @override
  String get windows_notifications_blocked =>
      '無法使用通知。請使用已安裝的 Ares 應用程式，並檢查 Windows 的「設定」→「系統」→「通知」。';

  @override
  String get windows_notification_diagnostics => 'Ares 傳送給 Windows 的內容';

  @override
  String get chat_activity_share => '分享聊天活動';

  @override
  String get chat_activity_share_hint =>
      '在你使用此聊天時告知相容的已連線閘道，讓其手機通知外掛程式避免重複提醒。不會傳送任何金鑰或訊息內容。';

  @override
  String get completion_sound => '完成提示音';

  @override
  String get completion_sound_system => '系統預設';

  @override
  String get completion_sound_mail => '郵件';

  @override
  String get completion_sound_reminder => '提醒';

  @override
  String get completion_sound_silent => '靜音';

  @override
  String get completion_sound_scope => '會在回覆完成、測試通知及應用程式內播放。核准和其他提醒維持原本的音效。';

  @override
  String get completion_sound_scope_android =>
      '會在回覆完成、測試通知及應用程式內播放。核准、其他提醒、伺服器的背景通知和 Android Auto 訊息維持原本的音效。';

  @override
  String get notification_open_action => '開啟';

  @override
  String get app_sounds_mute => '將應用程式音效設為靜音';

  @override
  String get app_sounds_mute_hint => '停止 Ares 開啟時播放的完成提示音。通知會保留自己的音效。';

  @override
  String get notifications_permission_denied =>
      '系統已阻止通知。請在 Android 設定中允許此應用程式傳送通知。';

  @override
  String get off_no_thinking => '關閉（無思考）';

  @override
  String get offline_showing_the_last_known_activity => '離線 — 顯示最後已知的活動。';

  @override
  String get offline_showing_the_last_known_chats => '離線 — 顯示最後已知的聊天';

  @override
  String get offline_showing_the_last_known_projects => '離線 — 正在顯示最後已知的專案。';

  @override
  String get on_this_device => '此裝置上';

  @override
  String get on_device => '裝置端';

  @override
  String get open_inbox => '開啟收件匣';

  @override
  String open_inbox_2(Object count) {
    return '開啟收件匣（$count）';
  }

  @override
  String get open_the_hermes_dashboard => '開啟 Hermes 儀表板';

  @override
  String get optional_for_the_memory_cron_skills_settings_tabs_leave_blank =>
      '選填。用於「記憶」、「Cron」、「技能」、「設定」分頁。留空則使用預設儀表板連接埠（9119）且不必登入。';

  @override
  String get organization => '組織';

  @override
  String get other_answer => '其他回答';

  @override
  String get overview => '概覽';

  @override
  String get passphrase => '密碼片語';

  @override
  String get password_optional => '密碼（選填）';

  @override
  String get phone_or_tablet => '手機或平板電腦';

  @override
  String get pin_batch_and_undo => '置頂、批次操作與復原';

  @override
  String get plugin_notifications => '外掛程式通知';

  @override
  String get plugin_notifications_description => '應用程式在背景時，閘道發來了通知。';

  @override
  String get port => '連接埠';

  @override
  String get preparing_attachments => '正在準備附件…';

  @override
  String get preview_truncated => '預覽已截斷';

  @override
  String get preview_unavailable => '預覽不可用';

  @override
  String get profile => '設定檔';

  @override
  String get profile_default_model => '設定檔預設模型';

  @override
  String profile_default_set_to_chats_with_their_own_model_keep(
    Object selectedModel,
  ) {
    return '此設定檔的預設模型已設為 $selectedModel。已個別指定模型的聊天不受影響。';
  }

  @override
  String
  get profile_this_connection_chats_as_when_the_dashboard_serves_several =>
      '如果儀表板提供多個設定檔，請指定此連線聊天時使用哪一個。若儀表板只供單一設定檔使用，請留白。';

  @override
  String get project => '專案';

  @override
  String get project_actions => '專案操作';

  @override
  String get project_chat => '專案聊天';

  @override
  String get project_chats_unavailable => '專案聊天不可用';

  @override
  String get projects => '專案';

  @override
  String get projects_group_related_chats_files_and_activity_and_stay_in =>
      '專案將相關的聊天、檔案和活動進行分組，並與你電腦上的 Hermes 保持同步。';

  @override
  String
  get projects_need_a_desktop_gateway_connection_add_the_desktop_gateway =>
      '專案需要 Desktop Gateway 連線。請將 Desktop Gateway URL 新增到此連線，以便跨裝置管理聊天。';

  @override
  String get projects_unavailable => '專案不可用';

  @override
  String get projects_activity_new_navigation => '專案、活動 — 新導覽';

  @override
  String get promote_to_project => '提升為專案';

  @override
  String get prompt => '提示詞';

  @override
  String get protect_this_backup => '保護此備份';

  @override
  String get provider => '供應商';

  @override
  String get proxy_injects_auth_app_sends_clean_requests =>
      '由代理伺服器加入驗證資訊，應用程式送出要求時不附驗證資訊';

  @override
  String get quick_chat => '快速聊天';

  @override
  String get quick_chats_appear_here_after_their_retention_period =>
      '快速聊天將在保留期過後顯示在此處。';

  @override
  String get read_aloud => '朗讀';

  @override
  String get read_aloud_is_unavailable_on_this_device => '此裝置不支援朗讀功能';

  @override
  String get reading_response_aloud => '正在朗讀回覆';

  @override
  String get ready_to_upload => '準備上傳';

  @override
  String get reasoning => '推理';

  @override
  String get recently_completed => '最近完成';

  @override
  String get recently_active => '最近活躍';

  @override
  String get recovering_hermes => '正在復原 Hermes…';

  @override
  String get refresh => '重新整理';

  @override
  String get regenerate_response => '重新生成回覆';

  @override
  String get remove_attachment => '移除附件';

  @override
  String get rename => '重新命名';

  @override
  String get rename_chat => '重新命名聊天';

  @override
  String get rename_project => '重新命名專案';

  @override
  String get rename_space => '重新命名空間';

  @override
  String rename_2(Object projectName) {
    return '重新命名 $projectName';
  }

  @override
  String rename_3(Object name) {
    return '重新命名 $name';
  }

  @override
  String get replace => '替換';

  @override
  String get repositories => '程式碼儲存庫';

  @override
  String
  get research_the_attached_content_verify_the_important_claims_and_cite =>
      '研究附件內容，核實重要主張並引用來源。';

  @override
  String research_this_content_verify_the_important_claims_and_cite_sources(
    Object text,
  ) {
    return '研究此內容，核實重要主張並引用來源：\n\n$text';
  }

  @override
  String reset_failed_the_secure_storage_may_need_reinstall(Object retryError) {
    return '重設失敗：$retryError。安全儲存可能需要重新安裝。';
  }

  @override
  String get reset_saved_connections => '重設已儲存的連線';

  @override
  String get responding => '正在回應…';

  @override
  String response_closed_locally_gateway_stop_failed(Object error) {
    return '回應已在本機關閉；閘道停止失敗：$error';
  }

  @override
  String get response_closed_locally_no_active_gateway_turn_was_found =>
      '回應已在本機關閉；未找到活動的閘道回合。';

  @override
  String get response_complete => '回應完成';

  @override
  String get response_complete_description => '應用程式在背景時，一輪對話已完成。';

  @override
  String get response_ready => '回覆就緒';

  @override
  String get response_stopped => '回覆已停止。';

  @override
  String get restore => '還原';

  @override
  String get restore_configuration => '還原設定';

  @override
  String get restore_project => '還原專案';

  @override
  String get retry => '重試';

  @override
  String retry_failed_for_the_draft_and_prompt_were_kept(Object name) {
    return '$name 重試失敗。草稿和提示詞已保留。';
  }

  @override
  String get retry_upload => '重試上傳';

  @override
  String retrying(Object name) {
    return '正在重試 $name…';
  }

  @override
  String get review_local_spaces => '檢查本機空間';

  @override
  String get review_or_promote_quick_chats_past_their_retention_period =>
      '查看或提升超出保留期限的快速聊天';

  @override
  String get review_the_attached_content => '查看附件內容。';

  @override
  String get run_only_this_command => '僅執行此指令。';

  @override
  String get running_now => '正在執行';

  @override
  String get save => '儲存';

  @override
  String get save_changes => '儲存更改';

  @override
  String get save_a_permanent_rule_in_the_hermes_configuration =>
      '在 Hermes 設定中儲存永久規則。';

  @override
  String get save_the_durable_facts_from_the_attached_content_to_memory =>
      '將附件內容中的持久事實儲存到記憶中，然後確認保留的內容。';

  @override
  String save_the_durable_facts_from_this_content_to_memory_then(Object text) {
    return '將此內容中的持久事實儲存到記憶中，然後確認保留的內容：\n\n$text';
  }

  @override
  String get save_your_connections_and_settings_to_an_encrypted_file_then =>
      '將連線和設定儲存為加密檔案，重新安裝後或換用其他裝置時即可還原。';

  @override
  String save_2(Object filename) {
    return '儲存 $filename';
  }

  @override
  String get schedule => '排程';

  @override
  String get scheduled_jobs_and_their_last_runs => '排程任務及其最近執行情況';

  @override
  String get scheduled_tasks => '排程任務';

  @override
  String get script_only_no_agent => '僅執行指令稿（不使用代理程式）';

  @override
  String get scroll_horizontally => '水平捲動';

  @override
  String get search_all_chats => '搜尋所有聊天';

  @override
  String get search_all_message_content => '搜尋所有訊息內容';

  @override
  String get search_chats => '搜尋聊天';

  @override
  String get search_conversations => '搜尋對話';

  @override
  String get search_loaded_chats => '搜尋已載入的聊天';

  @override
  String get search_mode => '搜尋模式';

  @override
  String get select_one_option_or_enter_another_answer => '選擇一個選項，或輸入其他答案。';

  @override
  String get select_one_or_more_options_then_continue => '選擇一個或多個選項，然後繼續。';

  @override
  String get select_text => '選擇文字';

  @override
  String get send => '傳送';

  @override
  String send_failed(Object error) {
    return '傳送失敗：$error';
  }

  @override
  String send_failed_api_only_permission_denied(Object error) {
    return '傳送失敗：$error。伺服器拒絕了以 API 金鑰身分進行的寫入。如果這個工作階段屬於儀表板，為此連線填寫儀表板使用者名稱和密碼或許就能傳送；伺服器也可能是刻意拒絕這項操作。';
  }

  @override
  String get send_message => '傳送訊息';

  @override
  String get send_test_notification => '傳送測試通知';

  @override
  String get session_sources => '工作階段來源';

  @override
  String get session_deleted_from_remote_hermes => '已從遠端 Hermes 中刪除工作階段。';

  @override
  String session_search_failed(Object error) {
    return '工作階段搜尋失敗：$error';
  }

  @override
  String get set_profile_default => '設為此設定檔的預設模型';

  @override
  String get settings => '設定';

  @override
  String get share_to_hermes => '分享到 Hermes';

  @override
  String get show_passphrase => '顯示密碼片語';

  @override
  String get show_tool_calls_thinking_and_message_metadata =>
      '顯示工具呼叫、思考過程和訊息中繼資料';

  @override
  String get signal_messages => 'Signal 訊息';

  @override
  String get skills => '技能';

  @override
  String skills_2(Object count) {
    return '技能（$count）';
  }

  @override
  String get skills_and_tools => '技能與工具';

  @override
  String get skip => '跳過';

  @override
  String get slack_chats => 'Slack 聊天';

  @override
  String source(Object source) {
    return '來源：$source';
  }

  @override
  String get space_actions => '空間操作';

  @override
  String get spaces => '空間';

  @override
  String get speak_to_hermes => '對 Hermes 說話';

  @override
  String get speech_recognition_is_unavailable => '語音辨識不可用';

  @override
  String get spoken_replies => '語音回覆';

  @override
  String get spoken_replies_off => '語音回覆已關閉';

  @override
  String get spoken_replies_on => '語音回覆已開啟';

  @override
  String get stalled_no_update_from_hermes => '已停滯 — 未收到來自 Hermes 的更新';

  @override
  String get start_something_new => '開啟新任務';

  @override
  String get start_voice_input => '開始語音輸入';

  @override
  String get starting_hermes => '正在啟動 Hermes…';

  @override
  String get media_card_download => '下載檔案';

  @override
  String get media_card_tap_to_download => '點選即可下載';

  @override
  String get still_loading_your_projects => '正在載入你的專案。';

  @override
  String get stop => '停止';

  @override
  String get stop_response => '停止回應';

  @override
  String get stop_voice_input => '停止語音輸入';

  @override
  String get submitted_waiting_for_hermes => '已送出，等待 Hermes 回應';

  @override
  String get suggest_projects_and_learn_from_your_corrections =>
      '建議專案並從你的更正中學習';

  @override
  String get summarize_the_attached_content => '摘要附件內容。';

  @override
  String summarize_this_content(Object text) {
    return '摘要此內容：\n\n$text';
  }

  @override
  String get switch_profile => '切換設定檔';

  @override
  String get system => '系統';

  @override
  String get take_photo => '拍照';

  @override
  String get tap_to_add_a_remote_hermes_gateway_api_server_port =>
      '點選 + 新增遠端 Hermes 閘道\n（API 伺服器，連接埠 8642）';

  @override
  String get tap_the_button_to_start_a_new_chat => '點選 + 按鈕開始新的聊天';

  @override
  String get telegram_messages => 'Telegram 訊息';

  @override
  String get terminal_sessions => '終端機工作階段';

  @override
  String get test_notification_body => '如果你能看到這條通知，說明通知功能正常。';

  @override
  String get test_notification_sent => '已傳送測試通知。';

  @override
  String get test_notification_title => 'Hermes 通知測試';

  @override
  String get test_notification_unsupported => '無法傳送通知——請檢查系統是否允許通知。';

  @override
  String get text_size => '文字大小';

  @override
  String get text_size_preview => '文字大小預覽';

  @override
  String text_size_2(Object label) {
    return '文字大小：$label';
  }

  @override
  String get the_api_key_could_not_be_stored_securely => '無法安全儲存 API 金鑰。';

  @override
  String get the_project_will_move_to_archived_its_chats_and_files =>
      '專案會移至「已封存」，聊天和檔案都會保留。你可以隨時還原專案。';

  @override
  String get the_project_will_move_to_archived_its_chats_and_files_2 =>
      '專案會移至「已封存」，聊天和檔案都會保留。你可以稍後還原專案。';

  @override
  String get the_active_profile_did_not_return_any_selectable_models =>
      '目前的設定檔未傳回任何可供選擇的模型。';

  @override
  String get the_backup_could_not_be_exported => '無法匯出備份。';

  @override
  String get the_backup_could_not_be_restored => '無法還原備份。';

  @override
  String get the_connection_could_not_be_deleted_safely => '無法安全刪除連線。';

  @override
  String get the_connection_could_not_be_stored_securely => '無法安全儲存連線。';

  @override
  String get the_dashboard_credentials_could_not_be_stored_securely =>
      '無法安全儲存儀表板驗證資訊。';

  @override
  String get the_detached_reply_failed => '已分離的回覆失敗。';

  @override
  String the_detached_reply_failed_2(Object error) {
    return '已分離的回覆失敗：$error';
  }

  @override
  String get the_file_contains_your_api_keys_and_dashboard_password_so =>
      '這份檔案包含你的 API 金鑰和儀表板密碼，因此已加密。沒有密碼片語就無法還原備份。';

  @override
  String get the_last_turn_failed => '上一輪對話失敗';

  @override
  String the_local_connection_store_looks_damaged_you_can_reset_the(
    Object errorType,
  ) {
    return '本機連線儲存似乎已損壞 ($errorType)。你可以重設已儲存的連線並重新開始。閘道上的聊天記錄不受影響。';
  }

  @override
  String get the_model_only_rewrites_your_question_into_a_short_full =>
      '該模型僅將你的問題重寫為簡短的全文查詢。Hermes 使用已在主機上設定的供應商驗證資訊。';

  @override
  String get the_server_has_not_reported_folders_for_this_project_yet =>
      '伺服器尚未報告此專案的資料夾。全局檔案仍可在「更多」中查看。';

  @override
  String get the_turn_failed => '本輪對話失敗';

  @override
  String get the_two_passphrases_do_not_match => '兩次輸入的密碼片語不一致。';

  @override
  String get the_value_is_sent_directly_to_the_active_hermes_gateway =>
      '該值將直接傳送至目前活動的 Hermes 閘道，不會被此 Android 應用程式儲存。';

  @override
  String get there_are_no_visible_files_in_this_server_folder =>
      '此伺服器資料夾中沒有可見檔案。';

  @override
  String get thinking_effort => '思考強度';

  @override
  String get this_hermes_gateway_does_not_support_opening_a_project_yet =>
      '此 Hermes 閘道尚不支援開啟專案。請更新伺服器上的 Hermes 以在手機上瀏覽專案。';

  @override
  String get this_hermes_gateway_is_older_than_server_side_projects_so =>
      '此 Hermes 閘道版本舊於伺服器端專案功能，因此聊天僅在此裝置上分組。請更新 Hermes 以在多台裝置間共用相同專案。';

  @override
  String get this_project_has_no_folder_to_open_the_chat_in =>
      '此專案需要先新增資料夾才能在其中開始聊天。新增資料夾後請重試。';

  @override
  String get this_chat_has_no_messages_available_in_the_desktop_session =>
      '桌面版的工作階段中尚無此聊天的訊息。';

  @override
  String get this_creates_a_permanent_rule_in_hermes_review_the_full =>
      '這將在 Hermes 中建立永久規則。確認前請仔細檢查完整指令。';

  @override
  String get this_gateway_does_not_host_projects_yet_update_the_gateway =>
      '此閘道尚不支援代管專案。請更新閘道以在各裝置間整理聊天。';

  @override
  String get this_permanently_deletes_the_project_chats_will_not_be_deleted =>
      '這將永久刪除該專案。聊天記錄不會被刪除；它們將返回至未分配狀態。';

  @override
  String get this_server_doesn_t_offer_background_recovery_chats_run_live =>
      '此伺服器不提供背景復原 — 聊天只在連線時即時進行';

  @override
  String get this_week => '本週';

  @override
  String get titles_previews_and_models => '標題、預覽與模型';

  @override
  String get tool_activity => '工具活動';

  @override
  String get trigger_now => '立即觸發';

  @override
  String get received_outcome_unknown => '本輪對話已結束 — 結果未確認';

  @override
  String get turn_completed => '本輪對話已完成';

  @override
  String get turn_failed => '對話失敗';

  @override
  String get turn_failed_description => '背景對話以錯誤結束。';

  @override
  String get turn_recovery_failed => '無法復原這個回合';

  @override
  String get unable_to_prepare_this_file_try_another_one => '無法準備此檔案，請嘗試其他檔案。';

  @override
  String get unable_to_prepare_this_image_try_another_one => '無法準備此圖片，請嘗試其他圖片。';

  @override
  String unable_to_prepare(Object name) {
    return '無法準備 $name。';
  }

  @override
  String get unable_to_read_the_selected_image_the_selection_was_kept =>
      '無法讀取所選圖片，已保留目前選擇。';

  @override
  String get unassigned => '未分配';

  @override
  String get unassigned_chats => '未分配的聊天';

  @override
  String get untitled_chat => '未命名聊天';

  @override
  String get untitled_session => '未命名工作階段';

  @override
  String get update_api_key => '更新 API 金鑰';

  @override
  String get upload_failed => '上傳失敗';

  @override
  String get upload_failed_tap_retry => '上傳失敗 • 點選重試';

  @override
  String uploading(Object index, Object name, Object total) {
    return '正在上傳 $index/$total：$name';
  }

  @override
  String get use_as_is => '直接使用';

  @override
  String get use_at_least_8_characters => '請使用至少 8 個字元。';

  @override
  String get use_for_cron_jobs_backed_by_scripts => '用於由腳本支援的 Cron 任務。';

  @override
  String get use_on_device => '使用裝置端';

  @override
  String get use_the_attached_content_to_identify_and_fill_the_relevant =>
      '使用附件內容辨識並填寫相關文件或表單欄位。送出任何內容前請先詢問。';

  @override
  String use_this_content_to_identify_and_fill_the_relevant_document(
    Object text,
  ) {
    return '使用此內容辨識並填寫相關文件或表單欄位。送出任何內容前請先詢問：\n\n$text';
  }

  @override
  String get used_for_hosted_path_prefixes_and_for_the_settings_memory =>
      '用於代管服務的路徑前綴，以及「設定」、「記憶」、「技能」和「Cron」分頁。如果儀表板不需登入，請將使用者名稱和密碼留白；如果由反向代理伺服器加入驗證資訊，請啟用代理伺服器模式。';

  @override
  String get username_optional => '使用者名稱（選填）';

  @override
  String using(Object displayName) {
    return '正在使用 $displayName…';
  }

  @override
  String get verbose_mode => '詳細模式';

  @override
  String get message_metadata => '訊息詳細資料';

  @override
  String get voice => '語音';

  @override
  String voice_setup_failed(Object error) {
    return '語音設定失敗：$error';
  }

  @override
  String get waiting_for_your_input => '等待你的輸入';

  @override
  String get what_hermes_knows_how_to_do => 'Hermes 能夠做的事情';

  @override
  String get what_should_the_agent_do => '要讓代理程式做什麼？';

  @override
  String get whatsapp_messages => 'WhatsApp 訊息';

  @override
  String get which_project => '哪個專案？';

  @override
  String get workspace => '工作區';

  @override
  String get wrap_lines => '自動換行';

  @override
  String you_can_attach_up_to_items(Object maxRemoteAttachmentDrafts) {
    return '最多可附加 $maxRemoteAttachmentDrafts 個項目。';
  }

  @override
  String get your_answer => '你的回答';

  @override
  String get e_g_dashboard => '例如 /dashboard';

  @override
  String get e_g_dashboard_proxy_path_before_api =>
      '例如 /dashboard（/api/ 之前的代理伺服器路徑）';

  @override
  String get e_g_profile_peter => '例如 /profile/peter';

  @override
  String get e_g_sol => '例如 sol';

  @override
  String get e_g_0_9_or_every_2h => '例如 0 9 * * * 或 every 2h';

  @override
  String get e_g_daily_backup => '例如每日備份';

  @override
  String downloaded(Object filename) {
    return '已下載 $filename';
  }

  @override
  String activity_name_status(Object displayName, Object statusLabel) {
    return '$displayName：$statusLabel';
  }

  @override
  String connection_status_label(Object connectionLabel, Object label) {
    return '$connectionLabel $label';
  }

  @override
  String get example_host_hint =>
      '192.168.1.50、100.x.y.z 或 hermes-machine.tailnet.ts.net';

  @override
  String get example_profile_prefix_hint_full =>
      '例如 /profile/peter（/api/ 和 /v1/ 之前的代理伺服器路徑）';

  @override
  String and_more(Object count) {
    return '另外 $count 個';
  }

  @override
  String chats_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個聊天',
      one: '$count 個聊天',
    );
    return '$_temp0';
  }

  @override
  String on_this_device_only(Object chats) {
    return '$chats · 僅在此裝置上';
  }

  @override
  String spaces_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個空間',
      one: '$count 個空間',
    );
    return '$_temp0';
  }

  @override
  String get no_new_projects_needed => '不必建立新專案';

  @override
  String projects_to_create(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '待建立 $count 個專案',
      one: '待建立 $count 個專案',
    );
    return '$_temp0';
  }

  @override
  String chats_migrated_projects_created(
    Object createdProjects,
    Object linkedSessions,
  ) {
    return '已遷移 $linkedSessions 個聊天 · 已建立 $createdProjects 個專案';
  }

  @override
  String chats_stayed_in_local_spaces(Object unlinkedSessions) {
    return '$unlinkedSessions 個聊天保留在本機空間中，可安全重試。';
  }

  @override
  String model_recommended(Object provider) {
    return '$provider • 推薦：小巧且經濟';
  }

  @override
  String session_meta(Object count, Object model, Object time) {
    return '$count 則訊息 • $model • $time';
  }

  @override
  String model_scope_label(Object model, Object scope) {
    return '$model • $scope';
  }

  @override
  String get this_chat => '此聊天';

  @override
  String get profile_default => '設定檔預設值';

  @override
  String minutes_ago(Object count) {
    return '$count 分鐘前';
  }

  @override
  String hours_ago(Object count) {
    return '$count 小時前';
  }

  @override
  String days_ago(Object count) {
    return '$count 天前';
  }

  @override
  String get now_label => '剛剛';

  @override
  String get latest_label => '最新';

  @override
  String new_count_indicator(Object count) {
    return '$count 則新訊息';
  }

  @override
  String new_messages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 則新訊息',
      one: '$count 則新訊息',
    );
    return '$_temp0';
  }

  @override
  String activity_failed_summary(Object failures, Object total) {
    return '$failures 個失敗 • 共 $total 個';
  }

  @override
  String activity_completed_summary(Object count) {
    return '已完成 $count 個';
  }

  @override
  String tool_start_observed(Object time) {
    return '偵測到開始的時間：$time（當地時間）';
  }

  @override
  String tool_last_observed(Object time) {
    return '最後一次偵測到的時間：$time（當地時間）';
  }

  @override
  String tool_result_recorded(Object time) {
    return '結果記錄時間：$time（當地時間）';
  }

  @override
  String get tool_time_unavailable => '時間不可用';

  @override
  String get hermes_is_using_a_tool => 'Hermes 正在使用工具';

  @override
  String hermes_is_using_tools(Object count) {
    return 'Hermes 正在使用 $count 個工具';
  }

  @override
  String delegated_tasks_completed(Object count) {
    return '已完成 $count 個委派任務';
  }

  @override
  String delegated_tasks_active(Object count) {
    return '$count 個委派任務進行中';
  }

  @override
  String branch_main(Object label) {
    return '$label · main';
  }

  @override
  String get you_heading => '## 你';

  @override
  String get hermes_heading => '## Hermes';

  @override
  String get action_label => '操作';

  @override
  String get destination_label => '目標';

  @override
  String get markdown_source => '原始碼';

  @override
  String get preview_label => '預覽';

  @override
  String get share_action_summarize => '摘要';

  @override
  String get share_action_explain => '解釋';

  @override
  String get share_action_research => '研究';

  @override
  String get share_action_remember => '記住';

  @override
  String get text_size_small => '小';

  @override
  String get text_size_default => '預設';

  @override
  String get text_size_large => '大';

  @override
  String get text_size_extra_large => '特大';

  @override
  String get text_size_use_system_description => '完全使用 Android 無障礙文字大小。';

  @override
  String text_size_percent_description(Object percent) {
    return 'Android 文字大小的 $percent%。';
  }

  @override
  String text_size_label_description(Object description, Object label) {
    return '$label — $description';
  }

  @override
  String files_skipped(Object count) {
    return '已跳過 $count 個檔案：超出限制、大小超限、無法讀取或檔名包含敏感資訊。';
  }

  @override
  String model_scope_applied(Object effort, Object model) {
    return '$model • $effort 現僅套用至此聊天。';
  }

  @override
  String get reasoning_minimal => '極簡';

  @override
  String get reasoning_low => '低';

  @override
  String get reasoning_medium => '中';

  @override
  String get reasoning_high => '高';

  @override
  String get reasoning_max => '最大';

  @override
  String get reasoning_ultra => '極致';

  @override
  String get status_running => '執行中';

  @override
  String get status_failed => '已失敗';

  @override
  String get status_done => '完成';

  @override
  String get status_idle => '空閒';

  @override
  String get upload_status_uploading => '正在上傳';

  @override
  String get upload_status_uploaded => '已上傳';

  @override
  String attachment_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個附件',
      one: '$count 個附件',
    );
    return '$_temp0';
  }

  @override
  String get action_create => '建立';

  @override
  String get action_rename => '重新命名';

  @override
  String get action_archive => '封存';

  @override
  String get action_restore => '還原';

  @override
  String get action_delete => '刪除';

  @override
  String get migrate => '遷移';

  @override
  String assigned_chats(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個已指派的聊天',
      one: '$count 個已指派的聊天',
    );
    return '$_temp0';
  }

  @override
  String get date_today => '今天';

  @override
  String get date_yesterday => '昨天';

  @override
  String get date_earlier => '更早';

  @override
  String get nav_home => '首頁';

  @override
  String get nav_more => '更多';

  @override
  String get status_completed => '已完成';

  @override
  String get filter_all => '全部';

  @override
  String get filter_recent => '最近';

  @override
  String connection_address_key(Object address, Object status) {
    return '$address  •  金鑰：$status';
  }

  @override
  String model_via_provider(Object model, Object provider) {
    return '$model  \n透過 `$provider`';
  }

  @override
  String get deny => '拒絕';

  @override
  String get connect => '連線';

  @override
  String get appearance => '外觀';

  @override
  String get connection_section => '連線';

  @override
  String get about => '關於';

  @override
  String version_label(Object version) {
    return '版本 $version';
  }

  @override
  String get matched => '相符';

  @override
  String get search => '搜尋';

  @override
  String get on => '開';

  @override
  String get off => '關';

  @override
  String get reasoning_off => '關';

  @override
  String get hermes_response_ready => 'Hermes 回覆已就緒';

  @override
  String get admin_password_needed => '需要管理員密碼';

  @override
  String get hermes_needs_a_sudo_password_for_the_pending_terminal_command =>
      'Hermes 需要 sudo 密碼來執行待執行的終端機指令。';

  @override
  String get sudo_password => 'sudo 密碼';

  @override
  String get secret_needed => '需要金鑰';

  @override
  String get hermes_needs_a_secret_for_the_pending_skill =>
      'Hermes 需要為待處理的技能提供一個金鑰。';

  @override
  String get secret_value => '金鑰值';

  @override
  String get attached_file => '已附加檔案';

  @override
  String get pin_chat => '置頂聊天';

  @override
  String get unpin_chat => '取消置頂';

  @override
  String get pinned_chats => '已置頂';

  @override
  String could_not_update_chat_pin(Object error) {
    return '無法更新聊天置頂：$error';
  }

  @override
  String get could_not_save_chat_spaces => '無法在此裝置上儲存聊天空間';

  @override
  String get update_available => '有可用更新';

  @override
  String get update_now => '立即更新';

  @override
  String get update_install => '安裝更新';

  @override
  String get update_downloading => '正在下載並驗證更新…';

  @override
  String get update_allow_install => '請允許 Hermes 安裝這項更新，然後回到這裡點選「安裝更新」。';

  @override
  String get update_failed => '無法下載、驗證或開啟更新。請重試，或前往版本發布頁面。';

  @override
  String get a_newer_hermes_android_build_is_available_on_github =>
      'GitHub 上已有更新的 Ares 版本。';

  @override
  String get release_notes => '發行說明';

  @override
  String get view_release => '查看發行版';

  @override
  String get skip_this_version => '跳過此版本';

  @override
  String get later => '稍後';

  @override
  String get check_for_updates => '檢查更新';

  @override
  String get check_for_updates_on_launch => '啟動時檢查更新';

  @override
  String get you_re_on_the_latest_version => '已是最新版本。';

  @override
  String get couldn_t_check_for_updates => '無法檢查更新。';

  @override
  String get chat_density => '聊天密度';

  @override
  String chat_density_2(Object label) {
    return '聊天密度：$label';
  }

  @override
  String get chat_density_comfortable => '舒適';

  @override
  String get chat_density_compact => '緊湊';

  @override
  String get chat_density_comfortable_description =>
      '訊息泡泡的留白較多，每則訊息上方也會顯示傳送者名稱。';

  @override
  String get chat_density_compact_description => '訊息泡泡較緊湊，不顯示傳送者名稱，讓螢幕能容納更多訊息。';

  @override
  String chat_density_label_description(Object description, Object label) {
    return '$label — $description';
  }

  @override
  String
  get compact_removes_the_you_and_hermes_labels_and_trims_bubble_padding_spacing_and_side_margins =>
      '緊湊模式不顯示「你」和「Hermes」標籤，並縮小訊息泡泡的內距、間距及兩側留白。';

  @override
  String get client_certificate_mtls => '用戶端憑證（mTLS）';

  @override
  String get client_certificate_mtls_description =>
      'HTTPS 代理伺服器要求雙向 TLS 驗證時，出示用戶端憑證。';

  @override
  String get client_certificate_https_only => '只有 HTTPS 連線會使用用戶端憑證。';

  @override
  String get choose_certificate => '選擇憑證';

  @override
  String get certificate_password => '憑證密碼';

  @override
  String get this_certificate_is_password_protected =>
      '這張憑證受密碼保護。輸入正確密碼後就會自動開啟。';

  @override
  String get enter_the_certificate_password_to_finish_loading_it =>
      '請輸入密碼，以完成載入所選的憑證。';

  @override
  String get client_certificate_required => '請載入用戶端憑證，或關閉用戶端憑證選項。';

  @override
  String client_certificate_loaded(String label) {
    return '已載入：$label';
  }

  @override
  String get remove_certificate => '移除憑證';

  @override
  String get certificate_import_failed => '無法載入這張憑證。';

  @override
  String get background_work => '背景執行';

  @override
  String get keep_chats_active_in_background => '在背景保持聊天連線';

  @override
  String get background_work_description =>
      '應用程式在背景時，你開啟的聊天仍會保持連線。閒置的連線可能會中斷。這會增加耗電量和網路用量。關閉此功能不會停止伺服器上的工作。';

  @override
  String get background_work_limits =>
      '在 Doze 模式下，Android 仍可能暫停連線或終止應用程式。程式終止後，必須另外設定推播才能收到通知；強制停止後則不支援通知。';

  @override
  String get background_work_disclosure => '背景保護開啟時，即使關閉了可選的聊天通知，仍會顯示必需的服務通知。';

  @override
  String get battery_optimisation_settings => '電池優化設定';

  @override
  String get battery_optimisation_description =>
      '開啟 Android 設定以查看電池限制。不會自動申請豁免，更改設定也不能保證通知送達。';

  @override
  String get battery_settings_unavailable => '無法在此裝置上開啟電池設定。';

  @override
  String get background_work_save_failed => '無法儲存背景執行設定。';

  @override
  String get ongoing_chat_channel_name => '進行中的聊天';

  @override
  String get ongoing_chat_channel_description => '以無聲通知顯示你發起但尚未結束的聊天狀態';

  @override
  String get task_timeline => '任務時間軸';

  @override
  String get task_refresh_history => '重新整理任務記錄';

  @override
  String get task_live_preview => '來自上層任務事件的即時預覽';

  @override
  String get task_preview_explanation => '這裡只顯示最新提供的預覽，不是已儲存的對話記錄。';

  @override
  String get task_preview => '預覽';

  @override
  String get task_recorded_history => '已儲存的任務記錄';

  @override
  String get task_loading_history => '正在載入任務記錄…';

  @override
  String get task_empty_history => '目前沒有已儲存的訊息。任務可能還沒寫入記錄，不代表它沒有執行任何工作。';

  @override
  String get task_load_older => '載入較早的記錄';

  @override
  String get task_default_goal => '委派任務';

  @override
  String task_status(Object status) {
    return '狀態：$status';
  }

  @override
  String task_identity(Object id) {
    return '任務：$id';
  }

  @override
  String task_stored_session(Object id) {
    return '已儲存的工作階段：$id';
  }

  @override
  String task_delegation(Object id) {
    return '委派作業：$id';
  }

  @override
  String get task_read_only_notice => '唯讀。任務寫入記錄後，內容才可能出現。請重新整理以查看最新記錄。';

  @override
  String task_row_label(Object id, Object role) {
    return '$role · 記錄列 $id';
  }

  @override
  String get task_role_assistant => '助理';

  @override
  String get task_role_user => '使用者';

  @override
  String get task_role_tool => '工具';

  @override
  String task_tool_call(Object name) {
    return '工具呼叫 · $name';
  }

  @override
  String task_tool_result(Object name) {
    return '工具結果 · $name';
  }

  @override
  String task_call_details(Object arguments, Object id) {
    return '呼叫識別碼：$id\n引數\n$arguments';
  }

  @override
  String task_result_details(Object id, Object result) {
    return '呼叫識別碼：$id\n結果\n$result';
  }

  @override
  String get task_not_supplied => '未提供';

  @override
  String get task_missing_arguments => '伺服器未保留呼叫引數。';

  @override
  String get task_image_placeholder => '[圖片]';

  @override
  String get task_invalid_reference => '無法顯示任務對話記錄：已儲存的工作階段參照無效。';

  @override
  String get task_auth_required =>
      '無法顯示任務對話記錄：請為此閘道設定儀表板驗證。API 伺服器金鑰無法讀取任務的推理內容。';

  @override
  String get task_auth_rejected => '無法顯示任務對話記錄：儀表板驗證遭拒。請檢查此閘道的儀表板設定。';

  @override
  String get task_incompatible_history =>
      '無法顯示任務對話記錄：此儀表板不支援依指定範圍讀取所選設定檔的原始記錄。';

  @override
  String get task_identity_unproven =>
      '無法顯示任務對話記錄：儀表板無法確認對應的已儲存工作階段，或其壓縮前後的關聯，因此不會顯示其他工作階段的記錄。';

  @override
  String get task_partial_compression =>
      '記錄不完整：任務在壓縮後繼續執行，但閘道尚未提供可驗證的新參照。記錄可能缺少最後的回覆。自動重新整理已暫停；請點選「重新整理」再試一次。';

  @override
  String get task_partial_ancestors =>
      '記錄不完整：閘道未提供此任務壓縮前的工作階段，可能缺少較早的任務片段。現有記錄仍會保留；請點選「重新整理」再試一次。';

  @override
  String get task_missing_reference => '無法顯示任務對話記錄：伺服器未保留此任務的工作階段參照。';

  @override
  String get task_missing_row_identity => '無法顯示任務對話記錄：伺服器未提供可持續識別各筆訊息的識別碼。';

  @override
  String get task_history_not_ready =>
      '目前無法取得任務記錄（HTTP 404）。任務可能尚未寫入記錄，或儀表板不支援此功能。請稍後重試。';

  @override
  String get task_refresh_failed => '無法重新整理任務記錄。請檢查連線後重試。';

  @override
  String get task_status_interrupted => '已中斷';

  @override
  String get task_status_cancelled => '已取消';

  @override
  String get task_status_requested => '已提出請求';

  @override
  String get task_status_thinking => '思考中';

  @override
  String get task_status_tool => '正在使用工具';

  @override
  String get task_status_pending => '待處理';

  @override
  String get task_status_dispatched => '已指派';

  @override
  String task_status_unknown(Object status) {
    return '未知狀態：$status';
  }

  @override
  String task_tasks_finished(Object count) {
    return '已完成 $count 個委派任務';
  }

  @override
  String get activity_status_unconfirmed => '狀態未確認';

  @override
  String get activity_recently_updated => '最近更新';

  @override
  String get activity_reconnecting => '正在重新連線 — 正在檢查回合狀態';

  @override
  String get activity_outcome_unknown => '無法確認本輪對話的結果。請開啟聊天查看。';

  @override
  String get activity_chat_updated_detail => '閘道已記錄聊天活動；無法取得回合的即時狀態。';

  @override
  String get activity_updated => '已更新';

  @override
  String get activity_empty_title => '目前沒有近期活動';

  @override
  String get activity_empty_detail => '在此應用程式開始的回合，以及過去 7 天內更新過的閘道聊天，都會顯示在這裡。';

  @override
  String get activity_read_error => '活動功能無法讀取回合記錄或閘道聊天。請檢查連線後重試。';

  @override
  String get activity_chat_unavailable => '此聊天已不可用，或無法連線至閘道。';

  @override
  String get activity_partial_title => '活動已部分載入';

  @override
  String get activity_partial_detail => '目前僅顯示閘道活動的有限範圍。可能還有更多聊天，請下拉重新整理。';

  @override
  String get provider_usage => '使用記錄';

  @override
  String get provider_usage_notice =>
      '這是 Hermes 最近 30 天的用量，不代表帳戶點數或模型定價。請在 Hermes 伺服器上設定供應商的驗證資訊；此應用程式不會儲存供應商的 API 金鑰。';

  @override
  String get provider_usage_failed => '無法載入使用記錄。';

  @override
  String get provider_usage_empty => '此供應商目前沒有使用記錄。';

  @override
  String provider_usage_counts(String sessions, String input, String output) {
    return '$sessions 個工作階段 · 輸入：$input · 輸出：$output';
  }

  @override
  String provider_usage_costs(String estimated, String actual) {
    return '預估費用：$estimated · 回報費用：$actual';
  }

  @override
  String get provider_quota_codex => 'OpenAI Codex 訂閱';

  @override
  String get provider_quota_claude => 'Claude 訂閱';

  @override
  String get provider_quota_openai_api => 'OpenAI API 已記錄用量';

  @override
  String get provider_quota_notice =>
      '由供應商報告的訂閱用量週期，與 Hermes 記錄的用量及 API 計費分開顯示。各帳戶單獨列出；達到模型限額並不代表整個帳戶的配額已耗盡。';

  @override
  String get provider_quota_windows_notice =>
      'Codex 和 Claude 訂閱設有五小時工作階段限額和每週限額。僅顯示供應商報告的週期；未報告的限額和重設時間仍不可用。每週限額可能適用於整個帳戶或特定模型。';

  @override
  String get provider_quota_five_hour_session => '5 小時工作階段';

  @override
  String get provider_quota_unavailable => '訂閱配額不可用。';

  @override
  String get provider_quota_failed => '無法重新整理訂閱配額。保留的數值來自上次查詢。';

  @override
  String get provider_quota_account => '帳戶';

  @override
  String get provider_quota_unknown => '未知';

  @override
  String provider_quota_state(String state) {
    return '帳戶狀態：$state';
  }

  @override
  String provider_quota_scope(String scope) {
    return '適用範圍：$scope';
  }

  @override
  String provider_quota_percent(String used, String remaining) {
    return '已用 $used% · 剩餘 $remaining%';
  }

  @override
  String provider_quota_reset(String reset) {
    return '重設時間：$reset';
  }

  @override
  String get provider_quota_reset_unknown => '重設時間不可用。';

  @override
  String get auxiliary_models => '輔助模型';

  @override
  String get auxiliary_notice => '為各任務選擇模型。自訂端點必須在伺服器管理。自動模式遵循任務的繼承規則。';

  @override
  String get auxiliary_inherit => '自動（繼承）';

  @override
  String get auxiliary_unavailable => '輔助設定不可用。';

  @override
  String get provider_oauth_title => '供應商登入';

  @override
  String get provider_oauth_more_subtitle => '管理 Hermes 主機上的供應商登入';

  @override
  String get provider_oauth_settings_subtitle =>
      '在 Hermes 主機上登入；供應商令牌不會儲存在此裝置上';

  @override
  String get provider_oauth_intro =>
      '請在外部瀏覽器登入供應商帳戶。令牌只會儲存在 Hermes 主機上，不會留在此裝置。登入不會變更此應用程式選用的聊天模型。';

  @override
  String get provider_oauth_defaults_notice =>
      '某些主機流程（包括替換 Nous 免費方案帳戶）可能會更新主機預設設定。登入後請檢查主機設定。';

  @override
  String get provider_oauth_transport_init_failed =>
      '無法初始化所選的安全儀表板連線。請檢查其 TLS 身分和連線設定。';

  @override
  String get provider_oauth_https_required => '供應商登入需要透過 HTTPS 連線至 Hermes 儀表板。';

  @override
  String get provider_oauth_auth_required => '登入前請設定儀表板密碼驗證或受信任的代理伺服器。';

  @override
  String get provider_oauth_catalog_failed =>
      '目前無法在此主機上登入供應商帳戶。請檢查儀表板驗證設定；如果主機不支援供應商 OAuth，請更新主機。';

  @override
  String get provider_oauth_expired => '登入已過期。請重新開始。';

  @override
  String get provider_oauth_start_failed => '無法啟動安全的供應商登入。請重試。';

  @override
  String get provider_oauth_denied => '登入被拒絕。請重新開始。';

  @override
  String get provider_oauth_cancelled => '登入已取消。';

  @override
  String get provider_oauth_host_failed => '主機無法完成登入。請重新開始。';

  @override
  String get provider_oauth_poll_failed => '無法檢查登入狀態。請重新開始。';

  @override
  String provider_oauth_cancellation_unconfirmed(String message) {
    return '$message 無法確認取消；主機工作階段可能會持續到過期為止。';
  }

  @override
  String get provider_oauth_browser_failed => '無法開啟外部瀏覽器。請重試或取消登入。';

  @override
  String get provider_oauth_retry => '重試';

  @override
  String provider_oauth_complete(String provider) {
    return '完成 $provider 的登入';
  }

  @override
  String get provider_oauth_code_instruction => '請在供應商的頁面輸入這組臨時驗證碼：';

  @override
  String get provider_oauth_waiting => '正在等待核准。此工作階段將自動過期。';

  @override
  String get provider_oauth_open_browser => '在瀏覽器中開啟供應商';

  @override
  String get provider_oauth_cancel => '取消登入';

  @override
  String get provider_oauth_signed_out => '未在主機上登入';

  @override
  String get provider_oauth_sign_in_again => '重新登入';

  @override
  String get provider_oauth_sign_in => '登入';

  @override
  String get provider_oauth_cli_required =>
      '請在 Hermes 主機上使用供應商 CLI 登入。此主機不支援該供應商的應用程式內登入。';

  @override
  String get provider_oauth_checking_account => '已收到授權。正在檢查主機帳戶…';

  @override
  String get provider_oauth_verification_unavailable =>
      '已收到授權；無法驗證帳戶。請開啟用量頁面以重新整理帳戶用量。';

  @override
  String provider_oauth_verified_account(String email) {
    return '已在 Hermes 主機上以 $email 登入。請開啟用量頁面以重新整理帳戶用量。';
  }

  @override
  String get provider_oauth_credentials_unverified => '主機報告驗證資訊可用；帳戶身分尚未驗證。';

  @override
  String get provider_oauth_account_status_unknown => '無法取得主機帳戶狀態。';

  @override
  String get app_language => '應用程式語言';

  @override
  String get app_language_system => '與手機相同';

  @override
  String get auto_archives_after_72_hours => '72 小時後自動封存';

  @override
  String get automation => '自動化';

  @override
  String get voice_recording_start => '錄製語音訊息';

  @override
  String get voice_recording_pause => '暫停錄音';

  @override
  String get voice_recording_preview => '播放錄音';

  @override
  String get voice_recording_resume => '繼續錄音';

  @override
  String get voice_recording_send => '傳送語音訊息';

  @override
  String get voice_recording_discard => '捨棄錄音';

  @override
  String get voice_recording_processing => '正在準備語音訊息…';

  @override
  String voice_recording_elapsed(String time) {
    return '錄音中 $time';
  }

  @override
  String voice_recording_draft(String time) {
    return '語音訊息 $time';
  }

  @override
  String get voice_recording_permission => '請允許使用麥克風，以便錄製語音訊息。';

  @override
  String get voice_recording_limit => '錄音已達 10 分鐘上限。';

  @override
  String get voice_recording_empty => '未錄到聲音，請再試一次。';

  @override
  String get voice_recording_failed => '無法處理錄音。已儲存的錄音片段仍會保留。';

  @override
  String get voice_recording_unconfirmed => '無法確認語音訊息是否送達。錄音已儲存，請先查看聊天記錄再重試。';

  @override
  String get voice_recording_submit_failed =>
      '無法傳送語音訊息。錄音已儲存，請檢查網路連線、儀表板存取權及伺服器的語音轉文字設定。';

  @override
  String get voice_recording_pause_playback => '暫停播放';

  @override
  String get projects_root_title => '伺服器上的專案資料夾';

  @override
  String get projects_root_more_subtitle => '伺服器上新增專案資料夾的位置';

  @override
  String get projects_root_description =>
      '從這部手機建立專案時，專案資料夾會放在這裡。選擇 Hermes 使用的同一個資料夾，手機和伺服器就能共用同一批專案。';

  @override
  String get projects_root_label => '專案根路徑';

  @override
  String projects_root_default_hint(String path) {
    return '伺服器預設值：$path';
  }

  @override
  String get projects_root_locked_title => '由伺服器設定';

  @override
  String get projects_root_locked_explanation =>
      '此伺服器將檔案存取限制在單一根目錄內，因此無法在應用程式中更改專案資料夾。';

  @override
  String get projects_root_saved => '已儲存專案資料夾。';

  @override
  String get projects_root_reset => '使用伺服器預設值';

  @override
  String get projects_root_invalid_empty => '請輸入資料夾路徑。';

  @override
  String get projects_root_invalid_absolute => '請輸入以斜線開頭的絕對路徑。';

  @override
  String get projects_root_invalid_segments => '請從路徑中移除點號片段和控制字元。';

  @override
  String get projects_root_unsupported =>
      '此連線不支援。讀取或更改伺服器上的專案資料夾需要具有儀表板存取權限的 Desktop Gateway 連線。';

  @override
  String get projects_root_unavailable => '無法讀取伺服器上的專案資料夾。請檢查儀表板連線後重試。';

  @override
  String get adopt_folder_action => '新增現有資料夾';

  @override
  String adopt_folder_description(String root) {
    return '$root 下尚未註冊為專案的資料夾。';
  }

  @override
  String adopt_folder_registered(String name) {
    return '已是專案：$name';
  }

  @override
  String get adopt_folder_none => '此路徑下的所有資料夾都已是專案。';

  @override
  String get adopt_folder_unsupported => '此連線無法列出伺服器資料夾。請改為輸入現有資料夾的絕對路徑。';

  @override
  String adopt_folder_failed(String error) {
    return '無法列出伺服器資料夾：$error';
  }

  @override
  String get adopt_folder_manual_label => '現有資料夾路徑';

  @override
  String get adopt_folder_name_label => '專案名稱';

  @override
  String get adopt_folder_add => '新增為專案';

  @override
  String adopt_folder_added(String name, String path) {
    return '$name 現在使用 $path';
  }

  @override
  String adopt_folder_error(String error) {
    return '無法新增該資料夾：$error';
  }

  @override
  String adopt_folder_folderless(String name) {
    return '已建立 $name，但未關聯資料夾。請在伺服器上的 Hermes 中關聯。';
  }

  @override
  String get slash_commands => '斜線指令';

  @override
  String get slash_commands_loading => '正在載入指令…';

  @override
  String get slash_commands_empty => '找不到符合的指令';

  @override
  String slash_command_info_alias(String alias, String command) {
    return '$alias 是 $command 的別名';
  }

  @override
  String get slash_command_info_no_description => '目前沒有說明。';

  @override
  String get slash_command_info_arguments_options => '接受固定選項中的一個。';

  @override
  String get slash_command_info_arguments_text => '在指令後接受文字。';

  @override
  String get slash_command_info_arguments_mixed => '在指令後接受選項或文字。';

  @override
  String get slash_command_output => '指令輸出';

  @override
  String get slash_command_no_output => '指令已執行完畢，沒有任何輸出。';

  @override
  String get slash_command_delivery_unknown =>
      '指令已送出，但未收到回覆。指令可能仍在閘道上執行，因此已保留草稿。請先查看閘道狀態再重試。';

  @override
  String get slash_command_failed => '無法執行指令。';

  @override
  String get slash_command_unsupported => '此指令在此伺服器上不可用。';

  @override
  String get slash_sessions_inline => '請開啟工作階段清單選擇聊天。草稿已保留。';

  @override
  String get composer_failure_switch_no_retry =>
      '切換只會變更模型：此連線無法重新執行失敗的輪次。切換後請重新傳送。';

  @override
  String get nextgen_toggle => 'NextGen 介面';

  @override
  String get nextgen_toggle_subtitle => '全新設計：一次登入、即時聊天和網路發現。你的閘道和聊天與此介面共用。';

  @override
  String get nextgen_single_login => '使用單一登入';

  @override
  String get nextgen_single_login_subtitle => '只需儀表板位址和一次登入即可新增閘道。';

  @override
  String get ng_allow_this_command => '允許執行此指令？';

  @override
  String ng_hermes_wants_to_run_this_with(Object tool) {
    return 'Hermes 想使用 $tool 執行此操作。';
  }

  @override
  String get ng_hermes_wants_to_run_this => 'Hermes 想執行此操作。';

  @override
  String get ng_hermes_has_a_question => 'Hermes 有一個問題';

  @override
  String get ng_hermes_has_questions => 'Hermes 有幾個問題';

  @override
  String get ng_password_for_sudo => 'sudo 密碼';

  @override
  String get ng_hermes_needs_your_sudo_password_to =>
      'Hermes 需要你的 sudo 密碼來執行此指令。';

  @override
  String get ng_a_secret_value => '機密值';

  @override
  String ng_value_for(Object variable) {
    return '$variable 的值';
  }

  @override
  String get ng_your_password_manager => '你的密碼管理器';

  @override
  String ng_unlock(Object name) {
    return '解鎖 $name';
  }

  @override
  String ng_hermes_needs_unlocked_to_sign_in(Object name) {
    return 'Hermes 需要先解鎖 $name，才能為你登入。';
  }

  @override
  String get ng_sign_in_code => '登入驗證碼';

  @override
  String get ng_enter_the_sign_in_code => '輸入登入驗證碼。';

  @override
  String ng_enter_the_sign_in_code_for(Object site) {
    return '輸入 $site 的登入驗證碼。';
  }

  @override
  String get ng_save_a_login => '儲存登入資訊？';

  @override
  String ng_save_your_login(Object site) {
    return '儲存你的 $site 登入資訊？';
  }

  @override
  String ng_couldn_t_load_this_chat(Object error) {
    return '無法載入此聊天：$error';
  }

  @override
  String ng_live_updates_are_unavailable(Object error) {
    return '即時更新不可用：$error';
  }

  @override
  String ng_preparing(Object name) {
    return '正在準備 $name…';
  }

  @override
  String get ng_the_turn_failed => '本輪對話失敗。';

  @override
  String get ng_turn_changed => '該輪對話已結束或已開始新一輪';

  @override
  String get ng_steer_rejected => '正在進行的對話未接受此內容';

  @override
  String get ng_turn_not_known_yet => '尚不清楚正在進行的對話；請稍後再試';

  @override
  String ng_couldn_t_stop(Object error) {
    return '無法停止：$error';
  }

  @override
  String get ng_server_access => '伺服器存取';

  @override
  String get ng_sign_in => '登入';

  @override
  String get ng_live_connection => '即時連線';

  @override
  String get ng_check_that_tailscale_is_on_on => '請確認此手機和伺服器上的 Tailscale 均已開啟。';

  @override
  String get ng_check_the_address_and_that_the => '請檢查位址，並確認代理伺服器已轉發到儀表板。';

  @override
  String get ng_use_the_same_network_as_the =>
      '請使用與伺服器相同的網路，並使用 --host 0.0.0.0 啟動儀表板，以便其他裝置存取。';

  @override
  String get ng_check_the_address_vpn_or_tailscale =>
      '請檢查位址、VPN 或 Tailscale 連線。';

  @override
  String get ng_not_checked_yet => '尚未檢查。';

  @override
  String get ng_checking => '正在檢查…';

  @override
  String ng_hermes_answers_at(Object version, Object address) {
    return 'Hermes $version 可透過 $address 存取。';
  }

  @override
  String get ng_something_answered_but_not_a_hermes => '有服務回應，但不是 Hermes 儀表板。';

  @override
  String ng_something_answered_http_but_not_a(Object status) {
    return '有服務回應（HTTP $status），但不是 Hermes 儀表板。';
  }

  @override
  String get ng_use_the_dashboard_s_address_and =>
      '請使用儀表板的位址和連接埠（預設為 9119），而不是 API 伺服器的位址和連接埠。';

  @override
  String get ng_cloudflare_access_turned_the_service_token =>
      'Cloudflare Access 拒絕了服務令牌。';

  @override
  String get ng_cloudflare_access_is_in_front_of =>
      '此位址前方設定了 Cloudflare Access。';

  @override
  String get ng_check_the_service_token_and_its =>
      '請檢查服務令牌和對應的 Service Auth 原則。';

  @override
  String get ng_add_a_cloudflare_access_service_token =>
      '為此位址新增 Cloudflare Access 服務令牌。';

  @override
  String get ng_the_server_asks_for_a_client => '伺服器要求提供用戶端憑證。';

  @override
  String get ng_pick_the_client_certificate_for_this => '為此閘道選擇用戶端憑證，然後再次測試。';

  @override
  String get ng_needs_server_access_first => '請先連線伺服器。';

  @override
  String get ng_needs_a_sign_in_first => '請先登入。';

  @override
  String ng_signed_in_as(Object name) {
    return '已登入為 $name。';
  }

  @override
  String get ng_this_dashboard_doesn_t_need_a => '此儀表板不必登入。';

  @override
  String get ng_the_saved_sign_in_has_expired => '已儲存的登入資訊已過期。';

  @override
  String get ng_sign_in_again => '重新登入。';

  @override
  String get ng_too_many_sign_in_attempts => '登入嘗試次數過多。';

  @override
  String get ng_wait_a_minute_then_check_again => '請稍等一分鐘後再試。';

  @override
  String ng_the_gateway_answered(Object message) {
    return '閘道返回：$message。';
  }

  @override
  String get ng_sign_in_again_or_update_hermes => '請重新登入，或更新 Hermes。';

  @override
  String ng_couldn_t_check_the_sign_in(Object error) {
    return '無法檢查登入狀態：$error';
  }

  @override
  String ng_the_gateway_wouldn_t_issue_a(Object message) {
    return '閘道無法核發聊天憑證（$message）。';
  }

  @override
  String get ng_the_chat_connection_opened_and_the => '聊天連線已建立，閘道已確認就緒。';

  @override
  String get ng_the_gateway_never_said_it_was => '閘道始終未確認就緒。';

  @override
  String get ng_check_that_the_agent_is_running => '請確認伺服器上的代理程式正在執行。';

  @override
  String get ng_the_gateway_refused_the_chat_connection =>
      '閘道拒絕了聊天連線（HTTP 403）。';

  @override
  String get ng_this_dashboard_has_no_chat_endpoint => '此儀表板沒有聊天端點（/api/ws）。';

  @override
  String ng_the_chat_connection_failed(Object detail) {
    return '聊天連線失敗：$detail';
  }

  @override
  String get ng_use_the_exact_address_the_dashboard => '請使用儀表板設定的完整位址。';

  @override
  String get ng_update_hermes => '更新 Hermes。';

  @override
  String get ng_make_sure_the_proxy_allows_websocket =>
      '請確認代理伺服器允許在 /api/ws 上進行 WebSocket 升級。';

  @override
  String get ng_offline => '離線';

  @override
  String get ng_connecting => '正在連線…';

  @override
  String get ng_connected => '已連線';

  @override
  String get ng_reconnecting => '正在重新連線…';

  @override
  String get ng_signed_out => '已登出登入';

  @override
  String get ng_connection_failed => '連線失敗';

  @override
  String get ng_rate_limited_by_gateway => '已觸發閘道限流';

  @override
  String ng_couldn_t_open_the_chat_connection(Object message) {
    return '無法建立聊天連線：$message';
  }

  @override
  String get ng_the_gateway_returned_no_websocket_ticket =>
      '閘道未返回 WebSocket 票據。';

  @override
  String get ng_connection_lost => '連線已中斷';

  @override
  String get ng_this_dashboard_has_no_chat_endpoint_2 =>
      '此儀表板沒有聊天端點（/api/ws）。請更新 Hermes。';

  @override
  String get ng_the_gateway_refused_the_chat_connection_2 =>
      '閘道拒絕了聊天連線。請檢查位址是否與儀表板設定的主機相符，並確認已啟用內嵌聊天。';

  @override
  String ng_the_gateway_refused(Object method) {
    return '閘道拒絕了 $method。';
  }

  @override
  String ng_couldn_t_read_your_saved_gateways(Object error) {
    return '無法讀取已儲存的閘道：$error';
  }

  @override
  String get ng_applies_to_new_chats => '僅套用至新聊天';

  @override
  String ng_couldn_t_change(Object label, Object error) {
    return '無法更改$label：$error';
  }

  @override
  String get ng_capabilities => '功能';

  @override
  String get ng_skills => '技能';

  @override
  String get ng_toolsets => '工具集';

  @override
  String get ng_search => '搜尋';

  @override
  String get ng_couldn_t_load => '無法載入';

  @override
  String get ng_try_again => '重試';

  @override
  String get ng_no_skills => '沒有技能';

  @override
  String get ng_no_toolsets => '沒有工具集';

  @override
  String get ng_no_mcp_servers => '沒有 MCP 伺服器';

  @override
  String get ng_that_file_is_too_large_to => '該檔案太大，無法作為憑證使用。';

  @override
  String ng_the_certificate_couldn_t_be_imported(Object error) {
    return '無法匯入憑證：$error';
  }

  @override
  String get ng_now_pick_its_private_key => '現在選擇對應的私密金鑰。';

  @override
  String get ng_now_pick_its_certificate => '現在選擇對應的憑證。';

  @override
  String get ng_that_file_isn_t_a_certificate => '該檔案不是憑證或私密金鑰。';

  @override
  String get ng_if_a_proxy_in_front_of =>
      '如果此位址前的代理伺服器要求用戶端憑證，請在此選擇憑證，以便測試、登入和聊天時都能出示。';

  @override
  String get ng_client_certificates_are_only_used_with =>
      '用戶端憑證僅用於 https:// 位址。';

  @override
  String get ng_remove => '移除';

  @override
  String get ng_certificate_password => '憑證密碼';

  @override
  String get ng_importing => '正在匯入…';

  @override
  String get ng_pick_certificate => '選擇憑證';

  @override
  String get ng_pick_a_different_certificate => '選擇其他憑證';

  @override
  String get ng_accepts_p12_pfx_or_pem_certificate =>
      '支援 .p12/.pfx 檔案，或 PEM 憑證和金鑰檔案。金鑰會儲存在此應用程式的私有儲存空間中。';

  @override
  String get ng_photos => '照片';

  @override
  String get ng_camera => '相機';

  @override
  String get ng_files => '檔案';

  @override
  String ng_you_can_attach_up_to_files(Object count) {
    return '最多可附加 $count 個檔案。';
  }

  @override
  String ng_couldn_t_read(Object name) {
    return '無法讀取 $name。';
  }

  @override
  String ng_couldn_t_prepare_that_file(Object error) {
    return '無法處理該檔案：$error';
  }

  @override
  String get ng_hermes_is_still_working => 'Hermes 仍在處理中';

  @override
  String get ng_steer => '引導';

  @override
  String get ng_adds_this_to_the_running_turn => '在目前回合的下一步中新增此內容';

  @override
  String get ng_queue => '排入佇列';

  @override
  String get ng_sends_it_when_the_turn_finishes => '目前回合結束後傳送';

  @override
  String get ng_stop_and_send => '停止並傳送';

  @override
  String get ng_stops_the_turn_then_sends_this => '停止目前回合，然後傳送此內容';

  @override
  String ng_dictation_stopped(Object message) {
    return '聽寫已停止：$message';
  }

  @override
  String get ng_speech_recognition_isn_t_available => '語音辨識不可用。';

  @override
  String get ng_working => '處理中';

  @override
  String get ng_ready => '就緒';

  @override
  String get ng_chats => '聊天';

  @override
  String get ng_new_chat => '新增聊天';

  @override
  String get ng_usage => '用量';

  @override
  String get ng_rename_chat => '重新命名聊天';

  @override
  String ng_couldn_t_rename(Object error) {
    return '無法重新命名：$error';
  }

  @override
  String get ng_this_chat => '此聊天';

  @override
  String get ng_input_tokens => '輸入令牌';

  @override
  String get ng_output_tokens => '輸出令牌';

  @override
  String get ng_reasoning_tokens => '推理令牌';

  @override
  String get ng_cache_reads => '快取讀取';

  @override
  String get ng_api_calls => 'API 呼叫';

  @override
  String get ng_cost => '費用';

  @override
  String get ng_context => '上下文';

  @override
  String get ng_your_sign_in_expired => '登入已過期。';

  @override
  String get ng_sign_in_2 => '登入';

  @override
  String get ng_retry => '重試';

  @override
  String get ng_project_home => '首頁';

  @override
  String get ng_choose_project => '選擇專案';

  @override
  String ng_project_cwd_fallback(String path) {
    return '專案資料夾不可用，因此此聊天在 $path 中執行。';
  }

  @override
  String get ng_project_create_uncertain =>
      '閘道可能已建立此聊天，但未確認。開始新聊天前請檢查聊天清單；此要求不會自動重試。';

  @override
  String get ng_what_should_we_work_on => '我們要做些什麼？';

  @override
  String get ng_ask_hermes_anything_it_can_run =>
      '向 Hermes 提問。它可以執行工具、瀏覽網頁，還能處理伺服器上的檔案。';

  @override
  String ng_working_2(Object frame) {
    return '正在處理 · $frame';
  }

  @override
  String get ng_default_model => '預設模型';

  @override
  String get ng_listening => '正在聆聽…';

  @override
  String get ng_steer_or_queue_a_message => '引導，或將訊息排入佇列';

  @override
  String get ng_message_hermes => '給 Hermes 傳送訊息';

  @override
  String get ng_attach => '新增附件';

  @override
  String get ng_stop_dictation => '停止聽寫';

  @override
  String get ng_dictate => '語音輸入';

  @override
  String get ng_stop => '停止';

  @override
  String get ng_send => '傳送';

  @override
  String ng_slash_command_alias(String alias, String command) {
    return '$alias 是 $command 的別名';
  }

  @override
  String get ng_slash_command_no_description => '目前沒有說明。';

  @override
  String get ng_slash_command_arguments_options => '接受固定選項中的一個。';

  @override
  String get ng_slash_command_arguments_text => '在指令後接受文字。';

  @override
  String get ng_slash_command_arguments_mixed => '在指令後接受選項或文字。';

  @override
  String get ng_slash_command_sent_as_message =>
      'NextGen 會將此作為普通訊息傳送給 Hermes，不會執行該指令。';

  @override
  String get ng_slash_command_output => '指令輸出';

  @override
  String get ng_slash_command_running => '正在執行指令…';

  @override
  String get ng_slash_command_done => '完成。';

  @override
  String ng_slash_command_failed(Object error) {
    return '無法執行指令：$error';
  }

  @override
  String get ng_slash_command_refused => 'Hermes 無法在此執行此指令。';

  @override
  String get ng_slash_command_delivery_unknown =>
      '指令已傳送，但未收到回覆。它可能仍在閘道上執行，因此沒有重新傳送，並保留了你的草稿。';

  @override
  String get ng_slash_command_nothing_running => '目前沒有正在執行的任務。';

  @override
  String get ng_steered => '已調整指示';

  @override
  String get ng_copied => '已複製';

  @override
  String ng_not_sent(Object reason) {
    return '未傳送：$reason';
  }

  @override
  String get ng_thinking => '正在思考…';

  @override
  String get ng_thought => '思考';

  @override
  String ng_used(Object name) {
    return '已使用 $name';
  }

  @override
  String ng_used_tools(Object count) {
    return '已使用 $count 個工具';
  }

  @override
  String get ng_copy => '複製';

  @override
  String get ng_read_aloud => '朗讀';

  @override
  String get ng_the_gateway_connection_dropped_try_again => '閘道連線已中斷，請重試。';

  @override
  String get ng_allow_once => '允許一次';

  @override
  String get ng_allow_until_sandbox_off => '直到關閉沙箱為止';

  @override
  String get ng_folder_access => '資料夾存取權';

  @override
  String get ng_folder_access_unspecified => '閘道未說明這是唯讀還是可讀寫。';

  @override
  String get ng_folder_read_only => '唯讀';

  @override
  String get ng_folder_read_write => '讀取與寫入';

  @override
  String get ng_website_access => '網站存取權';

  @override
  String get ng_allow_for_this_chat => '在此聊天中允許';

  @override
  String get ng_always_allow => '一律允許';

  @override
  String get ng_deny => '拒絕';

  @override
  String get ng_your_answer => '你的回答';

  @override
  String get ng_or_type_an_answer => '或輸入回答';

  @override
  String get ng_skip => '跳過';

  @override
  String get ng_answer => '回答';

  @override
  String get ng_cancel => '取消';

  @override
  String get ng_username_or_email => '使用者名稱或電子郵件地址';

  @override
  String get ng_password => '密碼';

  @override
  String get ng_not_now => '暫不';

  @override
  String get ng_save => '儲存';

  @override
  String get ng_enter_both_the_client_id_and => '請同時填寫用戶端識別碼和用戶端密鑰，或將兩者留白。';

  @override
  String get ng_enter_your_username_and_password => '請輸入使用者名稱和密碼。';

  @override
  String ng_couldn_t_save_the_sign_in(Object error) {
    return '無法儲存登入資訊：$error';
  }

  @override
  String get ng_wrong_username_or_password => '使用者名稱或密碼錯誤。';

  @override
  String get ng_too_many_attempts_wait_a_moment => '嘗試次數過多，請稍等片刻再試。';

  @override
  String get ng_welcome_to_hermes => '歡迎使用 Ares';

  @override
  String get ng_add_a_gateway => '新增閘道';

  @override
  String get ng_connect_to_your_hermes_agent_dashboard =>
      '連線至你的 Hermes Agent 儀表板。使用一個位址和一次登入，即可存取聊天、工具和設定。登入前不會傳送任何內容。';

  @override
  String get ng_connect_to_another_hermes_agent_dashboard =>
      '連線至另一個 Hermes Agent 儀表板。先前儲存的儀表板仍會維持登入狀態。';

  @override
  String get ng_dashboard_address => '儀表板位址';

  @override
  String get ng_testing => '正在測試…';

  @override
  String get ng_test => '測試';

  @override
  String get ng_where_your_hermes_dashboard_runs_lan =>
      'Hermes 儀表板的位址：可以是區域網路（LAN）、Tailscale 或 HTTPS 位址。';

  @override
  String get ng_find_on_my_network => '在我的網路中尋找';

  @override
  String get ng_which_address_do_i_use => '我應該使用哪個位址？';

  @override
  String get ng_behind_cloudflare_access => '使用 Cloudflare Access 保護？';

  @override
  String get ng_need_a_client_certificate => '需要用戶端憑證？';

  @override
  String get ng_this_address_isn_t_private_and =>
      '此位址不是私有位址，且未使用 https://，因此你的密碼和聊天內容會以未加密的形式透過網際網路傳輸。請改用 https://、Tailscale 或你自己的網路。';

  @override
  String get ng_continue_to_sign_in => '繼續登入';

  @override
  String get ng_use_the_classic_interface_instead => '改用經典介面';

  @override
  String get ng_if_cloudflare_access_protects_this_address =>
      '如果此位址受 Cloudflare Access 保護，請在 Cloudflare Zero Trust 的 Access → Service credentials 中建立服務令牌，再為 Access 應用程式新增對應的 Service Auth 原則。';

  @override
  String get ng_a_service_token_is_saved_for => '已為此位址儲存服務令牌';

  @override
  String get ng_forget => '移除';

  @override
  String get ng_client_id => '用戶端識別碼（Client ID）';

  @override
  String get ng_client_secret => '用戶端密鑰（Client Secret）';

  @override
  String get ng_stored_encrypted_on_this_phone_and => '加密儲存在此手機上，且只傳送到此位址。';

  @override
  String get ng_hermes_is_reachable => '已連線至 Hermes';

  @override
  String ng_hermes_is_reachable_2(Object version) {
    return '已連線至 Hermes $version';
  }

  @override
  String get ng_sign_in_is_tested_next_then => '接下來測試登入，然後測試聊天';

  @override
  String get ng_agent_gateway => '代理程式閘道';

  @override
  String get ng_running => '執行中';

  @override
  String get ng_stopped => '已停止';

  @override
  String get ng_username_password => '使用者名稱和密碼';

  @override
  String get ng_browser => '瀏覽器';

  @override
  String get ng_in_the_browser_sso => '在瀏覽器中（SSO）';

  @override
  String get ng_profiles => '設定檔';

  @override
  String get ng_this_dashboard_offers_neither_a_username =>
      '此儀表板既未提供使用者名稱和密碼登入，也未提供瀏覽器登入。請更新 Hermes，或在伺服器上設定使用者名稱和密碼登入。';

  @override
  String get ng_the_auth_gate_is_off_on => '此儀表板未啟用身分驗證。任何能連線的人都能使用你的代理程式。';

  @override
  String get ng_couldn_t_reach_the_dashboard => '無法連線至儀表板';

  @override
  String ng_check_the_address_and_port_9119(Object reason) {
    return '$reason\n\n請檢查位址和連接埠（預設為 9119）。如果儀表板尚未執行，請在伺服器上執行：\nhermes dashboard --host 0.0.0.0';
  }

  @override
  String get ng_that_isn_t_a_hermes_dashboard => '這不是 Hermes 儀表板';

  @override
  String get ng_something_answered_but_not_a_hermes_2 =>
      '伺服器有回應，但不是 Hermes 儀表板。請使用儀表板的位址，而不是 API 伺服器的位址（連接埠 8642）。';

  @override
  String ng_something_answered_http_but_not_a_2(Object status) {
    return '伺服器有回應（HTTP $status），但不是 Hermes 儀表板。請使用儀表板的位址，而不是 API 伺服器的位址（連接埠 8642）。';
  }

  @override
  String get ng_cloudflare_access_stopped_the_request =>
      'Cloudflare Access 已攔截此要求';

  @override
  String ng_cloudflare_access_turned_down_the_service(Object status) {
    return 'Cloudflare Access 拒絕了服務令牌（HTTP $status）。請檢查用戶端識別碼、用戶端密鑰及 Service Auth 原則。';
  }

  @override
  String get ng_add_a_cloudflare_access_service_token_2 =>
      '請在下方新增 Cloudflare Access 服務令牌，然後重新測試。';

  @override
  String get ng_a_client_certificate_is_needed => '需要用戶端憑證';

  @override
  String get ng_this_server_asks_for_a_client =>
      '此伺服器要求先提供用戶端憑證。請在下方選擇伺服器提供的憑證，然後重新測試。';

  @override
  String get ng_this_dashboard_doesn_t_ask_for => '此儀表板不需要登入。';

  @override
  String ng_use_the_dashboard_username_and_password(Object address) {
    return '請使用 $address 上設定的儀表板使用者名稱和密碼，或在瀏覽器中登入。';
  }

  @override
  String ng_use_the_dashboard_username_and_password_2(Object address) {
    return '請使用 $address 上設定的儀表板使用者名稱和密碼。';
  }

  @override
  String ng_sign_in_to_in_your_browser(Object address) {
    return '請在瀏覽器中登入 $address，並使用該儀表板所用的帳號。';
  }

  @override
  String ng_gateway(Object address) {
    return '閘道 $address';
  }

  @override
  String get ng_profile => '設定檔';

  @override
  String get ng_server_default => '伺服器預設設定';

  @override
  String get ng_continue => '繼續';

  @override
  String get ng_username => '使用者名稱';

  @override
  String get ng_signing_in => '正在登入…';

  @override
  String get ng_waiting_for_the_browser => '正在等待瀏覽器…';

  @override
  String get ng_sign_in_with_browser => '使用瀏覽器登入';

  @override
  String get ng_finish_signing_in_on_the_page =>
      '請在開啟的頁面上完成登入。完成後 Hermes 會自動返回。';

  @override
  String get ng_use_a_different_gateway => '使用其他閘道';

  @override
  String get ng_same_wi_fi_or_local_network => '同一 Wi-Fi 或區域網路';

  @override
  String get ng_use_the_server_s_local_address =>
      '請輸入伺服器的區域網路位址和連接埠，例如 192.168.1.20:9119。啟動儀表板時加上 --host 0.0.0.0，其他裝置才能連線。';

  @override
  String get ng_tailscale => 'Tailscale';

  @override
  String get ng_turn_on_tailscale_on_this_phone =>
      '在這部手機上啟用 Tailscale，然後使用伺服器的 Tailscale 位址，例如 100.64.0.1:9119 或其 .ts.net 網域名稱。離開家也能使用。';

  @override
  String get ng_use_your_https_address_when_the =>
      '如果儀表板位於帶憑證的代理伺服器後面，請使用你的 https:// 位址。代理伺服器還必須支援 /api/ws 上的 WebSocket 升級。';

  @override
  String get ng_start_the_dashboard_on_the_server => '在伺服器上啟動儀表板：';

  @override
  String get ng_enter_a_port_from_1_to => '請輸入 1 到 65535 之間的連接埠。';

  @override
  String get ng_looks_for_hermes_dashboards_on_port =>
      '在此 Wi-Fi 網路上搜尋連接埠 9119 的 Hermes 儀表板，並檢查已儲存的電腦。';

  @override
  String ng_looks_for_hermes_dashboards_on_ports(Object port) {
    return '在此 Wi-Fi 網路上搜尋連接埠 9119 和 $port 的 Hermes 儀表板，並檢查已儲存的電腦。';
  }

  @override
  String get ng_other_port_optional => '其他連接埠（選填）';

  @override
  String get ng_no_dashboards_answered_start_one_with =>
      '沒有儀表板回應。請執行 hermes dashboard --host 0.0.0.0 啟動，或輸入其位址。';

  @override
  String get ng_using_tailscale_or_a_vpn_those =>
      '正在使用 Tailscale 或 VPN？無法搜尋這些網路。請改為輸入電腦的 100.x 位址或 .ts.net 網域名稱。';

  @override
  String get ng_search_again => '重新搜尋';

  @override
  String get ng_insights => '使用量分析';

  @override
  String get ng_couldn_t_load_insights => '無法載入使用量分析';

  @override
  String get ng_sessions => '工作階段';

  @override
  String get ng_tokens => '令牌';

  @override
  String get ng_est_cost => '預估費用';

  @override
  String get ng_daily_tokens => '每日令牌用量';

  @override
  String get ng_models => '模型';

  @override
  String get ng_tools => '工具';

  @override
  String get ng_hermes_is_waiting_for_you => 'Hermes 正在等你。';

  @override
  String get ng_hermes_replied => 'Hermes 已回覆';

  @override
  String get ng_the_turn_finished => '本輪已完成。';

  @override
  String get ng_off => '關閉';

  @override
  String get ng_minimal => '最低';

  @override
  String get ng_low => '低';

  @override
  String get ng_medium => '中';

  @override
  String get ng_high => '高';

  @override
  String get ng_extra_high => '極高';

  @override
  String get ng_max => '最高';

  @override
  String get ng_ultra => '超強';

  @override
  String get ng_default => '預設';

  @override
  String ng_couldn_t_switch_model(Object error) {
    return '無法切換模型：$error';
  }

  @override
  String get ng_model => '模型';

  @override
  String get ng_thinking_2 => '思考';

  @override
  String get ng_search_models => '搜尋模型';

  @override
  String get ng_no_models_match => '沒有符合這些篩選條件的模型。';

  @override
  String get privacy_policy => '隱私政策';

  @override
  String get report_ai_output => '舉報 AI 輸出';

  @override
  String ng_couldn_t_load_models(Object error) {
    return '無法載入模型：$error';
  }

  @override
  String get ng_no_providers_are_set_up_on => '此閘道尚未設定任何供應商。';

  @override
  String get ng_starred => '已加星號';

  @override
  String get ng_recent => '最近';

  @override
  String get ng_more => '更多';

  @override
  String get ng_archived_chats => '已封存聊天';

  @override
  String get ng_projects => '專案';

  @override
  String get ng_chats_grouped_by_project_and_workspace => '按專案和工作區分組的聊天';

  @override
  String get ng_agent => '代理程式';

  @override
  String get ng_memory => '記憶';

  @override
  String get ng_what_hermes_remembers_about_you => 'Hermes 對你的記憶';

  @override
  String get ng_skills_library => '技能庫';

  @override
  String get ng_browse_and_read_installed_skills => '瀏覽並閱讀已安裝的技能';

  @override
  String get ng_cron_editor => 'Cron 編輯器';

  @override
  String get ng_edit_schedules_prompts_and_delivery => '編輯排程、提示詞和傳送方式';

  @override
  String get ng_config_file => '設定檔';

  @override
  String get ng_edit_config_yaml_on_the_gateway => '在閘道上編輯 config.yaml';

  @override
  String get ng_models_and_providers => '模型和供應商';

  @override
  String get ng_model_management => '模型管理';

  @override
  String get ng_default_fallback_and_auxiliary_models => '預設、備用和輔助模型';

  @override
  String get ng_provider_sign_in => '供應商登入';

  @override
  String get ng_connect_provider_accounts_with_oauth => '透過 OAuth 連線供應商帳號';

  @override
  String get ng_nous_portal => 'Nous Portal';

  @override
  String get ng_subscription_credits_and_usage => '訂閱、額度和使用情況';

  @override
  String get ng_interface => '介面';

  @override
  String get ng_switch_to_the_classic_interface => '切換到經典介面';

  @override
  String get ng_turns_nextgen_off_you_can_turn => '關閉 NextGen。你可以在設定中重新開啟。';

  @override
  String get ng_restored => '已還原';

  @override
  String get ng_archived => '已封存';

  @override
  String get ng_couldn_t_load_archived_chats => '無法載入已封存的聊天';

  @override
  String get ng_nothing_archived => '沒有已封存的內容';

  @override
  String get ng_restore => '還原';

  @override
  String get ng_saved_new_chats_use_it => '已儲存。新聊天將使用此設定。';

  @override
  String ng_couldn_t_save(Object error) {
    return '無法儲存：$error';
  }

  @override
  String get ng_saving => '正在儲存…';

  @override
  String ng_today(Object time) {
    return '今天 $time';
  }

  @override
  String get ng_mon => '週一';

  @override
  String get ng_tue => '週二';

  @override
  String get ng_wed => '週三';

  @override
  String get ng_thu => '週四';

  @override
  String get ng_fri => '週五';

  @override
  String get ng_sat => '週六';

  @override
  String get ng_sun => '週日';

  @override
  String get ng_scheduled => '排程任務';

  @override
  String get ng_new_job => '新增任務';

  @override
  String get ng_couldn_t_load_scheduled_jobs => '無法載入排程任務';

  @override
  String get ng_nothing_scheduled => '沒有排程任務';

  @override
  String get ng_ask_hermes_to_do_something_on => '讓 Hermes 按排程執行任務，或在此處新增任務。';

  @override
  String get ng_active => '執行中';

  @override
  String get ng_paused => '已暫停';

  @override
  String ng_next(Object when) {
    return '下次 $when';
  }

  @override
  String ng_last(Object when) {
    return '上次 $when';
  }

  @override
  String ng_last_2(Object when, Object result) {
    return '上次 $when · $result';
  }

  @override
  String ng_job(Object id) {
    return '任務 $id';
  }

  @override
  String get ng_delete => '刪除';

  @override
  String get ng_delete_this_job => '刪除此任務？';

  @override
  String get ng_it_stops_running_past_runs_stay => '刪除後將停止執行。以往的執行記錄仍會保留在聊天中。';

  @override
  String ng_next_run(Object when) {
    return '下次執行：$when';
  }

  @override
  String ng_delivers_to(Object target) {
    return '傳送至 $target';
  }

  @override
  String get ng_run_now => '立即執行';

  @override
  String get ng_started => '已啟動';

  @override
  String get ng_pause => '暫停';

  @override
  String get ng_resume => '繼續';

  @override
  String get ng_resumed => '已繼續';

  @override
  String get ng_prompt => '提示詞';

  @override
  String get ng_runs => '執行記錄';

  @override
  String get ng_no_runs_yet => '目前沒有執行記錄。';

  @override
  String get ng_enter_a_schedule_and_a_prompt => '請填寫排程和提示詞。';

  @override
  String get ng_name_optional => '名稱（選填）';

  @override
  String get ng_schedule => '排程';

  @override
  String get ng_every_1h_0_9_or_30m => '例如 every 1h、0 9 * * * 或 30m';

  @override
  String get ng_create => '建立';

  @override
  String get ng_unpin => '取消置頂';

  @override
  String get ng_pin => '置頂';

  @override
  String get ng_rename => '重新命名';

  @override
  String get ng_archive => '封存';

  @override
  String get ng_delete_this_chat => '刪除此聊天？';

  @override
  String get ng_it_is_removed_from_the_gateway => '此聊天會從閘道中刪除，並從所有裝置上移除。';

  @override
  String get ng_search_chats => '搜尋聊天';

  @override
  String get ng_pinned => '已置頂';

  @override
  String get ng_no_chats_match => '沒有符合的聊天。';

  @override
  String get ng_no_chats_yet => '目前沒有聊天。';

  @override
  String get ng_nothing_is_running => '目前沒有執行中的任務。';

  @override
  String get ng_nothing_is_waiting_on_you => '目前沒有待你處理的事項。';

  @override
  String get ng_settings => '設定';

  @override
  String get ng_all => '全部';

  @override
  String ng_needs_you(Object count) {
    return '需要你處理 · $count';
  }

  @override
  String get ng_needs_you_2 => '需要你處理';

  @override
  String get ng_gateways => '閘道';

  @override
  String ng_classic_connection(Object address) {
    return '$address · 經典連線';
  }

  @override
  String get ng_gateway_2 => '閘道';

  @override
  String get ng_signed_in => '已登入';

  @override
  String get ng_classic_connection_2 => '經典連線';

  @override
  String get ng_in_the_browser => '在瀏覽器中';

  @override
  String ng_in_the_browser_as(Object name) {
    return '以 $name 身分在瀏覽器中';
  }

  @override
  String get ng_not_required => '不需要';

  @override
  String get ng_test_connection => '測試連線';

  @override
  String get ng_sign_in_again_2 => '重新登入';

  @override
  String get ng_sign_out => '登出';

  @override
  String get ng_saved_gateways => '已儲存的閘道';

  @override
  String get ng_in_use => '使用中';

  @override
  String get ng_appearance => '外觀';

  @override
  String get ng_theme => '主題';

  @override
  String get ng_system => '跟隨系統';

  @override
  String get ng_light => '淺色';

  @override
  String get ng_dark => '深色';

  @override
  String get ng_accent => '強調色';

  @override
  String get ng_pure_black => '純黑';

  @override
  String get ng_dark_theme_uses_true_black_oled => '深色主題使用純黑（OLED）';

  @override
  String get ng_glow => '光暈';

  @override
  String get ng_soft_accent_light_behind_each_screen => '在每個畫面背景加上柔和的強調色光暈';

  @override
  String get ng_the_new_interface_turn_off_to => '新版介面。關閉後可切回經典介面；閘道和聊天記錄會共用。';

  @override
  String get ng_more_settings => '更多設定';

  @override
  String get ng_voice_notifications_language_backups_and_the =>
      '語音、通知、語言、備份和閘道設定';

  @override
  String get ng_licences => '授權條款';

  @override
  String ng_sign_out_of(Object name) {
    return '要登出 $name 嗎？';
  }

  @override
  String get ng_this_gateway_and_its_saved_sign =>
      '此閘道及其已儲存的登入資訊會從這部手機的兩個介面中移除。聊天記錄仍保留在閘道上。';

  @override
  String get ng_password_or_browser => '密碼或瀏覽器';

  @override
  String get ng_unsupported => '不支援';

  @override
  String get ng_background_task_finished => '背景任務已完成';

  @override
  String get ng_background_process_finished => '背景程序已結束';

  @override
  String get ng_system_message => '系統訊息';

  @override
  String get ng_summary => '摘要';

  @override
  String get classic_interface_only => '僅限經典介面';

  @override
  String get classic_only_settings_hint =>
      '標記為「僅限經典介面」的部分只會更改經典介面的外觀和聊天設定，不會影響 NextGen。NextGen 在其「設定」中有自己的外觀選項。';

  @override
  String get attachment_preview_too_large =>
      '檔案太大，無法在此預覽。儲存或分享即可將其下載到手機（最大 1 GB）。';

  @override
  String get attachment_over_phone_limit => '此檔案超過 1 GB，超出下載限制。請開啟儀表板下載。';

  @override
  String attachment_downloading_percent(int percent) {
    return '正在下載…$percent%';
  }

  @override
  String attachment_downloading_mb(int megabytes) {
    return '正在下載…$megabytes MB';
  }

  @override
  String ng_attachment_too_large_for_gateway(String name) {
    return '$name 超過 12 MB，超出此閘道的接收上限。更新 Hermes 後即可傳送最大 100 MB 的檔案。';
  }

  @override
  String ng_couldn_t_upload(String name) {
    return '無法上傳 $name。';
  }

  @override
  String ng_uploading_percent(int percent) {
    return '正在上傳…$percent%';
  }

  @override
  String get ng_show_tasks => '顯示任務';

  @override
  String get ng_hide_tasks => '隱藏任務';

  @override
  String get ng_goal => '目標';

  @override
  String get ng_loop => '循環';

  @override
  String get ng_heartbeat => '心跳';

  @override
  String get ng_goal_working => '進行中';

  @override
  String get ng_goal_waiting => '等待中';

  @override
  String get ng_goal_blocked => '受阻';

  @override
  String get ng_goal_done => '已完成';

  @override
  String ng_goal_turns_of(int used, int max) {
    return '第 $used 輪，共 $max 輪';
  }

  @override
  String ng_goal_turn(int used) {
    return '第 $used 輪';
  }

  @override
  String get ng_loop_held => '因目標暫停';

  @override
  String get ng_loop_finished => '已結束';

  @override
  String get ng_loop_running => '執行中';

  @override
  String ng_loop_runs_of(int fired, int times) {
    return '已執行 $fired 次，共 $times 次';
  }

  @override
  String ng_loop_runs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '執行 $count 次',
      one: '執行 1 次',
    );
    return '$_temp0';
  }

  @override
  String ng_loop_next(String time) {
    return '下次 $time';
  }

  @override
  String get ng_loop_due_now => '現在執行';

  @override
  String ng_every_seconds(int seconds) {
    return '每 $seconds 秒';
  }

  @override
  String ng_every_minutes(int minutes) {
    return '每 $minutes 分鐘';
  }

  @override
  String ng_every_hours(int hours) {
    return '每 $hours 小時';
  }

  @override
  String ng_every_hours_minutes(int hours, int minutes) {
    return '每 $hours 小時 $minutes 分鐘';
  }

  @override
  String ng_heartbeat_fired(int count) {
    return '已觸發 $count 次';
  }

  @override
  String ng_heartbeat_last_fired(String time) {
    return '上次觸發時間：$time';
  }

  @override
  String ng_wait_until(String time) {
    return '等待至 $time';
  }

  @override
  String get ng_wait_resume => '等待繼續';

  @override
  String get ng_wait_other_chat => '等待另一個聊天';

  @override
  String ng_wait_process(String pid) {
    return '等待程序 $pid';
  }

  @override
  String get ng_control_open => '開啟目標與自動化';

  @override
  String get ng_control_title => '目標與自動化';

  @override
  String get ng_control_subtitle => '此聊天正在努力實現的目標，以及自動執行的內容。';

  @override
  String get ng_contract_outcome => '預期結果';

  @override
  String get ng_contract_verification => '驗證方式';

  @override
  String get ng_contract_constraints => '約束條件';

  @override
  String get ng_contract_boundaries => '邊界';

  @override
  String get ng_contract_stop_when => '停止條件';

  @override
  String get ng_subgoals => '子目標';

  @override
  String get ng_subgoal_add_placeholder => '新增子目標';

  @override
  String get ng_add => '新增';

  @override
  String get ng_subgoal_remove => '移除子目標';

  @override
  String get ng_goal_checks => '檢查項';

  @override
  String get ng_gate_not_run => '尚未執行';

  @override
  String ng_gate_attempts(int attempts, int tries) {
    return '已嘗試 $attempts 次，共 $tries 次';
  }

  @override
  String ng_gate_exit(int code) {
    return '結束代碼 $code';
  }

  @override
  String get ng_resume_now => '立即繼續';

  @override
  String get ng_goal_clear => '清除目標';

  @override
  String get ng_goal_clear_title => '清除此目標？';

  @override
  String get ng_goal_clear_message => '代理程式會停止執行這個目標，相關的子目標和檢查項目也會一併清除。';

  @override
  String get ng_subgoal_remove_title => '移除此子目標？';

  @override
  String ng_subgoal_remove_message(String text) {
    return '「$text」將不再屬於此目標。';
  }

  @override
  String get ng_subgoals_clear_title => '清除所有子目標？';

  @override
  String get ng_subgoals_clear_message => '目標標題將保留，但所有子目標都會被清除。';

  @override
  String get ng_clear_all => '全部清除';

  @override
  String get ng_clear => '清除';

  @override
  String get ng_dismiss => '關閉';

  @override
  String get ng_loop_stop_title => '停止此循環？';

  @override
  String get ng_heartbeat_clear_title => '清除此心跳？';

  @override
  String get ng_wont_fire_again => '此後將不再觸發。';

  @override
  String get ng_loop_self_paced => '自主節奏';

  @override
  String ng_loop_until(String condition) {
    return '持續至：$condition';
  }

  @override
  String get ng_loop_waits_for_goal => '目標進行期間會等待。';

  @override
  String get ng_loop_awaiting_reply => '正在等待代理程式回覆。';

  @override
  String ng_loop_stopped_reason(String reason) {
    return '已停止：$reason';
  }

  @override
  String get ng_hide_subagents => '隱藏子代理';

  @override
  String get ng_show_subagents => '顯示子代理';

  @override
  String get ng_subagent => '子代理';

  @override
  String get ng_subagent_queued => '佇列中';

  @override
  String get ng_subagent_starting => '啟動中…';

  @override
  String get ng_subagent_running => '執行中';

  @override
  String get ng_subagent_done => '已完成';

  @override
  String get ng_subagent_failed => '失敗';

  @override
  String get ng_subagent_stopped => '已停止';

  @override
  String get ng_subagent_stop => '停止子代理';

  @override
  String ng_subagent_tools(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個工具',
      one: '1 個工具',
    );
    return '$_temp0';
  }

  @override
  String get ng_mark_as_read => '標記為已讀';

  @override
  String get ng_mark_as_unread => '標記為未讀';

  @override
  String ng_chats_unread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '聊天，$count 則未讀訊息',
      one: '聊天，1 則未讀訊息',
    );
    return '$_temp0';
  }

  @override
  String get ng_unread_finished => '已完成，回覆未讀';

  @override
  String get ng_unread_updates => '正在執行，有未讀更新';

  @override
  String get ng_notifications => '通知';

  @override
  String get ng_notifications_hint => 'Ares 在背景執行時接收回覆和要求通知';

  @override
  String get ng_notify_replies => '回覆';

  @override
  String get ng_notify_replies_hint => '目前開啟的聊天中，一輪對話完成或失敗時通知';

  @override
  String get ng_notify_requests => '核准和問題';

  @override
  String get ng_notify_requests_hint => '代理程式等待你處理時提醒你，並提供「允許一次」和「拒絕」選項';

  @override
  String get ng_keep_running => '回覆生成期間保持連線';

  @override
  String get ng_keep_running_hint => '在背景保持連線，直到回覆完成，並顯示一條靜默通知';

  @override
  String get ng_battery_settings => '電池優化';

  @override
  String get ng_battery_settings_hint => '允許 Ares 在背景執行，以便及時收到通知';

  @override
  String get ng_send_test_notification => '傳送測試通知';

  @override
  String get ng_test_notification_title => 'Ares 通知功能正常';

  @override
  String get ng_test_notification_body => '回覆和要求通知會以這種形式顯示。';

  @override
  String get ng_test_notification_sent => '測試通知已傳送';

  @override
  String get ng_notifications_blocked => '通知已被封鎖。請在 Android 設定中允許通知。';

  @override
  String get ng_notifications_off_hint => '通知已關閉，因此 Ares 在背景執行時不會傳送通知。';

  @override
  String get ng_insights_building => '正在產生報告。首次產生涵蓋較長期間的報告時，最多可能需要一分鐘。';

  @override
  String get ng_insights_timed_out => '閘道生成此報告逾時。請重試，或選擇更短的時間段。';

  @override
  String get ng_dock_goal_active => '目標進行中';

  @override
  String get ng_dock_goal_paused => '目標已暫停';

  @override
  String get ng_dock_goal_waiting => '目標等待中';

  @override
  String get ng_dock_goal_blocked => '目標受阻';

  @override
  String get ng_dock_goal_done => '目標已完成';

  @override
  String ng_dock_turn_of(int used, int max) {
    return '第 $used/$max 輪';
  }

  @override
  String ng_dock_turn(int used) {
    return '第 $used 輪';
  }

  @override
  String ng_dock_subagents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個子代理',
      one: '1 個子代理',
    );
    return '$_temp0';
  }

  @override
  String ng_dock_subagents_done(int count) {
    return '$count 個已完成';
  }

  @override
  String ng_dock_tasks(int done, int total) {
    return '任務 $done/$total';
  }

  @override
  String ng_dock_previous_tasks(int done, int total) {
    return '上輪任務 $done/$total';
  }

  @override
  String get ng_dock_manage => '管理';

  @override
  String get ng_recent_notifications => '最近通知';

  @override
  String get ng_recent_notifications_hint => 'Ares 嘗試發布的內容，以及 Android 是否顯示了通知';

  @override
  String get ng_recent_notifications_empty =>
      '目前還沒有。當回覆、問題或失敗會觸發通知時，相關嘗試會顯示在這裡。';

  @override
  String get ng_notify_permission_granted => '已獲得通知權限';

  @override
  String get ng_notify_permission_denied => '通知權限已被拒絕';

  @override
  String get ng_notify_master_on => '通知已開啟';

  @override
  String get ng_notify_master_off => '通知已關閉';

  @override
  String get ng_models_default => '預設模型';

  @override
  String get ng_models_change => '更改';

  @override
  String get ng_models_custom_endpoint => '使用自訂端點。請在閘道上更改。';

  @override
  String get ng_models_context_window => '上下文視窗';

  @override
  String ng_models_token_count(String count) {
    return '$count 個令牌';
  }

  @override
  String ng_models_context_override(String count) {
    return '已在閘道上設定。自動偵測：$count 令牌。';
  }

  @override
  String get ng_models_max_output => '最大輸出';

  @override
  String get ng_models_input_price => '輸入價格';

  @override
  String get ng_models_output_price => '輸出價格';

  @override
  String get ng_models_cache_price => '快取輸入價格';

  @override
  String ng_models_per_million(String price) {
    return '每百萬令牌 $price';
  }

  @override
  String ng_models_price_pair(String input, String output) {
    return '每百萬令牌：輸入 $input · 輸出 $output';
  }

  @override
  String get ng_models_free => '免費';

  @override
  String get ng_models_vision => '視覺';

  @override
  String get ng_models_reasoning => '推理';

  @override
  String get ng_models_fast => '快速模式';

  @override
  String get ng_models_in_use => '使用中';

  @override
  String ng_models_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個模型',
      one: '$count 個模型',
    );
    return '$_temp0';
  }

  @override
  String get ng_models_rate_limited => '已限流';

  @override
  String get ng_models_plan_locked => '你的方案不包含此模型';

  @override
  String get ng_models_unsaved => '未儲存的更改';

  @override
  String get ng_models_discard => '捨棄變更';

  @override
  String get ng_models_aux_hint => '輔助任務使用預設模型，除非你為其單獨指定。';

  @override
  String get ng_models_uses_default => '使用預設模型';

  @override
  String get ng_models_thinking_level => '思考等級';

  @override
  String get ng_models_providers => '供應商';

  @override
  String get ng_models_saved => '已儲存';

  @override
  String get ng_aux_vision => '視覺';

  @override
  String get ng_aux_vision_hint => '讀取圖片和螢幕截圖';

  @override
  String get ng_aux_compression => '壓縮';

  @override
  String get ng_aux_compression_hint => '壓縮較長的聊天，使其適應上下文視窗';

  @override
  String get ng_aux_approval => '核准';

  @override
  String get ng_aux_approval_hint => '判斷指令是否可以不經詢問安全執行';

  @override
  String get ng_aux_mcp => 'MCP';

  @override
  String get ng_aux_mcp_hint => '選擇要使用的 MCP 工具';

  @override
  String get ng_aux_title_generation => '聊天標題';

  @override
  String get ng_aux_title_generation_hint => '為新聊天命名';

  @override
  String get ng_aux_review => '審查';

  @override
  String get ng_aux_review_hint => '執行 /review 時檢查工作成果';

  @override
  String get ng_aux_voice_chat => '語音聊天';

  @override
  String get ng_aux_voice_chat_hint => '在語音模式下回覆';

  @override
  String get ng_aux_triage_specifier => '任務分類';

  @override
  String get ng_aux_triage_specifier_hint => '將一行的看板卡片擴展為規格說明';

  @override
  String get ng_aux_kanban_decomposer => '看板拆解';

  @override
  String get ng_aux_kanban_decomposer_hint => '將看板卡片拆分為更小的任務';

  @override
  String get ng_aux_profile_describer => '設定檔描述';

  @override
  String get ng_aux_profile_describer_hint => '為每個設定檔撰寫簡短描述';

  @override
  String get ng_aux_curator => '技能維護';

  @override
  String get ng_aux_curator_hint => '審查技能的使用情況';

  @override
  String get appearance_save_failed => '無法儲存這項變更。';

  @override
  String get appearance_keep_which_theme => '要保留哪個佈景主題？';

  @override
  String get appearance_tour_back => '上一步';

  @override
  String get appearance_tour_finish => '完成';

  @override
  String get appearance_tour_next => '下一步';

  @override
  String get appearance_tour_close => '關閉導覽';

  @override
  String get appearance_dismiss_tip => '關閉提示';

  @override
  String get appearance_search_settings => '搜尋設定';

  @override
  String get appearance_search_show => '顯示';

  @override
  String get appearance_no_matching_setting => '找不到相符的設定。';

  @override
  String get appearance_replay_tour => '再看一次導覽';

  @override
  String get appearance_show_tips_again => '再次顯示提示';

  @override
  String get appearance_window_translucency_unavailable =>
      '此主機無法使用視窗透明度。Linux 不支援，Apple 與 Windows 執行程式繪製的是不透明的 Flutter 視窗。';

  @override
  String get appearance_imported_themes => '匯入的佈景主題';

  @override
  String get appearance_import_theme_file => '匯入佈景主題檔';

  @override
  String get appearance_remove_theme => '移除佈景主題';

  @override
  String get appearance_chat_font => '聊天字型';

  @override
  String get appearance_terminal_font => '終端機字型';

  @override
  String get appearance_font_platform => '系統字型';

  @override
  String get appearance_automatic => '自動';

  @override
  String get appearance_force_left_to_right => '強制由左至右';

  @override
  String get appearance_force_right_to_left => '強制由右至左';

  @override
  String get appearance_user_bubble_opacity => '自己的訊息氣泡透明度';

  @override
  String get appearance_inline_embeds => '內嵌內容';

  @override
  String get appearance_inline_embeds_hint =>
      '豐富預覽會從第三方網站載入（YouTube、X 等）。「詢問」會先顯示預留位置，直到你逐一允許；「一律」會自動載入；「關閉」只保留一般連結。';

  @override
  String get appearance_embeds_ask => '詢問';

  @override
  String get appearance_embeds_always => '一律';

  @override
  String get appearance_embeds_off => '關閉';

  @override
  String appearance_embeds_reset(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '重設 $count 個已允許的服務',
      one: '重設 1 個已允許的服務',
    );
    return '$_temp0';
  }

  @override
  String get appearance_embed_load => '載入';

  @override
  String appearance_embed_always_allow(String service) {
    return '一律允許 $service';
  }

  @override
  String get appearance_embed_loading => '正在載入預覽…';

  @override
  String appearance_embed_image_failed(String host) {
    return '無法從 $host 載入圖片。輕觸即可開啟。';
  }

  @override
  String get appearance_embed_preview_unavailable => '無法預覽';

  @override
  String get appearance_emoji_reactions => '表情回應';

  @override
  String get appearance_celebration_hearts => '慶祝愛心';

  @override
  String get appearance_celebration_hearts_hint => '你離開時若有回覆送達，會播放一顆愛心。';

  @override
  String get appearance_pop_out_companion => '將夥伴彈出視窗';

  @override
  String get appearance_mosskip => '苔躍蛙';

  @override
  String get appearance_emberbun => '餘燼兔';

  @override
  String get appearance_tideling => '潮汐靈';

  @override
  String get appearance_my_hatchling => '我的孵化夥伴';

  @override
  String get appearance_at_rest => '休息中';

  @override
  String get appearance_working => '工作中';

  @override
  String get appearance_thinking => '思考中';

  @override
  String get appearance_waiting_for_you => '等你回應';

  @override
  String get appearance_reply_ready => '回覆已就緒';

  @override
  String get appearance_turn_failed => '本次回應失敗';

  @override
  String get appearance_small => '小';

  @override
  String get appearance_medium => '中';

  @override
  String get appearance_large => '大';

  @override
  String get appearance_hello => '你好！';

  @override
  String get appearance_unread_reply => '有未讀回覆';

  @override
  String get appearance_compose => '撰寫訊息';

  @override
  String get appearance_say_hello => '打個招呼';

  @override
  String get appearance_pet_image_failed => '無法開啟圖片，請選擇較小的 PNG 或 JPEG。';

  @override
  String get appearance_pet_companion => '寵物夥伴';

  @override
  String get appearance_pet_companion_hint => '在聊天時顯示夥伴。';

  @override
  String get appearance_adopt_a_companion => '領養夥伴';

  @override
  String get appearance_roam_when_idle => '閒置時漫步';

  @override
  String get appearance_pet_size => '夥伴大小';

  @override
  String get appearance_hatch_from_a_local_picture => '從本機圖片孵化';

  @override
  String get appearance_pet_image_limits =>
      '選擇 PNG 或 JPEG（最多 4 MiB、每邊 4096 像素且不超過 8 百萬像素）。先預覽，孵化後只儲存一張 24 × 24 像素的肖像，並取代上一次的孵化夥伴。';

  @override
  String get appearance_choose_picture => '選擇圖片';

  @override
  String get appearance_hatchling_preview => '預覽孵化夥伴';

  @override
  String get appearance_hatch_and_adopt => '孵化並領養';

  @override
  String get appearance_discard_draft => '捨棄草稿';

  @override
  String get appearance_forget_saved_hatchling => '移除已儲存的孵化夥伴';

  @override
  String get appearance_radio => '電台';

  @override
  String appearance_radio_hint(String stations) {
    return '串流直接來自 $stations，只有在你按下播放後才會開始。搜尋電台只會在此裝置上進行。';
  }

  @override
  String get appearance_radio_save_failed => '無法儲存電台設定。';

  @override
  String get appearance_choose_a_station => '選擇電台';

  @override
  String get appearance_pause_radio => '暫停電台';

  @override
  String get appearance_play_radio => '播放電台';

  @override
  String get appearance_next_station => '下一個電台';

  @override
  String get appearance_radio_trace_semantics => '串流活動。無法取得音量，所以這條線保持平直。';

  @override
  String get appearance_radio_is_off => '電台已關閉';

  @override
  String get appearance_paused => '已暫停';

  @override
  String get appearance_connecting => '正在連線…';

  @override
  String get appearance_live => '直播中';

  @override
  String get appearance_stream_unavailable => '無法播放串流';

  @override
  String appearance_now_playing(String credit) {
    return '目前播放：$credit';
  }

  @override
  String get appearance_audio_only_waveform_unavailable => '僅播放音訊 · 無法顯示波形';

  @override
  String get appearance_volume => '音量';

  @override
  String get appearance_search_presets => '搜尋預設電台';

  @override
  String get appearance_no_stations_found => '找不到電台';

  @override
  String appearance_unpin_station(String station) {
    return '取消釘選電台：$station';
  }

  @override
  String appearance_pin_station(String station) {
    return '釘選電台：$station';
  }

  @override
  String get appearance_radio_picker_metadata_notice =>
      '開啟此面板並播放時，會向支援此功能的廣播業者取得曲目資訊。';

  @override
  String get appearance_message_from_your_companion => '來自夥伴的訊息';

  @override
  String get appearance_send_to_the_open_chat => '送到目前的聊天';

  @override
  String get appearance_tour_theme_body =>
      '從這台裝置上的檔案匯入 VS Code 色彩佈景主題，再選擇要保留的版本。';

  @override
  String get appearance_tour_fonts_title => '閱讀字型';

  @override
  String get appearance_tour_fonts_body => '聊天內文和終端機程式碼使用 Ares 內建的不同字型。';

  @override
  String get appearance_tour_direction_title => '文字方向';

  @override
  String get appearance_tour_direction_body => '保持自動，或強制對話文字由左至右或由右至左。';

  @override
  String get appearance_tour_pet_title => '夥伴';

  @override
  String get appearance_tour_pet_body => '領養之前不會顯示夥伴。彈出視窗會附上一個小撰寫框。';

  @override
  String get appearance_tour_radio_body => '啟用之前不會播放電台。按下播放才會開啟串流。';

  @override
  String get appearance_tip_theme => '匯入的佈景主題會取代內建配色，直到你取消選擇。只會保留色彩。';

  @override
  String get appearance_tip_pet => '夥伴只在這台裝置上儲存一張小肖像，不會上傳你用來孵化的圖片。';

  @override
  String get appearance_theme_import_failed =>
      '無法匯入這個佈景主題。請選擇以 .vsix、.json 或 .jsonc 檔案儲存的 VS Code 色彩佈景主題。';

  @override
  String get render_svg_not_drawn => '未繪製此 SVG。';

  @override
  String get render_notes_directive => '筆記指令';

  @override
  String get render_maths_source => '數學原始碼';

  @override
  String get render_inline_maths_source => '行內數學原始碼';

  @override
  String get render_sequence_outline => '序列大綱';

  @override
  String get render_diagram_outline => '圖表大綱';

  @override
  String render_revision_of(int index, int count) {
    return '第 $index 版，共 $count 版';
  }

  @override
  String get render_previous_revision => '上一版';

  @override
  String get render_next_revision => '下一版';

  @override
  String get render_show_rendered => '呈現結果';

  @override
  String get render_show_source => '原始碼';

  @override
  String render_copied_file(String name) {
    return '已複製 $name';
  }

  @override
  String render_copy_file(String name) {
    return '複製 $name';
  }

  @override
  String get render_artifact_too_long => '此成品太長，無法在此以頁面顯示。';

  @override
  String get render_active_content_removed => '已移除指令碼、框架和外部位址。';

  @override
  String render_widget_file(String file) {
    return '小工具 $file';
  }

  @override
  String get render_widget_runs_as_text => '在此聊天中以文字執行。已移除指令碼和外部框架。';

  @override
  String get render_load_widget => '載入小工具';

  @override
  String get render_not_html_widget => '此檔案不是 HTML 小工具。';

  @override
  String get render_widget_sent => '已傳送至此聊天';

  @override
  String get render_widget_not_sent => '未傳送至此聊天';

  @override
  String get render_widget_throttled => '請稍候再傳送';

  @override
  String get render_widget_too_long => '此要求太長，無法傳送';

  @override
  String get render_widget_no_gesture => '點選小工具中的控制項以傳送';

  @override
  String get render_widget_invalid => '無法傳送此要求';

  @override
  String get render_inspected_image => '已檢查的圖片';

  @override
  String get render_contributions => '擴充內容';

  @override
  String get render_contributions_intro =>
      '只有編譯進 Ares 的擴充內容能加入回覆。聊天文字無法註冊擴充內容，而授權僅適用於此連線。';

  @override
  String render_grant_plugin(String name) {
    return '授權 $name';
  }

  @override
  String render_revoke_plugin(String name) {
    return '撤銷 $name';
  }

  @override
  String render_plugin_slots(String directive) {
    return '::$directive 的回覆卡片';
  }

  @override
  String get render_plugin_notes => '筆記';

  @override
  String get catalog_scan_passed => '通過';

  @override
  String get catalog_scan_warnings => '發現警告';

  @override
  String get catalog_scan_failed => '失敗';

  @override
  String get deployment_token_label => '部署權杖（選填）';

  @override
  String get deployment_token_helper =>
      '用於以 X-Hermes-Session-Token 傳送的 Hermes Dashboard 工作階段權杖。不會以明文儲存在偏好設定中。';

  @override
  String get deployment_token_hint => '儀表板工作階段權杖';

  @override
  String get custom_headers_label => '自訂標頭（選填）';

  @override
  String get custom_headers_helper => '每行一個，例如 X-Custom: 值。禁止的標頭會遭拒絕。';

  @override
  String get custom_headers_hint => '例如 X-Custom-Header: 值';

  @override
  String get desktop_tray_open => '開啟 Ares';

  @override
  String get desktop_tray_new_chat => '新聊天';

  @override
  String get desktop_tray_quick_entry => '快速輸入…';

  @override
  String get desktop_tray_pause_notifications => '暫停通知';

  @override
  String get desktop_tray_quit => '結束 Ares';

  @override
  String get desktop_integration_title => '桌面整合';

  @override
  String get desktop_tray_setting => '在系統匣或選單列中顯示 Ares';

  @override
  String get desktop_tray_setting_help => '可透過圖示開啟 Ares、開始聊天、開啟快速輸入、暫停通知或結束。';

  @override
  String get desktop_close_to_tray_setting => '關閉視窗後繼續在系統匣中執行';

  @override
  String get desktop_tray_unsupported => '此桌面沒有可供 Ares 使用的系統匣。';

  @override
  String get quick_entry_title => '快速輸入';

  @override
  String get quick_entry_hint => '輸入給 Ares 的提示…';

  @override
  String get quick_entry_submit => '放入輸入框';

  @override
  String get quick_entry_never_sends => '按 Enter 會將文字放入聊天輸入框。在你按下傳送之前不會傳送任何內容。';

  @override
  String get quick_entry_unavailable => '無法開啟快速輸入。請再試一次。';

  @override
  String get desktop_hotkey_setting => '快速輸入快捷鍵';

  @override
  String desktop_hotkey_help(String shortcut) {
    return '在任何地方按 $shortcut 即可開啟快速輸入。';
  }

  @override
  String desktop_hotkey_conflict(String shortcut) {
    return '其他應用程式已在使用 $shortcut。請選擇其他快捷鍵。';
  }

  @override
  String get desktop_hotkey_unsupported => '此桌面不允許應用程式註冊全域快捷鍵（例如 Wayland）。';

  @override
  String get desktop_hotkey_no_modifier => '請包含 Cmd、Ctrl 或 Alt。';

  @override
  String get desktop_hotkey_super_key => 'Windows 鍵或 Super 鍵保留給系統使用。';

  @override
  String get desktop_hotkey_reserved => '系統已在使用此快捷鍵。';

  @override
  String desktop_hotkey_in_app(String action) {
    return 'Ares 已將此快捷鍵用於$action。';
  }

  @override
  String get desktop_hotkey_change => '變更';

  @override
  String get desktop_hotkey_reset => '使用預設值';

  @override
  String get capture_screen_action => '擷取螢幕';

  @override
  String get capture_screen_help => '將螢幕截圖作為草稿加入訊息。在你按下傳送之前不會傳送任何內容。';

  @override
  String get capture_screen_unavailable => '此桌面無法使用螢幕擷取。';

  @override
  String get capture_screen_failed => '無法擷取螢幕。請再試一次。';

  @override
  String get capture_permission_title => '允許螢幕錄製';

  @override
  String get capture_permission_body =>
      '若要擷取視窗，Ares 需要螢幕錄製權限。請在「系統設定」>「隱私權與安全性」>「螢幕錄製」中開啟 Ares，然後再試一次。';

  @override
  String get capture_open_settings => '開啟系統設定';

  @override
  String get keep_awake_title => '讓電腦保持喚醒';

  @override
  String get keep_awake_title_mobile => '讓螢幕保持開啟';

  @override
  String get keep_awake_mode_off => '關閉';

  @override
  String get keep_awake_mode_while_working => '工作時';

  @override
  String get keep_awake_mode_always => '一律';

  @override
  String get keep_awake_off_help => '絕不阻止系統睡眠（預設）。';

  @override
  String get keep_awake_while_working_help => '僅在代理回合執行時阻止閒置睡眠。';

  @override
  String get keep_awake_always_help => '在此裝置上開啟 Ares 期間阻止閒置睡眠。';

  @override
  String get keep_awake_off_help_mobile => '讓螢幕照常關閉（預設）。';

  @override
  String get keep_awake_while_working_help_mobile =>
      '在代理回合執行且 Ares 開啟期間讓螢幕保持開啟。';

  @override
  String get keep_awake_always_help_mobile => '在 Ares 開啟期間讓螢幕保持開啟。';

  @override
  String get ng_token_gateway_has_no_sign_in =>
      '此閘道沒有登入功能，因此無法驗證部署權杖。請在主機上啟用儀表板驗證（或更新 Hermes），然後再試一次。';

  @override
  String get palette_open => '應用程式命令面板';

  @override
  String get palette_no_matches => '沒有相符的操作';

  @override
  String get palette_filter_hint => '輸入以篩選操作…';

  @override
  String get palette_keys_move => '↑↓ 移動';

  @override
  String get palette_keys_run => 'Enter 執行';

  @override
  String get palette_keys_close => 'Esc 關閉';

  @override
  String get palette_search_sessions => '搜尋工作階段';

  @override
  String get palette_scheduled_crons => '排程 / Cron';

  @override
  String get palette_capabilities_skills => '功能與技能';

  @override
  String get palette_insights_usage => '洞察與用量';

  @override
  String get palette_more_projects => '更多與專案';

  @override
  String get deeplink_chat_not_found => '清單中找不到此聊天，可能尚未載入。';

  @override
  String get keyboard_shortcuts_title => '鍵盤快速鍵';

  @override
  String get shortcuts_reset_all => '全部重設';

  @override
  String get shortcuts_reset_to_default => '還原預設值';

  @override
  String get shortcut_action_command_palette => '命令面板';

  @override
  String get shortcut_action_new_chat => '新增聊天';

  @override
  String get shortcut_action_search => '搜尋';

  @override
  String get shortcut_action_settings => '設定';

  @override
  String shortcut_action_go_to_tab(int number) {
    return '前往分頁 $number';
  }

  @override
  String shortcuts_conflict(String first, String second, String chord) {
    return '衝突：「$first」和「$second」都使用 $chord。在你變更其中一個之前，自訂快速鍵會保持預設值。';
  }

  @override
  String shortcuts_editor_title(String action) {
    return '快速鍵：$action';
  }

  @override
  String get shortcuts_editor_help => '按下按鍵組合，或在下方選擇輔助鍵和按鍵：';

  @override
  String get shortcuts_editor_needs_modifier =>
      '請至少選擇 Cmd/Meta、Ctrl 或 Alt，以免影響在輸入框中打字。';

  @override
  String shortcuts_text_editing_warning(String chord) {
    return '$chord 是文字編輯快速鍵（複製、貼上、剪下、復原、重做或全選）。在此指定後，文字欄位將無法使用它。';
  }

  @override
  String shortcuts_text_editing_in_use(String action, String chord) {
    return '「$action」使用了文字編輯快速鍵 $chord。在此指定期間，文字欄位無法使用它。';
  }

  @override
  String custom_headers_problem_format(int line) {
    return '第 $line 行：應為「名稱: 值」';
  }

  @override
  String custom_headers_problem_missing_name(int line) {
    return '第 $line 行：缺少標頭名稱';
  }

  @override
  String custom_headers_problem_invalid_name(int line, String name) {
    return '第 $line 行：標頭名稱「$name」無效';
  }

  @override
  String custom_headers_problem_reserved(int line, String name) {
    return '第 $line 行：「$name」為保留標頭，無法傳遞';
  }

  @override
  String custom_headers_problem_empty_value(int line) {
    return '第 $line 行：標頭值為空';
  }

  @override
  String get ng_enter_a_deployment_token => '請輸入部署工作階段權杖。';

  @override
  String get ng_custom_headers => '自訂標頭';

  @override
  String get ng_custom_headers_help =>
      '此閘道的額外 HTTP 標頭（名稱: 值，每行一個），隨其 REST 和 WebSocket 呼叫傳送，並保存在安全的憑證儲存區中。驗證標頭和逐跳標頭會遭拒絕。';

  @override
  String get ng_use_a_deployment_token => '使用部署工作階段權杖';

  @override
  String get ng_sign_in_with_deployment_token => '使用部署權杖登入';

  @override
  String get ng_signed_in_with_deployment_token => '已使用部署權杖登入。';

  @override
  String get auto_speak_replies_title => '自動朗讀回覆';

  @override
  String get auto_speak_replies_subtitle =>
      '回合完成後自動朗讀每則新回覆。預設關閉；單一對話的語音回覆開關仍然有效。';

  @override
  String get ng_auto_read_replies_title => '自動朗讀回覆';

  @override
  String get ng_auto_read_replies_subtitle => '回合完成後自動朗讀每則新回覆。預設關閉。';

  @override
  String get barge_in_title => '插話打斷';

  @override
  String get barge_in_subtitle => '朗讀回覆時開口說話即可中斷播放。朗讀回覆期間麥克風保持開啟。';

  @override
  String get barge_in_mic_live => '麥克風已開啟：說話即可打斷回覆';

  @override
  String get ng_barge_in_title => '插話打斷';

  @override
  String get ng_barge_in_subtitle => '朗讀回覆時開口說話即可中斷播放。朗讀回覆期間麥克風保持開啟。';

  @override
  String get ng_barge_in_mic_live => '麥克風已開啟：說話即可打斷回覆';

  @override
  String get wake_word_title => '喚醒詞';

  @override
  String get wake_word_subtitle => '由閘道器提供免持喚醒偵測。預設關閉；僅在啟用裝置麥克風擷取時傳送音訊。';

  @override
  String wake_word_listening(String phrase) {
    return '正在聆聽喚醒詞「$phrase」';
  }

  @override
  String wake_word_paused(String phrase) {
    return '喚醒詞「$phrase」— 已暫停';
  }

  @override
  String wake_word_off(String phrase) {
    return '喚醒詞「$phrase」— 已關閉';
  }

  @override
  String get wake_word_arming => '正在啟用喚醒詞…';

  @override
  String get wake_word_stop => '停止喚醒詞';

  @override
  String get wake_word_rearm => '重新啟用';

  @override
  String get wake_word_capture_mode => '擷取模式';

  @override
  String get wake_word_capture_auto => '自動';

  @override
  String get wake_word_capture_client => '此裝置麥克風';

  @override
  String get wake_word_capture_local => '閘道器主機麥克風';

  @override
  String get wake_word_input_device => '輸入麥克風';

  @override
  String get wake_word_default_device => '系統預設';

  @override
  String get ng_wake_word_title => '喚醒詞';

  @override
  String get ng_wake_word_subtitle => '由閘道器提供免持喚醒偵測。預設關閉。';

  @override
  String get voice_engine_title => '語音對話引擎';

  @override
  String get voice_engine_subtitle => '選擇此閘道器設定檔中免持語音對話的執行方式。';

  @override
  String get voice_engine_chained => '串接（語音轉文字 → Hermes → 語音）';

  @override
  String get voice_engine_chained_short => '串接';

  @override
  String get voice_engine_live => 'GPT-Live（即時語音）';

  @override
  String get voice_engine_live_short => 'GPT-Live';

  @override
  String get voice_engine_live_needs_key =>
      '請在閘道器主機上設定 OpenAI API 金鑰以啟用 GPT-Live。';

  @override
  String voice_engine_fallback_chained(String reason) {
    return 'GPT-Live 無法使用（$reason）— 改用串接語音。';
  }

  @override
  String get voice_live_start => '開始語音對話';

  @override
  String get voice_live_stop => '結束語音對話';

  @override
  String get voice_live_mute => '麥克風靜音';

  @override
  String get voice_live_unmute => '取消麥克風靜音';

  @override
  String get voice_live_interrupt => '打斷或立即回應';

  @override
  String get voice_live_listening => '正在聆聽';

  @override
  String get voice_live_speaking => '正在說話';

  @override
  String get voice_live_thinking => '正在思考';

  @override
  String get voice_live_muted => '已靜音';

  @override
  String get voice_live_ended_connection_lost => '即時語音工作階段的連線已中斷。';

  @override
  String get voice_live_ended_closed => '即時語音工作階段已被服務關閉。';

  @override
  String wake_word_other_profile(String profile) {
    return '此喚醒詞屬於設定檔「$profile」。請開啟連到該設定檔的連線以回應。';
  }

  @override
  String get wake_word_reason_disabled => '已關閉 — 點按以啟用';

  @override
  String get wake_word_reason_surface => '僅限其他介面使用（設定 wake_word.surface）';

  @override
  String get wake_word_reason_owned => '喚醒詞聆聽由其他介面佔用';

  @override
  String wake_word_reason_owned_by(String surface) {
    return '喚醒詞聆聽由其他介面（$surface）佔用';
  }

  @override
  String get wake_word_reason_unavailable => '此閘道器不支援喚醒詞';

  @override
  String get wake_word_reason_permission_denied => '麥克風權限遭拒';

  @override
  String get wake_word_reason_permission_required => '需要麥克風權限 — 點按以啟用';

  @override
  String get voice_live_not_enabled => '此設定檔未啟用 GPT-Live。';

  @override
  String get voice_live_not_available => 'GPT-Live 無法使用';

  @override
  String voice_live_start_failed(String error) {
    return '無法啟動 GPT-Live：$error';
  }

  @override
  String voice_direct_stt_timeout(String seconds, String provider) {
    return '轉錄在 $seconds 秒後逾時（$provider 未回應）';
  }

  @override
  String voice_direct_stt_error(String provider, String status) {
    return '$provider 語音轉文字錯誤（HTTP $status）';
  }

  @override
  String voice_direct_tts_failed(String provider) {
    return '$provider 文字轉語音要求失敗';
  }

  @override
  String voice_direct_tts_error(String provider, String status) {
    return '$provider 文字轉語音錯誤（HTTP $status）';
  }

  @override
  String ng_wake_status_listening(String phrase) {
    return '正在聆聽（「$phrase」）';
  }

  @override
  String ng_wake_status_off(String phrase) {
    return '已關閉（「$phrase」）';
  }

  @override
  String ng_wire_setting_unavailable(Object setting) {
    return '共用閘道尚不支援變更 $setting';
  }

  @override
  String ng_wire_method_unavailable(Object method) {
    return '共用閘道尚不支援 $method';
  }

  @override
  String ng_wire_session_options_unsupported(Object options) {
    return '標準閘道不支援下列明確指定的工作階段選項：$options';
  }

  @override
  String get ng_wire_prompt_stale => '此要求已過期或無法使用；請重新連線後再回覆';

  @override
  String get ng_wire_revision_unavailable => '無法取得工作階段修訂版本；請重新開啟工作階段後再編輯中繼資料';

  @override
  String get ng_wire_generation_unavailable => '無法取得工作階段執行識別碼；請重新連線後再使用此指令';

  @override
  String get ng_wire_message_not_saved => '此訊息尚未儲存；請等它完成後，再從它建立分支';

  @override
  String get ng_wire_not_available => '共用閘道尚不支援';

  @override
  String get edit_turn_title => '編輯此提示？';

  @override
  String get edit_turn_body => '將從此處重新執行該提示，後續輪次會被封存。';

  @override
  String get edit_turn_send => '傳送';

  @override
  String get restore_turn_title => '還原至此檢查點？';

  @override
  String get restore_turn_body => '此提示之後的所有內容將從對話中移除，並從此處重新執行該提示。';

  @override
  String get restore_turn_confirm => '還原並重新執行';

  @override
  String get edit_turn_later_turns_body => '這會將對話中的後續輪次封存。要繼續嗎？';

  @override
  String get session_history => '工作階段紀錄';

  @override
  String get import_claude_or_codex => '匯入 Claude 或 Codex';

  @override
  String get ng_session_history => '工作階段紀錄';

  @override
  String get ng_import_claude_or_codex => '匯入 Claude 或 Codex';

  @override
  String get ng_edit_and_resend => '編輯並重發';

  @override
  String get ng_restore_turn_confirm => '還原並重新執行';

  @override
  String get rewind_target_unsaved => '此訊息尚未儲存。請等待其完成後再編輯。';

  @override
  String get rewind_turn_busy => '目前的回覆尚未停止，因此未傳送任何內容。請稍後再試。';

  @override
  String get rewind_session_changed => '此聊天自在此處開啟後已有變更，因此未移除或傳送任何內容。請重新開啟後再試。';

  @override
  String get history_lineage => '相關聊天';

  @override
  String get history_lineage_none => '此聊天沒有分支或同層分支。';

  @override
  String get history_lineage_unavailable => '無法從此閘道讀取相關聊天。';

  @override
  String get history_lineage_parent => '上層';

  @override
  String get history_lineage_sibling => '同層';

  @override
  String get history_lineage_fork => '分支';

  @override
  String get history_messages => '訊息';

  @override
  String get history_messages_hint => '選擇一則已儲存的訊息，從該處分支或回溯。';

  @override
  String get history_messages_none => '尚無已儲存的訊息。';

  @override
  String get history_messages_unavailable => '無法讀取已儲存的訊息。請開啟此聊天後重新整理。';

  @override
  String get history_role_user => '你';

  @override
  String get history_role_assistant => 'Hermes';

  @override
  String get history_branch_here => '從這裡分支';

  @override
  String get history_rewind_here => '回溯到這裡';

  @override
  String get history_branch_title => '從此訊息分支';

  @override
  String get history_branch_body => '這會建立一個包含到所選訊息為止歷史的新聊天。目前的聊天保持不變。';

  @override
  String get history_rewind_title => '回溯到此訊息';

  @override
  String get history_rewind_body =>
      '從所選訊息起的訊息將從此聊天中移除。電腦上的檔案不會變更。還原檔案是另外的檢查點操作。';

  @override
  String history_branched(String id) {
    return '已分支為 $id';
  }

  @override
  String get history_open_chat => '開啟聊天';

  @override
  String get history_mutate_unsupported => '分支和回溯需要此閘道執行 Hermes 0.23 或更新版本。';

  @override
  String get history_checkpoints => '檢查點';

  @override
  String get history_checkpoints_none => '此工作階段沒有檔案檢查點。';

  @override
  String get history_checkpoints_unavailable => '此閘道不提供檢查點。';

  @override
  String get history_diff_none => '沒有差異。';

  @override
  String get history_diff_loading => '正在載入變更…';

  @override
  String get history_diff_failed => '無法載入變更，因此暫時不能還原此檢查點。';

  @override
  String get history_restore_checkpoint => '還原檢查點';

  @override
  String get history_restore_title => '還原此檢查點';

  @override
  String get history_restore_body =>
      '代理自此檢查點以來變更的檔案將還原到當時的狀態。你自己的變更會保留。之後的聊天訊息也可能被移除。對話不會分支。';

  @override
  String get history_restore_body_all =>
      '工作階段資料夾中的所有檔案都將還原到此檢查點，包括你自己的變更。之後的聊天訊息也可能被移除。對話不會分支。';

  @override
  String get history_restore_own_edits => '同時還原我自己的變更';

  @override
  String get history_restored => '檢查點已還原。';

  @override
  String history_restored_removed(int count) {
    return '檢查點已還原。已移除 $count 則聊天訊息。';
  }

  @override
  String get history_export => '匯出';

  @override
  String get history_export_redact => '隱去權杖';

  @override
  String get history_export_action => '匯出對話記錄';

  @override
  String get history_export_saved => '對話記錄已儲存。';

  @override
  String get history_export_unsupported => '匯出需要此閘道執行 Hermes 0.23 或更新版本。';

  @override
  String get history_import_unsupported => '此閘道不支援匯入 Claude 和 Codex。';

  @override
  String history_import_destination(String profile) {
    return '目標設定檔：$profile。';
  }

  @override
  String history_import_reading(String host, String profile, int count) {
    return '正在從 $host 讀取 · 目標設定檔：$profile。有 $count 個記錄無法讀取。';
  }

  @override
  String get history_import_all => '全部';

  @override
  String history_import_scan_failed(String reason) {
    return '無法掃描主機工作階段：$reason';
  }

  @override
  String get history_import_none => '在此主機上找不到 Claude Code 或 Codex 工作階段。';

  @override
  String get history_import_no_match => '沒有相符的主機工作階段。';

  @override
  String history_import_preview_failed(String reason) {
    return '無法預覽工作階段：$reason';
  }

  @override
  String get history_import_open => '開啟已匯入的工作階段';

  @override
  String get history_import_action => '匯入所選工作階段';

  @override
  String get history_import_title => '匯入此工作階段';

  @override
  String history_import_body(String profile) {
    return '將此 Claude 或 Codex 工作階段複製到此閘道上的設定檔「$profile」。';
  }

  @override
  String history_import_body_existing(String profile) {
    return '此工作階段已匯入到「$profile」。將繼續使用現有副本。';
  }

  @override
  String history_imported(String id) {
    return '已匯入為 $id';
  }

  @override
  String history_imported_already(String id) {
    return '先前已匯入為 $id';
  }

  @override
  String history_import_directory(String path) {
    return '目錄：$path';
  }

  @override
  String history_import_preview_partial(int shown, int total) {
    return '預覽顯示 $total 則中的 $shown 則。';
  }

  @override
  String history_failed(String reason) {
    return '無法完成：$reason';
  }

  @override
  String get history_error_unavailable => '閘道暫時無法執行此操作。請重試。';

  @override
  String get history_error_unsupported => '此閘道不支援此操作。';

  @override
  String get history_error_denied => '此閘道拒絕了該要求。';

  @override
  String get history_error_changed => '此頁面開啟期間聊天已有變更。請重新整理後再試。';

  @override
  String get history_error_unbound => '此聊天未在閘道上開啟。請開啟後再試。';

  @override
  String get history_error_invalid => '閘道傳回了此應用程式無法讀取的回應。';
}

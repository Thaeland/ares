// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get workspace_workers => 'العمّال النشطون';

  @override
  String get workers_unattached =>
      'أعداد فقط. لتوجيه عامل، اختر «العمّال النشطون» في المحادثة الأم المرتبط بها.';

  @override
  String get slash_local_arguments =>
      'لا يقبل هذا الاختصار معاملات هنا. استخدم عناصر التحكم في التطبيق. لم تتغير مسودتك.';

  @override
  String get fallback_title => 'النماذج الاحتياطية';

  @override
  String get fallback_notice =>
      'عندما لا يتوفر النموذج الرئيسي، تُجرَّب النماذج الاحتياطية بالترتيب. تخص التغييرات هذا الملف الشخصي فقط. اضغط على زر الحفظ لحفظ القائمة كاملة.';

  @override
  String get fallback_unavailable =>
      'إعدادات النماذج الاحتياطية غير متاحة أو غير صالحة. تحقق من الاتصال والملف الشخصي المحدد وإصدار المضيف، ثم أعد المحاولة.';

  @override
  String get fallback_discovery_unavailable =>
      'يتعذر اكتشاف المزوّدين حاليًا. ما زالت الإدخالات الحالية محفوظة. أعد المحاولة لاختيار المزوّدين والنماذج.';

  @override
  String get fallback_empty => 'قائمة النماذج الاحتياطية فارغة.';

  @override
  String get fallback_incomplete =>
      'اختر مزوّدًا ونموذجًا لكل إدخال، أو أزل الإدخالات غير المكتملة قبل الحفظ.';

  @override
  String get fallback_add => 'إضافة نموذج احتياطي';

  @override
  String get fallback_save => 'حفظ قائمة النماذج الاحتياطية';

  @override
  String get fallback_save_failed =>
      'تعذّر التحقق من قائمة النماذج الاحتياطية المحفوظة. ما زالت مسودتك محفوظة. أعد محاولة الحفظ أو حدّث الصفحة لإعادة تحميل إعدادات المضيف.';

  @override
  String get fallback_saved =>
      'حُفظت قائمة النماذج الاحتياطية وتم التحقق منها.';

  @override
  String get fallback_legacy_title =>
      'النماذج الاحتياطية القديمة (للقراءة فقط)';

  @override
  String get fallback_legacy_notice =>
      'يستخدم المضيف أيضًا fallback_model بعد هذه القائمة، ويتخطى المسارات المكررة. تظل الإدخالات القديمة محفوظة حتى لو كانت القائمة أعلاه فارغة. يمكنك تعديلها على المضيف.';

  @override
  String fallback_priority(String position) {
    return 'الأولوية: $position';
  }

  @override
  String get fallback_move_up => 'نقل لأعلى';

  @override
  String get fallback_move_down => 'نقل لأسفل';

  @override
  String get fallback_routing_read_only =>
      'يحتفظ التطبيق بتفاصيل التوجيه أو بالمزوّد غير المدرج. عدّل المزوّد أو النموذج على المضيف. لا يزال بإمكانك تغيير ترتيب الإدخال أو إزالته.';

  @override
  String get cron_model_default => 'استخدام النموذج الافتراضي';

  @override
  String get cron_model_notice =>
      'ينطبق هذا الاختيار على مهمة cron هذه فقط. إذا لم تحدد لها نموذجًا بعينه، يستخدم Hermes نموذج cron الافتراضي، ثم النموذج الرئيسي. يمكنك إدارة النماذج المخصصة على المضيف.';

  @override
  String get model_management_unavailable =>
      'تعذّر تحميل إعدادات النماذج أو حفظها. حدّث الصفحة وحاول مجددًا.';

  @override
  String get model_management_subtitle =>
      'النموذج الرئيسي والنماذج الاحتياطية والمساعدة لهذا الملف الشخصي';

  @override
  String get usage => 'الاستخدام';

  @override
  String get nous_portal => 'بوابة Nous';

  @override
  String get portal_menu_subtitle => 'حالة البوابة والاستخدام المسجّل';

  @override
  String get portal_read_only =>
      'بيانات البوابة للقراءة فقط. يمكنك إدارة مصادقة Nous على مضيف Hermes. لا تتيح نقاط النهاية هذه معرفة رصيد الاشتراك أو الرصيد الائتماني.';

  @override
  String get portal_status => 'حالة اتصال البوابة بخدمة Nous Portal';

  @override
  String get portal_free_tier =>
      'وصول ضمن الباقة المجانية (من دون تسجيل الدخول إلى حساب)';

  @override
  String get portal_signed_in => 'تم تسجيل الدخول';

  @override
  String get portal_signed_out => 'لم يتم تسجيل الدخول';

  @override
  String get portal_account_tier => 'فئة الحساب';

  @override
  String get portal_recorded_usage => 'الاستخدام المسجّل';

  @override
  String get portal_all_providers =>
      'يشمل جميع المزوّدين في الملف الشخصي المحدد للبوابة. تسجيل تكلفة قدرها صفر لا يعني أن النموذج مجاني.';

  @override
  String portal_period(String days) {
    return 'آخر $days يومًا';
  }

  @override
  String get portal_sessions => 'الجلسات';

  @override
  String get portal_input => 'رموز الإدخال';

  @override
  String get portal_output => 'رموز الإخراج';

  @override
  String get portal_estimated => 'التكلفة التقديرية المسجّلة';

  @override
  String get portal_actual => 'التكلفة الفعلية المسجّلة';

  @override
  String get portal_recorded_models => 'النماذج المسجّلة';

  @override
  String get portal_no_models => 'لا توجد نماذج مسجّلة.';

  @override
  String get portal_unavailable =>
      'البيانات غير متاحة. تحقق من الاتصال والملف الشخصي المحدد وإصدار البوابة، ثم أعد المحاولة.';

  @override
  String get paste_attachment_failed_text_kept =>
      'تعذّر إرفاق المحتوى الملصق. بقي النص في الرسالة.';

  @override
  String get background_task_report => 'مهمة في الخلفية';

  @override
  String get background_process_report => 'عملية في الخلفية';

  @override
  String get background_report_issues =>
      'أُبلغ عن مشكلات. وسّع التقرير لعرض التفاصيل.';

  @override
  String get background_report_expand => 'توسيع التقرير';

  @override
  String get background_report_collapse => 'طيّ التقرير';

  @override
  String get copy_session_id => 'نسخ معرّف الجلسة';

  @override
  String get copy_session_id_failed => 'تعذّر نسخ معرّف الجلسة.';

  @override
  String get setup_interface_title => 'اختر واجهتك';

  @override
  String get setup_interface_classic => 'Classic';

  @override
  String get setup_interface_nextgen => 'NextGen';

  @override
  String get setup_interface_classic_description =>
      'مساحة عمل Ares الأصلية، مع جميع أدوات التحكم في الاتصال وإعدادات واجهة Classic.';

  @override
  String get setup_interface_nextgen_description =>
      'واجهة أحدث تتيح تسجيل الدخول مرة واحدة إلى لوحة التحكم، ومتابعة الخطط مباشرة، واستخدام الوكلاء الفرعيين والإشعارات.';

  @override
  String get setup_interface_switch_later =>
      'يمكنك تبديل الواجهة في أي وقت من الإعدادات.';

  @override
  String get ng_confirm_model_switch => 'هل تريد تبديل النموذج؟';

  @override
  String get ng_switch => 'تبديل';

  @override
  String get ng_model_confirmation_required =>
      'يلزم التأكيد قبل اختيار هذا النموذج.';

  @override
  String ng_model_switches_next_turn(String model) {
    return 'سيُستخدم $model في الجولة التالية.';
  }

  @override
  String get ng_model_switch_not_connected =>
      'الدردشة غير جاهزة لتبديل النموذج. افتحها مجددًا وأعد المحاولة.';

  @override
  String ng_gateway_kept_default_model(String model) {
    return 'أبقت البوابة على $model لهذه الدردشة. أعد اختيار النموذج قبل الإرسال.';
  }

  @override
  String get hands_free_title => 'الاستخدام دون لمس';

  @override
  String get hands_free_start => 'بدء الاستخدام دون لمس';

  @override
  String get hands_free_stop => 'إيقاف الاستخدام دون لمس';

  @override
  String get hands_free_preparing => 'جارٍ تجهيز الصوت. انتظر إشارة الجاهزية';

  @override
  String get hands_free_listening => 'قل «Hey Hermes»';

  @override
  String get hands_free_recording => 'جاهز — تحدث الآن';

  @override
  String get hands_free_waiting => 'في انتظار Hermes';

  @override
  String get hands_free_speaking => 'جارٍ نطق الرد — الميكروفون مغلق';

  @override
  String hands_free_followup(int seconds) {
    return 'الاستماع لمدة تصل إلى $seconds ثانية';
  }

  @override
  String get hands_free_error => 'توقف وضع الاستخدام دون لمس';

  @override
  String get hands_free_setup => 'إعداد الاستخدام دون لمس';

  @override
  String hands_free_preview(String transcript) {
    return 'معاينة الإملاء الصوتي: $transcript';
  }

  @override
  String get hands_free_short_disclosure =>
      'يعمل هذا الوضع فقط عندما تكون هذه الدردشة مفتوحة في الواجهة. لا يتطلب رصد عبارة التنبيه اتصالًا، لكن الخدمات الصوتية قد تستخدم الشبكة. يستهلك الاستماع طاقة البطارية.';

  @override
  String get hands_free_error_action =>
      'تحقق من إذن الميكروفون وخدمة الكلام وصوت الرد والاتصال، ثم اضغط على زر الإيقاف يليه زر البدء لإعادة المحاولة. لن يُعاد إرسال أي شيء.';

  @override
  String get hands_free_disclosure =>
      'تُرصد عبارة التنبيه على وحدة المعالجة المركزية (CPU) دون اتصال. قد تستخدم خدمة التعرّف على الكلام في Android وصوت الرد المحدد والبوابة اتصالات الشبكة. يستهلك الاستماع طاقة البطارية وقد يتنشط الميكروفون بالخطأ. يتوقف الوضع إذا غطّت شاشة أخرى الدردشة أو أُغلقت أو انتقلت إلى الخلفية. لا يُستأنف تلقائيًا عند فتحها مجددًا. يبقى النص الذي تمليه يدويًا مسودة قابلة للتعديل.';

  @override
  String get hands_free_ready_cue =>
      'قل «Hey Hermes»، وانتظر إشارة «جاهز — تحدث الآن»، ثم تحدث. لا يُسجَّل الكلام المتصل بعبارة التنبيه، ولا ما سبق الإشارة. إذا انتقلت خارج التطبيق لضبط الإذن، فاضغط على زر البدء مجددًا بعد منحه.';

  @override
  String get hands_free_settings_title => 'التحكم الصوتي دون لمس';

  @override
  String get hands_free_settings_subtitle =>
      'إظهار زر بدء الاستماع لعبارة «Hey Hermes» في الدردشات. يؤدي تعطيل هذا الخيار إلى إيقاف أي جلسة نشطة للاستخدام دون لمس.';

  @override
  String get hands_free_timing_limit =>
      'مهلة انتظار المتابعة حد أقصى، وليست حدًا أدنى. قد يتوقف Android عن الاستماع قبل انتهائها. عند الصمت يعود التطبيق إلى رصد عبارة التنبيه محليًا دون تكرار تشغيل خدمة التعرّف على الكلام.';

  @override
  String get hands_free_followup_off =>
      'المتابعة معطّلة — قل «Hey Hermes» قبل كل طلب';

  @override
  String get hands_free_start_blocked =>
      'للبدء، يجب أن تكون المسودة فارغة وبلا مرفقات، وأن تكون الدردشة متصلة ولا تنفذ أي طلب، وأن تكون الردود المنطوقة مفعّلة. أنهِ أولًا أي إجراء صوتي بدأته يدويًا.';

  @override
  String get hands_free_setup_complete =>
      'اكتمل إعداد الميكروفون. اضغط على زر البدء مجددًا.';

  @override
  String message_time_recorded(String time) {
    return 'وقت التسجيل على الخادم: $time (بالتوقيت المحلي)';
  }

  @override
  String message_time_sent(String time) {
    return 'وقت رصد الإرسال على هذا الجهاز: $time (بالتوقيت المحلي)';
  }

  @override
  String message_time_received(String time) {
    return 'وقت أول استلام على هذا الجهاز: $time (بالتوقيت المحلي)';
  }

  @override
  String get stop_and_send => 'إيقاف وإرسال';

  @override
  String get message_queued_for_running_turn =>
      'أُضيفت الرسالة إلى قائمة انتظار التنفيذ الجاري.';

  @override
  String get running_message_not_accepted =>
      'تعذّر على Hermes قبول هذه الرسالة. ما زالت مسودتك محفوظة. أوقف الرد أو انتظر انتهاءه، ثم أعد الإرسال.';

  @override
  String get running_message_delivery_unknown =>
      'تعذّر تأكيد تسليم الرسالة. ما زالت مسودتك محفوظة. تحقق من الدردشة قبل إعادة المحاولة.';

  @override
  String get attachment_tap_to_preview => 'اضغط للمعاينة';

  @override
  String get attachment_save => 'حفظ';

  @override
  String get attachment_share => 'مشاركة';

  @override
  String get attachment_saved => 'حُفظ الملف';

  @override
  String get attachment_save_cancelled => 'أُلغي الحفظ';

  @override
  String get attachment_save_failed => 'تعذّر حفظ هذا الملف. حاول مجددًا.';

  @override
  String get attachment_share_failed => 'تعذّرت مشاركة هذا الملف. حاول مجددًا.';

  @override
  String get attachment_download_failed =>
      'تعذّر تحميل هذا الملف. تحقق من الاتصال وحاول مجددًا.';

  @override
  String get attachment_no_inline_preview =>
      'لا تتوفر معاينة داخل التطبيق لهذا النوع من الملفات. احفظ الملف الأصلي أو شاركه لفتحه في تطبيق آخر.';

  @override
  String get attachment_image_failed =>
      'تعذّر فك ترميز هذه الصورة. لا يزال بإمكانك حفظ الملف الأصلي أو مشاركته.';

  @override
  String get attachment_text_truncated =>
      'المعاينة مختصرة. احفظ الملف أو شاركه لقراءته كاملًا.';

  @override
  String get attachment_text_unavailable =>
      'تعذّر عرض هذا الملف كنص. احفظ الملف الأصلي أو شاركه.';

  @override
  String get attachment_pdf_failed =>
      'تعذّرت معاينة ملف PDF هذا. احفظ الملف الأصلي أو شاركه.';

  @override
  String get attachment_pdf_unavailable =>
      'تتوفر معاينة ملفات PDF على Android. لا يزال بإمكانك حفظ هذا الملف أو مشاركته.';

  @override
  String attachment_pdf_page(int page, int total) {
    return 'الصفحة $page من $total';
  }

  @override
  String get attachment_previous_page => 'الصفحة السابقة';

  @override
  String get attachment_next_page => 'الصفحة التالية';

  @override
  String get attachment_loading => 'جارٍ تحميل المعاينة…';

  @override
  String get attachment_document_text_notice =>
      'هذه معاينة نصية. قد يختلف تخطيط المستند وصوره وتنسيقه عن الأصل.';

  @override
  String get attachment_document_failed =>
      'تعذّرت معاينة هذا المستند. احفظ الملف الأصلي أو شاركه.';

  @override
  String get attachment_document_empty =>
      'لم يُعثر على نص قابل للقراءة في هذا المستند.';

  @override
  String get attachment_video_failed =>
      'تعذّر تشغيل هذا الفيديو. قد لا يكون تنسيقه أو برنامج الترميز المستخدم مدعومًا. احفظ الملف الأصلي أو شاركه.';

  @override
  String get attachment_video_play => 'تشغيل';

  @override
  String get attachment_video_pause => 'إيقاف مؤقت';

  @override
  String get attachment_video_mute => 'كتم الصوت';

  @override
  String get attachment_video_unmute => 'إلغاء كتم الصوت';

  @override
  String get attachment_video_seek => 'موضع التشغيل في الفيديو';

  @override
  String get attachment_close => 'إغلاق المعاينة';

  @override
  String get attachment_retry => 'إعادة المحاولة';

  @override
  String get saved_history_heading => 'السجل المحفوظ';

  @override
  String get received_output_heading =>
      'المخرجات المستلَمة — لم تتأكد مطابقتها للسجل المحفوظ';

  @override
  String get received_output_details => 'حول المخرجات المستلَمة';

  @override
  String get received_output_explanation =>
      'قد تظهر هذه المخرجات أيضًا في السجل المحفوظ. لا يستطيع التطبيق تأكيد تطابقها معه.';

  @override
  String get local_prompt_context => 'السياق المحلي للطلب';

  @override
  String get received_output_badge => 'مستلَم · لم يتأكد التطابق';

  @override
  String get received_output_lifetime =>
      'تُحفظ المخرجات المستلَمة مؤقتًا خلال جلسة التطبيق هذه، وقد تُختصر أو تُزال عند بلوغ حدود التخزين. وقد لا تبقى متاحة بعد إغلاق التطبيق أو قطع الاتصال.';

  @override
  String get theme_palette => 'نَسق الألوان';

  @override
  String get theme_palette_gold => 'ذهبي';

  @override
  String get theme_palette_purple => 'بنفسجي';

  @override
  String get theme_palette_orange => 'برتقالي';

  @override
  String get theme_palette_green => 'أخضر';

  @override
  String get theme_palette_blue => 'أزرق';

  @override
  String get theme_palette_red => 'أحمر';

  @override
  String get theme_palette_teal => 'أخضر مزرقّ';

  @override
  String get theme_palette_pink => 'وردي';

  @override
  String get theme_palette_indigo => 'نيلي';

  @override
  String get theme_palette_cyan => 'سماوي';

  @override
  String get assets_recent_subtitle =>
      'اعثر على الملفات التي شاركها Hermes في الدردشات المحفوظة';

  @override
  String get assets_scope_notice =>
      'تظهر هنا الملفات التي أُنشئت وشاركها Hermes صراحةً في الردود المحفوظة. هذه نظرة جزئية على سجل الدردشة وليست قائمة شاملة بالملفات أو المرفقات. قد لا تعود الملفات المشار إليها موجودة.';

  @override
  String get assets_download_limit =>
      'لا تُحمّل الملفات إلا عند الضغط عليها. الحد الأقصى لكل معاينة أو تنزيل هو 25 MiB. استخدم لوحة التحكم للملفات الأكبر.';

  @override
  String get assets_search_hint =>
      'ابحث في الملفات التي عُثر عليها أو في دردشاتها الأصلية';

  @override
  String get assets_all => 'الكل';

  @override
  String get assets_images => 'الصور';

  @override
  String get assets_audio => 'الصوتيات';

  @override
  String get assets_video => 'الفيديو';

  @override
  String get assets_documents => 'المستندات والملفات الأخرى';

  @override
  String get assets_empty => 'لم يُعثر على ملفات في الرسائل المفحوصة';

  @override
  String get assets_empty_detail =>
      'افحص مزيدًا من الدردشات أو رسائل أقدم لتوسيع نطاق البحث. لا تشمل الفهرسة هنا المرفقات العادية ولا الملفات التي لا توجد روابط لها.';

  @override
  String get assets_no_matches => 'لا توجد ملفات مطابقة';

  @override
  String get assets_load_more_chats => 'فحص مزيد من الدردشات';

  @override
  String get assets_load_older_messages => 'فحص رسائل أقدم';

  @override
  String get assets_load_failed =>
      'تعذّرت قراءة جزء من السجل، لذا فالنتائج غير مكتملة. تحقق من الاتصال بلوحة التحكم وأعد المحاولة.';

  @override
  String get assets_retry_failed =>
      'إعادة محاولة قراءة الأجزاء المتعذّرة من السجل';

  @override
  String get assets_partial =>
      'أفاد الخادم بأن السجل غير مكتمل. تحقق من لوحة التحكم ثم حدّث النتائج.';

  @override
  String assets_scan_summary(int files, int chats) {
    return 'عدد الإشارات إلى الملفات: $files، وعدد الدردشات المفحوصة: $chats';
  }

  @override
  String assets_open_chat(String title) {
    return 'فتح الدردشة: $title';
  }

  @override
  String get assets_file_too_large =>
      'يتجاوز هذا الملف حد التنزيل. افتح لوحة التحكم لتنزيله.';

  @override
  String get a_one_off_question_archives_itself_after_72_hours_anything =>
      'دردشة لسؤال واحد تُؤرشف تلقائيًا بعد 72 ساعة، ويظل ما يستحق الاحتفاظ به في الذاكرة.';

  @override
  String get archive_chat => 'أرشفة الدردشة';

  @override
  String get unarchive_chat => 'إلغاء أرشفة الدردشة';

  @override
  String get chat_archived => 'أُرشفت الدردشة';

  @override
  String get chat_unarchived => 'أُعيدت الدردشة من الأرشيف';

  @override
  String could_not_update_chat_archive(Object error) {
    return 'تعذّر تحديث حالة أرشفة الدردشة: $error';
  }

  @override
  String get quick_chat_description => 'دردشة لسؤال واحد.';

  @override
  String get ai_full_text => 'الذكاء الاصطناعي والبحث في النص الكامل';

  @override
  String get ai_search_model => 'نموذج البحث بالذكاء الاصطناعي';

  @override
  String ai_searched_for(Object aiRewrittenQuery) {
    return 'بحث الذكاء الاصطناعي عن: $aiRewrittenQuery';
  }

  @override
  String get ai_assisted_filing => 'التصنيف بمساعدة الذكاء الاصطناعي';

  @override
  String get api_key => 'مفتاح API';

  @override
  String get api_server_key_from_hermes_env =>
      'قيمة API_SERVER_KEY من الملف ~/.hermes/.env';

  @override
  String get active => 'نشط';

  @override
  String get activity => 'النشاط';

  @override
  String get activity_reads_the_durable_turn_journal_to_know_what_hermes =>
      'يعرض قسم النشاط ما يفعله Hermes استنادًا إلى سجل الجولات الدائم. تحقق من إمكانية الوصول إلى البوابة، ثم أعد المحاولة.';

  @override
  String get add => 'إضافة';

  @override
  String get add_connection => 'إضافة اتصال';

  @override
  String get add_cron_job => 'إضافة مهمة cron';

  @override
  String get add_gateway_connection => 'إضافة اتصال ببوابة';

  @override
  String get add_and_update_connections_from_the_backup_keep_the_rest =>
      'إضافة الاتصالات وتحديثها من النسخة الاحتياطية مع إبقاء بقية الاتصالات كما هي.';

  @override
  String get add_attachment => 'إضافة مرفق';

  @override
  String get add_new_cron_job => 'إضافة مهمة cron جديدة';

  @override
  String get add_to_chat => 'إضافة إلى الدردشة';

  @override
  String get all_chats => 'كل الدردشات';

  @override
  String get all_stored_message_content => 'جميع محتويات الرسائل المخزّنة';

  @override
  String get allow_for_this_session => 'السماح لهذه الجلسة';

  @override
  String get allow_matching_commands_until_this_hermes_session_ends =>
      'السماح بالأوامر المطابقة حتى انتهاء جلسة Hermes هذه.';

  @override
  String get allow_folder_until_sandbox_off =>
      'السماح بهذا المجلد حتى إيقاف بيئة العزل.';

  @override
  String get allow_once => 'السماح مرة واحدة';

  @override
  String get allow_website_until_sandbox_off =>
      'السماح بهذا الموقع حتى إيقاف بيئة العزل.';

  @override
  String get always_allow => 'السماح دائمًا';

  @override
  String get apply_to_this_chat => 'تطبيق على هذه الدردشة';

  @override
  String get approval_needed => 'الموافقة مطلوبة';

  @override
  String get approval_needed_description => 'هناك أمر ينتظر موافقتك أو رفضك.';

  @override
  String get approve => 'موافقة';

  @override
  String get archive => 'أرشفة';

  @override
  String get archive_project => 'أرشفة المشروع';

  @override
  String archive_2(Object projectName) {
    return 'هل تريد أرشفة $projectName؟';
  }

  @override
  String archive_3(Object name) {
    return 'هل تريد أرشفة $name؟';
  }

  @override
  String get archived => 'مؤرشف';

  @override
  String get archived_conversations_appear_here =>
      'تظهر هنا المحادثات المؤرشفة فقط. تبقى الدردشات القديمة ضمن «كل الدردشات».';

  @override
  String get archived_quick_chats => 'الدردشات السريعة المؤرشفة';

  @override
  String get artifacts_attachments_and_generated_media =>
      'الملفات الناتجة والمرفقات والوسائط المُولَّدة';

  @override
  String get ask_ai_to_find_a_conversation =>
      'اطلب من الذكاء الاصطناعي العثور على محادثة';

  @override
  String get assets => 'الملفات';

  @override
  String get assets_need_a_server_authoritative_assets_index_in_the_hermes =>
      'لعرض الملفات حسب المشروع، يجب أن توفر بوابة Hermes فهرسًا للملفات يديره الخادم ويُعتمد عليه مرجعًا.';

  @override
  String get assets_unavailable => 'الملفات غير متاحة';

  @override
  String get attach_image_or_file => 'إرفاق صورة أو ملف';

  @override
  String get attachment_drafts => 'مسودات المرفقات';

  @override
  String get recover_text_draft => 'استعادة مسودة نصية';

  @override
  String get undo_draft_recovery => 'تراجع';

  @override
  String get draft_session_exists =>
      'لا تزال هذه المحادثة موجودة. افتحها لمتابعة مسودتك.';

  @override
  String get draft_recovery_unavailable =>
      'تعذّر التحقق من هذه المسودة. لم يتغيّر أي شيء.';

  @override
  String attachment_of(Object index, Object total) {
    return 'المرفق $index من $total';
  }

  @override
  String get auto_device_default => 'تلقائي (إعداد الجهاز الافتراضي)';

  @override
  String get agent => 'الوكيل';

  @override
  String get autonomous_agents => 'الوكلاء المستقلون';

  @override
  String get background_recovery_unavailable_legacy_transport =>
      'الاستعادة في الخلفية غير متاحة بسبب استخدام آلية اتصال قديمة';

  @override
  String get background_task_completed => 'اكتملت المهمة في الخلفية';

  @override
  String get background_task_completed_description =>
      'اكتمل تنفيذ أمر في الطرفية كان يعمل في الخلفية.';

  @override
  String get backup_restore => 'النسخ الاحتياطي والاستعادة';

  @override
  String backup_exported(Object destination) {
    return 'صُدّرت النسخة الاحتياطية إلى $destination';
  }

  @override
  String get base_url => 'عنوان URL الأساسي';

  @override
  String get binary_preview_is_unavailable_download_the_file_to_open_it =>
      'لا تتوفر معاينة للملف الثنائي. نزّل الملف لفتحه.';

  @override
  String get branch => 'إنشاء فرع';

  @override
  String get branch_chat => 'إنشاء فرع من الدردشة';

  @override
  String get branch_created_in_hermes_history => 'أُنشئ فرع في سجل Hermes.';

  @override
  String get browse_and_manage_your_hermes_agent_sessions_from_your_phone =>
      'تصفّح جلسات Hermes Agent وأدرها من هاتفك. يتصل التطبيق بلوحة تحكم Hermes التي تعمل على شبكتك المحلية.';

  @override
  String get browse_server_files => 'تصفّح ملفات الخادم';

  @override
  String get browse_the_miniserver_folders_behind_your_projects =>
      'تصفّح مجلدات الخادم المصغّر التي تستند إليها مشاريعك';

  @override
  String get cancel => 'إلغاء';

  @override
  String get cancel_voice_input => 'إلغاء الإدخال الصوتي';

  @override
  String cannot_reach(Object host, Object port) {
    return 'تعذّر الوصول إلى $host:$port.';
  }

  @override
  String cannot_reach_check_the_host_and_port(Object host, Object port) {
    return 'تعذّر الوصول إلى $host:$port. تحقق من المضيف والمنفذ.';
  }

  @override
  String get change_ai_search_model => 'تغيير نموذج البحث بالذكاء الاصطناعي';

  @override
  String changes_the_default_for_use_the_selector_in_a_chat(Object label) {
    return 'يغيّر الإعداد الافتراضي لـ $label. لتغييره لمحادثة واحدة فقط، استخدم أداة الاختيار داخل تلك الدردشة.';
  }

  @override
  String get chat_actions => 'إجراءات الدردشة';

  @override
  String get chats => 'الدردشات';

  @override
  String get chats_from_this_gateway_are_not_grouped_yet_grouping_stays =>
      'لم تُجمع دردشات هذه البوابة في مشاريع بعد. يبقى تنظيمها محليًا على هذا الهاتف إلى أن تدعم البوابة استضافة المشاريع.';

  @override
  String get chats_in_this_project_will_show_their_state_and_last =>
      'تظهر هنا حالة كل دردشة في هذا المشروع وآخر نشاط فيها.';

  @override
  String get chats_that_are_not_assigned_to_a_project =>
      'الدردشات التي لا تنتمي إلى أي مشروع';

  @override
  String get chats_you_start_in_this_project_will_appear_here_on =>
      'ستظهر هنا الدردشات التي تبدأها في هذا المشروع، على كل جهاز سجّلت دخوله إلى خادم Hermes هذا.';

  @override
  String get check_that_the_gateway_is_running_and_reachable_then_try =>
      'تحقق من أن البوابة تعمل ويمكن الوصول إليها، ثم أعد المحاولة.';

  @override
  String get check_the_dashboard_connection_and_try_again =>
      'تحقق من الاتصال بلوحة التحكم وحاول مجددًا.';

  @override
  String get check_the_connection_and_try_again =>
      'تحقق من الاتصال وحاول مجددًا.';

  @override
  String get choose_a_small_model_to_rewrite_queries =>
      'اختر نموذجًا صغيرًا لإعادة صياغة استعلامات البحث';

  @override
  String get choose_an_ai_search_model_before_using_ai_search =>
      'اختر نموذجًا للبحث بالذكاء الاصطناعي قبل استخدامه.';

  @override
  String get choose_an_active_project_next =>
      'اختر مشروعًا نشطًا في الخطوة التالية';

  @override
  String get choose_chat_model => 'اختيار نموذج الدردشة';

  @override
  String get choose_files => 'اختيار ملفات';

  @override
  String get choose_image => 'اختيار صورة';

  @override
  String get choose_images => 'اختيار صور';

  @override
  String get choose_its_destination_space =>
      'اختر المساحة التي تريد نقله إليها';

  @override
  String get clear_search => 'مسح البحث';

  @override
  String get close => 'إغلاق';

  @override
  String get code_copied => 'نُسخت الشيفرة';

  @override
  String get code_format => 'شيفرة';

  @override
  String get coming_next => 'قريبًا';

  @override
  String get command => 'الأمر';

  @override
  String get command_palette => 'لوحة الأوامر';

  @override
  String get command_palette_hint => 'اكتب أمرًا';

  @override
  String get command_palette_no_results => 'لم يُعثر على أوامر';

  @override
  String get command_palette_new_chat => 'دردشة جديدة';

  @override
  String get command_palette_search_chats => 'البحث في الدردشات';

  @override
  String get command_palette_toggle_theme => 'تبديل المظهر';

  @override
  String get command_palette_copy_last_code => 'نسخ آخر كتلة شيفرة';

  @override
  String get command_line_chats => 'دردشات سطر الأوامر';

  @override
  String get compatibility_mode => 'وضع التوافق';

  @override
  String get configure_a_valid_desktop_gateway_url_before_attaching_files =>
      'أدخل عنوان URL صالحًا لبوابة سطح المكتب قبل إرفاق الملفات.';

  @override
  String get confirm_always_allow => 'تأكيد السماح الدائم';

  @override
  String get confirm_passphrase => 'تأكيد عبارة المرور';

  @override
  String connecting_to(Object baseUrl) {
    return 'جارٍ الاتصال بـ $baseUrl...';
  }

  @override
  String get connection_issue => 'مشكلة في الاتصال';

  @override
  String
  get connection_switched_the_running_reply_continues_on_the_server_and =>
      'تبدّل الاتصال. يستمر إنشاء الرد على الخادم، وسيتصل التطبيق به مجددًا بشكل تلقائي.';

  @override
  String get connection_appearance_and_device_preferences =>
      'الاتصال والمظهر وتفضيلات الجهاز';

  @override
  String context_tokens(Object effectiveContextLength) {
    return 'طول السياق بالرموز: $effectiveContextLength';
  }

  @override
  String get continue_label => 'متابعة';

  @override
  String get continue_working => 'متابعة العمل';

  @override
  String get conversations_in_this_project => 'المحادثات في هذا المشروع';

  @override
  String get copy_code => 'نسخ الشيفرة';

  @override
  String get copy_message => 'نسخ الرسالة';

  @override
  String could_not_branch_chat(Object error) {
    return 'تعذّر إنشاء فرع من الدردشة: $error';
  }

  @override
  String could_not_delete_session(Object error) {
    return 'تعذّر حذف الجلسة: $error';
  }

  @override
  String could_not_deny_the_command(Object error) {
    return 'تعذّر رفض الأمر: $error';
  }

  @override
  String could_not_load_ai_search_models(Object error) {
    return 'تعذّر تحميل نماذج البحث بالذكاء الاصطناعي: $error';
  }

  @override
  String get could_not_load_conversations => 'تعذّر تحميل المحادثات';

  @override
  String get could_not_load_files => 'تعذّر تحميل الملفات';

  @override
  String could_not_load_models_for_this_profile(Object error) {
    return 'تعذّر تحميل نماذج هذا الملف الشخصي: $error';
  }

  @override
  String could_not_load_more_chats(Object error) {
    return 'تعذّر تحميل مزيد من الدردشات: $error';
  }

  @override
  String get could_not_open_link => 'تعذّر فتح هذا الرابط.';

  @override
  String get could_not_open_the_hermes_dashboard =>
      'تعذّر فتح لوحة تحكم Hermes.';

  @override
  String get could_not_open_this_project => 'تعذّر فتح هذا المشروع';

  @override
  String get could_not_preview_file => 'تعذّرت معاينة الملف';

  @override
  String get could_not_reach_hermes => 'تعذّر الوصول إلى Hermes';

  @override
  String could_not_reach_authenticate_the_dashboard_at_check_the_port(
    Object dashboardPort,
    Object host,
  ) {
    return 'تعذّر الوصول إلى لوحة التحكم على $host:$dashboardPort أو إتمام المصادقة. تحقق من المنفذ وبيانات الاعتماد.';
  }

  @override
  String get could_not_read_activity => 'تعذّرت قراءة سجل النشاط';

  @override
  String could_not_rename_chat(Object error) {
    return 'تعذّر تغيير اسم الدردشة: $error';
  }

  @override
  String could_not_send_the_approval(Object error) {
    return 'تعذّر إرسال الموافقة: $error';
  }

  @override
  String get could_not_skip_the_hermes_question => 'تعذّر تخطي سؤال Hermes.';

  @override
  String could_not_the_project(Object action, Object error) {
    return 'تعذّر تنفيذ الإجراء «$action» على المشروع: $error';
  }

  @override
  String get couldn_t_delete_project => 'تعذّر حذف المشروع';

  @override
  String couldn_t_load_runs(Object error) {
    return 'تعذّر تحميل سجل التشغيل: $error';
  }

  @override
  String get couldn_t_move_conversation => 'تعذّر نقل المحادثة';

  @override
  String couldn_t_move_to(Object label, Object reason) {
    return 'تعذّر النقل إلى $label: $reason';
  }

  @override
  String get couldn_t_prepare_the_shared_files =>
      'تعذّر تجهيز الملفات المشتركة.';

  @override
  String get couldn_t_promote_conversation => 'تعذّرت إضافة المحادثة إلى مشروع';

  @override
  String couldn_t_project(Object action) {
    return 'تعذّر تنفيذ الإجراء «$action» على المشروع';
  }

  @override
  String get create => 'إنشاء';

  @override
  String get create_a_project => 'إنشاء مشروع';

  @override
  String get create_a_project_first_then_chats_can_live_inside_it =>
      'أنشئ مشروعًا أولًا لتتمكن من جمع الدردشات فيه.';

  @override
  String get create_a_space_to_separate_related_conversations =>
      'أنشئ مساحة تجمع المحادثات المرتبطة ببعضها بعيدًا عن غيرها.';

  @override
  String get create_branch => 'إنشاء فرع';

  @override
  String get credit_notifications => 'إشعارات الرصيد';

  @override
  String get credit_notifications_description =>
      'تنبيهات عند إيقاف استخدام الرصيد أو استئنافه.';

  @override
  String get cron => 'Cron';

  @override
  String get crons => 'الجدولة';

  @override
  String get cron_conversations_empty =>
      'تظهر هنا محادثات المهام المجدولة، بما فيها محادثات مرات التشغيل السابقة.';

  @override
  String get search_cron_conversations => 'البحث في محادثات مهام cron';

  @override
  String get cron_jobs => 'مهام cron';

  @override
  String cron_schedule_timezone(Object zone) {
    return 'المنطقة الزمنية للجدول: $zone';
  }

  @override
  String get crons_upcoming => 'القادمة';

  @override
  String get crons_history => 'السجل';

  @override
  String cron_time_with_zone(Object time, Object zone) {
    return '$time ($zone)';
  }

  @override
  String cron_time_zone_unknown(Object time) {
    return '$time (المنطقة الزمنية غير معروفة)';
  }

  @override
  String get cron_no_next_run => 'لا يوجد موعد تشغيل تالٍ';

  @override
  String get cron_status_scheduled => 'مجدولة';

  @override
  String get cron_status_paused => 'متوقفة مؤقتًا';

  @override
  String cron_delivers_to(Object target) {
    return 'وجهة التسليم: $target';
  }

  @override
  String get cron_upcoming_empty_title => 'لا توجد مهام مجدولة';

  @override
  String get cron_upcoming_empty_message =>
      'لا توجد مهام بانتظار التشغيل. أنشئ مهمة في «مهام cron» أو اطلب من الوكيل جدولة مهمة.';

  @override
  String get cron_upcoming_unavailable => 'المهام المجدولة غير متاحة';

  @override
  String get cron_upcoming_needs_dashboard =>
      'تتطلب المهام المجدولة اتصالًا بلوحة التحكم. لا يتيح هذا العنوان الاطلاع على جدول cron. تحقق من عنوان لوحة التحكم ومن دعم المضيف لهذه الميزة.';

  @override
  String get cron_upcoming_needs_dashboard_auth =>
      'تتطلب المهام المجدولة المصادقة لدى لوحة التحكم. أضف اسم المستخدم وكلمة المرور للوحة التحكم الخاصة بهذا الاتصال، أو فعّل وضع الاتصال عبر وكيل الشبكة.';

  @override
  String get cron_upcoming_dashboard_unreachable =>
      'تعذّر الوصول إلى لوحة التحكم. تحقق من المضيف ومنفذ لوحة التحكم والشبكة، ثم أعد المحاولة.';

  @override
  String get cron_upcoming_load_failed =>
      'تعذّرت قراءة المهام المجدولة. تحقق من الاتصال بلوحة التحكم، ثم أعد المحاولة.';

  @override
  String get cron_upcoming_refresh_failed =>
      'تعذّر تحديث الجدول. المعروض هو آخر جدول أمكن تحميله.';

  @override
  String get cron_job_added => 'أُضيفت مهمة cron';

  @override
  String get cron_job_updated => 'حُدّثت مهمة cron';

  @override
  String get cron_run => 'تشغيل مهمة cron';

  @override
  String get cross_device_ordering_and_reversible_bulk_organization =>
      'ترتيب موحّد عبر الأجهزة وتنظيم جماعي يمكن التراجع عنه';

  @override
  String get current_profile_default => 'الإعداد الافتراضي للملف الشخصي الحالي';

  @override
  String get custom_proxy_and_dashboard_details =>
      'تفاصيل وكيل الشبكة ولوحة التحكم المخصّصة';

  @override
  String get dark => 'داكن';

  @override
  String get dashboard_proxy_settings => 'إعدادات لوحة التحكم ووكيل الشبكة';

  @override
  String get dashboard_password_optional => 'كلمة مرور لوحة التحكم (اختيارية)';

  @override
  String get dashboard_port => 'منفذ لوحة التحكم';

  @override
  String get dashboard_username_optional => 'اسم مستخدم لوحة التحكم (اختياري)';

  @override
  String get dashboard_behind_proxy => 'لوحة التحكم خلف وكيل شبكة';

  @override
  String get dashboard_path_prefix => 'بادئة مسار لوحة التحكم';

  @override
  String delegated_task(Object goal) {
    return 'المهمة المفوّضة: $goal';
  }

  @override
  String get delete => 'حذف';

  @override
  String delete_2(Object name) {
    return 'هل تريد حذف «$name»؟';
  }

  @override
  String delete_from_the_remote_hermes_history_this_cannot_be_undone(
    Object title,
  ) {
    return 'هل تريد حذف «$title» من سجل Hermes البعيد؟ لا يمكن التراجع عن الحذف.';
  }

  @override
  String get delete_cron_job => 'حذف مهمة Cron';

  @override
  String get delete_connections_that_are_not_in_the_backup =>
      'احذف الاتصالات غير الموجودة في النسخة الاحتياطية.';

  @override
  String delete_failed(Object error) {
    return 'تعذّر الحذف: $error';
  }

  @override
  String get delete_project => 'حذف المشروع';

  @override
  String get delete_session => 'هل تريد حذف الجلسة؟';

  @override
  String delete_3(Object projectName) {
    return 'هل تريد حذف $projectName؟';
  }

  @override
  String deleted(Object name) {
    return 'حُذف «$name»';
  }

  @override
  String get delivery_is_uncertain_recovering_without_resending =>
      'لم يتأكد التسليم؛ تجري محاولة الاستعادة دون إعادة الإرسال…';

  @override
  String get desktop_gateway_url_optional =>
      'عنوان URL لبوابة Desktop Gateway (اختياري)';

  @override
  String get desktop_gateway_is_not_configured_for_this_connection =>
      'لم تُضبط بوابة سطح المكتب (Desktop Gateway) لهذا الاتصال.';

  @override
  String get desktop_app => 'تطبيق سطح المكتب';

  @override
  String get developer_tool_calls => 'استدعاءات الأدوات للمطوّرين';

  @override
  String get discord_chats => 'محادثات Discord';

  @override
  String get dismiss => 'إغلاق';

  @override
  String get do_not_run_this_command => 'لا تشغّل هذا الأمر.';

  @override
  String get documents_archives_audio_video_or_data =>
      'مستندات أو أرشيفات أو ملفات صوت أو فيديو أو بيانات';

  @override
  String get download => 'تنزيل';

  @override
  String download_failed(Object error) {
    return 'تعذّر التنزيل: $error';
  }

  @override
  String get durable_facts_hermes_keeps_about_you =>
      'معلومات يحتفظ بها Hermes عنك على المدى الطويل';

  @override
  String get durable_work_inside_one_of_your_projects_shared_with_desktop =>
      'عمل محفوظ ضمن أحد مشاريعك ومشترك مع تطبيق سطح المكتب.';

  @override
  String get edit => 'تعديل';

  @override
  String get edit_connection => 'تعديل الاتصال';

  @override
  String get edit_cron_job => 'تعديل مهمة Cron';

  @override
  String get edit_gateway_connection => 'تعديل الاتصال بالبوابة';

  @override
  String get edit_and_resend => 'تعديل وإعادة إرسال';

  @override
  String get enable_notifications => 'تفعيل الإشعارات';

  @override
  String get enable_notifications_description =>
      'يؤدي إيقاف هذا الخيار إلى تعطيل جميع الإشعارات أدناه.';

  @override
  String get enables_file_attachments_through_the_desktop_remote_gateway =>
      'يتيح إرفاق الملفات عبر بوابة سطح المكتب البعيدة.';

  @override
  String get enter_a_name => 'أدخل اسمًا';

  @override
  String get enter_a_passphrase => 'أدخل عبارة مرور.';

  @override
  String get enter_the_passphrase_for_this_backup =>
      'أدخل عبارة المرور لهذه النسخة الاحتياطية.';

  @override
  String get every_conversation_is_already_assigned_to_a_project =>
      'كل محادثة مرتبطة بمشروع بالفعل.';

  @override
  String get everything_not_yet_native_in_the_authenticated_web_dashboard =>
      'الميزات التي لم تُدمج بعد في التطبيق متاحة في لوحة تحكم الويب بعد تسجيل الدخول';

  @override
  String get explain_the_attached_content_clearly =>
      'اشرح المحتوى المرفق بوضوح.';

  @override
  String explain_this_content_clearly(Object text) {
    return 'اشرح هذا المحتوى بوضوح:\n\n$text';
  }

  @override
  String
  get explicit_choices_adjust_android_accessibility_text_size_system_leaves_it =>
      'يؤدي اختيار حجم محدد إلى تغيير حجم النص في إعدادات تسهيل الاستخدام على Android. أما خيار «النظام» فيُبقي الحجم كما هو.';

  @override
  String get export_label => 'تصدير';

  @override
  String get export_share => 'تصدير / مشاركة';

  @override
  String get external_api_clients => 'تطبيقات خارجية تستخدم واجهة API';

  @override
  String get extra_high => 'مرتفع جدًا';

  @override
  String get extract_tasks => 'استخراج المهام';

  @override
  String
  get extract_the_decisions_deadlines_owners_and_actionable_action_items_from =>
      'استخرج من المحتوى المرفق القرارات والمواعيد النهائية وأسماء المسؤولين والخطوات المطلوب تنفيذها.';

  @override
  String
  extract_the_decisions_deadlines_owners_and_actionable_action_items_from_2(
    Object text,
  ) {
    return 'استخرج من المحتوى التالي القرارات والمواعيد النهائية وأسماء المسؤولين والخطوات المطلوب تنفيذها:\n\n$text';
  }

  @override
  String failed_to_add_job(Object error) {
    return 'تعذّرت إضافة المهمة: $error';
  }

  @override
  String get failed_to_load_cron_jobs => 'تعذّر تحميل مهام cron';

  @override
  String get failed_to_load_memory => 'تعذّر تحميل الذاكرة';

  @override
  String get failed_to_load_messages => 'تعذّر تحميل الرسائل';

  @override
  String get failed_to_load_settings => 'تعذّر تحميل الإعدادات';

  @override
  String get failed_to_load_skills => 'تعذّر تحميل المهارات';

  @override
  String failed_to_update_job(Object error) {
    return 'تعذّر تحديث المهمة: $error';
  }

  @override
  String failed(Object error) {
    return 'فشلت العملية: $error';
  }

  @override
  String get file_attached_document_catalog_registration_is_pending =>
      'أُرفق الملف، ولم يُسجّل بعد في فهرس المستندات.';

  @override
  String get file_reference_added_to_chat => 'أُضيف مرجع الملف إلى المحادثة';

  @override
  String get files => 'الملفات';

  @override
  String get fill_from_document => 'تعبئة من مستند';

  @override
  String get folder_is_empty => 'المجلد فارغ';

  @override
  String get folders => 'المجلدات';

  @override
  String get full_text => 'النص الكامل';

  @override
  String get gateway_api_access => 'الوصول إلى واجهة API للبوابة';

  @override
  String get gateway_connected_but_the_dashboard_could_not_be_reached_or =>
      'تم الاتصال بالبوابة، لكن تعذّر الوصول إلى لوحة التحكم أو التحقق من الهوية. تحقّق من بيانات لوحة التحكم، أو امسحها لتخطّي هذه الخطوة.';

  @override
  String get gateway_path_prefix => 'بادئة مسار البوابة';

  @override
  String get go_to_end => 'الانتقال إلى النهاية';

  @override
  String get hermes_agent => 'Ares - المعروف سابقًا باسم Hermes Android';

  @override
  String get hermes_agent_for_android =>
      'Ares - المعروف سابقًا باسم Hermes Android';

  @override
  String get hermes_could_not_accept_the_answer_please_try_again =>
      'تعذّر على Hermes قبول الإجابة. حاول مجددًا.';

  @override
  String get hermes_could_not_load_your_saved_connections =>
      'تعذّر على Hermes تحميل اتصالاتك المحفوظة';

  @override
  String get hermes_did_not_accept_the_response_please_try_again =>
      'لم يقبل Hermes الرد. حاول مجددًا.';

  @override
  String get hermes_is_responding => 'يكتب Hermes ردًا…';

  @override
  String get hermes_is_waiting_for_input => 'ينتظر Hermes ردّك…';

  @override
  String get hermes_keeps_android_accessibility_text_scaling_active =>
      'يحافظ Ares على تفعيل تحجيم النص وفق إعدادات تسهيل الاستخدام في Android.';

  @override
  String get hermes_needs_your_input => 'يحتاج Hermes إلى ردّك';

  @override
  String get hermes_profile_optional => 'ملف Hermes الشخصي (اختياري)';

  @override
  String get hermes_profile_must_be_a_plain_profile_name_such_as =>
      'أدخل اسم ملف Hermes الشخصي فقط، مثل \"sol\"، وليس مسارًا.';

  @override
  String get hermes_reasoning_details => 'تفاصيل استدلال Hermes';

  @override
  String hermes_recovery_is_unavailable(Object error) {
    return 'استعادة Hermes غير متاحة: $error';
  }

  @override
  String get hermes_stopped_recovery_safely_no_prompt_was_resent =>
      'أوقف Hermes الاستعادة بأمان. لم يُعَد إرسال أي طلب.';

  @override
  String get hide_passphrase => 'إخفاء عبارة المرور';

  @override
  String get home_needs_your_recent_chats_to_know_what_deserves_your =>
      'تحتاج الصفحة الرئيسية إلى محادثاتك الأخيرة لتعرض ما يستحق انتباهك. تأكّد من إمكانية الوصول إلى البوابة، ثم حاول مجددًا.';

  @override
  String get host => 'المضيف';

  @override
  String get image_selection_was_interrupted_try_again =>
      'توقفت عملية اختيار الصورة قبل اكتمالها. حاول مجددًا.';

  @override
  String get import_label => 'استيراد';

  @override
  String get inbox => 'صندوق الوارد';

  @override
  String get inbox_is_clear => 'صندوق الوارد فارغ';

  @override
  String get input_needed => 'مطلوب ردّ منك';

  @override
  String get input_needed_description =>
      'طرح Hermes سؤالًا أو يحتاج إلى كلمة مرور أو معلومة سرية.';

  @override
  String get insert_a_remote_file_reference => 'إدراج مرجع @file لملف بعيد';

  @override
  String get invalid_port_number => 'رقم المنفذ غير صالح.';

  @override
  String get job_paused => 'أُوقفت المهمة مؤقتًا';

  @override
  String get job_resumed => 'استُؤنفت المهمة';

  @override
  String get job_triggered => 'طُلب تشغيل المهمة';

  @override
  String get label => 'التسمية';

  @override
  String last_activity(Object day, Object month, Object year) {
    return 'آخر نشاط: $day/$month/$year';
  }

  @override
  String last(Object lastRun) {
    return 'آخر تشغيل: $lastRun';
  }

  @override
  String get leave_blank_for_default_8642_443_with_https =>
      'اتركه فارغًا لاستخدام المنفذ الافتراضي (8642؛ أو 443 مع https)';

  @override
  String get leave_blank_for_default_9119 =>
      'اتركه فارغًا لاستخدام المنفذ الافتراضي (9119)';

  @override
  String get light => 'فاتح';

  @override
  String listening(Object elapsed) {
    return 'جارٍ الاستماع • $elapsed';
  }

  @override
  String listening_elapsed(Object elapsed) {
    return 'جارٍ الاستماع، الوقت المنقضي: $elapsed';
  }

  @override
  String get load_more => 'تحميل المزيد…';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get location => 'الموقع';

  @override
  String get make_sure_the_gateway_api_server_is_running_hermes_gateway =>
      'تأكّد من تشغيل خادم واجهة API للبوابة\n(hermes gateway status)';

  @override
  String matches(Object assigned, Object name) {
    return 'يطابق $name · $assigned';
  }

  @override
  String get memory => 'الذاكرة';

  @override
  String get memory_about_you => 'عنك';

  @override
  String get memory_agent_notes => 'ملاحظات الوكيل';

  @override
  String get memory_builtin_scope =>
      'معلومات محفوظة من ملفّي USER.md وMEMORY.md لهذا الملف الشخصي. لا يظهر هنا مزوّدو الذاكرة الخارجيون، بما فيهم MemPalace.';

  @override
  String get memory_read_only =>
      'للقراءة فقط. اطلب من Hermes في المحادثة تصحيح معلومة أو نسيانها.';

  @override
  String get memory_unavailable =>
      'لا توفّر هذه البوابة أو هذا الملف الشخصي معلومات الذاكرة المحفوظة. تحقّق من الملف الشخصي المحدد وحدّث Hermes عند الحاجة.';

  @override
  String get memory_load_error =>
      'تحقّق من الاتصال بلوحة التحكم ومن بيانات تسجيل الدخول، ثم حاول مجددًا.';

  @override
  String get memory_read_full_fact => 'قراءة المعلومة كاملة';

  @override
  String get memory_full_fact_requires_update =>
      'يتطلب عرض المعلومات كاملةً إصدارًا أحدث من بوابة Hermes. حدّث Hermes ثم أعد تحميل القائمة.';

  @override
  String get memory_fact_detail_error =>
      'تعذّر تحميل المعلومة كاملةً. ربما تغيّرت؛ حدّث القائمة ثم حاول مجددًا.';

  @override
  String get memory_entries_are_cross_session_facts_the_agent_remembers_they =>
      'ستظهر المعلومات المحفوظة هنا بعد أن يتذكّرها Hermes.';

  @override
  String get merge => 'دمج';

  @override
  String get message => 'رسالة';

  @override
  String get message_hermes => 'راسل Hermes…';

  @override
  String get message_actions => 'إجراءات الرسالة';

  @override
  String get message_copied => 'نُسخت الرسالة';

  @override
  String get migrating => 'جارٍ الترحيل…';

  @override
  String get migration_complete => 'اكتمل الترحيل';

  @override
  String get migration_failed_local_spaces_were_kept_unchanged =>
      'فشل الترحيل. بقيت المساحات المحلية دون تغيير.';

  @override
  String get migration_incomplete => 'لم يكتمل الترحيل';

  @override
  String get migration_preview => 'معاينة الترحيل';

  @override
  String get model => 'النموذج';

  @override
  String get model_and_thinking_for_this_chat =>
      'النموذج ومستوى التفكير لهذه المحادثة';

  @override
  String model_was_not_changed(Object error) {
    return 'لم يتغيّر النموذج: $error';
  }

  @override
  String get move_attachment_next => 'نقل المرفق إلى الموضع التالي';

  @override
  String get move_attachment_previous => 'نقل المرفق إلى الموضع السابق';

  @override
  String get move_chat => 'نقل المحادثة';

  @override
  String get move_conversation => 'نقل المحادثة';

  @override
  String get move_to_project => 'نقل إلى مشروع';

  @override
  String get move_to_space => 'نقل إلى مساحة';

  @override
  String get moved_to_a_project => 'نُقلت المحادثة إلى مشروع';

  @override
  String moved_to(Object label) {
    return 'نُقلت إلى $label';
  }

  @override
  String get name => 'الاسم';

  @override
  String get name_prompt_and_schedule_are_required =>
      'يجب إدخال الاسم والطلب والجدول الزمني';

  @override
  String get nav_activity => 'النشاط';

  @override
  String get nav_projects => 'المشاريع';

  @override
  String get needs_a_correction_aware_filing_contract_in_the_hermes_gateway =>
      'يتطلب ذلك آلية تصنيف تراعي التصحيحات في بوابة Hermes.';

  @override
  String get needs_a_reachable_hermes_dashboard_check_the_host_port_and =>
      'يجب أن تكون لوحة تحكم Hermes متاحة. تحقّق من المضيف والمنفذ وبيانات الاعتماد لهذا الاتصال.';

  @override
  String get needs_a_server_authoritative_assets_index_in_the_hermes_gateway =>
      'يتطلب ذلك فهرسًا للأصول في بوابة Hermes يكون الخادم مرجعه المعتمد.';

  @override
  String get needs_durable_pin_ordering_batch_mutation_and_undo_contracts_in =>
      'يتطلب ذلك دعم بوابة Hermes لحفظ ترتيب العناصر المثبّتة وإجراء تغييرات جماعية والتراجع عنها.';

  @override
  String get needs_you => 'يحتاج إلى تدخّلك';

  @override
  String get new_label => 'جديد';

  @override
  String get new_chat => 'محادثة جديدة';

  @override
  String get new_chat_2 => 'محادثة جديدة';

  @override
  String new_chat_3(Object projectName) {
    return 'محادثة جديدة · $projectName';
  }

  @override
  String get new_project => 'مشروع جديد';

  @override
  String get new_space => 'مساحة جديدة';

  @override
  String next(Object nextRun) {
    return 'التشغيل التالي: $nextRun';
  }

  @override
  String get nginx_injects_auth_app_sends_clean_requests =>
      'يضيف Nginx بيانات المصادقة؛ يرسل التطبيق الطلبات دونها';

  @override
  String get no_tts_voices_found_ninstall_google_text_to_speech_and =>
      'لم يُعثر على أصوات لتحويل النص إلى كلام (TTS).\nثبّت Google Text-to-Speech ونزّل بيانات الأصوات.';

  @override
  String get no_active_projects_on_this_gateway =>
      'لا توجد مشاريع نشطة على هذه البوابة';

  @override
  String get no_activity_yet => 'لا يوجد نشاط بعد';

  @override
  String get no_chat_is_blocked_running_or_waiting_to_be_resumed =>
      'لا توجد محادثة متوقفة أو جارية أو بانتظار الاستئناف. ابدأ محادثة جديدة متى شئت.';

  @override
  String no_chats_in_this_project_match(Object searchQuery) {
    return 'لا توجد محادثات في هذا المشروع تطابق «$searchQuery».';
  }

  @override
  String get no_chats_in_this_space_yet_tap_to_start_one =>
      'لا توجد محادثات في هذه المساحة بعد. اضغط على + لبدء محادثة.';

  @override
  String get no_chats_yet => 'لا توجد محادثات بعد';

  @override
  String get no_connections => 'لا توجد اتصالات';

  @override
  String get no_conversation_matches_this_view =>
      'لا توجد محادثة تطابق معايير العرض الحالية.';

  @override
  String get no_cron_jobs => 'لا توجد مهام cron';

  @override
  String get no_folders_yet => 'لا توجد مجلدات بعد';

  @override
  String get no_local_spaces_were_found_for_this_connection_so_projects =>
      'لم يُعثر على مساحات محلية لهذا الاتصال، لذا فالمشاريع هي بالفعل الوسيلة الوحيدة للتنظيم هنا.';

  @override
  String get no_matches => 'لا توجد نتائج مطابقة';

  @override
  String get no_memory_entries => 'لا توجد معلومات محفوظة في الذاكرة';

  @override
  String get no_message_content_matches =>
      'لا توجد نتائج مطابقة في نصوص الرسائل';

  @override
  String get no_new_messages => 'لا توجد رسائل جديدة';

  @override
  String get no_projects_yet => 'لا توجد مشاريع بعد';

  @override
  String get no_runs_yet => 'لم تُشغّل المهمة بعد.';

  @override
  String no_server_project_matches_this_name(Object assigned) {
    return 'لا يوجد مشروع على الخادم يطابق هذا الاسم · $assigned';
  }

  @override
  String get no_sessions_yet => 'لا توجد جلسات بعد';

  @override
  String get no_skills_found => 'لم يُعثر على مهارات';

  @override
  String get no_spaces_on_this_device => 'لا توجد مساحات على هذا الجهاز';

  @override
  String get no_text_shared => 'لم يُشارَك أي نص';

  @override
  String get no_turn_is_blocked_in_flight_or_recently_finished_work =>
      'لا يوجد طلب متعثر أو قيد التنفيذ أو اكتمل مؤخرًا. سيظهر هنا أي عمل تبدأه.';

  @override
  String get no_turn_needs_your_input_or_has_failed =>
      'لا توجد طلبات فشلت أو تنتظر ردّك.';

  @override
  String get no_unassigned_chats => 'لا توجد محادثات بلا مشروع.';

  @override
  String get nothing_changed_in_the_last_seven_days =>
      'لم يتغيّر شيء خلال الأيام السبعة الماضية.';

  @override
  String get nothing_has_moved_yet_this_is_only_what_a_migration =>
      'لم يُنقل أي شيء بعد. هذه مجرد معاينة لما سيحدث عند الترحيل.';

  @override
  String get nothing_here => 'لا يوجد شيء هنا';

  @override
  String get nothing_is_running => 'لا شيء قيد التشغيل';

  @override
  String get nothing_needs_you => 'لا شيء يتطلّب تدخّلك';

  @override
  String get nothing_to_migrate => 'لا يوجد ما يمكن ترحيله';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get windows_notifications_blocked =>
      'الإشعارات غير متاحة. استخدم تطبيق Ares المثبّت وتحقق من الإعدادات ← النظام ← الإشعارات في Windows.';

  @override
  String get windows_notification_diagnostics => 'ما أرسله Ares إلى Windows';

  @override
  String get chat_activity_share => 'مشاركة نشاط المحادثة';

  @override
  String get chat_activity_share_hint =>
      'أبلِغ البوابة المتصلة المتوافقة عندما تستخدم هذه المحادثة، حتى يتجنّب ملحق إشعارات الهاتف فيها التنبيهات المكررة. لا تُرسَل أي مفاتيح أو نصوص رسائل.';

  @override
  String get completion_sound => 'صوت الاكتمال';

  @override
  String get completion_sound_system => 'الافتراضي للنظام';

  @override
  String get completion_sound_mail => 'البريد';

  @override
  String get completion_sound_reminder => 'تذكير';

  @override
  String get completion_sound_silent => 'صامت';

  @override
  String get completion_sound_scope =>
      'يُشغَّل للردود المكتملة والإشعار التجريبي وداخل التطبيق. تحتفظ الموافقات والتنبيهات الأخرى بصوتها المعتاد.';

  @override
  String get completion_sound_scope_android =>
      'يُشغَّل للردود المكتملة والإشعار التجريبي وداخل التطبيق. تحتفظ الموافقات والتنبيهات الأخرى وإشعارات الخلفية من الخادم ورسائل Android Auto بصوتها المعتاد.';

  @override
  String get notification_open_action => 'فتح';

  @override
  String get app_sounds_mute => 'كتم أصوات التطبيق';

  @override
  String get app_sounds_mute_hint =>
      'يوقف صوت الاكتمال الذي يشغّله Ares أثناء فتحه. تحتفظ الإشعارات بصوتها الخاص.';

  @override
  String get notifications_permission_denied =>
      'يحظر نظام التشغيل الإشعارات. فعّل إشعارات هذا التطبيق في إعدادات Android.';

  @override
  String get off_no_thinking => 'متوقف (دون تفكير)';

  @override
  String get offline_showing_the_last_known_activity =>
      'غير متصل — يُعرض آخر نشاط معروف.';

  @override
  String get offline_showing_the_last_known_chats =>
      'غير متصل — تُعرض آخر المحادثات المعروفة';

  @override
  String get offline_showing_the_last_known_projects =>
      'غير متصل — تُعرض آخر المشاريع المعروفة.';

  @override
  String get on_this_device => 'على هذا الجهاز';

  @override
  String get on_device => 'على الجهاز';

  @override
  String get open_inbox => 'فتح صندوق الوارد';

  @override
  String open_inbox_2(Object count) {
    return 'فتح صندوق الوارد ($count)';
  }

  @override
  String get open_the_hermes_dashboard => 'فتح لوحة تحكم Hermes';

  @override
  String get optional_for_the_memory_cron_skills_settings_tabs_leave_blank =>
      'اختياري. يُستخدم لتبويبات الذاكرة وCron والمهارات والإعدادات. اتركه فارغًا لاستخدام منفذ لوحة التحكم الافتراضي (9119) دون تسجيل الدخول.';

  @override
  String get organization => 'التنظيم';

  @override
  String get other_answer => 'إجابة أخرى';

  @override
  String get overview => 'نظرة عامة';

  @override
  String get passphrase => 'عبارة المرور';

  @override
  String get password_optional => 'كلمة المرور (اختياري)';

  @override
  String get phone_or_tablet => 'هاتف أو جهاز لوحي';

  @override
  String get pin_batch_and_undo => 'التثبيت والإجراءات الجماعية والتراجع';

  @override
  String get plugin_notifications => 'إشعارات الإضافات';

  @override
  String get plugin_notifications_description =>
      'أرسلت البوابة إشعارًا أثناء عمل التطبيق في الخلفية.';

  @override
  String get port => 'المنفذ';

  @override
  String get preparing_attachments => 'جارٍ تحضير المرفقات…';

  @override
  String get preview_truncated => 'المعاينة مختصرة';

  @override
  String get preview_unavailable => 'المعاينة غير متاحة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get profile_default_model => 'النموذج الافتراضي للملف الشخصي';

  @override
  String profile_default_set_to_chats_with_their_own_model_keep(
    Object selectedModel,
  ) {
    return 'أصبح $selectedModel النموذج الافتراضي للملف الشخصي. تحتفظ المحادثات التي اخترت لها نموذجًا محددًا بنموذجها.';
  }

  @override
  String
  get profile_this_connection_chats_as_when_the_dashboard_serves_several =>
      'الملف الشخصي المستخدم للمحادثات عبر هذا الاتصال عندما تدعم لوحة التحكم عدة ملفات شخصية. اتركه فارغًا إذا كانت لكل ملف شخصي لوحة تحكم مستقلة.';

  @override
  String get project => 'مشروع';

  @override
  String get project_actions => 'إجراءات المشروع';

  @override
  String get project_chat => 'محادثة المشروع';

  @override
  String get project_chats_unavailable => 'محادثات المشروع غير متاحة';

  @override
  String get projects => 'المشاريع';

  @override
  String get projects_group_related_chats_files_and_activity_and_stay_in =>
      'تجمع المشاريع المحادثات والملفات والأنشطة ذات الصلة، وتظل متزامنة مع Hermes على حاسوبك.';

  @override
  String
  get projects_need_a_desktop_gateway_connection_add_the_desktop_gateway =>
      'تتطلب المشاريع اتصالًا ببوابة سطح المكتب (Desktop Gateway). أضف عنوان URL الخاص ببوابة Desktop Gateway إلى إعدادات هذا الاتصال لتنظيم محادثاتك عبر أجهزتك.';

  @override
  String get projects_unavailable => 'المشاريع غير متاحة';

  @override
  String get projects_activity_new_navigation =>
      'المشاريع والنشاط — طريقة جديدة للتنقّل';

  @override
  String get promote_to_project => 'تحويل إلى مشروع';

  @override
  String get prompt => 'الطلب';

  @override
  String get protect_this_backup => 'حماية هذه النسخة الاحتياطية';

  @override
  String get provider => 'المزوّد';

  @override
  String get proxy_injects_auth_app_sends_clean_requests =>
      'يضيف الوكيل الوسيط بيانات المصادقة؛ يرسل التطبيق الطلبات دونها';

  @override
  String get quick_chat => 'محادثة سريعة';

  @override
  String get quick_chats_appear_here_after_their_retention_period =>
      'تظهر المحادثات السريعة هنا بعد انتهاء مدة الاحتفاظ بها.';

  @override
  String get read_aloud => 'قراءة بصوت عالٍ';

  @override
  String get read_aloud_is_unavailable_on_this_device =>
      'القراءة بصوت عالٍ غير متاحة على هذا الجهاز';

  @override
  String get reading_response_aloud => 'جارٍ قراءة الرد بصوت عالٍ';

  @override
  String get ready_to_upload => 'جاهز للرفع';

  @override
  String get reasoning => 'الاستدلال';

  @override
  String get recently_completed => 'اكتمل مؤخرًا';

  @override
  String get recently_active => 'نشط مؤخرًا';

  @override
  String get recovering_hermes => 'جارٍ استعادة Hermes…';

  @override
  String get refresh => 'تحديث';

  @override
  String get regenerate_response => 'توليد الرد مجددًا';

  @override
  String get remove_attachment => 'إزالة المرفق';

  @override
  String get rename => 'إعادة تسمية';

  @override
  String get rename_chat => 'إعادة تسمية المحادثة';

  @override
  String get rename_project => 'إعادة تسمية المشروع';

  @override
  String get rename_space => 'إعادة تسمية المساحة';

  @override
  String rename_2(Object projectName) {
    return 'إعادة تسمية $projectName';
  }

  @override
  String rename_3(Object name) {
    return 'إعادة تسمية $name';
  }

  @override
  String get replace => 'استبدال';

  @override
  String get repositories => 'المستودعات';

  @override
  String
  get research_the_attached_content_verify_the_important_claims_and_cite =>
      'ابحث في موضوع المحتوى المرفق، وتحقّق من الادعاءات المهمة، واذكر المصادر.';

  @override
  String research_this_content_verify_the_important_claims_and_cite_sources(
    Object text,
  ) {
    return 'ابحث في موضوع المحتوى التالي، وتحقّق من الادعاءات المهمة، واذكر المصادر:\n\n$text';
  }

  @override
  String reset_failed_the_secure_storage_may_need_reinstall(Object retryError) {
    return 'تعذّرت إعادة الضبط: $retryError. قد يلزم إعادة تثبيت مكوّن التخزين الآمن.';
  }

  @override
  String get reset_saved_connections => 'إعادة ضبط الاتصالات المحفوظة';

  @override
  String get responding => 'جارٍ الرد…';

  @override
  String response_closed_locally_gateway_stop_failed(Object error) {
    return 'أُغلق الرد محليًا، لكن تعذّر إيقافه على البوابة: $error';
  }

  @override
  String get response_closed_locally_no_active_gateway_turn_was_found =>
      'أُغلق الرد محليًا؛ لم يُعثر على طلب نشط في البوابة.';

  @override
  String get response_complete => 'اكتمل الرد';

  @override
  String get response_complete_description =>
      'اكتمل الرد على طلب أثناء عمل التطبيق في الخلفية.';

  @override
  String get response_ready => 'الرد جاهز';

  @override
  String get response_stopped => 'أُوقف الرد.';

  @override
  String get restore => 'استعادة';

  @override
  String get restore_configuration => 'استعادة التكوين';

  @override
  String get restore_project => 'استعادة المشروع';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String retry_failed_for_the_draft_and_prompt_were_kept(Object name) {
    return 'تعذّرت إعادة المحاولة لـ $name. احتُفظ بالمسودة والطلب.';
  }

  @override
  String get retry_upload => 'إعادة محاولة الرفع';

  @override
  String retrying(Object name) {
    return 'جارٍ إعادة المحاولة لـ $name…';
  }

  @override
  String get review_local_spaces => 'مراجعة المساحات المحلية';

  @override
  String get review_or_promote_quick_chats_past_their_retention_period =>
      'راجع المحادثات السريعة التي انتهت مدة الاحتفاظ بها أو حوّلها إلى محادثات مشروع';

  @override
  String get review_the_attached_content => 'راجع المحتوى المرفق.';

  @override
  String get run_only_this_command => 'شغّل هذا الأمر فقط.';

  @override
  String get running_now => 'قيد التشغيل الآن';

  @override
  String get save => 'حفظ';

  @override
  String get save_changes => 'حفظ التغييرات';

  @override
  String get save_a_permanent_rule_in_the_hermes_configuration =>
      'احفظ قاعدة دائمة في إعدادات Hermes.';

  @override
  String get save_the_durable_facts_from_the_attached_content_to_memory =>
      'احفظ في الذاكرة المعلومات المفيدة على المدى الطويل من المحتوى المرفق، ثم أكّد ما احتفظت به.';

  @override
  String save_the_durable_facts_from_this_content_to_memory_then(Object text) {
    return 'احفظ في الذاكرة المعلومات المفيدة على المدى الطويل من المحتوى التالي، ثم أكّد ما احتفظت به:\n\n$text';
  }

  @override
  String get save_your_connections_and_settings_to_an_encrypted_file_then =>
      'احفظ اتصالاتك وإعداداتك في ملف مشفّر لتستعيدها بعد إعادة التثبيت أو على جهاز آخر.';

  @override
  String save_2(Object filename) {
    return 'حفظ $filename';
  }

  @override
  String get schedule => 'الجدول الزمني';

  @override
  String get scheduled_jobs_and_their_last_runs =>
      'المهام المجدولة وآخر تشغيل لكل منها';

  @override
  String get scheduled_tasks => 'المهام المجدولة';

  @override
  String get script_only_no_agent => 'برنامج نصي فقط (دون وكيل)';

  @override
  String get scroll_horizontally => 'تمرير أفقي';

  @override
  String get search_all_chats => 'البحث في جميع المحادثات';

  @override
  String get search_all_message_content => 'البحث في محتوى جميع الرسائل';

  @override
  String get search_chats => 'البحث في المحادثات';

  @override
  String get search_conversations => 'البحث في المحادثات';

  @override
  String get search_loaded_chats => 'البحث في المحادثات المحمّلة';

  @override
  String get search_mode => 'وضع البحث';

  @override
  String get select_one_option_or_enter_another_answer =>
      'اختر أحد الخيارات، أو أدخل إجابة أخرى.';

  @override
  String get select_one_or_more_options_then_continue =>
      'اختر خيارًا واحدًا أو أكثر، ثم تابع.';

  @override
  String get select_text => 'تحديد النص';

  @override
  String get send => 'إرسال';

  @override
  String send_failed(Object error) {
    return 'تعذّر الإرسال: $error';
  }

  @override
  String send_failed_api_only_permission_denied(Object error) {
    return 'تعذّر الإرسال: $error. رفض الخادم عملية الكتابة هذه للهوية المرتبطة بمفتاح API. إذا كانت المحادثة مملوكة للوحة التحكم، فقد تتيح إضافة اسم المستخدم وكلمة المرور الخاصّين بلوحة التحكم إلى هذا الاتصال إرسال الرسائل. وقد يكون الخادم يرفض الإرسال عن قصد.';
  }

  @override
  String get send_message => 'إرسال رسالة';

  @override
  String get send_test_notification => 'إرسال إشعار تجريبي';

  @override
  String get session_sources => 'مصادر الجلسات';

  @override
  String get session_deleted_from_remote_hermes =>
      'حُذفت الجلسة من Hermes البعيد.';

  @override
  String session_search_failed(Object error) {
    return 'تعذّر البحث في الجلسات: $error';
  }

  @override
  String get set_profile_default => 'تعيين كخيار افتراضي للملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get share_to_hermes => 'مشاركة مع Hermes';

  @override
  String get show_passphrase => 'إظهار عبارة المرور';

  @override
  String get show_tool_calls_thinking_and_message_metadata =>
      'اعرض الأدوات والاستدلال والمهام وتفاصيل الرسائل في أقسام مطوية. عند تعطيل هذا الخيار، لا تظهر سوى المحادثة.';

  @override
  String get signal_messages => 'رسائل Signal';

  @override
  String get skills => 'المهارات';

  @override
  String skills_2(Object count) {
    return 'المهارات ($count)';
  }

  @override
  String get skills_and_tools => 'المهارات والأدوات';

  @override
  String get skip => 'تخطّي';

  @override
  String get slack_chats => 'محادثات Slack';

  @override
  String source(Object source) {
    return 'المصدر: $source';
  }

  @override
  String get space_actions => 'إجراءات المساحة';

  @override
  String get spaces => 'المساحات';

  @override
  String get speak_to_hermes => 'تحدّث إلى Hermes';

  @override
  String get speech_recognition_is_unavailable => 'التعرّف على الكلام غير متاح';

  @override
  String get spoken_replies => 'الردود الصوتية';

  @override
  String get spoken_replies_off => 'الردود الصوتية معطّلة';

  @override
  String get spoken_replies_on => 'الردود الصوتية مفعّلة';

  @override
  String get stalled_no_update_from_hermes =>
      'توقّف التقدّم — لا تحديث من Hermes';

  @override
  String get start_something_new => 'ابدأ شيئًا جديدًا';

  @override
  String get start_voice_input => 'بدء الإدخال الصوتي';

  @override
  String get starting_hermes => 'جارٍ بدء تشغيل Hermes…';

  @override
  String get media_card_download => 'تنزيل الملف';

  @override
  String get media_card_tap_to_download => 'اضغط للتنزيل';

  @override
  String get still_loading_your_projects => 'لا يزال تحميل مشاريعك جاريًا.';

  @override
  String get stop => 'إيقاف';

  @override
  String get stop_response => 'إيقاف الرد';

  @override
  String get stop_voice_input => 'إيقاف الإدخال الصوتي';

  @override
  String get submitted_waiting_for_hermes => 'أُرسل الطلب، بانتظار Hermes';

  @override
  String get suggest_projects_and_learn_from_your_corrections =>
      'اقتراح مشاريع والتعلّم من تصحيحاتك';

  @override
  String get summarize_the_attached_content => 'لخّص المحتوى المرفق.';

  @override
  String summarize_this_content(Object text) {
    return 'لخّص هذا المحتوى:\n\n$text';
  }

  @override
  String get switch_profile => 'تبديل الملف الشخصي';

  @override
  String get system => 'النظام';

  @override
  String get take_photo => 'التقاط صورة';

  @override
  String get tap_to_add_a_remote_hermes_gateway_api_server_port =>
      'اضغط على + لإضافة بوابة Hermes بعيدة\n(API Server، المنفذ 8642)';

  @override
  String get tap_the_button_to_start_a_new_chat =>
      'اضغط على زر + لبدء محادثة جديدة';

  @override
  String get telegram_messages => 'رسائل Telegram';

  @override
  String get terminal_sessions => 'جلسات الطرفية';

  @override
  String get test_notification_body =>
      'إذا ظهر لك هذا الإشعار، فإشعارات النظام تعمل.';

  @override
  String get test_notification_sent => 'أُرسل إشعار الاختبار.';

  @override
  String get test_notification_title => 'اختبار إشعارات Hermes';

  @override
  String get test_notification_unsupported =>
      'تعذّر إرسال الإشعار. تأكد من أن نظام التشغيل (OS) يسمح بالإشعارات.';

  @override
  String get text_size => 'حجم النص';

  @override
  String get text_size_preview => 'معاينة حجم النص';

  @override
  String text_size_2(Object label) {
    return 'حجم النص: $label';
  }

  @override
  String get the_api_key_could_not_be_stored_securely =>
      'تعذّر تخزين مفتاح API بأمان.';

  @override
  String get the_project_will_move_to_archived_its_chats_and_files =>
      'سينتقل المشروع إلى الأرشيف. ستبقى محادثاته وملفاته كما هي، ويمكنك استعادته في أي وقت.';

  @override
  String get the_project_will_move_to_archived_its_chats_and_files_2 =>
      'سينتقل المشروع إلى الأرشيف. ستبقى محادثاته وملفاته كما هي، ويمكنك استعادته لاحقًا.';

  @override
  String get the_active_profile_did_not_return_any_selectable_models =>
      'لم يعرض ملف التعريف النشط أي نماذج يمكن اختيارها.';

  @override
  String get the_backup_could_not_be_exported =>
      'تعذّر تصدير النسخة الاحتياطية.';

  @override
  String get the_backup_could_not_be_restored =>
      'تعذّرت استعادة النسخة الاحتياطية.';

  @override
  String get the_connection_could_not_be_deleted_safely =>
      'تعذّر حذف الاتصال بأمان.';

  @override
  String get the_connection_could_not_be_stored_securely =>
      'تعذّر تخزين الاتصال بأمان.';

  @override
  String get the_dashboard_credentials_could_not_be_stored_securely =>
      'تعذّر تخزين بيانات اعتماد لوحة التحكم بأمان.';

  @override
  String get the_detached_reply_failed => 'فشل الرد الذي كان يعمل في الخلفية.';

  @override
  String the_detached_reply_failed_2(Object error) {
    return 'فشل الرد الذي كان يعمل في الخلفية: $error';
  }

  @override
  String get the_file_contains_your_api_keys_and_dashboard_password_so =>
      'الملف مشفّر لأنه يحتوي على مفاتيح API وكلمة مرور لوحة التحكم. لا يمكن استعادة النسخة الاحتياطية من دون عبارة المرور هذه.';

  @override
  String get the_last_turn_failed => 'فشلت الجولة الأخيرة';

  @override
  String the_local_connection_store_looks_damaged_you_can_reset_the(
    Object errorType,
  ) {
    return 'يبدو أن مخزن الاتصالات المحلي تالف ($errorType). يمكنك إعادة ضبط الاتصالات المحفوظة والبدء من جديد. لن تتأثر المحادثات الموجودة على البوابة.';
  }

  @override
  String get the_model_only_rewrites_your_question_into_a_short_full =>
      'يقتصر دور النموذج على إعادة صياغة سؤالك في عبارة قصيرة للبحث في النص الكامل. يستخدم Hermes بيانات اعتماد المزوّد التي سبق إعدادها على المضيف.';

  @override
  String get the_server_has_not_reported_folders_for_this_project_yet =>
      'لم يُبلغ الخادم عن أي مجلدات لهذا المشروع بعد. ما زال بإمكانك فتح «الملفات العامة» من «المزيد».';

  @override
  String get the_turn_failed => 'فشلت الجولة';

  @override
  String get the_two_passphrases_do_not_match => 'عبارتا المرور غير متطابقتين.';

  @override
  String get the_value_is_sent_directly_to_the_active_hermes_gateway =>
      'تُرسل القيمة مباشرة إلى بوابة Hermes النشطة ولا يحفظها تطبيق Android هذا.';

  @override
  String get there_are_no_visible_files_in_this_server_folder =>
      'لا توجد ملفات ظاهرة في هذا المجلد على الخادم.';

  @override
  String get thinking_effort => 'مستوى جهد التفكير';

  @override
  String get this_hermes_gateway_does_not_support_opening_a_project_yet =>
      'لا تدعم بوابة Hermes هذه فتح المشاريع بعد. حدّث Hermes على الخادم لتتمكن من تصفّح مشروع من هاتفك.';

  @override
  String get this_hermes_gateway_is_older_than_server_side_projects_so =>
      'إصدار بوابة Hermes هذه أقدم من ميزة المشاريع على الخادم، لذا يقتصر تجميع المحادثات على هذا الجهاز. حدّث Hermes لاستخدام المشاريع نفسها على جميع أجهزتك.';

  @override
  String get this_project_has_no_folder_to_open_the_chat_in =>
      'يحتاج هذا المشروع إلى مجلد قبل أن تتمكن من بدء محادثة فيه. أضف مجلدًا ثم حاول مجددًا.';

  @override
  String get this_chat_has_no_messages_available_in_the_desktop_session =>
      'لا تتوفر أي رسائل لهذه المحادثة في جلسة سطح المكتب بعد.';

  @override
  String get this_creates_a_permanent_rule_in_hermes_review_the_full =>
      'سيؤدي هذا إلى إنشاء قاعدة دائمة في Hermes. راجع الأمر كاملًا قبل التأكيد.';

  @override
  String get this_gateway_does_not_host_projects_yet_update_the_gateway =>
      'لا تستضيف هذه البوابة مشاريع بعد. حدّث البوابة لتنظيم المحادثات عبر أجهزتك.';

  @override
  String get this_permanently_deletes_the_project_chats_will_not_be_deleted =>
      'سيُحذف المشروع نهائيًا. لن تُحذف محادثاته، بل ستعود إلى قسم «غير معيّنة».';

  @override
  String get this_server_doesn_t_offer_background_recovery_chats_run_live =>
      'لا يدعم هذا الخادم استئناف المحادثات في الخلفية، لذا تجري المحادثات مباشرة فقط';

  @override
  String get this_week => 'هذا الأسبوع';

  @override
  String get titles_previews_and_models => 'العناوين والمعاينات والنماذج';

  @override
  String get tool_activity => 'نشاط الأدوات';

  @override
  String get trigger_now => 'تشغيل الآن';

  @override
  String get received_outcome_unknown => 'انتهت الجولة ولم تتأكد نتيجتها';

  @override
  String get turn_completed => 'اكتملت الجولة';

  @override
  String get turn_failed => 'فشلت الجولة';

  @override
  String get turn_failed_description => 'انتهت جولة في الخلفية بخطأ.';

  @override
  String get turn_recovery_failed => 'تعذّر استئناف الجولة';

  @override
  String get unable_to_prepare_this_file_try_another_one =>
      'تعذّر تجهيز هذا الملف. جرّب ملفًا آخر.';

  @override
  String get unable_to_prepare_this_image_try_another_one =>
      'تعذّر تجهيز هذه الصورة. جرّب صورة أخرى.';

  @override
  String unable_to_prepare(Object name) {
    return 'تعذّر تجهيز $name.';
  }

  @override
  String get unable_to_read_the_selected_image_the_selection_was_kept =>
      'تعذّرت قراءة الصورة المحددة. لم يتغيّر اختيارك.';

  @override
  String get unassigned => 'غير معيّنة';

  @override
  String get unassigned_chats => 'محادثات غير معيّنة';

  @override
  String get untitled_chat => 'محادثة بلا عنوان';

  @override
  String get untitled_session => 'جلسة بلا عنوان';

  @override
  String get update_api_key => 'تحديث مفتاح API';

  @override
  String get upload_failed => 'فشل الرفع';

  @override
  String get upload_failed_tap_retry => 'فشل الرفع • اضغط لإعادة المحاولة';

  @override
  String uploading(Object index, Object name, Object total) {
    return 'جارٍ رفع $index/$total: $name';
  }

  @override
  String get use_as_is => 'استخدام النص كما هو';

  @override
  String get use_at_least_8_characters => 'استخدم 8 أحرف على الأقل.';

  @override
  String get use_for_cron_jobs_backed_by_scripts =>
      'استخدم هذا الخيار لمهام cron التي تشغّل نصوصًا برمجية.';

  @override
  String get use_on_device => 'البحث على الجهاز';

  @override
  String get use_the_attached_content_to_identify_and_fill_the_relevant =>
      'استخدم المحتوى المرفق لتحديد الحقول المناسبة في المستند أو النموذج وتعبئتها. اطلب الإذن قبل إرسال أي شيء.';

  @override
  String use_this_content_to_identify_and_fill_the_relevant_document(
    Object text,
  ) {
    return 'استخدم هذا المحتوى لتحديد الحقول المناسبة في المستند أو النموذج وتعبئتها. اطلب الإذن قبل إرسال أي شيء:\n\n$text';
  }

  @override
  String get used_for_hosted_path_prefixes_and_for_the_settings_memory =>
      'تُستخدم هذه الإعدادات لبادئات مسارات الاستضافة ولتبويبات الإعدادات والذاكرة والمهارات وCron. إذا كانت لوحة التحكم متاحة بلا مصادقة، فاترك اسم المستخدم وكلمة المرور فارغين. وإذا كان الوكيل العكسي يضيف بيانات المصادقة للوحة التحكم، ففعّل وضع الوكيل.';

  @override
  String get username_optional => 'اسم المستخدم (اختياري)';

  @override
  String using(Object displayName) {
    return 'جارٍ استخدام $displayName…';
  }

  @override
  String get verbose_mode => 'الوضع المفصّل';

  @override
  String get message_metadata => 'تفاصيل الرسالة';

  @override
  String get voice => 'الصوت';

  @override
  String voice_setup_failed(Object error) {
    return 'تعذّر إعداد الصوت: $error';
  }

  @override
  String get waiting_for_your_input => 'بانتظار ردّك';

  @override
  String get what_hermes_knows_how_to_do => 'ما يستطيع Hermes فعله';

  @override
  String get what_should_the_agent_do => 'ماذا تريد من الوكيل أن يفعل؟';

  @override
  String get whatsapp_messages => 'رسائل WhatsApp';

  @override
  String get which_project => 'أي مشروع؟';

  @override
  String get workspace => 'مساحة العمل';

  @override
  String get wrap_lines => 'التفاف الأسطر';

  @override
  String you_can_attach_up_to_items(Object maxRemoteAttachmentDrafts) {
    return 'الحد الأقصى للعناصر التي يمكنك إرفاقها هو $maxRemoteAttachmentDrafts.';
  }

  @override
  String get your_answer => 'إجابتك';

  @override
  String get e_g_dashboard => 'مثل: /dashboard';

  @override
  String get e_g_dashboard_proxy_path_before_api =>
      'مثل: /dashboard (مسار الوكيل قبل /api/)';

  @override
  String get e_g_profile_peter => 'مثل: /profile/peter';

  @override
  String get e_g_sol => 'مثل: sol';

  @override
  String get e_g_0_9_or_every_2h => 'مثل: 0 9 * * * أو every 2h';

  @override
  String get e_g_daily_backup => 'مثل: نسخ احتياطي يومي';

  @override
  String downloaded(Object filename) {
    return 'اكتمل تنزيل $filename';
  }

  @override
  String activity_name_status(Object displayName, Object statusLabel) {
    return '$displayName: $statusLabel';
  }

  @override
  String connection_status_label(Object connectionLabel, Object label) {
    return '$connectionLabel $label';
  }

  @override
  String get example_host_hint =>
      '192.168.1.50 أو 100.x.y.z أو hermes-machine.tailnet.ts.net';

  @override
  String get example_profile_prefix_hint_full =>
      'مثل: /profile/peter (مسار الوكيل قبل /api/ و/v1/)';

  @override
  String and_more(Object count) {
    return 'والمزيد ($count)';
  }

  @override
  String chats_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد المحادثات: $count',
      one: '$count محادثة',
    );
    return '$_temp0';
  }

  @override
  String on_this_device_only(Object chats) {
    return '$chats · على هذا الجهاز فقط';
  }

  @override
  String spaces_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد المساحات: $count',
      one: '$count مساحة',
    );
    return '$_temp0';
  }

  @override
  String get no_new_projects_needed => 'لا حاجة إلى مشاريع جديدة';

  @override
  String projects_to_create(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد المشاريع التي ستُنشأ: $count',
      one: '$count مشروع سيُنشأ',
    );
    return '$_temp0';
  }

  @override
  String chats_migrated_projects_created(
    Object createdProjects,
    Object linkedSessions,
  ) {
    return 'المحادثات التي نُقلت: $linkedSessions · المشاريع التي أُنشئت: $createdProjects';
  }

  @override
  String chats_stayed_in_local_spaces(Object unlinkedSessions) {
    return 'بقيت بعض المحادثات في المساحات المحلية (عددها: $unlinkedSessions). يمكنك إعادة محاولة نقلها بأمان.';
  }

  @override
  String model_recommended(Object provider) {
    return '$provider • موصى به: نموذج صغير ومنخفض التكلفة';
  }

  @override
  String session_meta(Object count, Object model, Object time) {
    return 'الرسائل: $count • $model • $time';
  }

  @override
  String model_scope_label(Object model, Object scope) {
    return '$model • $scope';
  }

  @override
  String get this_chat => 'هذه المحادثة';

  @override
  String get profile_default => 'الإعداد الافتراضي لملف التعريف';

  @override
  String minutes_ago(Object count) {
    return 'منذ $count د';
  }

  @override
  String hours_ago(Object count) {
    return 'منذ $count س';
  }

  @override
  String days_ago(Object count) {
    return 'منذ $count ي';
  }

  @override
  String get now_label => 'الآن';

  @override
  String get latest_label => 'الأحدث';

  @override
  String new_count_indicator(Object count) {
    return 'رسائل جديدة: $count';
  }

  @override
  String new_messages(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الرسائل الجديدة: $count',
      one: '$count رسالة جديدة',
    );
    return '$_temp0';
  }

  @override
  String activity_failed_summary(Object failures, Object total) {
    return 'حالات الفشل: $failures • الإجمالي: $total';
  }

  @override
  String activity_completed_summary(Object count) {
    return 'المكتمل: $count';
  }

  @override
  String tool_start_observed(Object time) {
    return 'رُصد البدء في $time (بالتوقيت المحلي)';
  }

  @override
  String tool_last_observed(Object time) {
    return 'آخر رصد في $time (بالتوقيت المحلي)';
  }

  @override
  String tool_result_recorded(Object time) {
    return 'سُجّلت النتيجة في $time (بالتوقيت المحلي)';
  }

  @override
  String get tool_time_unavailable => 'الوقت غير متاح';

  @override
  String get hermes_is_using_a_tool => 'يستخدم Hermes أداة';

  @override
  String hermes_is_using_tools(Object count) {
    return 'عدد الأدوات التي يستخدمها Hermes: $count';
  }

  @override
  String delegated_tasks_completed(Object count) {
    return 'المهام المفوّضة المكتملة: $count';
  }

  @override
  String delegated_tasks_active(Object count) {
    return 'المهام المفوّضة النشطة: $count';
  }

  @override
  String branch_main(Object label) {
    return '$label · الفرع الرئيسي';
  }

  @override
  String get you_heading => '## أنت';

  @override
  String get hermes_heading => '## Hermes';

  @override
  String get action_label => 'الإجراء';

  @override
  String get destination_label => 'الوجهة';

  @override
  String get markdown_source => 'المصدر';

  @override
  String get preview_label => 'معاينة';

  @override
  String get share_action_summarize => 'تلخيص';

  @override
  String get share_action_explain => 'شرح';

  @override
  String get share_action_research => 'بحث';

  @override
  String get share_action_remember => 'تذكّر';

  @override
  String get text_size_small => 'صغير';

  @override
  String get text_size_default => 'افتراضي';

  @override
  String get text_size_large => 'كبير';

  @override
  String get text_size_extra_large => 'كبير جدًا';

  @override
  String get text_size_use_system_description =>
      'استخدام حجم النص المحدد في إعدادات تسهيل الاستخدام في Android دون تغيير.';

  @override
  String text_size_percent_description(Object percent) {
    return '$percent% من حجم النص في Android.';
  }

  @override
  String text_size_label_description(Object description, Object label) {
    return '$label — $description';
  }

  @override
  String files_skipped(Object count) {
    return 'عدد الملفات التي جرى تخطّيها: $count. السبب: تجاوز حدّ العدد أو الحجم، أو تعذّر القراءة، أو حساسية اسم الملف.';
  }

  @override
  String model_scope_applied(Object effort, Object model) {
    return '$model • $effort — تسري هذه الإعدادات الآن على هذه المحادثة فقط.';
  }

  @override
  String get reasoning_minimal => 'أدنى';

  @override
  String get reasoning_low => 'منخفض';

  @override
  String get reasoning_medium => 'متوسط';

  @override
  String get reasoning_high => 'مرتفع';

  @override
  String get reasoning_max => 'أقصى';

  @override
  String get reasoning_ultra => 'فائق';

  @override
  String get status_running => 'قيد التشغيل';

  @override
  String get status_failed => 'فشل';

  @override
  String get status_done => 'تمّ';

  @override
  String get status_idle => 'خامل';

  @override
  String get upload_status_uploading => 'جارٍ الرفع';

  @override
  String get upload_status_uploaded => 'اكتمل الرفع';

  @override
  String attachment_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد المرفقات: $count',
      one: '$count مرفق',
    );
    return '$_temp0';
  }

  @override
  String get action_create => 'إنشاء';

  @override
  String get action_rename => 'إعادة تسمية';

  @override
  String get action_archive => 'أرشفة';

  @override
  String get action_restore => 'استعادة';

  @override
  String get action_delete => 'حذف';

  @override
  String get migrate => 'نقل';

  @override
  String assigned_chats(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد المحادثات المعيّنة: $count',
      one: '$count محادثة معيّنة',
    );
    return '$_temp0';
  }

  @override
  String get date_today => 'اليوم';

  @override
  String get date_yesterday => 'أمس';

  @override
  String get date_earlier => 'في وقت سابق';

  @override
  String get nav_home => 'الرئيسية';

  @override
  String get nav_more => 'المزيد';

  @override
  String get status_completed => 'مكتمل';

  @override
  String get filter_all => 'الكل';

  @override
  String get filter_recent => 'الأحدث';

  @override
  String connection_address_key(Object address, Object status) {
    return '$address  •  المفتاح: $status';
  }

  @override
  String model_via_provider(Object model, Object provider) {
    return '$model  \nعبر `$provider`';
  }

  @override
  String get deny => 'رفض';

  @override
  String get connect => 'اتصال';

  @override
  String get appearance => 'المظهر';

  @override
  String get connection_section => 'الاتصال';

  @override
  String get about => 'حول التطبيق';

  @override
  String version_label(Object version) {
    return 'الإصدار $version';
  }

  @override
  String get matched => 'مطابق';

  @override
  String get search => 'بحث';

  @override
  String get on => 'مفعّل';

  @override
  String get off => 'معطّل';

  @override
  String get reasoning_off => 'معطّل';

  @override
  String get hermes_response_ready => 'ردّ Hermes جاهز';

  @override
  String get admin_password_needed => 'كلمة مرور المسؤول مطلوبة';

  @override
  String get hermes_needs_a_sudo_password_for_the_pending_terminal_command =>
      'يحتاج Hermes إلى كلمة مرور sudo لتنفيذ أمر الطرفية المعلّق.';

  @override
  String get sudo_password => 'كلمة مرور sudo';

  @override
  String get secret_needed => 'يلزم إدخال قيمة سرّية';

  @override
  String get hermes_needs_a_secret_for_the_pending_skill =>
      'يحتاج Hermes إلى قيمة سرّية لتشغيل المهارة المعلّقة.';

  @override
  String get secret_value => 'القيمة السرّية';

  @override
  String get attached_file => 'ملف مرفق';

  @override
  String get pin_chat => 'تثبيت المحادثة';

  @override
  String get unpin_chat => 'إلغاء تثبيت المحادثة';

  @override
  String get pinned_chats => 'المحادثات المثبّتة';

  @override
  String could_not_update_chat_pin(Object error) {
    return 'تعذّر تحديث حالة تثبيت المحادثة: $error';
  }

  @override
  String get could_not_save_chat_spaces =>
      'تعذّر حفظ مساحات المحادثات على هذا الجهاز';

  @override
  String get update_available => 'يتوفر تحديث';

  @override
  String get update_now => 'تحديث الآن';

  @override
  String get update_install => 'تثبيت التحديث';

  @override
  String get update_downloading => 'جارٍ تنزيل التحديث والتحقق منه…';

  @override
  String get update_allow_install =>
      'اسمح لتطبيق Hermes بتثبيت هذا التحديث، ثم عُد إلى هنا واضغط على «تثبيت التحديث».';

  @override
  String get update_failed =>
      'تعذّر تنزيل التحديث أو التحقق منه أو فتحه. حاول مجددًا أو راجع صفحة الإصدار.';

  @override
  String get a_newer_hermes_android_build_is_available_on_github =>
      'يتوفر إصدار أحدث من Ares على GitHub.';

  @override
  String get release_notes => 'ملاحظات الإصدار';

  @override
  String get view_release => 'عرض الإصدار';

  @override
  String get skip_this_version => 'تخطّي هذا الإصدار';

  @override
  String get later => 'لاحقًا';

  @override
  String get check_for_updates => 'التحقق من وجود تحديثات';

  @override
  String get check_for_updates_on_launch =>
      'التحقق من وجود تحديثات عند بدء التشغيل';

  @override
  String get you_re_on_the_latest_version => 'أنت تستخدم أحدث إصدار.';

  @override
  String get couldn_t_check_for_updates => 'تعذّر التحقق من وجود تحديثات.';

  @override
  String get chat_density => 'كثافة عرض المحادثة';

  @override
  String chat_density_2(Object label) {
    return 'كثافة عرض المحادثة: $label';
  }

  @override
  String get chat_density_comfortable => 'مريح';

  @override
  String get chat_density_compact => 'مضغوط';

  @override
  String get chat_density_comfortable_description =>
      'فقاعات أوسع يظهر فوق كلّ منها اسم المُرسِل.';

  @override
  String get chat_density_compact_description =>
      'فقاعات أصغر بلا أسماء للمرسلين، لتتسع الشاشة لعدد أكبر من الرسائل.';

  @override
  String chat_density_label_description(Object description, Object label) {
    return '$label — $description';
  }

  @override
  String
  get compact_removes_the_you_and_hermes_labels_and_trims_bubble_padding_spacing_and_side_margins =>
      'يخفي العرض المضغوط التسميتين «أنت» و«Hermes»، ويقلّل المساحة داخل الفقاعات والمسافات بينها والهوامش الجانبية.';

  @override
  String get client_certificate_mtls => 'شهادة العميل (mTLS)';

  @override
  String get client_certificate_mtls_description =>
      'قدّم شهادة عندما يتطلب وكيل HTTPS مصادقة متبادلة باستخدام TLS.';

  @override
  String get client_certificate_https_only =>
      'لا تُستخدم شهادات العميل إلا مع اتصالات HTTPS.';

  @override
  String get choose_certificate => 'اختيار شهادة';

  @override
  String get certificate_password => 'كلمة مرور الشهادة';

  @override
  String get this_certificate_is_password_protected =>
      'هذه الشهادة محمية بكلمة مرور. ستُفتح بمجرد كتابة كلمة المرور الصحيحة.';

  @override
  String get enter_the_certificate_password_to_finish_loading_it =>
      'أدخل كلمة مرور الشهادة التي اخترتها لإكمال تحميلها.';

  @override
  String get client_certificate_required =>
      'حمّل شهادة عميل أو عطّل خيار شهادة العميل.';

  @override
  String client_certificate_loaded(String label) {
    return 'الشهادة المحمّلة: $label';
  }

  @override
  String get remove_certificate => 'إزالة الشهادة';

  @override
  String get certificate_import_failed => 'تعذّر تحميل تلك الشهادة.';

  @override
  String get background_work => 'العمل في الخلفية';

  @override
  String get keep_chats_active_in_background =>
      'إبقاء المحادثات نشطة في الخلفية';

  @override
  String get background_work_description =>
      'يُبقي هذا الخيار المحادثات التي بدأتها متصلة أثناء عمل التطبيق في الخلفية. قد تنقطع الاتصالات الخاملة. يزيد تفعيل هذا الخيار من استهلاك البطارية والبيانات، ولا يؤدي تعطيله إلى إيقاف العمل على الخادم.';

  @override
  String get background_work_limits =>
      'قد يعلّق Android الاتصالات في وضع السكون (Doze) أو ينهي عملية التطبيق. لتلقّي الإشعارات بعد انتهاء العملية، يجب إعداد الإشعارات الفورية بشكل منفصل. الإيقاف الإجباري غير مدعوم.';

  @override
  String get background_work_disclosure =>
      'يبقى إشعار الخدمة الإلزامي ظاهرًا ما دامت الحماية في الخلفية مفعّلة، حتى عند إيقاف إشعارات المحادثة الاختيارية.';

  @override
  String get battery_optimisation_settings => 'إعدادات تحسين استهلاك البطارية';

  @override
  String get battery_optimisation_description =>
      'افتح إعدادات Android لمراجعة قيود البطارية. لا يطلب التطبيق إعفاءً تلقائيًا، وتغيير الإعدادات لا يضمن وصول الإشعارات.';

  @override
  String get battery_settings_unavailable =>
      'تعذّر فتح إعدادات البطارية على هذا الجهاز.';

  @override
  String get background_work_save_failed => 'تعذّر حفظ إعداد العمل في الخلفية.';

  @override
  String get ongoing_chat_channel_name => 'المحادثات النشطة';

  @override
  String get ongoing_chat_channel_description =>
      'إشعارات صامتة بحالة المحادثات التي بدأتها ولم تنتهِ بعد';

  @override
  String get task_timeline => 'التسلسل الزمني للمهمة';

  @override
  String get task_refresh_history => 'تحديث سجل المهمة';

  @override
  String get task_live_preview => 'معاينة مباشرة من أحداث المهمة الأم';

  @override
  String get task_preview_explanation =>
      'تعرض المعاينة آخر ما أُتيح فقط، وليست جزءًا من السجل المحفوظ.';

  @override
  String get task_preview => 'معاينة';

  @override
  String get task_recorded_history => 'سجل المهمة المحفوظ';

  @override
  String get task_loading_history => 'جارٍ تحميل سجل المهمة…';

  @override
  String get task_empty_history =>
      'لا توجد رسائل مسجّلة بعد. ربما لم تحفظ المهمة سجلها بعد، وهذا لا يعني أنها لم تنجز أي عمل.';

  @override
  String get task_load_older => 'تحميل السجلات الأقدم';

  @override
  String get task_default_goal => 'مهمة مفوّضة';

  @override
  String task_status(Object status) {
    return 'الحالة: $status';
  }

  @override
  String task_identity(Object id) {
    return 'المهمة: $id';
  }

  @override
  String task_stored_session(Object id) {
    return 'الجلسة المحفوظة: $id';
  }

  @override
  String task_delegation(Object id) {
    return 'التفويض: $id';
  }

  @override
  String get task_read_only_notice =>
      'للقراءة فقط · قد يظهر السجل بعد أن تحفظه المهمة. حدّث الصفحة للتحقق مجددًا.';

  @override
  String task_row_label(Object id, Object role) {
    return '$role · السطر $id';
  }

  @override
  String get task_role_assistant => 'المساعد';

  @override
  String get task_role_user => 'المستخدم';

  @override
  String get task_role_tool => 'الأداة';

  @override
  String task_tool_call(Object name) {
    return 'استدعاء أداة · $name';
  }

  @override
  String task_tool_result(Object name) {
    return 'نتيجة الأداة · $name';
  }

  @override
  String task_call_details(Object arguments, Object id) {
    return 'معرّف الاستدعاء: $id\nالوسائط\n$arguments';
  }

  @override
  String task_result_details(Object id, Object result) {
    return 'معرّف الاستدعاء: $id\nالنتيجة\n$result';
  }

  @override
  String get task_not_supplied => 'غير متوفر';

  @override
  String get task_missing_arguments => 'لم يحتفظ الخادم بوسائط الاستدعاء.';

  @override
  String get task_image_placeholder => '[صورة]';

  @override
  String get task_invalid_reference =>
      'نصّ المهمة غير متاح: المرجع المحفوظ للجلسة غير صالح.';

  @override
  String get task_auth_required =>
      'نصّ المهمة غير متاح: اضبط إعدادات مصادقة لوحة التحكم لهذه البوابة. لا يتيح مفتاح خادم API الاطّلاع على خطوات تفكير المهمة.';

  @override
  String get task_auth_rejected =>
      'نصّ المهمة غير متاح: رفضت لوحة التحكم المصادقة. تحقّق من إعدادات لوحة التحكم لهذه البوابة.';

  @override
  String get task_incompatible_history =>
      'نصّ المهمة غير متاح: لا تتيح لوحة التحكم هذه قراءة جزء محدود من السجل بصيغته الأصلية بطريقة متوافقة مع ملف التعريف المحدد.';

  @override
  String get task_identity_unproven =>
      'نصّ المهمة غير متاح: لم تتمكن لوحة التحكم من التحقق من هوية الجلسة المحفوظة أو تتبّع أصلها عبر عمليات الضغط. لم يُعرض نصّ من أي جلسة أخرى.';

  @override
  String get task_partial_compression =>
      'السجل غير مكتمل: استمرّت المهمة بعد الضغط، لكن البوابة لم تُتح مرجعًا أحدث يمكن التحقق منه. قد لا يظهر الرد الأخير. أُوقف التحديث التلقائي مؤقتًا؛ اضغط على «تحديث» للمحاولة مجددًا.';

  @override
  String get task_partial_ancestors =>
      'السجل غير مكتمل: لا تعرض البوابة السجلات السابقة التي استُخدمت في ضغط سجل هذه المهمة، لذا قد تغيب بعض أجزائه الأولى. تبقى السطور المتاحة محفوظة؛ اضغط على «تحديث» للمحاولة مجددًا.';

  @override
  String get task_missing_reference =>
      'نصّ المهمة غير متاح: لم يحتفظ الخادم بمرجع الجلسة الخاصة بها.';

  @override
  String get task_missing_row_identity =>
      'نصّ المهمة غير متاح: لم يوفّر الخادم معرّفات ثابتة لسطور الرسائل.';

  @override
  String get task_history_not_ready =>
      'سجل المهمة غير متاح بعد (HTTP 404). ربما لم تحفظ المهمة سجلها بعد، أو ربما لا تدعم لوحة التحكم سجل المهام. حاول مجددًا للتحقق.';

  @override
  String get task_refresh_failed =>
      'تعذّر تحديث سجل المهمة. تحقّق من الاتصال ثم حاول مجددًا.';

  @override
  String get task_status_interrupted => 'انقطعت';

  @override
  String get task_status_cancelled => 'أُلغيت';

  @override
  String get task_status_requested => 'طُلِبت';

  @override
  String get task_status_thinking => 'جارٍ التفكير';

  @override
  String get task_status_tool => 'جارٍ استخدام أداة';

  @override
  String get task_status_pending => 'قيد الانتظار';

  @override
  String get task_status_dispatched => 'أُرسلت للتنفيذ';

  @override
  String task_status_unknown(Object status) {
    return 'حالة غير معروفة: $status';
  }

  @override
  String task_tasks_finished(Object count) {
    return 'المهام المفوّضة التي انتهت: $count';
  }

  @override
  String get activity_status_unconfirmed => 'الحالة غير مؤكدة';

  @override
  String get activity_recently_updated => 'حُدّث مؤخرًا';

  @override
  String get activity_reconnecting =>
      'جارٍ إعادة الاتصال للتحقق من حالة الجولة';

  @override
  String get activity_outcome_unknown =>
      'تعذّر تأكيد نتيجة الجولة. افتح المحادثة للتحقق.';

  @override
  String get activity_chat_updated_detail =>
      'سجّلت البوابة نشاطًا في المحادثة، لكن الحالة المباشرة للجولة غير متاحة.';

  @override
  String get activity_updated => 'حُدّث';

  @override
  String get activity_empty_title => 'لا يوجد نشاط حديث';

  @override
  String get activity_empty_detail =>
      'تظهر هنا الجولات التي بدأتَها في هذا التطبيق ومحادثات البوابة التي حُدّثت خلال آخر 7 أيام.';

  @override
  String get activity_read_error =>
      'تعذّرت قراءة سجلات الجولات أو محادثات البوابة لعرض النشاط. تحقّق من الاتصال وحاول مجددًا.';

  @override
  String get activity_chat_unavailable =>
      'لم تعد هذه المحادثة متاحة، أو تعذّر الاتصال بالبوابة.';

  @override
  String get activity_partial_title => 'لم يُحمَّل النشاط بالكامل';

  @override
  String get activity_partial_detail =>
      'يظهر جزء فقط من نشاط البوابة. قد تكون هناك محادثات أخرى؛ اسحب لأسفل للتحديث.';

  @override
  String get provider_usage => 'الاستخدام المسجّل';

  @override
  String get provider_usage_notice =>
      'هذه بيانات استخدام Hermes خلال آخر 30 يومًا، وليست رصيد الحساب أو أسعار النماذج. اضبط بيانات اعتماد المزوّد على خادم Hermes؛ فهذا التطبيق لا يخزّن مفاتيح API الخاصة بالمزوّد.';

  @override
  String get provider_usage_failed => 'تعذّر تحميل بيانات الاستخدام المسجّل.';

  @override
  String get provider_usage_empty => 'لا يوجد استخدام مسجّل لهذا المزوّد.';

  @override
  String provider_usage_counts(String sessions, String input, String output) {
    return 'الجلسات: $sessions · المدخلات: $input · المخرجات: $output';
  }

  @override
  String provider_usage_costs(String estimated, String actual) {
    return 'التكلفة المقدّرة: $estimated · التكلفة المُبلّغ عنها: $actual';
  }

  @override
  String get provider_quota_codex => 'اشتراك OpenAI Codex';

  @override
  String get provider_quota_claude => 'اشتراك Claude';

  @override
  String get provider_quota_openai_api => 'الاستخدام المسجّل لواجهة OpenAI API';

  @override
  String get provider_quota_notice =>
      'يعرض المزوّد حدود الاشتراك لكل فترة، وهي منفصلة عن الاستخدام الذي يسجّله Hermes وعن فواتير API. يُعرض كل حساب على حدة؛ وبلوغ حدّ نموذج معيّن لا يعني استنفاد حصة الحساب بالكامل.';

  @override
  String get provider_quota_windows_notice =>
      'لاشتراكات Codex وClaude حدود لكل جلسة مدتها خمس ساعات وحدود أسبوعية. لا تظهر إلا الفترات التي يُبلغ عنها المزوّد. إذا لم يذكر حدًا أو موعدًا لتجديد الحصة، تظل هذه المعلومة غير متاحة. قد تسري الحدود الأسبوعية على الحساب أو على نماذج معيّنة.';

  @override
  String get provider_quota_five_hour_session => 'جلسة مدتها 5 ساعات';

  @override
  String get provider_quota_unavailable => 'حصة الاشتراك غير متاحة.';

  @override
  String get provider_quota_failed =>
      'تعذّر تحديث حصة الاشتراك. أي قيم محفوظة تعود إلى آخر قراءة.';

  @override
  String get provider_quota_account => 'الحساب';

  @override
  String get provider_quota_unknown => 'غير معروف';

  @override
  String provider_quota_state(String state) {
    return 'حالة الحساب: $state';
  }

  @override
  String provider_quota_scope(String scope) {
    return 'النطاق: $scope';
  }

  @override
  String provider_quota_percent(String used, String remaining) {
    return 'المُستخدَم: $used% · المتبقي: $remaining%';
  }

  @override
  String provider_quota_reset(String reset) {
    return 'موعد تجديد الحصة: $reset';
  }

  @override
  String get provider_quota_reset_unknown => 'موعد تجديد الحصة غير متاح.';

  @override
  String get auxiliary_models => 'النماذج المساعدة';

  @override
  String get auxiliary_notice =>
      'اختر نموذجًا لكل مهمة. يجب إدارة نقاط الاتصال المخصّصة على الخادم. يتّبع الخيار «تلقائي» قواعد توارث الإعدادات الخاصة بالمهمة.';

  @override
  String get auxiliary_inherit => 'تلقائي (توارث الإعدادات)';

  @override
  String get auxiliary_unavailable => 'إعدادات النماذج المساعدة غير متاحة.';

  @override
  String get provider_oauth_title => 'تسجيل الدخول لدى المزوّد';

  @override
  String get provider_oauth_more_subtitle =>
      'إدارة تسجيل الدخول لدى المزوّد على مضيف Hermes';

  @override
  String get provider_oauth_settings_subtitle =>
      'سجّل الدخول على مضيف Hermes؛ لا تُخزَّن رموز المزوّد على هذا الجهاز';

  @override
  String get provider_oauth_intro =>
      'سجّل الدخول إلى حسابك لدى المزوّد في متصفح خارجي. تُحفظ رموز الوصول على مضيف Hermes فقط، وليس على هذا الجهاز. لا يؤدي تسجيل الدخول إلى اختيار نموذج للمحادثة في هذا التطبيق.';

  @override
  String get provider_oauth_defaults_notice =>
      'قد تؤدي بعض إجراءات المضيف، مثل استبدال حساب الباقة المجانية لدى Nous، إلى تغيير إعداداته الافتراضية. راجع إعدادات المضيف بعد تسجيل الدخول.';

  @override
  String get provider_oauth_transport_init_failed =>
      'تعذّر تهيئة وسيلة الاتصال الآمن المحددة للوحة التحكم. تحقّق من هوية TLS وإعدادات الاتصال.';

  @override
  String get provider_oauth_https_required =>
      'يتطلب تسجيل الدخول لدى المزوّد اتصالًا بلوحة تحكم Hermes عبر HTTPS.';

  @override
  String get provider_oauth_auth_required =>
      'أعدّ المصادقة بكلمة مرور للوحة التحكم أو اضبط وكيلًا موثوقًا قبل تسجيل الدخول.';

  @override
  String get provider_oauth_catalog_failed =>
      'تسجيل الدخول لدى المزوّد غير متاح على هذا المضيف. تحقّق من مصادقة لوحة التحكم، وحدّث المضيف إن لم يكن يدعم OAuth للمزوّد.';

  @override
  String get provider_oauth_expired =>
      'انتهت صلاحية طلب تسجيل الدخول. ابدأ من جديد.';

  @override
  String get provider_oauth_start_failed =>
      'تعذّر بدء تسجيل الدخول الآمن لدى المزوّد. حاول مجددًا.';

  @override
  String get provider_oauth_denied => 'رُفض طلب تسجيل الدخول. ابدأ من جديد.';

  @override
  String get provider_oauth_cancelled => 'أُلغي تسجيل الدخول.';

  @override
  String get provider_oauth_host_failed =>
      'تعذّر على المضيف إكمال تسجيل الدخول. ابدأ من جديد.';

  @override
  String get provider_oauth_poll_failed =>
      'تعذّر التحقق من حالة تسجيل الدخول. ابدأ من جديد.';

  @override
  String provider_oauth_cancellation_unconfirmed(String message) {
    return '$message تعذّر تأكيد الإلغاء؛ قد تبقى الجلسة نشطة على المضيف حتى تنتهي صلاحيتها.';
  }

  @override
  String get provider_oauth_browser_failed =>
      'تعذّر فتح المتصفح الخارجي. أعد المحاولة أو ألغِ تسجيل الدخول.';

  @override
  String get provider_oauth_retry => 'إعادة المحاولة';

  @override
  String provider_oauth_complete(String provider) {
    return 'إكمال تسجيل الدخول إلى $provider';
  }

  @override
  String get provider_oauth_code_instruction =>
      'أدخل هذا الرمز المؤقت في صفحة المزوّد:';

  @override
  String get provider_oauth_waiting =>
      'بانتظار الموافقة. تنتهي صلاحية هذه الجلسة تلقائيًا.';

  @override
  String get provider_oauth_open_browser => 'فتح صفحة المزوّد في المتصفح';

  @override
  String get provider_oauth_cancel => 'إلغاء تسجيل الدخول';

  @override
  String get provider_oauth_signed_out => 'لم تسجّل الدخول على المضيف';

  @override
  String get provider_oauth_sign_in_again => 'تسجيل الدخول مجددًا';

  @override
  String get provider_oauth_sign_in => 'تسجيل الدخول';

  @override
  String get provider_oauth_cli_required =>
      'سجّل الدخول باستخدام واجهة سطر الأوامر (CLI) الخاصة بالمزوّد على مضيف Hermes. لا يتيح هذا المضيف تسجيل الدخول إلى هذا المزوّد من داخل التطبيق.';

  @override
  String get provider_oauth_checking_account =>
      'وصلت الموافقة. جارٍ التحقق من الحساب على المضيف…';

  @override
  String get provider_oauth_verification_unavailable =>
      'وصلت الموافقة، لكن التحقق من الحساب غير متاح. افتح «الاستخدام» لتحديث بيانات استخدام الحساب.';

  @override
  String provider_oauth_verified_account(String email) {
    return 'سجّلت الدخول إلى مضيف Hermes بالحساب $email. افتح «الاستخدام» لتحديث بيانات استخدام الحساب.';
  }

  @override
  String get provider_oauth_credentials_unverified =>
      'يشير المضيف إلى توفّر بيانات الاعتماد، لكن لم يجرِ التحقق من هوية الحساب.';

  @override
  String get provider_oauth_account_status_unknown =>
      'حالة الحساب على المضيف غير متاحة.';

  @override
  String get app_language => 'لغة التطبيق';

  @override
  String get app_language_system => 'لغة الهاتف';

  @override
  String get auto_archives_after_72_hours => 'يُؤرشف تلقائيًا بعد 72 ساعة';

  @override
  String get automation => 'الأتمتة';

  @override
  String get voice_recording_start => 'تسجيل رسالة صوتية';

  @override
  String get voice_recording_pause => 'إيقاف التسجيل مؤقتًا';

  @override
  String get voice_recording_preview => 'تشغيل التسجيل';

  @override
  String get voice_recording_resume => 'متابعة التسجيل';

  @override
  String get voice_recording_send => 'إرسال الرسالة الصوتية';

  @override
  String get voice_recording_discard => 'تجاهل التسجيل';

  @override
  String get voice_recording_processing => 'جارٍ تجهيز الرسالة الصوتية…';

  @override
  String voice_recording_elapsed(String time) {
    return 'جارٍ التسجيل: $time';
  }

  @override
  String voice_recording_draft(String time) {
    return 'رسالة صوتية: $time';
  }

  @override
  String get voice_recording_permission =>
      'اسمح بالوصول إلى الميكروفون لتسجيل رسالة صوتية.';

  @override
  String get voice_recording_limit => 'بلغ التسجيل مدته القصوى وهي عشر دقائق.';

  @override
  String get voice_recording_empty => 'لم يُسجَّل أي صوت. أعد المحاولة.';

  @override
  String get voice_recording_failed =>
      'تعذّرت معالجة التسجيل. احتفظ التطبيق بكل المقاطع المحفوظة.';

  @override
  String get voice_recording_unconfirmed =>
      'لم يتأكد وصول الرسالة. تسجيلك محفوظ. تحقّق من المحادثة قبل إعادة المحاولة.';

  @override
  String get voice_recording_submit_failed =>
      'تعذّر إرسال الرسالة الصوتية. تسجيلك محفوظ. تحقّق من الاتصال وإمكانية الوصول إلى لوحة التحكم وإعدادات تحويل الصوت إلى نص على الخادم.';

  @override
  String get voice_recording_pause_playback => 'إيقاف التشغيل مؤقتًا';

  @override
  String get projects_root_title => 'مجلد المشاريع على الخادم';

  @override
  String get projects_root_more_subtitle =>
      'المكان الذي تُنشأ فيه مجلدات المشاريع الجديدة على الخادم';

  @override
  String get projects_root_description =>
      'يُنشأ هنا مجلد لكل مشروع تنشئه على هذا الهاتف. حدّد المجلد الذي يستخدمه Hermes نفسه لتتمكن من الوصول إلى المشاريع نفسها من الهاتف والخادم.';

  @override
  String get projects_root_label => 'مسار المجلد الجذر للمشاريع';

  @override
  String projects_root_default_hint(String path) {
    return 'المسار الافتراضي للخادم: $path';
  }

  @override
  String get projects_root_locked_title => 'يحدّده الخادم';

  @override
  String get projects_root_locked_explanation =>
      'يقصر هذا الخادم الوصول إلى الملفات على مجلد جذر واحد، لذا لا يمكنك تغيير مجلد المشاريع من التطبيق.';

  @override
  String get projects_root_saved => 'حُفظ مجلد المشاريع.';

  @override
  String get projects_root_reset => 'استخدام المسار الافتراضي للخادم';

  @override
  String get projects_root_invalid_empty => 'أدخل مسار مجلد.';

  @override
  String get projects_root_invalid_absolute =>
      'أدخل مسارًا مطلقًا يبدأ بشرطة مائلة (/).';

  @override
  String get projects_root_invalid_segments =>
      'أزل مقاطع النقاط ومحارف التحكم من المسار.';

  @override
  String get projects_root_unsupported =>
      'هذا الاتصال لا يدعم هذه الميزة. تحتاج إلى اتصال ببوابة سطح المكتب (Desktop Gateway) يتيح الوصول إلى لوحة التحكم لقراءة مجلد المشاريع على الخادم أو تغييره.';

  @override
  String get projects_root_unavailable =>
      'تعذّرت قراءة مجلد المشاريع على الخادم. تحقّق من الاتصال بلوحة التحكم، ثم أعد المحاولة.';

  @override
  String get adopt_folder_action => 'إضافة مجلد موجود';

  @override
  String adopt_folder_description(String root) {
    return 'المجلدات الموجودة ضمن $root التي لم تُسجَّل كمشاريع بعد.';
  }

  @override
  String adopt_folder_registered(String name) {
    return 'مسجّل بالفعل كمشروع: $name';
  }

  @override
  String get adopt_folder_none => 'كل مجلد ضمن هذا المسار مسجّل بالفعل كمشروع.';

  @override
  String get adopt_folder_unsupported =>
      'لا يتيح هذا الاتصال عرض مجلدات الخادم. أدخل بدلًا من ذلك المسار المطلق لمجلد موجود.';

  @override
  String adopt_folder_failed(String error) {
    return 'تعذّر عرض مجلدات الخادم: $error';
  }

  @override
  String get adopt_folder_manual_label => 'مسار المجلد الموجود';

  @override
  String get adopt_folder_name_label => 'اسم المشروع';

  @override
  String get adopt_folder_add => 'إضافة كمشروع';

  @override
  String adopt_folder_added(String name, String path) {
    return 'يستخدم $name الآن المسار $path';
  }

  @override
  String adopt_folder_error(String error) {
    return 'تعذّرت إضافة المجلد: $error';
  }

  @override
  String adopt_folder_folderless(String name) {
    return 'أُنشئ المشروع $name، لكن لم يُربط به المجلد. اربطه من خلال Hermes على الخادم.';
  }

  @override
  String get slash_commands => 'أوامر الشرطة المائلة';

  @override
  String get slash_commands_loading => 'جارٍ تحميل الأوامر…';

  @override
  String get slash_commands_empty => 'لا توجد أوامر مطابقة';

  @override
  String slash_command_info_alias(String alias, String command) {
    return '$alias اسم بديل للأمر $command';
  }

  @override
  String get slash_command_info_no_description => 'لا يوجد وصف متاح.';

  @override
  String get slash_command_info_arguments_options =>
      'يقبل خيارًا واحدًا من قائمة محدّدة.';

  @override
  String get slash_command_info_arguments_text => 'يقبل نصًا بعد الأمر.';

  @override
  String get slash_command_info_arguments_mixed =>
      'يقبل خيارًا أو نصًا بعد الأمر.';

  @override
  String get slash_command_output => 'مخرجات الأمر';

  @override
  String get slash_command_no_output => 'اكتمل تنفيذ الأمر دون مخرجات.';

  @override
  String get slash_command_delivery_unknown =>
      'أُرسل الأمر لكن لم يصل ردّ. قد يظلّ قيد التنفيذ على البوابة، لذا احتفظنا بمسودتك. تحقّق من البوابة قبل إعادة المحاولة.';

  @override
  String get slash_command_failed => 'تعذّر تنفيذ الأمر.';

  @override
  String get slash_command_unsupported => 'هذا الأمر غير متاح على هذا الخادم.';

  @override
  String get slash_sessions_inline =>
      'افتح قائمة الجلسات لاختيار محادثة. مسودتك محفوظة.';

  @override
  String get nextgen_toggle => 'واجهة NextGen';

  @override
  String get nextgen_toggle_subtitle =>
      'تصميم جديد يتيح تسجيل الدخول مرة واحدة والمحادثات المباشرة واكتشاف الأجهزة على الشبكة. بواباتك ومحادثاتك متاحة في هذه الواجهة أيضًا.';

  @override
  String get nextgen_single_login => 'تسجيل الدخول مرة واحدة';

  @override
  String get nextgen_single_login_subtitle =>
      'لإضافة بوابة، يكفي إدخال عنوان لوحة التحكم وتسجيل الدخول مرة واحدة.';

  @override
  String get ng_allow_this_command => 'هل تسمح بتنفيذ هذا الأمر؟';

  @override
  String ng_hermes_wants_to_run_this_with(Object tool) {
    return 'يريد Hermes تنفيذ هذا الأمر باستخدام $tool.';
  }

  @override
  String get ng_hermes_wants_to_run_this => 'يريد Hermes تنفيذ هذا الأمر.';

  @override
  String get ng_hermes_has_a_question => 'لدى Hermes سؤال';

  @override
  String get ng_hermes_has_questions => 'لدى Hermes أسئلة';

  @override
  String get ng_password_for_sudo => 'كلمة مرور sudo';

  @override
  String get ng_hermes_needs_your_sudo_password_to =>
      'يحتاج Hermes إلى كلمة مرور sudo الخاصة بك لتنفيذ هذا الأمر.';

  @override
  String get ng_a_secret_value => 'قيمة سرية';

  @override
  String ng_value_for(Object variable) {
    return 'قيمة $variable';
  }

  @override
  String get ng_your_password_manager => 'مدير كلمات المرور لديك';

  @override
  String ng_unlock(Object name) {
    return 'فتح قفل $name';
  }

  @override
  String ng_hermes_needs_unlocked_to_sign_in(Object name) {
    return 'يحتاج Hermes إلى فتح قفل $name لتسجيل الدخول نيابةً عنك.';
  }

  @override
  String get ng_sign_in_code => 'رمز تسجيل الدخول';

  @override
  String get ng_enter_the_sign_in_code => 'أدخل رمز تسجيل الدخول.';

  @override
  String ng_enter_the_sign_in_code_for(Object site) {
    return 'أدخل رمز تسجيل الدخول إلى $site.';
  }

  @override
  String get ng_save_a_login => 'هل تريد حفظ بيانات تسجيل الدخول؟';

  @override
  String ng_save_your_login(Object site) {
    return 'هل تريد حفظ بيانات تسجيل دخولك إلى $site؟';
  }

  @override
  String ng_couldn_t_load_this_chat(Object error) {
    return 'تعذّر تحميل هذه المحادثة: $error';
  }

  @override
  String ng_live_updates_are_unavailable(Object error) {
    return 'التحديثات المباشرة غير متاحة: $error';
  }

  @override
  String ng_preparing(Object name) {
    return 'جارٍ تجهيز $name…';
  }

  @override
  String get ng_the_turn_failed => 'فشلت معالجة الطلب.';

  @override
  String get ng_turn_changed =>
      'انتهت معالجة ذلك الطلب أو بدأت معالجة طلب أحدث';

  @override
  String get ng_steer_rejected => 'لم تُقبل الرسالة أثناء معالجة الطلب الحالي';

  @override
  String get ng_turn_not_known_yet =>
      'لم يُحدَّد الطلب الجاري بعد؛ أعد المحاولة بعد قليل';

  @override
  String ng_couldn_t_stop(Object error) {
    return 'تعذّر الإيقاف: $error';
  }

  @override
  String get ng_server_access => 'الوصول إلى الخادم';

  @override
  String get ng_sign_in => 'تسجيل الدخول';

  @override
  String get ng_live_connection => 'الاتصال المباشر';

  @override
  String get ng_check_that_tailscale_is_on_on =>
      'تأكّد من تشغيل Tailscale على هذا الهاتف وعلى الخادم.';

  @override
  String get ng_check_the_address_and_that_the =>
      'تحقّق من العنوان وتأكّد من أن الوكيل يعيد توجيه الطلبات إلى لوحة التحكم.';

  @override
  String get ng_use_the_same_network_as_the =>
      'اتصل بالشبكة نفسها التي يتصل بها الخادم، وشغّل لوحة التحكم باستخدام --host 0.0.0.0 لتتمكن الأجهزة الأخرى من الوصول إليها.';

  @override
  String get ng_check_the_address_vpn_or_tailscale =>
      'تحقّق من العنوان أو من اتصال VPN أو Tailscale.';

  @override
  String get ng_not_checked_yet => 'لم يجرِ التحقق بعد.';

  @override
  String get ng_checking => 'جارٍ التحقق…';

  @override
  String ng_hermes_answers_at(Object version, Object address) {
    return 'يستجيب Hermes $version على العنوان $address.';
  }

  @override
  String get ng_something_answered_but_not_a_hermes =>
      'وصل ردّ، لكنه ليس من لوحة تحكم Hermes.';

  @override
  String ng_something_answered_http_but_not_a(Object status) {
    return 'وصل ردّ (HTTP $status)، لكنه ليس من لوحة تحكم Hermes.';
  }

  @override
  String get ng_use_the_dashboard_s_address_and =>
      'استخدم عنوان لوحة التحكم ومنفذها (9119 افتراضيًا)، وليس عنوان خادم API ومنفذه.';

  @override
  String get ng_cloudflare_access_turned_the_service_token =>
      'رفضت Cloudflare Access رمز الخدمة.';

  @override
  String get ng_cloudflare_access_is_in_front_of =>
      'هذا العنوان محميّ بواسطة Cloudflare Access.';

  @override
  String get ng_check_the_service_token_and_its =>
      'تحقّق من رمز الخدمة وسياسة Service Auth الخاصة به.';

  @override
  String get ng_add_a_cloudflare_access_service_token =>
      'أضف رمز خدمة Cloudflare Access لهذا العنوان.';

  @override
  String get ng_the_server_asks_for_a_client => 'يطلب الخادم شهادة عميل.';

  @override
  String get ng_pick_the_client_certificate_for_this =>
      'اختر شهادة العميل لهذه البوابة، ثم أعد الاختبار.';

  @override
  String get ng_needs_server_access_first => 'يلزم الوصول إلى الخادم أولًا.';

  @override
  String get ng_needs_a_sign_in_first => 'يلزم تسجيل الدخول أولًا.';

  @override
  String ng_signed_in_as(Object name) {
    return 'سجّلت الدخول باسم $name.';
  }

  @override
  String get ng_this_dashboard_doesn_t_need_a =>
      'لا تتطلب لوحة التحكم هذه تسجيل الدخول.';

  @override
  String get ng_the_saved_sign_in_has_expired =>
      'انتهت صلاحية جلسة الدخول المحفوظة.';

  @override
  String get ng_sign_in_again => 'سجّل الدخول مجددًا.';

  @override
  String get ng_too_many_sign_in_attempts =>
      'تجاوزت الحد المسموح به لمحاولات تسجيل الدخول.';

  @override
  String get ng_wait_a_minute_then_check_again =>
      'انتظر دقيقة ثم تحقّق مجددًا.';

  @override
  String ng_the_gateway_answered(Object message) {
    return 'ردّت البوابة: $message.';
  }

  @override
  String get ng_sign_in_again_or_update_hermes =>
      'سجّل الدخول مجددًا أو حدّث Hermes.';

  @override
  String ng_couldn_t_check_the_sign_in(Object error) {
    return 'تعذّر التحقق من تسجيل الدخول: $error';
  }

  @override
  String ng_the_gateway_wouldn_t_issue_a(Object message) {
    return 'رفضت البوابة إصدار تذكرة اتصال بالمحادثة ($message).';
  }

  @override
  String get ng_the_chat_connection_opened_and_the =>
      'فُتح اتصال المحادثة وأكّدت البوابة جاهزيتها.';

  @override
  String get ng_the_gateway_never_said_it_was => 'لم تؤكّد البوابة جاهزيتها.';

  @override
  String get ng_check_that_the_agent_is_running =>
      'تأكّد من أن الوكيل يعمل على الخادم.';

  @override
  String get ng_the_gateway_refused_the_chat_connection =>
      'رفضت البوابة اتصال المحادثة (HTTP 403).';

  @override
  String get ng_this_dashboard_has_no_chat_endpoint =>
      'لا توفّر لوحة التحكم هذه نقطة اتصال للمحادثة (/api/ws).';

  @override
  String ng_the_chat_connection_failed(Object detail) {
    return 'فشل اتصال المحادثة: $detail';
  }

  @override
  String get ng_use_the_exact_address_the_dashboard =>
      'استخدم العنوان المحدّد في إعدادات لوحة التحكم كما هو.';

  @override
  String get ng_update_hermes => 'حدّث Hermes.';

  @override
  String get ng_make_sure_the_proxy_allows_websocket =>
      'تأكّد من أن الوكيل يسمح بترقية الاتصال إلى WebSocket على المسار /api/ws.';

  @override
  String get ng_offline => 'غير متصل';

  @override
  String get ng_connecting => 'جارٍ الاتصال…';

  @override
  String get ng_connected => 'متصل';

  @override
  String get ng_reconnecting => 'جارٍ إعادة الاتصال…';

  @override
  String get ng_signed_out => 'لم تسجّل الدخول';

  @override
  String get ng_connection_failed => 'فشل الاتصال';

  @override
  String get ng_rate_limited_by_gateway =>
      'فرضت البوابة حدًّا على معدل الطلبات';

  @override
  String ng_couldn_t_open_the_chat_connection(Object message) {
    return 'تعذّر فتح اتصال المحادثة: $message';
  }

  @override
  String get ng_the_gateway_returned_no_websocket_ticket =>
      'لم تُرسل البوابة تذكرة WebSocket.';

  @override
  String get ng_connection_lost => 'انقطع الاتصال';

  @override
  String get ng_this_dashboard_has_no_chat_endpoint_2 =>
      'لا توفّر لوحة التحكم هذه نقطة اتصال للمحادثة (/api/ws). حدّث Hermes.';

  @override
  String get ng_the_gateway_refused_the_chat_connection_2 =>
      'رفضت البوابة اتصال المحادثة. تأكّد من أن العنوان يطابق المضيف المحدّد في إعدادات لوحة التحكم وأن المحادثة المضمّنة مفعّلة.';

  @override
  String ng_the_gateway_refused(Object method) {
    return 'رفضت البوابة $method.';
  }

  @override
  String ng_couldn_t_read_your_saved_gateways(Object error) {
    return 'تعذّرت قراءة بواباتك المحفوظة: $error';
  }

  @override
  String get ng_applies_to_new_chats => 'يسري على المحادثات الجديدة';

  @override
  String ng_couldn_t_change(Object label, Object error) {
    return 'تعذّر تغيير $label: $error';
  }

  @override
  String get ng_capabilities => 'الإمكانات';

  @override
  String get ng_skills => 'المهارات';

  @override
  String get ng_toolsets => 'مجموعات الأدوات';

  @override
  String get ng_search => 'بحث';

  @override
  String get ng_couldn_t_load => 'تعذّر التحميل';

  @override
  String get ng_try_again => 'إعادة المحاولة';

  @override
  String get ng_no_skills => 'لا توجد مهارات';

  @override
  String get ng_no_toolsets => 'لا توجد مجموعات أدوات';

  @override
  String get ng_no_mcp_servers => 'لا توجد خوادم MCP';

  @override
  String get ng_that_file_is_too_large_to =>
      'هذا الملف أكبر من الحجم المتوقع لملف شهادة.';

  @override
  String ng_the_certificate_couldn_t_be_imported(Object error) {
    return 'تعذّر استيراد الشهادة: $error';
  }

  @override
  String get ng_now_pick_its_private_key => 'اختر الآن المفتاح الخاص بالشهادة.';

  @override
  String get ng_now_pick_its_certificate =>
      'اختر الآن الشهادة المرتبطة بالمفتاح.';

  @override
  String get ng_that_file_isn_t_a_certificate =>
      'هذا الملف ليس شهادة ولا مفتاحًا خاصًا.';

  @override
  String get ng_if_a_proxy_in_front_of =>
      'إذا كان الوكيل الذي يحمي هذا العنوان يطلب شهادة عميل، فاخترها هنا لتُقدَّم عند اختبار الاتصال وتسجيل الدخول واستخدام المحادثة.';

  @override
  String get ng_client_certificates_are_only_used_with =>
      'تُستخدم شهادات العميل فقط مع العناوين التي تبدأ بـ https://.';

  @override
  String get ng_remove => 'إزالة';

  @override
  String get ng_certificate_password => 'كلمة مرور الشهادة';

  @override
  String get ng_importing => 'جارٍ الاستيراد…';

  @override
  String get ng_pick_certificate => 'اختيار شهادة';

  @override
  String get ng_pick_a_different_certificate => 'اختيار شهادة أخرى';

  @override
  String get ng_accepts_p12_pfx_or_pem_certificate =>
      'يُقبل ملف بصيغة .p12/.pfx أو ملفا شهادة ومفتاح بصيغة PEM. يبقى المفتاح في مساحة التخزين الخاصة بالتطبيق.';

  @override
  String get ng_photos => 'الصور';

  @override
  String get ng_camera => 'الكاميرا';

  @override
  String get ng_files => 'الملفات';

  @override
  String ng_you_can_attach_up_to_files(Object count) {
    return 'الحد الأقصى لعدد الملفات التي يمكنك إرفاقها هو $count.';
  }

  @override
  String ng_couldn_t_read(Object name) {
    return 'تعذّرت قراءة $name.';
  }

  @override
  String ng_couldn_t_prepare_that_file(Object error) {
    return 'تعذّر تجهيز الملف: $error';
  }

  @override
  String get ng_hermes_is_still_working => 'لا يزال Hermes يعمل';

  @override
  String get ng_steer => 'توجيه';

  @override
  String get ng_adds_this_to_the_running_turn =>
      'يضيف هذه الرسالة إلى الطلب الجاري عند خطوته التالية';

  @override
  String get ng_queue => 'إضافة إلى قائمة الانتظار';

  @override
  String get ng_sends_it_when_the_turn_finishes =>
      'يرسل الرسالة بعد اكتمال معالجة الطلب الجاري';

  @override
  String get ng_stop_and_send => 'إيقاف وإرسال';

  @override
  String get ng_stops_the_turn_then_sends_this =>
      'يوقف معالجة الطلب الجاري ثم يرسل هذه الرسالة';

  @override
  String ng_dictation_stopped(Object message) {
    return 'توقّف الإملاء: $message';
  }

  @override
  String get ng_speech_recognition_isn_t_available =>
      'التعرّف على الكلام غير متاح.';

  @override
  String get ng_working => 'جارٍ العمل';

  @override
  String get ng_ready => 'جاهز';

  @override
  String get ng_chats => 'المحادثات';

  @override
  String get ng_new_chat => 'محادثة جديدة';

  @override
  String get ng_usage => 'الاستخدام';

  @override
  String get ng_rename_chat => 'إعادة تسمية المحادثة';

  @override
  String ng_couldn_t_rename(Object error) {
    return 'تعذّرت إعادة التسمية: $error';
  }

  @override
  String get ng_this_chat => 'هذه المحادثة';

  @override
  String get ng_input_tokens => 'رموز الإدخال';

  @override
  String get ng_output_tokens => 'رموز الإخراج';

  @override
  String get ng_reasoning_tokens => 'رموز الاستدلال';

  @override
  String get ng_cache_reads => 'عمليات القراءة من ذاكرة التخزين المؤقت';

  @override
  String get ng_api_calls => 'استدعاءات API';

  @override
  String get ng_cost => 'التكلفة';

  @override
  String get ng_context => 'السياق';

  @override
  String get ng_your_sign_in_expired => 'انتهت صلاحية جلسة دخولك.';

  @override
  String get ng_sign_in_2 => 'تسجيل الدخول';

  @override
  String get ng_retry => 'إعادة المحاولة';

  @override
  String get ng_project_home => 'الرئيسية';

  @override
  String get ng_choose_project => 'اختيار مشروع';

  @override
  String ng_project_cwd_fallback(String path) {
    return 'مجلد المشروع غير متاح، لذا تعمل هذه المحادثة في $path.';
  }

  @override
  String get ng_project_create_uncertain =>
      'ربما أنشأت البوابة هذه المحادثة، لكنها لم تؤكّد ذلك. تحقّق من «المحادثات» قبل بدء محادثة أخرى. لن يُعاد إرسال الطلب تلقائيًا.';

  @override
  String get ng_what_should_we_work_on => 'ما الذي تودّ أن نعمل عليه؟';

  @override
  String get ng_ask_hermes_anything_it_can_run =>
      'اسأل Hermes عمّا تشاء. يمكنه تشغيل الأدوات والتصفّح والعمل على ملفاتك الموجودة على الخادم.';

  @override
  String ng_working_2(Object frame) {
    return 'جارٍ العمل · $frame';
  }

  @override
  String get ng_default_model => 'النموذج الافتراضي';

  @override
  String get ng_listening => 'جارٍ الاستماع…';

  @override
  String get ng_steer_or_queue_a_message =>
      'أرسل توجيهًا أو أضف رسالة إلى قائمة الانتظار';

  @override
  String get ng_message_hermes => 'راسل Hermes';

  @override
  String get ng_attach => 'إرفاق';

  @override
  String get ng_stop_dictation => 'إيقاف الإملاء';

  @override
  String get ng_dictate => 'إملاء';

  @override
  String get ng_stop => 'إيقاف';

  @override
  String get ng_send => 'إرسال';

  @override
  String ng_slash_command_alias(String alias, String command) {
    return '$alias اسم بديل للأمر $command';
  }

  @override
  String get ng_slash_command_no_description => 'لا يوجد وصف متاح.';

  @override
  String get ng_slash_command_arguments_options =>
      'يقبل خيارًا واحدًا من قائمة محدّدة.';

  @override
  String get ng_slash_command_arguments_text => 'يقبل نصًا بعد الأمر.';

  @override
  String get ng_slash_command_arguments_mixed =>
      'يقبل خيارًا أو نصًا بعد الأمر.';

  @override
  String get ng_slash_command_sent_as_message =>
      'ترسل واجهة NextGen هذا النص إلى Hermes كرسالة عادية، ولا يُنفَّذ الأمر نفسه.';

  @override
  String get ng_slash_command_output => 'مخرجات الأمر';

  @override
  String get ng_slash_command_running => 'جارٍ تنفيذ الأمر…';

  @override
  String get ng_slash_command_done => 'تمّ.';

  @override
  String ng_slash_command_failed(Object error) {
    return 'تعذّر تنفيذ الأمر: $error';
  }

  @override
  String get ng_slash_command_refused =>
      'لا يستطيع Hermes تنفيذ هذا الأمر هنا.';

  @override
  String get ng_slash_command_delivery_unknown =>
      'أُرسل الأمر لكن لم يصل ردّ. قد يظلّ قيد التنفيذ على البوابة، لذا لم يُرسَل مجددًا واحتفظنا بمسودتك.';

  @override
  String get ng_slash_command_nothing_running => 'لا شيء قيد التنفيذ.';

  @override
  String get ng_steered => 'أُرسل التوجيه';

  @override
  String get ng_copied => 'نُسخ';

  @override
  String ng_not_sent(Object reason) {
    return 'لم يُرسَل: $reason';
  }

  @override
  String get ng_thinking => 'جارٍ التفكير…';

  @override
  String get ng_thought => 'التفكير';

  @override
  String ng_used(Object name) {
    return 'استخدم $name';
  }

  @override
  String ng_used_tools(Object count) {
    return 'عدد الأدوات المستخدمة: $count';
  }

  @override
  String get ng_copy => 'نسخ';

  @override
  String get ng_read_aloud => 'قراءة بصوت عالٍ';

  @override
  String get ng_the_gateway_connection_dropped_try_again =>
      'انقطع الاتصال بالبوابة. أعد المحاولة.';

  @override
  String get ng_allow_once => 'السماح مرة واحدة';

  @override
  String get ng_allow_until_sandbox_off => 'حتى إيقاف بيئة العزل';

  @override
  String get ng_folder_access => 'الوصول إلى المجلد';

  @override
  String get ng_folder_access_unspecified =>
      'لم تحدّد البوابة ما إذا كان الوصول للقراءة فقط أم للقراءة والكتابة.';

  @override
  String get ng_folder_read_only => 'للقراءة فقط';

  @override
  String get ng_folder_read_write => 'قراءة وكتابة';

  @override
  String get ng_website_access => 'الوصول إلى الموقع';

  @override
  String get ng_allow_for_this_chat => 'السماح لهذه المحادثة';

  @override
  String get ng_always_allow => 'السماح دائمًا';

  @override
  String get ng_deny => 'رفض';

  @override
  String get ng_your_answer => 'إجابتك';

  @override
  String get ng_or_type_an_answer => 'أو اكتب إجابة';

  @override
  String get ng_skip => 'تخطّي';

  @override
  String get ng_answer => 'إجابة';

  @override
  String get ng_cancel => 'إلغاء';

  @override
  String get ng_username_or_email => 'اسم المستخدم أو البريد الإلكتروني';

  @override
  String get ng_password => 'كلمة المرور';

  @override
  String get ng_not_now => 'ليس الآن';

  @override
  String get ng_save => 'حفظ';

  @override
  String get ng_enter_both_the_client_id_and =>
      'أدخل معرّف العميل (Client ID) وسرّ العميل (Client Secret) معًا، أو اترك الحقلين فارغين.';

  @override
  String get ng_enter_your_username_and_password =>
      'أدخل اسم المستخدم وكلمة المرور.';

  @override
  String ng_couldn_t_save_the_sign_in(Object error) {
    return 'تعذّر حفظ بيانات تسجيل الدخول: $error';
  }

  @override
  String get ng_wrong_username_or_password =>
      'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get ng_too_many_attempts_wait_a_moment =>
      'تجاوزت الحد المسموح به للمحاولات. انتظر قليلًا ثم أعد المحاولة.';

  @override
  String get ng_welcome_to_hermes => 'مرحبًا بك في Ares';

  @override
  String get ng_add_a_gateway => 'إضافة بوابة';

  @override
  String get ng_connect_to_your_hermes_agent_dashboard =>
      'اتصل بلوحة تحكم Hermes Agent. يكفي عنوان واحد وتسجيل الدخول مرة واحدة للوصول إلى محادثاتك وأدواتك وإعداداتك. لن يُرسل أي شيء حتى تسجّل الدخول.';

  @override
  String get ng_connect_to_another_hermes_agent_dashboard =>
      'اتصل بلوحة تحكم أخرى لـ Hermes Agent. ستبقى مسجّل الدخول إلى لوحات التحكم التي حفظتها.';

  @override
  String get ng_dashboard_address => 'عنوان لوحة التحكم';

  @override
  String get ng_testing => 'جارٍ الاختبار…';

  @override
  String get ng_test => 'اختبار';

  @override
  String get ng_where_your_hermes_dashboard_runs_lan =>
      'مكان تشغيل لوحة تحكم Hermes: عبر LAN أو Tailscale أو HTTPS.';

  @override
  String get ng_find_on_my_network => 'بحث في شبكتي';

  @override
  String get ng_which_address_do_i_use => 'أي عنوان أستخدم؟';

  @override
  String get ng_behind_cloudflare_access =>
      'هل يحمي Cloudflare Access هذا العنوان؟';

  @override
  String get ng_need_a_client_certificate => 'هل تحتاج إلى شهادة عميل؟';

  @override
  String get ng_this_address_isn_t_private_and =>
      'هذا العنوان ليس خاصًا ولا يستخدم https://، لذا ستنتقل كلمة مرورك ومحادثاتك عبر الإنترنت دون تشفير. استخدم https:// أو Tailscale أو شبكتك الخاصة بدلًا من ذلك.';

  @override
  String get ng_continue_to_sign_in => 'المتابعة لتسجيل الدخول';

  @override
  String get ng_use_the_classic_interface_instead =>
      'استخدام الواجهة التقليدية بدلًا من ذلك';

  @override
  String get ng_if_cloudflare_access_protects_this_address =>
      'إذا كان Cloudflare Access يحمي هذا العنوان، فأنشئ رمز خدمة في Cloudflare Zero Trust (Access، ثم Service credentials)، وأضف إلى تطبيق Access سياسة Service Auth لهذا الرمز.';

  @override
  String get ng_a_service_token_is_saved_for =>
      'يوجد رمز خدمة محفوظ لهذا العنوان';

  @override
  String get ng_forget => 'إزالة من المحفوظات';

  @override
  String get ng_client_id => 'معرّف العميل (Client ID)';

  @override
  String get ng_client_secret => 'سرّ العميل (Client Secret)';

  @override
  String get ng_stored_encrypted_on_this_phone_and =>
      'تُحفظ هذه البيانات مشفّرة على هذا الهاتف ولا تُرسَل إلا إلى هذا العنوان.';

  @override
  String get ng_hermes_is_reachable => 'يمكن الوصول إلى Hermes';

  @override
  String ng_hermes_is_reachable_2(Object version) {
    return 'يمكن الوصول إلى Hermes $version';
  }

  @override
  String get ng_sign_in_is_tested_next_then =>
      'الخطوة التالية هي اختبار تسجيل الدخول، ثم المحادثة';

  @override
  String get ng_agent_gateway => 'بوابة الوكيل';

  @override
  String get ng_running => 'قيد التشغيل';

  @override
  String get ng_stopped => 'متوقف';

  @override
  String get ng_username_password => 'اسم المستخدم وكلمة المرور';

  @override
  String get ng_browser => 'المتصفح';

  @override
  String get ng_in_the_browser_sso => 'في المتصفح (SSO)';

  @override
  String get ng_profiles => 'الملفات الشخصية';

  @override
  String get ng_this_dashboard_offers_neither_a_username =>
      'لا توفّر لوحة التحكم هذه مزوّدًا للمصادقة باسم المستخدم وكلمة المرور، ولا تتيح تسجيل الدخول عبر المتصفح. حدّث Hermes أو اضبط مزوّد المصادقة باسم المستخدم وكلمة المرور على الخادم.';

  @override
  String get ng_the_auth_gate_is_off_on =>
      'التحقق من الهوية معطّل في لوحة التحكم هذه. يمكن لأي شخص يصل إليها استخدام وكيلك.';

  @override
  String get ng_couldn_t_reach_the_dashboard => 'تعذّر الوصول إلى لوحة التحكم';

  @override
  String ng_check_the_address_and_port_9119(Object reason) {
    return '$reason\n\nتحقّق من العنوان والمنفذ (9119 افتراضيًا). إذا لم تكن لوحة التحكم قيد التشغيل بعد، فنفّذ هذا الأمر على الخادم:\nhermes dashboard --host 0.0.0.0';
  }

  @override
  String get ng_that_isn_t_a_hermes_dashboard => 'هذه ليست لوحة تحكم Hermes';

  @override
  String get ng_something_answered_but_not_a_hermes_2 =>
      'وصل ردّ، لكنه ليس من لوحة تحكم Hermes. استخدم عنوان لوحة التحكم، لا عنوان خادم API (المنفذ 8642).';

  @override
  String ng_something_answered_http_but_not_a_2(Object status) {
    return 'وصل ردّ (HTTP $status)، لكنه ليس من لوحة تحكم Hermes. استخدم عنوان لوحة التحكم، لا عنوان خادم API (المنفذ 8642).';
  }

  @override
  String get ng_cloudflare_access_stopped_the_request =>
      'أوقف Cloudflare Access الطلب';

  @override
  String ng_cloudflare_access_turned_down_the_service(Object status) {
    return 'رفض Cloudflare Access رمز الخدمة (HTTP $status). تحقّق من معرّف العميل (Client ID) وسرّه (Client Secret) ومن سياسة Service Auth.';
  }

  @override
  String get ng_add_a_cloudflare_access_service_token_2 =>
      'أضف رمز خدمة Cloudflare Access أدناه، ثم أعد الاختبار.';

  @override
  String get ng_a_client_certificate_is_needed => 'يلزم تقديم شهادة عميل';

  @override
  String get ng_this_server_asks_for_a_client =>
      'يطلب هذا الخادم شهادة عميل قبل أن يستجيب. اختر أدناه الشهادة التي منحك إياها، ثم أعد الاختبار.';

  @override
  String get ng_this_dashboard_doesn_t_ask_for =>
      'لا تطلب لوحة التحكم هذه تسجيل الدخول.';

  @override
  String ng_use_the_dashboard_username_and_password(Object address) {
    return 'استخدم اسم المستخدم وكلمة المرور المحدّدين للوحة التحكم على $address، أو سجّل الدخول عبر المتصفح.';
  }

  @override
  String ng_use_the_dashboard_username_and_password_2(Object address) {
    return 'استخدم اسم المستخدم وكلمة المرور المحدّدين للوحة التحكم على $address.';
  }

  @override
  String ng_sign_in_to_in_your_browser(Object address) {
    return 'سجّل الدخول إلى $address عبر المتصفح باستخدام الحساب الذي تستخدمه لوحة التحكم هناك.';
  }

  @override
  String ng_gateway(Object address) {
    return 'البوابة: $address';
  }

  @override
  String get ng_profile => 'الملف الشخصي';

  @override
  String get ng_server_default => 'الإعداد الافتراضي للخادم';

  @override
  String get ng_continue => 'متابعة';

  @override
  String get ng_username => 'اسم المستخدم';

  @override
  String get ng_signing_in => 'جارٍ تسجيل الدخول…';

  @override
  String get ng_waiting_for_the_browser => 'بانتظار المتصفح…';

  @override
  String get ng_sign_in_with_browser => 'تسجيل الدخول عبر المتصفح';

  @override
  String get ng_finish_signing_in_on_the_page =>
      'أكمل تسجيل الدخول في الصفحة التي فُتحت. ستعود تلقائيًا إلى Hermes عند الانتهاء.';

  @override
  String get ng_use_a_different_gateway => 'استخدام بوابة أخرى';

  @override
  String get ng_same_wi_fi_or_local_network =>
      'شبكة Wi-Fi نفسها أو الشبكة المحلية نفسها';

  @override
  String get ng_use_the_server_s_local_address =>
      'استخدم العنوان المحلي للخادم ومنفذه، مثل 192.168.1.20:9119. شغّل لوحة التحكم باستخدام --host 0.0.0.0 لتتمكن الأجهزة الأخرى من الوصول إليها.';

  @override
  String get ng_tailscale => 'Tailscale';

  @override
  String get ng_turn_on_tailscale_on_this_phone =>
      'شغّل Tailscale على هذا الهاتف واستخدم عنوان الخادم على Tailscale، مثل 100.64.0.1:9119، أو اسمه المنتهي بـ .ts.net. يعمل هذا الاتصال خارج المنزل أيضًا.';

  @override
  String get ng_use_your_https_address_when_the =>
      'استخدم عنوان https:// عندما تكون لوحة التحكم خلف وكيل مزوّد بشهادة. يجب أن يسمح الوكيل أيضًا بتمرير طلبات ترقية الاتصال إلى WebSocket على المسار /api/ws.';

  @override
  String get ng_start_the_dashboard_on_the_server =>
      'شغّل لوحة التحكم على الخادم:';

  @override
  String get ng_enter_a_port_from_1_to => 'أدخل رقم منفذ من 1 إلى 65535.';

  @override
  String get ng_looks_for_hermes_dashboards_on_port =>
      'يبحث عن لوحات تحكم Hermes على المنفذ 9119 في شبكة Wi-Fi هذه، ويفحص أيضًا أجهزة الكمبيوتر التي حفظتها سابقًا.';

  @override
  String ng_looks_for_hermes_dashboards_on_ports(Object port) {
    return 'يبحث عن لوحات تحكم Hermes على المنفذين 9119 و$port في شبكة Wi-Fi هذه، ويتحقق أيضًا من أجهزة الكمبيوتر التي حفظتها سابقًا.';
  }

  @override
  String get ng_other_port_optional => 'منفذ آخر (اختياري)';

  @override
  String get ng_no_dashboards_answered_start_one_with =>
      'لم تستجب أي لوحة تحكم. شغّل إحداها بالأمر hermes dashboard --host 0.0.0.0، أو أدخل عنوانها.';

  @override
  String get ng_using_tailscale_or_a_vpn_those =>
      'هل تستخدم Tailscale أو شبكة VPN؟ لا يمكن البحث في هذه الشبكات. أدخل بدلًا من ذلك عنوان جهاز الكمبيوتر الذي يبدأ بـ 100.x أو اسمه المنتهي بـ .ts.net.';

  @override
  String get ng_search_again => 'البحث مجددًا';

  @override
  String get ng_insights => 'إحصاءات الاستخدام';

  @override
  String get ng_couldn_t_load_insights => 'تعذّر تحميل إحصاءات الاستخدام';

  @override
  String get ng_sessions => 'الجلسات';

  @override
  String get ng_tokens => 'الرموز النصية';

  @override
  String get ng_est_cost => 'التكلفة التقديرية';

  @override
  String get ng_daily_tokens => 'استهلاك الرموز اليومي';

  @override
  String get ng_models => 'النماذج';

  @override
  String get ng_tools => 'الأدوات';

  @override
  String get ng_hermes_is_waiting_for_you => 'ينتظر Hermes ردّك.';

  @override
  String get ng_hermes_replied => 'ردّ Hermes';

  @override
  String get ng_the_turn_finished => 'انتهت الجولة.';

  @override
  String get ng_off => 'متوقف';

  @override
  String get ng_minimal => 'أدنى مستوى';

  @override
  String get ng_low => 'منخفض';

  @override
  String get ng_medium => 'متوسط';

  @override
  String get ng_high => 'مرتفع';

  @override
  String get ng_extra_high => 'مرتفع جدًا';

  @override
  String get ng_max => 'أقصى مستوى';

  @override
  String get ng_ultra => 'فائق';

  @override
  String get ng_default => 'افتراضي';

  @override
  String ng_couldn_t_switch_model(Object error) {
    return 'تعذّر تبديل النموذج: $error';
  }

  @override
  String get ng_model => 'النموذج';

  @override
  String get ng_thinking_2 => 'التفكير';

  @override
  String get ng_search_models => 'البحث عن نموذج';

  @override
  String get ng_no_models_match => 'لا توجد نماذج تطابق عوامل التصفية هذه.';

  @override
  String get privacy_policy => 'سياسة الخصوصية';

  @override
  String get report_ai_output => 'الإبلاغ عن محتوى أنشأه الذكاء الاصطناعي';

  @override
  String ng_couldn_t_load_models(Object error) {
    return 'تعذّر تحميل النماذج: $error';
  }

  @override
  String get ng_no_providers_are_set_up_on =>
      'لم يُضبط أي مزوّد على هذه البوابة بعد.';

  @override
  String get ng_starred => 'المميّزة بنجمة';

  @override
  String get ng_recent => 'الأخيرة';

  @override
  String get ng_more => 'المزيد';

  @override
  String get ng_archived_chats => 'المحادثات المؤرشفة';

  @override
  String get ng_projects => 'المشاريع';

  @override
  String get ng_chats_grouped_by_project_and_workspace =>
      'المحادثات مرتبة حسب المشروع ومساحة العمل';

  @override
  String get ng_agent => 'الوكيل';

  @override
  String get ng_memory => 'الذاكرة';

  @override
  String get ng_what_hermes_remembers_about_you => 'ما يتذكّره Hermes عنك';

  @override
  String get ng_skills_library => 'مكتبة المهارات';

  @override
  String get ng_browse_and_read_installed_skills =>
      'تصفّح المهارات المثبّتة واقرأها';

  @override
  String get ng_cron_editor => 'محرّر Cron';

  @override
  String get ng_edit_schedules_prompts_and_delivery =>
      'تعديل مواعيد التشغيل والتعليمات ووجهات الإرسال';

  @override
  String get ng_config_file => 'ملف الإعدادات';

  @override
  String get ng_edit_config_yaml_on_the_gateway =>
      'تعديل ملف config.yaml على البوابة';

  @override
  String get ng_models_and_providers => 'النماذج والمزوّدون';

  @override
  String get ng_model_management => 'إدارة النماذج';

  @override
  String get ng_default_fallback_and_auxiliary_models =>
      'النماذج الافتراضية والاحتياطية والمساعدة';

  @override
  String get ng_provider_sign_in => 'تسجيل الدخول إلى المزوّد';

  @override
  String get ng_connect_provider_accounts_with_oauth =>
      'ربط حسابات المزوّدين باستخدام OAuth';

  @override
  String get ng_nous_portal => 'Nous Portal';

  @override
  String get ng_subscription_credits_and_usage => 'الاشتراك والرصيد والاستخدام';

  @override
  String get ng_interface => 'الواجهة';

  @override
  String get ng_switch_to_the_classic_interface =>
      'التبديل إلى الواجهة الكلاسيكية';

  @override
  String get ng_turns_nextgen_off_you_can_turn =>
      'يُوقف واجهة NextGen. يمكنك تفعيلها مجددًا من الإعدادات.';

  @override
  String get ng_restored => 'تمت الاستعادة';

  @override
  String get ng_archived => 'تمت الأرشفة';

  @override
  String get ng_couldn_t_load_archived_chats =>
      'تعذّر تحميل المحادثات المؤرشفة';

  @override
  String get ng_nothing_archived => 'لا توجد محادثات مؤرشفة';

  @override
  String get ng_restore => 'استعادة';

  @override
  String get ng_saved_new_chats_use_it =>
      'حُفظ الإعداد. ستستخدمه المحادثات الجديدة.';

  @override
  String ng_couldn_t_save(Object error) {
    return 'تعذّر الحفظ: $error';
  }

  @override
  String get ng_saving => 'جارٍ الحفظ…';

  @override
  String ng_today(Object time) {
    return 'اليوم، $time';
  }

  @override
  String get ng_mon => 'الاثنين';

  @override
  String get ng_tue => 'الثلاثاء';

  @override
  String get ng_wed => 'الأربعاء';

  @override
  String get ng_thu => 'الخميس';

  @override
  String get ng_fri => 'الجمعة';

  @override
  String get ng_sat => 'السبت';

  @override
  String get ng_sun => 'الأحد';

  @override
  String get ng_scheduled => 'المهام المجدولة';

  @override
  String get ng_new_job => 'مهمة جديدة';

  @override
  String get ng_couldn_t_load_scheduled_jobs => 'تعذّر تحميل المهام المجدولة';

  @override
  String get ng_nothing_scheduled => 'لا توجد مهام مجدولة';

  @override
  String get ng_ask_hermes_to_do_something_on =>
      'اطلب من Hermes جدولة مهمة، أو أضف مهمة هنا.';

  @override
  String get ng_active => 'نشطة';

  @override
  String get ng_paused => 'متوقفة مؤقتًا';

  @override
  String ng_next(Object when) {
    return 'التشغيل التالي: $when';
  }

  @override
  String ng_last(Object when) {
    return 'آخر تشغيل: $when';
  }

  @override
  String ng_last_2(Object when, Object result) {
    return 'آخر تشغيل: $when · $result';
  }

  @override
  String ng_job(Object id) {
    return 'المهمة $id';
  }

  @override
  String get ng_delete => 'حذف';

  @override
  String get ng_delete_this_job => 'هل تريد حذف هذه المهمة؟';

  @override
  String get ng_it_stops_running_past_runs_stay =>
      'لن تُشغّل هذه المهمة مجددًا. تبقى نتائج التشغيل السابقة في محادثاتك.';

  @override
  String ng_next_run(Object when) {
    return 'التشغيل التالي: $when';
  }

  @override
  String ng_delivers_to(Object target) {
    return 'تُرسَل النتائج إلى $target';
  }

  @override
  String get ng_run_now => 'تشغيل الآن';

  @override
  String get ng_started => 'بدأ التشغيل';

  @override
  String get ng_pause => 'إيقاف مؤقت';

  @override
  String get ng_resume => 'استئناف';

  @override
  String get ng_resumed => 'استُؤنف التشغيل';

  @override
  String get ng_prompt => 'التعليمات';

  @override
  String get ng_runs => 'سجلّ التشغيل';

  @override
  String get ng_no_runs_yet => 'لم تُشغّل المهمة بعد.';

  @override
  String get ng_enter_a_schedule_and_a_prompt =>
      'حدّد موعد التشغيل وأدخل التعليمات.';

  @override
  String get ng_name_optional => 'الاسم (اختياري)';

  @override
  String get ng_schedule => 'جدول التشغيل';

  @override
  String get ng_every_1h_0_9_or_30m => 'every 1h، أو 0 9 * * *، أو 30m';

  @override
  String get ng_create => 'إنشاء';

  @override
  String get ng_unpin => 'إلغاء التثبيت';

  @override
  String get ng_pin => 'تثبيت';

  @override
  String get ng_rename => 'إعادة تسمية';

  @override
  String get ng_archive => 'أرشفة';

  @override
  String get ng_delete_this_chat => 'هل تريد حذف هذه المحادثة؟';

  @override
  String get ng_it_is_removed_from_the_gateway =>
      'ستُحذف المحادثة من البوابة ولن تظهر على أي جهاز.';

  @override
  String get ng_search_chats => 'البحث في المحادثات';

  @override
  String get ng_pinned => 'المحادثات المثبّتة';

  @override
  String get ng_no_chats_match => 'لا توجد محادثات تطابق بحثك.';

  @override
  String get ng_no_chats_yet => 'لا توجد محادثات بعد.';

  @override
  String get ng_nothing_is_running => 'لا شيء قيد التشغيل.';

  @override
  String get ng_nothing_is_waiting_on_you => 'لا شيء ينتظر تدخّلك.';

  @override
  String get ng_settings => 'الإعدادات';

  @override
  String get ng_all => 'الكل';

  @override
  String ng_needs_you(Object count) {
    return 'بانتظار تدخّلك · $count';
  }

  @override
  String get ng_needs_you_2 => 'بانتظار تدخّلك';

  @override
  String get ng_gateways => 'البوابات';

  @override
  String ng_classic_connection(Object address) {
    return '$address · اتصال كلاسيكي';
  }

  @override
  String get ng_gateway_2 => 'البوابة';

  @override
  String get ng_signed_in => 'تم تسجيل الدخول';

  @override
  String get ng_classic_connection_2 => 'اتصال كلاسيكي';

  @override
  String get ng_in_the_browser => 'في المتصفّح';

  @override
  String ng_in_the_browser_as(Object name) {
    return 'في المتصفّح باسم $name';
  }

  @override
  String get ng_not_required => 'غير مطلوب';

  @override
  String get ng_test_connection => 'اختبار الاتصال';

  @override
  String get ng_sign_in_again_2 => 'تسجيل الدخول مجددًا';

  @override
  String get ng_sign_out => 'تسجيل الخروج';

  @override
  String get ng_saved_gateways => 'البوابات المحفوظة';

  @override
  String get ng_in_use => 'قيد الاستخدام';

  @override
  String get ng_appearance => 'المظهر';

  @override
  String get ng_theme => 'السمة';

  @override
  String get ng_system => 'حسب النظام';

  @override
  String get ng_light => 'فاتحة';

  @override
  String get ng_dark => 'داكنة';

  @override
  String get ng_accent => 'لون التمييز';

  @override
  String get ng_pure_black => 'أسود خالص';

  @override
  String get ng_dark_theme_uses_true_black_oled =>
      'تستخدم السمة الداكنة الأسود الخالص لشاشات OLED';

  @override
  String get ng_glow => 'التوهّج';

  @override
  String get ng_soft_accent_light_behind_each_screen =>
      'توهّج خافت بلون التمييز خلف كل شاشة';

  @override
  String get ng_the_new_interface_turn_off_to =>
      'هذه هي الواجهة الجديدة. عطّلها للعودة إلى الواجهة الكلاسيكية. بواباتك ومحادثاتك متاحة في كلتا الواجهتين.';

  @override
  String get ng_more_settings => 'المزيد من الإعدادات';

  @override
  String get ng_voice_notifications_language_backups_and_the =>
      'الصوت والإشعارات واللغة والنُسخ الاحتياطية وإعدادات البوابة';

  @override
  String get ng_licences => 'التراخيص';

  @override
  String ng_sign_out_of(Object name) {
    return 'هل تريد تسجيل الخروج من $name؟';
  }

  @override
  String get ng_this_gateway_and_its_saved_sign =>
      'ستُزال هذه البوابة وبيانات الدخول المحفوظة لها من هذا الهاتف في كلتا الواجهتين. ستبقى محادثاتك على البوابة.';

  @override
  String get ng_password_or_browser => 'كلمة المرور أو المتصفّح';

  @override
  String get ng_unsupported => 'غير مدعوم';

  @override
  String get ng_background_task_finished =>
      'انتهت المهمة التي كانت تعمل في الخلفية';

  @override
  String get ng_background_process_finished =>
      'انتهت العملية التي كانت تعمل في الخلفية';

  @override
  String get ng_system_message => 'رسالة من النظام';

  @override
  String get ng_summary => 'الملخّص';

  @override
  String get classic_interface_only => 'للواجهة الكلاسيكية فقط';

  @override
  String get classic_only_settings_hint =>
      'الأقسام التي تحمل علامة «للواجهة الكلاسيكية فقط» تغيّر مظهر الواجهة الكلاسيكية ومحادثاتها، ولا تؤثّر في NextGen. يمكنك تخصيص مظهر NextGen من إعداداتها.';

  @override
  String get attachment_preview_too_large =>
      'الملف أكبر من أن يُعايَن هنا. اختر «حفظ» أو «مشاركة» لتنزيله على هاتفك (حتى 1 GB).';

  @override
  String get attachment_over_phone_limit =>
      'يتجاوز حجم الملف حدّ التنزيل البالغ 1 GB. افتح لوحة التحكم لتنزيله.';

  @override
  String attachment_downloading_percent(int percent) {
    return 'جارٍ التنزيل… $percent%';
  }

  @override
  String attachment_downloading_mb(int megabytes) {
    return 'جارٍ التنزيل… $megabytes MB';
  }

  @override
  String ng_attachment_too_large_for_gateway(String name) {
    return 'يتجاوز حجم $name حدّ هذه البوابة البالغ 12 MB. حدّث Hermes لإرسال ملفات يصل حجمها إلى 100 MB.';
  }

  @override
  String ng_couldn_t_upload(String name) {
    return 'تعذّر رفع $name.';
  }

  @override
  String ng_uploading_percent(int percent) {
    return 'جارٍ الرفع… $percent%';
  }

  @override
  String get ng_show_tasks => 'إظهار المهام';

  @override
  String get ng_hide_tasks => 'إخفاء المهام';

  @override
  String get ng_goal => 'الهدف';

  @override
  String get ng_loop => 'حلقة التكرار';

  @override
  String get ng_heartbeat => 'النبض الدوري';

  @override
  String get ng_goal_working => 'العمل جارٍ';

  @override
  String get ng_goal_waiting => 'قيد الانتظار';

  @override
  String get ng_goal_blocked => 'متعذّر التقدّم';

  @override
  String get ng_goal_done => 'مكتمل';

  @override
  String ng_goal_turns_of(int used, int max) {
    return 'الجولات: $used من $max';
  }

  @override
  String ng_goal_turn(int used) {
    return 'الجولة $used';
  }

  @override
  String get ng_loop_held => 'معلّقة بانتظار الهدف';

  @override
  String get ng_loop_finished => 'انتهت';

  @override
  String get ng_loop_running => 'قيد التشغيل';

  @override
  String ng_loop_runs_of(int fired, int times) {
    return 'مرّات التشغيل: $fired من $times';
  }

  @override
  String ng_loop_runs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد مرّات التشغيل: $count',
      one: 'تشغيل واحد',
    );
    return '$_temp0';
  }

  @override
  String ng_loop_next(String time) {
    return 'الموعد التالي: $time';
  }

  @override
  String get ng_loop_due_now => 'حان موعد التشغيل';

  @override
  String ng_every_seconds(int seconds) {
    return 'كل $seconds s';
  }

  @override
  String ng_every_minutes(int minutes) {
    return 'كل $minutes min';
  }

  @override
  String ng_every_hours(int hours) {
    return 'كل $hours h';
  }

  @override
  String ng_every_hours_minutes(int hours, int minutes) {
    return 'كل $hours h و$minutes min';
  }

  @override
  String ng_heartbeat_fired(int count) {
    return 'عدد النبضات: $count';
  }

  @override
  String ng_heartbeat_last_fired(String time) {
    return 'آخر نبضة: $time';
  }

  @override
  String ng_wait_until(String time) {
    return 'بانتظار حلول $time';
  }

  @override
  String get ng_wait_resume => 'بانتظار الاستئناف';

  @override
  String get ng_wait_other_chat => 'بانتظار محادثة أخرى';

  @override
  String ng_wait_process(String pid) {
    return 'بانتظار العملية $pid';
  }

  @override
  String get ng_control_open => 'فتح لوحة الهدف والأتمتة';

  @override
  String get ng_control_title => 'الهدف والأتمتة';

  @override
  String get ng_control_subtitle =>
      'الهدف الذي تسعى إليه هذه المحادثة والمهام التي تعمل تلقائيًا.';

  @override
  String get ng_contract_outcome => 'النتيجة المطلوبة';

  @override
  String get ng_contract_verification => 'التحقّق';

  @override
  String get ng_contract_constraints => 'القيود';

  @override
  String get ng_contract_boundaries => 'الحدود';

  @override
  String get ng_contract_stop_when => 'شروط التوقّف';

  @override
  String get ng_subgoals => 'الأهداف الفرعية';

  @override
  String get ng_subgoal_add_placeholder => 'أضف هدفًا فرعيًا';

  @override
  String get ng_add => 'إضافة';

  @override
  String get ng_subgoal_remove => 'إزالة الهدف الفرعي';

  @override
  String get ng_goal_checks => 'الفحوصات';

  @override
  String get ng_gate_not_run => 'لم يُنفّذ بعد';

  @override
  String ng_gate_attempts(int attempts, int tries) {
    return 'المحاولات: $attempts من $tries';
  }

  @override
  String ng_gate_exit(int code) {
    return 'رمز الخروج: $code';
  }

  @override
  String get ng_resume_now => 'استئناف الآن';

  @override
  String get ng_goal_clear => 'مسح الهدف';

  @override
  String get ng_goal_clear_title => 'هل تريد مسح هذا الهدف؟';

  @override
  String get ng_goal_clear_message =>
      'سيتوقّف الوكيل عن العمل على هذا الهدف، وستُحذف أهدافه الفرعية وفحوصاته أيضًا.';

  @override
  String get ng_subgoal_remove_title => 'هل تريد إزالة هذا الهدف الفرعي؟';

  @override
  String ng_subgoal_remove_message(String text) {
    return 'لن يعود «$text» جزءًا من الهدف.';
  }

  @override
  String get ng_subgoals_clear_title => 'هل تريد مسح كل الأهداف الفرعية؟';

  @override
  String get ng_subgoals_clear_message =>
      'سيبقى عنوان الهدف، لكن ستُحذف كل أهدافه الفرعية.';

  @override
  String get ng_clear_all => 'مسح الكل';

  @override
  String get ng_clear => 'مسح';

  @override
  String get ng_dismiss => 'إغلاق';

  @override
  String get ng_loop_stop_title => 'هل تريد إيقاف حلقة التكرار هذه؟';

  @override
  String get ng_heartbeat_clear_title => 'هل تريد مسح هذا النبض الدوري؟';

  @override
  String get ng_wont_fire_again => 'لن يتكرّر التشغيل.';

  @override
  String get ng_loop_self_paced => 'بوتيرة تلقائية';

  @override
  String ng_loop_until(String condition) {
    return 'حتى يتحقّق الشرط: $condition';
  }

  @override
  String get ng_loop_waits_for_goal =>
      'تنتظر الحلقة ما دام العمل على الهدف جاريًا.';

  @override
  String get ng_loop_awaiting_reply => 'بانتظار ردّ الوكيل.';

  @override
  String ng_loop_stopped_reason(String reason) {
    return 'توقّفت: $reason';
  }

  @override
  String get ng_hide_subagents => 'إخفاء الوكلاء الفرعيين';

  @override
  String get ng_show_subagents => 'إظهار الوكلاء الفرعيين';

  @override
  String get ng_subagent => 'وكيل فرعي';

  @override
  String get ng_subagent_queued => 'في قائمة الانتظار';

  @override
  String get ng_subagent_starting => 'جارٍ البدء…';

  @override
  String get ng_subagent_running => 'قيد التشغيل';

  @override
  String get ng_subagent_done => 'أنهى عمله';

  @override
  String get ng_subagent_failed => 'فشل';

  @override
  String get ng_subagent_stopped => 'متوقّف';

  @override
  String get ng_subagent_stop => 'إيقاف الوكيل الفرعي';

  @override
  String ng_subagent_tools(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد الأدوات: $count',
      one: 'أداة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get ng_mark_as_read => 'وضع علامة «مقروءة»';

  @override
  String get ng_mark_as_unread => 'وضع علامة «غير مقروءة»';

  @override
  String ng_chats_unread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'المحادثات، عدد المحادثات غير المقروءة: $count',
      one: 'المحادثات، محادثة واحدة غير مقروءة',
    );
    return '$_temp0';
  }

  @override
  String get ng_unread_finished => 'انتهى التشغيل، وهناك ردّ غير مقروء';

  @override
  String get ng_unread_updates => 'التشغيل جارٍ، وهناك تحديثات غير مقروءة';

  @override
  String get ng_notifications => 'الإشعارات';

  @override
  String get ng_notifications_hint =>
      'الردود والطلبات أثناء عمل Ares في الخلفية';

  @override
  String get ng_notify_replies => 'الردود';

  @override
  String get ng_notify_replies_hint =>
      'عند اكتمال جولة أو فشلها في المحادثة المفتوحة';

  @override
  String get ng_notify_requests => 'طلبات الموافقة والأسئلة';

  @override
  String get ng_notify_requests_hint =>
      'تنبيه عندما ينتظر الوكيل تدخّلك، مع خياري «السماح مرة واحدة» و«رفض»';

  @override
  String get ng_keep_running => 'إبقاء الاتصال مفتوحًا أثناء إعداد الردّ';

  @override
  String get ng_keep_running_hint =>
      'يبقى الاتصال مفتوحًا في الخلفية حتى يكتمل الردّ، ويظهر إشعار صامت خلال ذلك';

  @override
  String get ng_battery_settings => 'تحسين استهلاك البطارية';

  @override
  String get ng_battery_settings_hint =>
      'اسمح بتشغيل Ares في الخلفية لتصلك الإشعارات في وقتها';

  @override
  String get ng_send_test_notification => 'إرسال إشعار تجريبي';

  @override
  String get ng_test_notification_title => 'إشعارات Ares تعمل';

  @override
  String get ng_test_notification_body => 'ستظهر الردود والطلبات بهذا الشكل.';

  @override
  String get ng_test_notification_sent => 'أُرسل الإشعار التجريبي';

  @override
  String get ng_notifications_blocked =>
      'الإشعارات محظورة. اسمح بها في إعدادات Android.';

  @override
  String get ng_notifications_off_hint =>
      'الإشعارات معطّلة، لذا لن يرسل Ares أي إشعار أثناء عمله في الخلفية.';

  @override
  String get ng_insights_building =>
      'جارٍ إعداد التقرير. إذا كانت الفترة طويلة، فقد يستغرق إعداده دقيقة عند طلبه أول مرة.';

  @override
  String get ng_insights_timed_out =>
      'استغرقت البوابة وقتًا أطول من اللازم لإعداد التقرير. حاول مجددًا أو اختر فترة أقصر.';

  @override
  String get ng_dock_goal_active => 'الهدف نشط';

  @override
  String get ng_dock_goal_paused => 'الهدف متوقّف مؤقتًا';

  @override
  String get ng_dock_goal_waiting => 'الهدف قيد الانتظار';

  @override
  String get ng_dock_goal_blocked => 'تعذّر التقدّم نحو الهدف';

  @override
  String get ng_dock_goal_done => 'اكتمل الهدف';

  @override
  String ng_dock_turn_of(int used, int max) {
    return 'الجولة $used/$max';
  }

  @override
  String ng_dock_turn(int used) {
    return 'الجولة $used';
  }

  @override
  String ng_dock_subagents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد الوكلاء الفرعيين: $count',
      one: 'وكيل فرعي واحد',
    );
    return '$_temp0';
  }

  @override
  String ng_dock_subagents_done(int count) {
    return 'عدد من أنهوا العمل: $count';
  }

  @override
  String ng_dock_tasks(int done, int total) {
    return 'المهام: $done/$total';
  }

  @override
  String ng_dock_previous_tasks(int done, int total) {
    return 'المهام السابقة: $done/$total';
  }

  @override
  String get ng_dock_manage => 'إدارة';

  @override
  String get ng_recent_notifications => 'الإشعارات الأخيرة';

  @override
  String get ng_recent_notifications_hint =>
      'الإشعارات التي حاول Ares إرسالها وما إذا كان Android قد عرضها';

  @override
  String get ng_recent_notifications_empty =>
      'لا توجد إشعارات بعد. ستظهر المحاولات هنا عند وجود ردّ أو سؤال أو إخفاق يستدعي إشعارك.';

  @override
  String get ng_notify_permission_granted => 'مُنح الإذن';

  @override
  String get ng_notify_permission_denied => 'رُفض الإذن';

  @override
  String get ng_notify_master_on => 'الإشعارات مفعّلة';

  @override
  String get ng_notify_master_off => 'الإشعارات معطّلة';

  @override
  String get ng_models_default => 'النموذج الافتراضي';

  @override
  String get ng_models_change => 'تغيير';

  @override
  String get ng_models_custom_endpoint =>
      'يعمل عبر نقطة اتصال مخصّصة. يمكنك تغييرها على البوابة.';

  @override
  String get ng_models_context_window => 'نافذة السياق';

  @override
  String ng_models_token_count(String count) {
    return 'عدد الرموز النصية: $count';
  }

  @override
  String ng_models_context_override(String count) {
    return 'ضُبطت نافذة السياق على البوابة. عدد الرموز المكتشف تلقائيًا: $count.';
  }

  @override
  String get ng_models_max_output => 'الحدّ الأقصى للمخرجات';

  @override
  String get ng_models_input_price => 'سعر الإدخال';

  @override
  String get ng_models_output_price => 'سعر الإخراج';

  @override
  String get ng_models_cache_price => 'سعر المدخلات المخزّنة مؤقتًا';

  @override
  String ng_models_per_million(String price) {
    return '$price لكل مليون رمز نصي';
  }

  @override
  String ng_models_price_pair(String input, String output) {
    return '$input للإدخال · $output للإخراج لكل مليون رمز نصي';
  }

  @override
  String get ng_models_free => 'مجاني';

  @override
  String get ng_models_vision => 'الرؤية';

  @override
  String get ng_models_reasoning => 'الاستدلال';

  @override
  String get ng_models_fast => 'الوضع السريع';

  @override
  String get ng_models_in_use => 'قيد الاستخدام';

  @override
  String ng_models_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'عدد النماذج: $count',
      one: 'عدد النماذج: $count',
    );
    return '$_temp0';
  }

  @override
  String get ng_models_rate_limited => 'معدّل الطلبات مقيّد';

  @override
  String get ng_models_plan_locked => 'غير مشمول في خطتك';

  @override
  String get ng_models_unsaved => 'تغييرات غير محفوظة';

  @override
  String get ng_models_discard => 'تجاهل';

  @override
  String get ng_models_aux_hint =>
      'تستخدم المهام المساعدة النموذج الافتراضي ما لم تحدّد لها نموذجًا خاصًا.';

  @override
  String get ng_models_uses_default => 'يستخدم النموذج الافتراضي';

  @override
  String get ng_models_thinking_level => 'مستوى التفكير';

  @override
  String get ng_models_providers => 'المزوّدون';

  @override
  String get ng_models_saved => 'تم الحفظ';

  @override
  String get ng_aux_vision => 'الرؤية';

  @override
  String get ng_aux_vision_hint => 'يقرأ الصور ولقطات الشاشة';

  @override
  String get ng_aux_compression => 'الضغط';

  @override
  String get ng_aux_compression_hint =>
      'يختصر المحادثات الطويلة لتلائم نافذة السياق';

  @override
  String get ng_aux_approval => 'الموافقة';

  @override
  String get ng_aux_approval_hint =>
      'يقرّر ما إذا كان يمكن تنفيذ الأمر بأمان دون طلب موافقتك';

  @override
  String get ng_aux_mcp => 'MCP';

  @override
  String get ng_aux_mcp_hint => 'يختار أدوات MCP المناسبة للاستخدام';

  @override
  String get ng_aux_title_generation => 'عناوين المحادثات';

  @override
  String get ng_aux_title_generation_hint => 'يضع عناوين للمحادثات الجديدة';

  @override
  String get ng_aux_review => 'المراجعة';

  @override
  String get ng_aux_review_hint => 'يراجع العمل عند تشغيل الأمر /review';

  @override
  String get ng_aux_voice_chat => 'المحادثة الصوتية';

  @override
  String get ng_aux_voice_chat_hint => 'يردّ في وضع المحادثة الصوتية';

  @override
  String get ng_aux_triage_specifier => 'فرز المهام';

  @override
  String get ng_aux_triage_specifier_hint =>
      'يحوّل بطاقة Kanban من سطر واحد إلى مواصفات مفصّلة';

  @override
  String get ng_aux_kanban_decomposer => 'تقسيم مهام Kanban';

  @override
  String get ng_aux_kanban_decomposer_hint =>
      'يقسّم بطاقة Kanban إلى مهام أصغر';

  @override
  String get ng_aux_profile_describer => 'أوصاف الملفات الشخصية';

  @override
  String get ng_aux_profile_describer_hint => 'يكتب وصفًا موجزًا لكل ملف شخصي';

  @override
  String get ng_aux_curator => 'منسّق المهارات';

  @override
  String get ng_aux_curator_hint => 'يراجع كيفية استخدام المهارات';

  @override
  String get appearance_save_failed => 'تعذّر حفظ هذا التغيير.';

  @override
  String get appearance_keep_which_theme => 'أي سمة نُبقي؟';

  @override
  String get appearance_tour_back => 'رجوع';

  @override
  String get appearance_tour_finish => 'إنهاء';

  @override
  String get appearance_tour_next => 'التالي';

  @override
  String get appearance_tour_close => 'إغلاق الجولة';

  @override
  String get appearance_dismiss_tip => 'إخفاء التلميح';

  @override
  String get appearance_search_settings => 'البحث في الإعدادات';

  @override
  String get appearance_search_show => 'إظهار';

  @override
  String get appearance_no_matching_setting => 'لا يوجد إعداد مطابق.';

  @override
  String get appearance_replay_tour => 'إعادة الجولة';

  @override
  String get appearance_show_tips_again => 'أظهر التلميحات مجددًا';

  @override
  String get appearance_window_translucency_unavailable =>
      'شفافية النافذة غير متاحة على هذا الجهاز. لا يدعمها لينكس، وترسم إصدارات آبل وويندوز نافذة Flutter معتمة.';

  @override
  String get appearance_imported_themes => 'السمات المستوردة';

  @override
  String get appearance_import_theme_file => 'استيراد ملف سمة';

  @override
  String get appearance_remove_theme => 'حذف السمة';

  @override
  String get appearance_chat_font => 'خط الدردشة';

  @override
  String get appearance_terminal_font => 'خط الطرفية';

  @override
  String get appearance_font_platform => 'خط الجهاز';

  @override
  String get appearance_automatic => 'تلقائي';

  @override
  String get appearance_force_left_to_right => 'إجبار من اليسار';

  @override
  String get appearance_force_right_to_left => 'إجبار من اليمين';

  @override
  String get appearance_user_bubble_opacity => 'شفافية فقاعة رسائلك';

  @override
  String get appearance_inline_embeds => 'المحتوى المضمّن';

  @override
  String get appearance_inline_embeds_hint =>
      'تُحمَّل المعاينات الغنية من مواقع خارجية (YouTube وX و…). يعرض «اسأل» عنصرًا نائبًا حتى تسمح بكل واحدة؛ ويحمّلها «دائمًا» تلقائيًا؛ ويُبقي «إيقاف» الروابط عادية.';

  @override
  String get appearance_embeds_ask => 'اسأل';

  @override
  String get appearance_embeds_always => 'دائمًا';

  @override
  String get appearance_embeds_off => 'إيقاف';

  @override
  String appearance_embeds_reset(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إعادة تعيين الخدمات المسموح بها: $count',
      one: 'إعادة تعيين خدمة واحدة مسموح بها',
    );
    return '$_temp0';
  }

  @override
  String get appearance_embed_load => 'تحميل';

  @override
  String appearance_embed_always_allow(String service) {
    return 'السماح دائمًا بـ $service';
  }

  @override
  String get appearance_embed_loading => 'جارٍ تحميل المعاينة…';

  @override
  String appearance_embed_image_failed(String host) {
    return 'تعذّر تحميل الصورة من $host. اضغط لفتحها.';
  }

  @override
  String get appearance_embed_preview_unavailable => 'المعاينة غير متاحة';

  @override
  String get appearance_emoji_reactions => 'تفاعلات الإيموجي';

  @override
  String get appearance_celebration_hearts => 'قلوب الاحتفال';

  @override
  String get appearance_celebration_hearts_hint =>
      'يظهر قلب عندما يصل رد وأنت بعيد.';

  @override
  String get appearance_pop_out_companion => 'افتح الرفيق في نافذة';

  @override
  String get appearance_mosskip => 'موسكيب';

  @override
  String get appearance_emberbun => 'إمبربن';

  @override
  String get appearance_tideling => 'تايدلينغ';

  @override
  String get appearance_my_hatchling => 'رفيقي الصغير';

  @override
  String get appearance_at_rest => 'يستريح';

  @override
  String get appearance_working => 'يعمل';

  @override
  String get appearance_thinking => 'يفكّر';

  @override
  String get appearance_waiting_for_you => 'ينتظرك';

  @override
  String get appearance_reply_ready => 'الرد جاهز';

  @override
  String get appearance_turn_failed => 'تعذّر إكمال الدور';

  @override
  String get appearance_small => 'صغير';

  @override
  String get appearance_medium => 'متوسط';

  @override
  String get appearance_large => 'كبير';

  @override
  String get appearance_hello => 'مرحبًا!';

  @override
  String get appearance_unread_reply => 'رد غير مقروء';

  @override
  String get appearance_compose => 'كتابة رسالة';

  @override
  String get appearance_say_hello => 'إلقاء التحية';

  @override
  String get appearance_pet_image_failed =>
      'تعذّر فتح الصورة. اختر صورة PNG أو JPEG أصغر.';

  @override
  String get appearance_pet_companion => 'الرفيق الصغير';

  @override
  String get appearance_pet_companion_hint => 'أظهر رفيقًا أثناء الدردشة.';

  @override
  String get appearance_adopt_a_companion => 'تبنَّ رفيقًا';

  @override
  String get appearance_roam_when_idle => 'التجوّل أثناء الراحة';

  @override
  String get appearance_pet_size => 'حجم الرفيق';

  @override
  String get appearance_hatch_from_a_local_picture => 'فقس رفيق من صورة محلية';

  @override
  String get appearance_pet_image_limits =>
      'اختر صورة PNG أو JPEG (حتى ٤ ميبيبايت و٤٠٩٦ بكسل للضلع و٨ ميغابكسل). عاينها أولًا. يحفظ الفقس صورة ٢٤ × ٢٤ بكسل بدلًا من رفيقك المُفقس السابق.';

  @override
  String get appearance_choose_picture => 'اختيار صورة';

  @override
  String get appearance_hatchling_preview => 'معاينة الرفيق';

  @override
  String get appearance_hatch_and_adopt => 'فقس وتبنٍّ';

  @override
  String get appearance_discard_draft => 'تجاهل المسودة';

  @override
  String get appearance_forget_saved_hatchling => 'حذف الرفيق المُفقس المحفوظ';

  @override
  String get appearance_radio => 'الراديو';

  @override
  String appearance_radio_hint(String stations) {
    return 'يأتي البث مباشرةً من $stations، ولا يبدأ إلا عند الضغط على تشغيل. يبقى البحث عن المحطات على هذا الجهاز.';
  }

  @override
  String get appearance_radio_save_failed => 'تعذّر حفظ إعدادات الراديو.';

  @override
  String get appearance_choose_a_station => 'اختيار محطة';

  @override
  String get appearance_pause_radio => 'إيقاف الراديو مؤقتًا';

  @override
  String get appearance_play_radio => 'تشغيل الراديو';

  @override
  String get appearance_next_station => 'المحطة التالية';

  @override
  String get appearance_radio_trace_semantics =>
      'نشاط البث. مستويات الصوت غير متاحة، لذا يبقى الخط مستويًا.';

  @override
  String get appearance_radio_is_off => 'الراديو متوقف';

  @override
  String get appearance_paused => 'متوقف مؤقتًا';

  @override
  String get appearance_connecting => 'جارٍ الاتصال…';

  @override
  String get appearance_live => 'بث مباشر';

  @override
  String get appearance_stream_unavailable => 'البث غير متاح';

  @override
  String appearance_now_playing(String credit) {
    return 'يُبث الآن: $credit';
  }

  @override
  String get appearance_audio_only_waveform_unavailable =>
      'صوت فقط · شكل الموجة غير متاح';

  @override
  String get appearance_volume => 'مستوى الصوت';

  @override
  String get appearance_search_presets => 'البحث في المحطات المحفوظة مسبقًا';

  @override
  String get appearance_no_stations_found => 'لم يُعثر على محطات';

  @override
  String appearance_unpin_station(String station) {
    return 'إلغاء تثبيت المحطة: $station';
  }

  @override
  String appearance_pin_station(String station) {
    return 'تثبيت المحطة: $station';
  }

  @override
  String get appearance_radio_picker_metadata_notice =>
      'عندما تكون هذه القائمة مفتوحة، قد تُعرض معلومات المقطع من جهة البث مباشرةً أثناء التشغيل.';

  @override
  String get appearance_message_from_your_companion => 'رسالة من رفيقك';

  @override
  String get appearance_send_to_the_open_chat => 'أرسل إلى الدردشة المفتوحة';

  @override
  String get appearance_tour_theme_body =>
      'استورد سمة ألوان من ملف على هذا الجهاز، ثم اختر النسخة التي تريد إبقاءها.';

  @override
  String get appearance_tour_fonts_title => 'خطوط القراءة';

  @override
  String get appearance_tour_fonts_body =>
      'يستخدم نص الدردشة وشفرة الطرفية خطين منفصلين مدمجين مع آريس.';

  @override
  String get appearance_tour_direction_title => 'اتجاه النص';

  @override
  String get appearance_tour_direction_body =>
      'اتركه تلقائيًا، أو أجبر نص المحادثة من اليسار أو من اليمين.';

  @override
  String get appearance_tour_pet_title => 'الرفيق';

  @override
  String get appearance_tour_pet_body =>
      'يبقى الرفيق متوقفًا حتى تتبناه. النافذة المنبثقة تضيف مربع كتابة صغيرًا.';

  @override
  String get appearance_tour_radio_body =>
      'يبقى الراديو متوقفًا حتى تفعّله. زر التشغيل هو ما يفتح البث.';

  @override
  String get appearance_tip_theme =>
      'تحل السمات المستوردة محل لوحة الألوان المدمجة حتى تلغي الاختيار. تُحفظ الألوان فقط.';

  @override
  String get appearance_tip_pet =>
      'يحفظ الرفيق صورة صغيرة واحدة على هذا الجهاز. لا يرفع الصورة التي تفقس منها.';

  @override
  String get appearance_theme_import_failed =>
      'تعذّر استيراد هذه السمة. اختر سمة ألوان من VS Code محفوظة في ملف بامتداد vsix أو json أو jsonc.';

  @override
  String get render_widget_file_truncated =>
      'Only the start of this file was read, so the widget may be incomplete.';

  @override
  String get setup_beat_title => 'Setup';

  @override
  String setup_beat_use_name(String name) {
    return 'Use $name';
  }

  @override
  String get setup_beat_name_hint => 'What should Hermes call you?';

  @override
  String get setup_beat_on_computer =>
      'This step is done in Hermes on the computer it runs on. Continue keeps what is set up there.';

  @override
  String get setup_beat_not_waiting =>
      'This setup card is no longer waiting for an answer.';

  @override
  String get catalog_kind_plugin => 'Plugin';

  @override
  String get catalog_kind_skill => 'Skill';

  @override
  String get catalog_tier_official => 'Official';

  @override
  String get catalog_tier_verified => 'Verified';

  @override
  String get catalog_tier_community => 'Community';

  @override
  String get catalog_install => 'Install';

  @override
  String get catalog_waiting => 'Waiting for your choice';

  @override
  String get catalog_installed => 'Installed';

  @override
  String get catalog_installed_off => 'Installed, not turned on';

  @override
  String get catalog_skipped => 'Skipped';

  @override
  String get catalog_not_installed => 'Not installed';

  @override
  String catalog_target_profile(String profile) {
    return 'Installs into the $profile profile';
  }

  @override
  String catalog_source(String repo, String sha) {
    return '$repo at $sha';
  }

  @override
  String catalog_scan(String status, String summary) {
    return 'Security scan: $status. $summary';
  }

  @override
  String catalog_requires_hermes(String range) {
    return 'Needs Hermes $range';
  }

  @override
  String catalog_skill_ready(String name) {
    return 'Skill $name is ready to use';
  }

  @override
  String catalog_missing_env(String names) {
    return 'Still needs: $names';
  }

  @override
  String catalog_server_error(String name, String error) {
    return '$name did not connect: $error';
  }

  @override
  String get catalog_send_failed => 'Your choice was not sent. Try again.';

  @override
  String get attachment_video_speed => 'Playback speed';

  @override
  String get catalog_installing => 'Installing…';

  @override
  String get catalog_phase_downloading => 'Downloading…';

  @override
  String get catalog_phase_python_packages => 'Installing Python packages…';

  @override
  String get catalog_phase_loading_tools => 'Loading its tools…';

  @override
  String get setup_beat_send_failed => 'Your answer was not sent. Try again.';

  @override
  String catalog_tool_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tools',
      one: '1 tool',
    );
    return '$_temp0';
  }

  @override
  String get render_svg_not_drawn => 'لم تُرسَم صورة SVG هذه.';

  @override
  String get render_notes_directive => 'توجيه الملاحظات';

  @override
  String get render_maths_source => 'مصدر الرياضيات';

  @override
  String get render_inline_maths_source => 'مصدر الرياضيات المضمّنة';

  @override
  String get render_sequence_outline => 'مخطط التسلسل';

  @override
  String get render_diagram_outline => 'مخطط الرسم البياني';

  @override
  String render_revision_of(int index, int count) {
    return 'المراجعة $index من $count';
  }

  @override
  String get render_previous_revision => 'المراجعة السابقة';

  @override
  String get render_next_revision => 'المراجعة التالية';

  @override
  String get render_show_rendered => 'المعروض';

  @override
  String get render_show_source => 'المصدر';

  @override
  String render_copied_file(String name) {
    return 'تم نسخ $name';
  }

  @override
  String render_copy_file(String name) {
    return 'نسخ $name';
  }

  @override
  String get render_artifact_too_long =>
      'هذا المحتوى أطول من أن يُعرض كصفحة هنا.';

  @override
  String get render_active_content_removed =>
      'أُزيلت النصوص البرمجية والإطارات والعناوين الخارجية.';

  @override
  String render_widget_file(String file) {
    return 'الأداة $file';
  }

  @override
  String get render_widget_runs_as_text =>
      'تعمل كنص في هذه الدردشة. تُزال النصوص البرمجية والإطارات الخارجية.';

  @override
  String get render_load_widget => 'تحميل الأداة';

  @override
  String get render_not_html_widget => 'هذا الملف ليس أداة HTML.';

  @override
  String get render_widget_sent => 'أُرسل إلى هذه الدردشة';

  @override
  String get render_widget_not_sent => 'لم يُرسل إلى هذه الدردشة';

  @override
  String get render_widget_throttled => 'انتظر قليلًا قبل الإرسال مرة أخرى';

  @override
  String get render_widget_too_long => 'هذا الطلب أطول من أن يُرسل';

  @override
  String get render_widget_no_gesture => 'اضغط على عنصر تحكم في الأداة للإرسال';

  @override
  String get render_widget_invalid => 'تعذّر إرسال هذا الطلب';

  @override
  String get render_inspected_image => 'الصورة المفحوصة';

  @override
  String get render_contributions => 'المساهمات';

  @override
  String get render_contributions_intro =>
      'يمكن فقط للمساهمات المضمّنة في Ares أن تضيف إلى الرد. لا يمكن لنص الدردشة تسجيل مساهمة، والإذن يسري على هذا الاتصال فقط.';

  @override
  String render_grant_plugin(String name) {
    return 'منح $name';
  }

  @override
  String render_revoke_plugin(String name) {
    return 'إلغاء $name';
  }

  @override
  String render_plugin_slots(String directive) {
    return 'بطاقات الرد لـ ::$directive';
  }

  @override
  String get render_plugin_notes => 'الملاحظات';

  @override
  String get catalog_scan_passed => 'نجح';

  @override
  String get catalog_scan_warnings => 'وُجدت تحذيرات';

  @override
  String get catalog_scan_failed => 'فشل';

  @override
  String get deployment_token_label => 'رمز النشر (اختياري)';

  @override
  String get deployment_token_helper =>
      'لرموز جلسات Hermes Dashboard المرسلة بصفة X-Hermes-Session-Token. لا يُخزَّن كنص عادي في التفضيلات.';

  @override
  String get deployment_token_hint => 'رمز جلسة لوحة التحكم';

  @override
  String get custom_headers_label => 'ترويسات مخصصة (اختياري)';

  @override
  String get custom_headers_helper =>
      'واحدة في كل سطر، مثل X-Custom: value. تُرفض الترويسات المحظورة.';

  @override
  String get custom_headers_hint => 'مثال: X-Custom-Header: value';

  @override
  String get desktop_tray_open => 'فتح Ares';

  @override
  String get desktop_tray_new_chat => 'دردشة جديدة';

  @override
  String get desktop_tray_quick_entry => 'إدخال سريع…';

  @override
  String get desktop_tray_pause_notifications => 'إيقاف الإشعارات مؤقتًا';

  @override
  String get desktop_tray_quit => 'إنهاء Ares';

  @override
  String get desktop_integration_title => 'التكامل مع سطح المكتب';

  @override
  String get desktop_tray_setting =>
      'إظهار Ares في علبة النظام أو شريط القوائم';

  @override
  String get desktop_tray_setting_help =>
      'افتح Ares أو ابدأ دردشة أو افتح الإدخال السريع أو أوقف الإشعارات مؤقتًا أو أنهِ التطبيق من الأيقونة.';

  @override
  String get desktop_close_to_tray_setting =>
      'استمر في العمل في علبة النظام عند إغلاق النافذة';

  @override
  String get desktop_tray_unsupported =>
      'لا يوفّر سطح المكتب هذا علبة نظام يمكن لـ Ares استخدامها.';

  @override
  String get quick_entry_title => 'إدخال سريع';

  @override
  String get quick_entry_hint => 'اكتب طلبًا لـ Ares…';

  @override
  String get quick_entry_submit => 'ضعه في مربع الكتابة';

  @override
  String get quick_entry_never_sends =>
      'يضع Enter النص في مربع كتابة الدردشة. لا يُرسَل شيء حتى تضغط إرسال.';

  @override
  String get quick_entry_unavailable =>
      'تعذّر فتح الإدخال السريع. حاول مرة أخرى.';

  @override
  String get desktop_hotkey_setting => 'اختصار الإدخال السريع';

  @override
  String desktop_hotkey_help(String shortcut) {
    return 'اضغط $shortcut في أي مكان لفتح الإدخال السريع.';
  }

  @override
  String desktop_hotkey_conflict(String shortcut) {
    return 'يستخدم تطبيق آخر $shortcut بالفعل. اختر اختصارًا مختلفًا.';
  }

  @override
  String get desktop_hotkey_unsupported =>
      'لا يسمح سطح المكتب هذا للتطبيقات بتسجيل اختصار عام (مثل Wayland).';

  @override
  String get desktop_hotkey_no_modifier => 'أضف Cmd أو Ctrl أو Alt.';

  @override
  String get desktop_hotkey_super_key => 'مفتاح Windows أو Super محجوز للنظام.';

  @override
  String get desktop_hotkey_reserved => 'يستخدم النظام هذا الاختصار بالفعل.';

  @override
  String desktop_hotkey_in_app(String action) {
    return 'يستخدم Ares هذا الاختصار بالفعل لـ $action.';
  }

  @override
  String get desktop_hotkey_change => 'تغيير';

  @override
  String get desktop_hotkey_reset => 'استخدام الافتراضي';

  @override
  String get capture_screen_action => 'التقاط الشاشة';

  @override
  String get capture_screen_help =>
      'يضيف لقطة شاشة إلى الرسالة كمسودة. لا يُرسَل شيء حتى تضغط إرسال.';

  @override
  String get capture_screen_unavailable =>
      'التقاط الشاشة غير متاح على سطح المكتب هذا.';

  @override
  String get capture_screen_failed => 'تعذّر التقاط الشاشة. حاول مرة أخرى.';

  @override
  String get capture_permission_title => 'السماح بتسجيل الشاشة';

  @override
  String get capture_permission_body =>
      'يحتاج Ares إلى إذن تسجيل الشاشة لالتقاط نافذة. فعّل Ares في إعدادات النظام > الخصوصية والأمن > تسجيل الشاشة، ثم حاول مرة أخرى.';

  @override
  String get capture_open_settings => 'فتح إعدادات النظام';

  @override
  String get keep_awake_title => 'إبقاء الحاسوب مستيقظًا';

  @override
  String get keep_awake_title_mobile => 'إبقاء الشاشة قيد التشغيل';

  @override
  String get keep_awake_mode_off => 'إيقاف';

  @override
  String get keep_awake_mode_while_working => 'أثناء العمل';

  @override
  String get keep_awake_mode_always => 'دائمًا';

  @override
  String get keep_awake_off_help => 'لا تمنع سكون النظام أبدًا (الافتراضي).';

  @override
  String get keep_awake_while_working_help =>
      'منع السكون بسبب الخمول فقط أثناء تشغيل دور الوكيل.';

  @override
  String get keep_awake_always_help =>
      'منع السكون بسبب الخمول ما دام Ares مفتوحًا على هذا الجهاز.';

  @override
  String get keep_awake_off_help_mobile =>
      'دع الشاشة تنطفئ كالمعتاد (الافتراضي).';

  @override
  String get keep_awake_while_working_help_mobile =>
      'إبقاء الشاشة قيد التشغيل أثناء تشغيل دور الوكيل وما دام Ares مفتوحًا.';

  @override
  String get keep_awake_always_help_mobile =>
      'إبقاء الشاشة قيد التشغيل ما دام Ares مفتوحًا.';

  @override
  String get ng_token_gateway_has_no_sign_in =>
      'لا تحتوي هذه البوابة على تسجيل دخول، لذا لا يمكنها التحقق من رمز النشر. فعّل مصادقة لوحة التحكم على المضيف (أو حدّث Hermes)، ثم حاول مرة أخرى.';

  @override
  String get palette_open => 'لوحة أوامر التطبيق';

  @override
  String get palette_no_matches => 'لا توجد إجراءات مطابقة';

  @override
  String get palette_filter_hint => 'اكتب لتصفية الإجراءات…';

  @override
  String get palette_keys_move => '↑↓ للتنقل';

  @override
  String get palette_keys_run => 'Enter للتشغيل';

  @override
  String get palette_keys_close => 'Esc للإغلاق';

  @override
  String get palette_search_sessions => 'البحث في الجلسات';

  @override
  String get palette_scheduled_crons => 'المجدولة / Cron';

  @override
  String get palette_capabilities_skills => 'القدرات والمهارات';

  @override
  String get palette_insights_usage => 'الرؤى والاستخدام';

  @override
  String get palette_more_projects => 'المزيد والمشاريع';

  @override
  String get deeplink_chat_not_found =>
      'لم يُعثر على المحادثة في القائمة. ربما لم تُحمَّل بعد.';

  @override
  String get keyboard_shortcuts_title => 'اختصارات لوحة المفاتيح';

  @override
  String get shortcuts_reset_all => 'إعادة تعيين الكل';

  @override
  String get shortcuts_reset_to_default => 'استعادة الافتراضي';

  @override
  String get shortcut_action_command_palette => 'لوحة الأوامر';

  @override
  String get shortcut_action_new_chat => 'محادثة جديدة';

  @override
  String get shortcut_action_search => 'بحث';

  @override
  String get shortcut_action_settings => 'الإعدادات';

  @override
  String shortcut_action_go_to_tab(int number) {
    return 'الانتقال إلى علامة التبويب $number';
  }

  @override
  String shortcuts_conflict(String first, String second, String chord) {
    return 'تعارض: يستخدم «$first» و«$second» كلاهما $chord. يبقى الاختصار المخصص على قيمته الافتراضية حتى تغيّر أحدهما.';
  }

  @override
  String shortcuts_editor_title(String action) {
    return 'الاختصار: $action';
  }

  @override
  String get shortcuts_editor_help =>
      'اضغط مجموعة مفاتيح، أو اختر مفاتيح التعديل ومفتاحًا أدناه:';

  @override
  String get shortcuts_editor_needs_modifier =>
      'اختر على الأقل Cmd/Meta أو Ctrl أو Alt حتى لا تتأثر الكتابة في حقل الرسالة.';

  @override
  String shortcuts_text_editing_warning(String chord) {
    return '$chord اختصار لتحرير النص (نسخ أو لصق أو قص أو تراجع أو إعادة أو تحديد الكل). ربطه هنا يحرم حقول النص منه.';
  }

  @override
  String shortcuts_text_editing_in_use(String action, String chord) {
    return 'يستخدم «$action» الاختصار $chord الخاص بتحرير النص. تفقده حقول النص ما دام مربوطًا هنا.';
  }

  @override
  String custom_headers_problem_format(int line) {
    return 'السطر $line: المتوقع «الاسم: القيمة»';
  }

  @override
  String custom_headers_problem_missing_name(int line) {
    return 'السطر $line: اسم الترويسة مفقود';
  }

  @override
  String custom_headers_problem_invalid_name(int line, String name) {
    return 'السطر $line: اسم ترويسة غير صالح «$name»';
  }

  @override
  String custom_headers_problem_reserved(int line, String name) {
    return 'السطر $line: «$name» محجوز ولا يمكن تمريره';
  }

  @override
  String custom_headers_problem_empty_value(int line) {
    return 'السطر $line: قيمة الترويسة فارغة';
  }

  @override
  String get ng_enter_a_deployment_token => 'أدخل رمز جلسة النشر.';

  @override
  String get ng_custom_headers => 'ترويسات مخصصة';

  @override
  String get ng_custom_headers_help =>
      'ترويسات HTTP إضافية لهذه البوابة (الاسم: القيمة، واحدة في كل سطر)، تُرسل مع استدعاءات REST وWebSocket الخاصة بها، وتُحفظ في مخزن بيانات الاعتماد الآمن. تُرفض ترويسات المصادقة والترويسات بين القفزات.';

  @override
  String get ng_use_a_deployment_token => 'استخدام رمز جلسة النشر';

  @override
  String get ng_sign_in_with_deployment_token => 'تسجيل الدخول برمز النشر';

  @override
  String get ng_signed_in_with_deployment_token =>
      'تم تسجيل الدخول برمز النشر.';
}

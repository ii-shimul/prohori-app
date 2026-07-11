// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get acknowledgeAlert => 'সতর্কতা স্বীকার করুন';

  @override
  String get acknowledgingAlert => 'সতর্কতা স্বীকার করা হচ্ছে…';

  @override
  String get alertAcknowledged =>
      'সতর্কতা স্বীকার করা হয়েছে। কেসের সময়রেখা খোলা হচ্ছে।';

  @override
  String get caseTimeline => 'কেসের সময়রেখা';

  @override
  String get caseStatus => 'কেসের অবস্থা';

  @override
  String get addNote => 'সীমাবদ্ধ নোট যোগ করুন';

  @override
  String get noteHint => 'অনুমোদিত পরিচালনা দলের জন্য তথ্যভিত্তিক আপডেট লিখুন।';

  @override
  String get sendNote => 'নোট পাঠান';

  @override
  String get sendingNote => 'নোট পাঠানো হচ্ছে…';

  @override
  String get noteSent => 'কেসের সময়রেখায় নোট যোগ করা হয়েছে।';

  @override
  String get timelineEmpty => 'এখনও কোনো সময়রেখা ঘটনা নেই।';

  @override
  String get actionFailed => 'কাজটি সম্পন্ন হয়নি। আবার চেষ্টা করুন।';
}

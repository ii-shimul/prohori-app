// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get acknowledgeAlert => 'Acknowledge alert';

  @override
  String get acknowledgingAlert => 'Acknowledging alert…';

  @override
  String get alertAcknowledged => 'Alert acknowledged. Opening case timeline.';

  @override
  String get caseTimeline => 'Case timeline';

  @override
  String get caseStatus => 'Case status';

  @override
  String get addNote => 'Add scoped note';

  @override
  String get noteHint => 'Write a factual update for authorized operations.';

  @override
  String get sendNote => 'Send note';

  @override
  String get sendingNote => 'Sending note…';

  @override
  String get noteSent => 'Note added to case timeline.';

  @override
  String get timelineEmpty => 'No timeline events yet.';

  @override
  String get actionFailed => 'Action could not be completed. Try again.';

  @override
  String get inbox => 'Inbox';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get signOut => 'Sign out';

  @override
  String get telemetry => 'Data telemetry';

  @override
  String get dataGood => 'GOOD';

  @override
  String get dataDegraded => 'DEGRADED';

  @override
  String get dataCritical => 'CRITICAL';
}

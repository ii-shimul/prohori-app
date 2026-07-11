import 'package:intl/intl.dart';

class TimeFormat {
  const TimeFormat._();

  static String clock(DateTime value) => DateFormat('h:mm').format(value.toLocal());

  static String relative(DateTime? value, {DateTime? now}) {
    if (value == null) return 'Time unavailable';
    final minutes = (now ?? DateTime.now()).difference(value).inMinutes;
    if (minutes <= 0) return 'just now';
    if (minutes < 60) return '$minutes min ago';
    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours h ago';
    return '${hours ~/ 24} d ago';
  }
}

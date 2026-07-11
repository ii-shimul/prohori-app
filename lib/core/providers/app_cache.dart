import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppCacheEpoch extends Notifier<int> {
  @override
  int build() => 0;

  void clear() => state++;
}

final appCacheEpochProvider = NotifierProvider<AppCacheEpoch, int>(AppCacheEpoch.new);

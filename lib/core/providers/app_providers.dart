import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/secure_auth_storage.dart';
import '../../auth/data/supabase_auth_data_source.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/presentation/auth_notifier.dart' as local_auth;
import '../config/app_environment.dart';
import '../network/api_client.dart';
import '../network/auth_token_interceptor.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final secureAuthStorageProvider = Provider<SecureAuthStorage>((ref) {
  return SecureAuthStorage(ref.watch(secureStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dataSource: SupabaseAuthDataSource(ref.watch(supabaseClientProvider)),
    secureStorage: ref.watch(secureAuthStorageProvider),
  );
});

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: AppEnvironment.apiBaseUrl));
  dio.interceptors.add(AuthTokenInterceptor(ref.watch(supabaseClientProvider)));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioClientProvider));
});

final authNotifierProvider = AsyncNotifierProvider<
    local_auth.AuthNotifier,
    local_auth.AuthState
>(
  local_auth.AuthNotifier.new,
);

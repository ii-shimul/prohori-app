import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prohori_app/core/network/api_client.dart';
import 'package:prohori_app/outlets/data/outlets_api.dart';

void main() {
  test('GET /outlets maps backend catalog fields exactly', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        expect(options.path, '/outlets');
        handler.resolve(Response<Object>(
          requestOptions: options,
          data: [
            {
              'id': '30000000-0000-4000-8000-000000000001',
              'code': 'DHK-001',
              'name': 'Dhaka North Outlet',
              'area': {
                'id': '20000000-0000-4000-8000-000000000001',
                'code': 'DHAKA_NORTH',
                'name': 'Dhaka North',
                'parentId': null,
              },
              'tier': 2,
              'timezone': 'Asia/Dhaka',
              'status': 'ACTIVE',
            },
          ],
        ));
      },
    ));

    final outlets = await OutletsApi(ApiClient(dio)).fetchOutlets();

    expect(outlets, hasLength(1));
    expect(outlets.single.name, 'Dhaka North Outlet');
    expect(outlets.single.area.code, 'DHAKA_NORTH');
    expect(outlets.single.timezone, 'Asia/Dhaka');
  });

  test('GET /outlets rejects a non-list response', () async {
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(Response<Object>(
          requestOptions: options,
          data: {'items': []},
        ));
      },
    ));

    expect(
      () => OutletsApi(ApiClient(dio)).fetchOutlets(),
      throwsFormatException,
    );
  });
}

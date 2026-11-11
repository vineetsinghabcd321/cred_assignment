import 'package:flutter_test/flutter_test.dart';
import 'package:job_hive/core/routes/app_pages.dart';
import 'package:job_hive/core/routes/app_routes.dart';

void main() {
  group('App route structure', () {
    test('initial route should be login', () {
      expect(AppPages.initialRoute, AppRoutes.login);
    });

    test('routes should contain login and signup pages', () {
      final routeNames = AppPages.routes.map((route) => route.name).toList();
      expect(routeNames, containsAll([AppRoutes.login, AppRoutes.signUp]));
    });
  });
}

import 'package:get/route_manager.dart';
import 'package:job_hive/core/routes/app_routes.dart';
import 'package:job_hive/features/auth/binding/auth_binding.dart';
import 'package:job_hive/features/auth/views/login_view.dart';
import 'package:job_hive/features/auth/views/sign_up_view.dart';
import 'package:job_hive/features/home/binding/home_binding.dart';
import 'package:job_hive/features/home/views/home_view.dart';

class AppPages {
  static const initialRoute = AppRoutes.home;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.signUp, page: () => const SignUpView()),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}

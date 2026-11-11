import 'package:get/instance_manager.dart';
import 'package:job_hive/features/auth/controllers/auth_controller.dart';
import 'package:job_hive/features/auth/repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<AuthController>(
      () => AuthController(repository: Get.find<AuthRepository>()),
    );
  }
}

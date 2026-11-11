import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:job_hive/features/auth/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository repository;

  AuthController({required this.repository});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    try {
      await repository.login(emailController.text, passwordController.text);
      Get.snackbar("success", 'Login Successful');
    } catch (e) {
      Get.snackbar('error', e.toString());
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

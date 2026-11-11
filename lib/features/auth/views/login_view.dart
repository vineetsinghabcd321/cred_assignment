import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_hive/core/constants/app_text_style.dart';
import 'package:job_hive/core/routes/app_routes.dart';
import 'package:job_hive/features/auth/controllers/auth_controller.dart';
import 'package:job_hive/widgets/custom_elevated_button.dart';
import 'package:job_hive/widgets/custom_text_field.dart';
import 'package:job_hive/widgets/custom_widget_text.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Email', style: AppTextStyle.filledName),
          CustomTextField(
            hintText: "jhon@mail.com",
            controller: controller.emailController,
          ),
          const SizedBox(height: 10),
          const Text('Password', style: AppTextStyle.filledName),
          CustomTextField(
            hintText: "Jhon@123",
            controller: controller.passwordController,
          ),
          CustomWidgetText(
            text: "Forget Password",
            color: Colors.blue,
            size: 22,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.end,
          ),
          customElevatedButton(
            text: "Login",
            onPressed: () {
              controller.login();
              print("Login button pressed");
            },
          ),

          InkWell(
            onTap: () {
              Get.toNamed(AppRoutes.signUp);
            },
            child: Center(
              child: Text(
                "sign up",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

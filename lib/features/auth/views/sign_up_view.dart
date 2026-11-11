import 'package:flutter/material.dart';
import 'package:job_hive/core/constants/app_text_style.dart';
import 'package:job_hive/widgets/custom_text_field.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('Email', style: AppTextStyle.filledName),
            CustomTextField(),
            SizedBox(height: 10),
            Text('Password', style: AppTextStyle.filledName),
            CustomTextField(),
          ],
        ),
      ),
    );
  }
}

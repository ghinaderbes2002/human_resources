import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/auth/login_controller.dart';
import 'package:human_resources/core/function/validinput.dart';
import 'package:human_resources/core/them/app_colors.dart';
import 'package:human_resources/view/widget/auth/CustomButton.dart';
import 'package:human_resources/view/widget/auth/CustomTextFormFiled.dart';
import 'package:human_resources/view/widget/auth/logo.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginControllerImp());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: GetBuilder<LoginControllerImp>(
            builder: (controller) {
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),

                      // Logo Section
                      const Logo(),
                      const SizedBox(height: 10),

                      // Main Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Form(
                            key: controller.formState,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Card Header
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'مرحباً بك',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'قم بتسجيل الدخول للمتابعة',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Form Fields
                                CustomTextFormField(
                                  controller: controller.username,
                                  label: ' الاسم الكامل ',
                                  hintText: 'أدخل الاسم الكامل',
                                  prefixIcon: Icons.person_outline,
                                  validator: (val) =>
                                      validInput(val!, 3, 100, "username"),
                                  isDarkMode: false,
                                ),
                                const SizedBox(height: 20),

                                CustomTextFormField(
                                  controller: controller.password,
                                  label: "كلمة المرور",
                                  hintText: "********",
                                  prefixIcon: Icons.lock_outline,
                                  isPassword: controller.isPasswordHidden,
                                  onPasswordToggle:
                                      controller.togglePasswordVisibility,
                                  // validator: controller.validatePassword,
                                  isDarkMode: false,
                                ),
                                const SizedBox(height: 12),

                                // // Forgot Password
                                // Align(
                                //   alignment: Alignment.centerLeft,
                                //   child: GestureDetector(
                                //     child: Text(
                                //       'نسيت كلمة المرور؟',
                                //       style: TextStyle(
                                //         color: AppColors.primary,
                                //         fontWeight: FontWeight.w500,
                                //         fontSize: 14,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // const SizedBox(height: 30),

                                // Login Button
                                CustomButton(
                                  text: 'تسجيل الدخول',
                                  onPressed: () {
                                    controller.login();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Sign Up Section
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 20,
                      //     vertical: 15,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(15),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: Colors.black.withOpacity(0.05),
                      //         spreadRadius: 1,
                      //         blurRadius: 10,
                      //         offset: const Offset(0, 2),
                      //       ),
                      //     ],
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         "ليس لديك حساب؟",
                      //         style: TextStyle(
                      //           fontSize: 15,
                      //           color: Colors.grey[600],
                      //         ),
                      //       ),
                      //       const SizedBox(width: 8),
                      //       GestureDetector(
                      //         onTap: () => Get.offAllNamed(AppRoute.signup),
                      //         child: Row(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             Text(
                      //               "إنشاء حساب",
                      //               style: TextStyle(
                      //                 color: AppColors.primary,
                      //                 fontWeight: FontWeight.bold,
                      //                 fontSize: 15,
                      //               ),
                      //             ),
                      //             const SizedBox(width: 6),
                      //             Icon(
                      //               Icons.person_add,
                      //               size: 18,
                      //               color: AppColors.primary,
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

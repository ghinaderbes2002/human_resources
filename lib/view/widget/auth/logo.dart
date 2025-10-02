import 'package:flutter/material.dart';
import 'package:human_resources/core/constant/App_images.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          AppImage.logo,
          width: 200, // عرض الصورة
          height: 200, // ارتفاع الصورة
          fit: BoxFit.contain, // يحافظ على نسبة الصورة
        ),
        const SizedBox(height: 15),
        // const Text(
        //   "ORDERLY",
        //   style: TextStyle(
        //     fontSize: 28,
        //     fontWeight: FontWeight.bold,
        //     color: AppColors.background,
        //   ),
        // ),
      ],
    );
  }
}

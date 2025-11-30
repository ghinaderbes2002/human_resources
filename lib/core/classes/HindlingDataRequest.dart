// import 'package:flutter/widgets.dart';
// import 'package:human_resources/core/classes/staterequest.dart';
// import 'package:human_resources/core/constant/App_images.dart';
// import 'package:lottie/lottie.dart';

// class HindlingDataRequest extends StatelessWidget {
//   final Staterequest stateRequest;
//   final Widget widget;
//   const HindlingDataRequest({
//     Key? key,
//     required this.stateRequest,
//     required this.widget,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return stateRequest == Staterequest.loading
//         ? Center(child: Lottie.asset(AppImage.loding, width: 250, height: 250))
//         : stateRequest == Staterequest.offlinefailure
//         ? Center(child: Lottie.asset(AppImage.loding, width: 250, height: 250))
//         : stateRequest == Staterequest.serverfailure
//         ? Center(child: Lottie.asset(AppImage.loding, width: 250, height: 250))
//         : widget;
//   }
// }

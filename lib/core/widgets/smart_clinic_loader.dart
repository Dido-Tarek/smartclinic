// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class SmartClinicLoader extends StatefulWidget {
//   final double size;
//   const SmartClinicLoader({super.key, this.size = 200.0});

//   @override
//   State<SmartClinicLoader> createState() => _SmartClinicLoaderState();
// }

// class _SmartClinicLoaderState extends State<SmartClinicLoader> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     // تأكد من وضع ملف الفيديو في assets/videos/
//     _controller =
//         VideoPlayerController.asset("assets/videos/logo_animation.mp4")
//           ..initialize().then((_) {
//             setState(() {
//               _controller.play();
//               _controller.setLooping(true);
//             });
//           });

//     // تحكم في مدة الـ Loop (5 ثوانٍ)
//     _controller.addListener(() {
//       if (_controller.value.position >= const Duration(seconds: 5)) {
//         _controller.seekTo(Duration.zero);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: SizedBox(
//         width: widget.size,
//         height: widget.size,
//         child: _controller.value.isInitialized
//             ? ColorFiltered(
//                 // هذه الخاصية تقوم بحذف اللون الأسود (الخلفية) من الفيديو
//                 // واظهار اللوجو فقط ليظهر وكأنه شفاف فوق خلفية التطبيق الكحلية
//                 colorFilter: const ColorFilter.mode(
//                   Colors.black,
//                   BlendMode.dstOut,
//                 ),
//                 child: VideoPlayer(_controller),
//               )
//             : const CircularProgressIndicator(color: Colors.white),
//       ),
//     );
//   }
// }

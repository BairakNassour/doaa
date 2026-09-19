// import 'dart:async';
// import 'package:doaa/component/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class DigitalClockWidget extends StatefulWidget {
//   @override
//   _DigitalClockWidgetState createState() => _DigitalClockWidgetState();
// }

// class _DigitalClockWidgetState extends State<DigitalClockWidget> {
//   late String _timeString;
//   late String _secondsString;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _updateStrings(DateTime.now());
    
//     // تحديث كل ثانية لضمان دقة الثواني
//     _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getCurrentTime());
//   }

//   void _getCurrentTime() {
//     setState(() {
//       _updateStrings(DateTime.now());
//     });
//   }

//   void _updateStrings(DateTime now) {
//     // الساعات والدقائق
//     _timeString = DateFormat('hh:mm').format(now);
//     // الثواني فقط
//     _secondsString = DateFormat(':ss').format(now);
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.end, // محاذاة الثواني لأسفل النص
//       children: [
//         Text(
//           _timeString,
//           style: TextStyle(
//             color: AppColors.textWhite,
//             fontSize: 32, // حجم الساعات والدقائق
//             fontWeight: FontWeight.bold,
//             letterSpacing: -1,
//           ),
//         ),
//         Text(
//           _secondsString,
//           style: TextStyle(
//           color: AppColors.textWhite,
//           fontSize: 32, // حجم الساعات والدقائق
//           fontWeight: FontWeight.bold,
//           letterSpacing: -1,
//         ),
//         ),
//       ],
//     );
//   }
// }
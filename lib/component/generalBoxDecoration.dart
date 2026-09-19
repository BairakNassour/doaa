import 'package:flutter/material.dart';

getBoxDecoration(){
  return BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            colorFilter: ColorFilter.mode(
              Color.fromARGB(255, 70, 137, 120), // اللون الذي تريد تطبيقه ونسبة شفافيته
              BlendMode.srcATop, // طريقة دمج اللون مع الصورة
            ), // مسار الصورة تبعك
            fit: BoxFit
                .fitHeight,opacity: 0.1 // عشان الصورة تغطي كامل الكونتينر بدون ما تخرب أبعادها
          ),
        );
}
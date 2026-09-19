import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
   SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      // زر العودة للخلف
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios, color: AppColors.accentGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
               SizedBox(height: 20),
               Text(
                'إنشاء حساب جديد'.tr,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
               SizedBox(height: 10),
               Text(
                'انضم إلينا في رحلة الذكر والطاعة'.tr,
                style: TextStyle(color:AppColors.textWhite, fontSize: 16),
              ),
               SizedBox(height: 40),

              // حقل الاسم الكامل
              _buildTextField(
                controller: _nameController,
                hint: 'الاسم الكامل',
                icon: Icons.person_outline,
              ),
               SizedBox(height: 20),

              // حقل البريد الإلكتروني
              _buildTextField(
                controller: _emailController,
                hint: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
              ),
               SizedBox(height: 20),

              // حقل كلمة المرور
              _buildTextField(
                controller: _passwordController,
                hint: 'كلمة المرور',
                icon: Icons.lock_outline,
                isPassword: true,
                isVisible: _isPasswordVisible,
                onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
               SizedBox(height: 20),

              // حقل تأكيد كلمة المرور
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'تأكيد كلمة المرور',
                icon: Icons.lock_reset_outlined,
                isPassword: true,
                isVisible: _isConfirmPasswordVisible,
                onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),

               SizedBox(height: 40),

              // زر إنشاء الحساب
              _buildSignUpButton(),

               SizedBox(height: 20),

              // العودة لتسجيل الدخول
              _buildLoginOption(),
               SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !isVisible : false,
        style:  TextStyle(color:  AppColors.textWhite),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:  TextStyle(color:  AppColors.textWhite),
          prefixIcon: Icon(icon, color: AppColors.accentGold),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color:  AppColors.textWhite,
                  ),
                  onPressed: onToggle,
                )
              : null,
          filled: true,
          fillColor: AppColors.secondaryDark.withOpacity(0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide:  BorderSide(color: AppColors.accentGold, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // منطق البرمجة لإنشاء الحساب
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
        child:  Text(
          'إنشاء الحساب'.tr,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.textWhite),
        ),
      ),
    );
  }

  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:  Text(
            'سجل دخولك'.tr,
            style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
          ),
        ),
         Text(
          'لديك حساب بالفعل؟'.tr,
          style: TextStyle(color: AppColors.textWhite),
        ),
      ],
    );
  }
}
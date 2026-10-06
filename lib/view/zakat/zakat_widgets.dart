import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, color: const Color(0xFFC0A080), size: 28),
      const SizedBox(width: 10),
      Text(
        title,
        style: TextStyle(
          color: AppColors.textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    style: TextStyle(color: AppColors.textWhite),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textWhite.withOpacity(0.8)),
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textWhite.withOpacity(0.3)),
      prefixIcon: Icon(icon, color: const Color(0xFFC0A080)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFFC0A080).withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC0A080)),
      ),
      filled: true,
      fillColor: AppColors.secondaryDark,
    ),
  );
}

Widget buildCalculateButton(String title, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC0A080),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget buildResultCard(String label, String value) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    decoration: BoxDecoration(
      color: AppColors.secondaryDark,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textWhite)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget buildWarningCard(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F4F0).withOpacity(isDark ? 0.05 : 1.0),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFC0A080),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              "تنبيه",
              style: TextStyle(
                color: isDark ? AppColors.textWhite : const Color(0xFFC0A080),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          "حاسبة الزكاة أداة مساعدة لتقدير مقدار الزكاة، وليس فتوى شرعية، وقد تختلف بعض الأحكام والتفاصيل بحسب نوع المال وحالة المستخدم.",
          style: TextStyle(
            color: AppColors.textWhite.withOpacity(isDark ? 0.6 : 0.8),
            height: 1.5,
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

Widget buildIslamicDecoration() {
  return const Center(
    child: Text(
      "✿ ✿ ✿",
      style: TextStyle(color: Color(0xFFC0A080), fontSize: 22),
    ),
  );
}
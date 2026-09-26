import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ZakatCalculatorPage extends StatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  State<ZakatCalculatorPage> createState() => _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers - المال
  final TextEditingController _cashController = TextEditingController();

  // Controllers - الذهب والفضة
  final TextEditingController _goldGramsController = TextEditingController();
  final TextEditingController _goldPricePerGramController = TextEditingController();
  final TextEditingController _silverGramsController = TextEditingController();
  final TextEditingController _silverPricePerGramController = TextEditingController();

  // Controllers - الزروع والثمار
  final TextEditingController _cropsWeightController = TextEditingController();
  final TextEditingController _cropValueController = TextEditingController();
  bool _isIrrigatedWithCost = false; // هل تُسقى بتكلفة أم بماء المطر

  // Controllers - الأنعام
  final TextEditingController _camelsController = TextEditingController();
  final TextEditingController _cowsController = TextEditingController();
  final TextEditingController _sheepController = TextEditingController();

  // نتائج الزكاة لكل قسم
  double _cashZakat = 0.0;
  double _goldZakat = 0.0;
  double _silverZakat = 0.0;
  double _cropsZakat = 0.0;
  String _livestockZakatResult = "أدخل عدد الأنعام لحساب الزكاة الشرعية";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashController.dispose();
    _goldGramsController.dispose();
    _goldPricePerGramController.dispose();
    _silverGramsController.dispose();
    _silverPricePerGramController.dispose();
    _cropsWeightController.dispose();
    _cropValueController.dispose();
    _camelsController.dispose();
    _cowsController.dispose();
    _sheepController.dispose();
    super.dispose();
  }

  // --- حساب زكاة المال ---
  void _calculateCashZakat() {
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    setState(() {
      _cashZakat = cash >= 0 ? cash * 0.025 : 0.0;
    });
    HapticFeedback.mediumImpact();
  }

  // --- حساب زكاة الذهب والفضة ---
  void _calculateGoldSilverZakat() {
    double goldGrams = double.tryParse(_goldGramsController.text) ?? 0.0;
    double goldPrice = double.tryParse(_goldPricePerGramController.text) ?? 0.0;
    double silverGrams = double.tryParse(_silverGramsController.text) ?? 0.0;
    double silverPrice = double.tryParse(_silverPricePerGramController.text) ?? 0.0;

    double goldValue = goldGrams * goldPrice;
    double silverValue = silverGrams * silverPrice;

    setState(() {
      _goldZakat = goldGrams >= 85 ? goldValue * 0.025 : 0.0;
      _silverZakat = silverGrams >= 595 ? silverValue * 0.025 : 0.0;
    });
    HapticFeedback.mediumImpact();
  }

  // --- حساب زكاة الزروع والثمار ---
  void _calculateCropsZakat() {
    double totalValue = double.tryParse(_cropValueController.text) ?? 0.0;
    double weightKg = double.tryParse(_cropsWeightController.text) ?? 0.0;

    // النصاب: 5 أوسق ≈ 653 كجم
    if (weightKg >= 653) {
      double rate = _isIrrigatedWithCost ? 0.05 : 0.10;
      setState(() {
        _cropsZakat = totalValue * rate;
      });
    } else {
      setState(() {
        _cropsZakat = 0.0;
      });
    }
    HapticFeedback.mediumImpact();
  }

  // --- حساب زكاة الأنعام ---
  void _calculateLivestockZakat() {
    int camels = int.tryParse(_camelsController.text) ?? 0;
    int cows = int.tryParse(_cowsController.text) ?? 0;
    int sheep = int.tryParse(_sheepController.text) ?? 0;

    List<String> results = [];

    // الإبل
    if (camels < 5) {
      results.add("الإبل: لا زكاة فيها (أقل من النصاب 5)");
    } else if (camels <= 9) {
      results.add("الإبل: شاة واحدة");
    } else if (camels <= 14) {
      results.add("الإبل: شاتان");
    } else if (camels <= 19) {
      results.add("الإبل: 3 شياه");
    } else if (camels <= 24) {
      results.add("الإبل: 4 شياه");
    } else {
      results.add("الإبل: بلغت النصاب الأعلى (تجب فيها بنت مخاض أو أسن)");
    }

    // البقر
    if (cows < 30) {
      results.add("البقر: لا زكاة فيها (أقل من النصاب 30)");
    } else if (cows <= 39) {
      results.add("البقر: تبيع أو تبيعة (سنة)");
    } else if (cows <= 59) {
      results.add("البقر: مسنة (سنتان)");
    } else {
      results.add("البقر: تجب فيها تبيعة عن كل 30 ومسنة عن كل 40");
    }

    // الغنم
    if (sheep < 40) {
      results.add("الغنم: لا زكاة فيها (أقل من النصاب 40)");
    } else if (sheep <= 120) {
      results.add("الغنم: شاة واحدة");
    } else if (sheep <= 200) {
      results.add("الغنم: شاتان");
    } else if (sheep <= 399) {
      results.add("الغنم: 3 شياه");
    } else {
      results.add("الغنم: 4 شياه (وعن كل 100 إضافية شاة)");
    }

    setState(() {
      _livestockZakatResult = results.join("\n• ");
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondaryDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "حاسبة الزكاة".tr,
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: const Color(0xFFC0A080),
            labelColor: const Color(0xFFC0A080),
            unselectedLabelColor: AppColors.textWhite.withOpacity(0.6),
            tabs: const [
              Tab(icon: Icon(Icons.attach_money), text: "المال"),
              Tab(icon: Icon(Icons.diamond_outlined), text: "الذهب والفضة"),
              Tab(icon: Icon(Icons.grass), text: "الزرع والثمار"),
              Tab(icon: Icon(Icons.pets), text: "الأنعام"),
              Tab(icon: Icon(Icons.calculate_outlined), text: "الملخص"),
            ],
          ),
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCashZakatTab(),
                _buildGoldSilverZakatTab(),
                _buildCropsZakatTab(),
                _buildLivestockZakatTab(),
                _buildSummaryTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. زكاة المال ---
  Widget _buildCashZakatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("زكاة النقود والمدخرات", Icons.monetization_on),
          const SizedBox(height: 10),
          Text(
            "تجب الزكاة في المال إذا بلغ النصاب (ما يعادل قيمة 85g ذهب) وحال عليه الحول بنسبة 2.5%.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 25),
          _buildTextField(
            controller: _cashController,
            label: "إجمالي المبلغ المدخر",
            hint: "أدخل المبلغ بالعملة المحلية",
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: 25),
          _buildCalculateButton("حساب زكاة المال", _calculateCashZakat),
          const SizedBox(height: 30),
          _buildResultCard("مقدار زكاة المال المستحقة", "${_cashZakat.toStringAsFixed(2)}"),
          const SizedBox(height: 30),
          _buildIslamicDecoration(),
        ],
      ),
    );
  }

  // --- 2. زكاة الذهب والفضة ---
  Widget _buildGoldSilverZakatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("زكاة الذهب والفضة", Icons.diamond),
          const SizedBox(height: 10),
          Text(
            "نصاب الذهب 85 جرام، ونصاب الفضة 595 جرام. نسبة الزكاة الواجبة هي 2.5%.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 20),
          Text("الذهب", style: TextStyle(color: const Color(0xFFC0A080), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _goldGramsController,
            label: "وزن الذهب بالجرام",
            hint: "مثال: 90",
            icon: Icons.scale,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _goldPricePerGramController,
            label: "سعر جرام الذهب الحالي",
            hint: "سعر الجرام بالعملة المحلية",
            icon: Icons.price_change,
          ),
          const SizedBox(height: 20),
          Text("الفضة", style: TextStyle(color: const Color(0xFFC0A080), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _silverGramsController,
            label: "وزن الفضة بالجرام",
            hint: "مثال: 600",
            icon: Icons.scale,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _silverPricePerGramController,
            label: "سعر جرام الفضة الحالي",
            hint: "سعر الجرام بالعملة المحلية",
            icon: Icons.price_change,
          ),
          const SizedBox(height: 25),
          _buildCalculateButton("حساب زكاة الذهب والفضة", _calculateGoldSilverZakat),
          const SizedBox(height: 25),
          _buildResultCard("زكاة الذهب المستحقة", "${_goldZakat.toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          _buildResultCard("زكاة الفضة المستحقة", "${_silverZakat.toStringAsFixed(2)}"),
          const SizedBox(height: 30),
          _buildIslamicDecoration(),
        ],
      ),
    );
  }

  // --- 3. زكاة الزروع والثمار ---
  Widget _buildCropsZakatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("زكاة الزروع والثمار", Icons.eco),
          const SizedBox(height: 10),
          Text(
            "نصاب الزروع هو 5 أوسق (حوالي 653 كجم). مقدار الزكاة 10% للري بماء المطر، و5% للري بالتكلفة والآلات.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _cropsWeightController,
            label: "إجمالي وزن المحصول (كجم)",
            hint: "مثال: 700",
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _cropValueController,
            label: "القيمة المادية الإجمالية للمحصول",
            hint: "القيمة بالعملة المحلية",
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 15),
          SwitchListTile(
            title: Text("سقي بتكلفة ومكائن؟", style: TextStyle(color: AppColors.textWhite)),
            subtitle: Text(
              _isIrrigatedWithCost ? "النسبة الواجبة: 5% (بآلات وكلفة)" : "النسبة الواجبة: 10% (بماء المطر/بدون كلفة)",
              style: TextStyle(color: const Color(0xFFC0A080), fontSize: 12),
            ),
            value: _isIrrigatedWithCost,
            activeColor: const Color(0xFFC0A080),
            onChanged: (val) {
              setState(() {
                _isIrrigatedWithCost = val;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildCalculateButton("حساب زكاة الزروع", _calculateCropsZakat),
          const SizedBox(height: 25),
          _buildResultCard("قيمة زكاة الزروع المستحقة", "${_cropsZakat.toStringAsFixed(2)}"),
          const SizedBox(height: 30),
          _buildIslamicDecoration(),
        ],
      ),
    );
  }

  // --- 4. زكاة الأنعام ---
  Widget _buildLivestockZakatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("زكاة الأنعام (المواشي)", Icons.pets),
          const SizedBox(height: 10),
          Text(
            "يشترط فيها أن تكون سائمة (ترعى أكثر العام) وأن تحول عليها الحول.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _camelsController,
            label: "عدد الإبل (الجمال)",
            hint: "النصاب من 5 فأكثر",
            icon: Icons.landscape,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _cowsController,
            label: "عدد البقر",
            hint: "النصاب من 30 فأكثر",
            icon: Icons.set_meal,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _sheepController,
            label: "عدد الغنم (الضأن والمعز)",
            hint: "النصاب من 40 فأكثر",
            icon: Icons.groups,
          ),
          const SizedBox(height: 25),
          _buildCalculateButton("حساب زكاة الأنعام", _calculateLivestockZakat),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("تفاصيل الواجب إخراجه:", style: TextStyle(color: const Color(0xFFC0A080), fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  "• $_livestockZakatResult",
                  style: TextStyle(color: AppColors.textWhite, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildIslamicDecoration(),
        ],
      ),
    );
  }

  // --- 5. ملخص النتيجة الإجمالية ---
  Widget _buildSummaryTab() {
    double totalMoneyZakat = _cashZakat + _goldZakat + _silverZakat + _cropsZakat;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildSectionHeader("ملخص إجمالي الزكاة", Icons.summarize),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "المبلغ الإجمالي المستحق للزكاة",
                  style: TextStyle(color: AppColors.textWhite, fontSize: 16),
                ),
                const SizedBox(height: 15),
                Text(
                  "${totalMoneyZakat.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "(يشمل النقدية + الذهب والفضة + الزروع)",
                  style: TextStyle(color: AppColors.textWhite.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildIslamicDecoration(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- عناصر واجهة المستخدم المساعدة ---

  Widget _buildSectionHeader(String title, IconData icon) {
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

  Widget _buildTextField({
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

  Widget _buildCalculateButton(String title, VoidCallback onPressed) {
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

  Widget _buildResultCard(String label, String value) {
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

  Widget _buildIslamicDecoration() {
    return const Center(
      child: Text(
        "✿ ✿ ✿",
        style: TextStyle(
          color: Color(0xFFC0A080),
          fontSize: 22,
        ),
      ),
    );
  }
}
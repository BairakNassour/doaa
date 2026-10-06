import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'zakat_widgets.dart';

// --- 1. زكاة المال ---
class CashZakatCalculatorView extends StatefulWidget {
  const CashZakatCalculatorView({super.key});

  @override
  State<CashZakatCalculatorView> createState() => _CashZakatCalculatorViewState();
}

class _CashZakatCalculatorViewState extends State<CashZakatCalculatorView> {
  final TextEditingController _cashController = TextEditingController();
  double _cashZakat = 0.0;

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _calculateCashZakat() {
    double cash = double.tryParse(_cashController.text) ?? 0.0;
    setState(() => _cashZakat = cash >= 0 ? cash * 0.025 : 0.0);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader("زكاة النقود والمدخرات", Icons.monetization_on),
          const SizedBox(height: 10),
          Text(
            "تجب الزكاة في المال إذا بلغ النصاب وحال عليه الحول بنسبة 2.5%.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 25),
          buildTextField(
            controller: _cashController,
            label: "إجمالي المبلغ المدخر",
            hint: "أدخل المبلغ بالعملة المحلية",
            icon: Icons.account_balance_wallet,
          ),
          const SizedBox(height: 25),
          buildCalculateButton("حساب زكاة المال", _calculateCashZakat),
          const SizedBox(height: 30),
          buildResultCard("مقدار زكاة المال المستحقة", _cashZakat.toStringAsFixed(2)),
          const SizedBox(height: 30),
          buildIslamicDecoration(),
        ],
      ),
    );
  }
}

// --- 2. زكاة الذهب ---
class GoldZakatCalculatorView extends StatefulWidget {
  const GoldZakatCalculatorView({super.key});

  @override
  State<GoldZakatCalculatorView> createState() => _GoldZakatCalculatorViewState();
}

class _GoldZakatCalculatorViewState extends State<GoldZakatCalculatorView> {
  final TextEditingController _goldGramsController = TextEditingController();
  final TextEditingController _goldPricePerGramController = TextEditingController();
  double _goldZakat = 0.0;

  @override
  void dispose() {
    _goldGramsController.dispose();
    _goldPricePerGramController.dispose();
    super.dispose();
  }

  void _calculateGoldZakat() {
    double goldGrams = double.tryParse(_goldGramsController.text) ?? 0.0;
    double goldPrice = double.tryParse(_goldPricePerGramController.text) ?? 0.0;
    double goldValue = goldGrams * goldPrice;

    setState(() {
      _goldZakat = goldGrams >= 85 ? goldValue * 0.025 : 0.0;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader("زكاة الذهب", Icons.diamond),
          const SizedBox(height: 10),
          Text(
            "نصاب الذهب 85 جرام. نسبة الزكاة الواجبة هي 2.5%.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 20),
          buildTextField(
            controller: _goldGramsController,
            label: "وزن الذهب بالجرام",
            hint: "مثال: 90",
            icon: Icons.scale,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _goldPricePerGramController,
            label: "سعر جرام الذهب الحالي",
            hint: "سعر الجرام بالعملة المحلية",
            icon: Icons.price_change,
          ),
          const SizedBox(height: 25),
          buildCalculateButton("حساب زكاة الذهب", _calculateGoldZakat),
          const SizedBox(height: 25),
          buildResultCard("زكاة الذهب المستحقة", _goldZakat.toStringAsFixed(2)),
          const SizedBox(height: 30),
          buildIslamicDecoration(),
        ],
      ),
    );
  }
}

// --- 3. زكاة الفضة ---
class SilverZakatCalculatorView extends StatefulWidget {
  const SilverZakatCalculatorView({super.key});

  @override
  State<SilverZakatCalculatorView> createState() => _SilverZakatCalculatorViewState();
}

class _SilverZakatCalculatorViewState extends State<SilverZakatCalculatorView> {
  final TextEditingController _silverGramsController = TextEditingController();
  final TextEditingController _silverPricePerGramController = TextEditingController();
  double _silverZakat = 0.0;

  @override
  void dispose() {
    _silverGramsController.dispose();
    _silverPricePerGramController.dispose();
    super.dispose();
  }

  void _calculateSilverZakat() {
    double silverGrams = double.tryParse(_silverGramsController.text) ?? 0.0;
    double silverPrice = double.tryParse(_silverPricePerGramController.text) ?? 0.0;
    double silverValue = silverGrams * silverPrice;

    setState(() {
      _silverZakat = silverGrams >= 595 ? silverValue * 0.025 : 0.0;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader("زكاة الفضة", Icons.scale_outlined),
          const SizedBox(height: 10),
          Text(
            "نصاب الفضة 595 جرام. نسبة الزكاة الواجبة هي 2.5%.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 20),
          buildTextField(
            controller: _silverGramsController,
            label: "وزن الفضة بالجرام",
            hint: "مثال: 600",
            icon: Icons.scale,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _silverPricePerGramController,
            label: "سعر جرام الفضة الحالي",
            hint: "سعر الجرام بالعملة المحلية",
            icon: Icons.price_change,
          ),
          const SizedBox(height: 25),
          buildCalculateButton("حساب زكاة الفضة", _calculateSilverZakat),
          const SizedBox(height: 25),
          buildResultCard("زكاة الفضة المستحقة", _silverZakat.toStringAsFixed(2)),
          const SizedBox(height: 30),
          buildIslamicDecoration(),
        ],
      ),
    );
  }
}

// --- 4. زكاة الأنعام ---
class LivestockZakatCalculatorView extends StatefulWidget {
  const LivestockZakatCalculatorView({super.key});

  @override
  State<LivestockZakatCalculatorView> createState() => _LivestockZakatCalculatorViewState();
}

class _LivestockZakatCalculatorViewState extends State<LivestockZakatCalculatorView> {
  final TextEditingController _camelsController = TextEditingController();
  final TextEditingController _cowsController = TextEditingController();
  final TextEditingController _sheepController = TextEditingController();
  String _livestockZakatResult = "أدخل عدد الأنعام لحساب الزكاة الشرعية";

  @override
  void dispose() {
    _camelsController.dispose();
    _cowsController.dispose();
    _sheepController.dispose();
    super.dispose();
  }

  void _calculateLivestockZakat() {
    int camels = int.tryParse(_camelsController.text) ?? 0;
    int cows = int.tryParse(_cowsController.text) ?? 0;
    int sheep = int.tryParse(_sheepController.text) ?? 0;

    List<String> results = [];

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
      results.add("الإبل: بلغت النصاب الأعلى");
    }

    if (cows < 30) {
      results.add("البقر: لا زكاة فيها (أقل من النصاب 30)");
    } else if (cows <= 39) {
      results.add("البقر: تبيع أو تبيعة (سنة)");
    } else if (cows <= 59) {
      results.add("البقر: مسنة (سنتان)");
    } else {
      results.add("البقر: تجب فيها تبيعة عن كل 30 ومسنة عن كل 40");
    }

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader("زكاة الأنعام (المواشي)", Icons.pets),
          const SizedBox(height: 10),
          Text(
            "يشترط فيها أن تكون سائمة وأن تحول عليها الحول.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 20),
          buildTextField(
            controller: _camelsController,
            label: "عدد الإبل",
            hint: "النصاب من 5 فأكثر",
            icon: Icons.landscape,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _cowsController,
            label: "عدد البقر",
            hint: "النصاب من 30 فأكثر",
            icon: Icons.set_meal,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _sheepController,
            label: "عدد الغنم",
            hint: "النصاب من 40 فأكثر",
            icon: Icons.groups,
          ),
          const SizedBox(height: 25),
          buildCalculateButton("حساب زكاة الأنعام", _calculateLivestockZakat),
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
                const Text("تفاصيل الواجب إخراجه:",
                    style: TextStyle(color: Color(0xFFC0A080), fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  "• $_livestockZakatResult",
                  style: TextStyle(color: AppColors.textWhite, fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          buildIslamicDecoration(),
        ],
      ),
    );
  }
}

// --- 5. زكاة الزرع ---
class CropsZakatCalculatorView extends StatefulWidget {
  const CropsZakatCalculatorView({super.key});

  @override
  State<CropsZakatCalculatorView> createState() => _CropsZakatCalculatorViewState();
}

class _CropsZakatCalculatorViewState extends State<CropsZakatCalculatorView> {
  final TextEditingController _cropsWeightController = TextEditingController();
  final TextEditingController _cropValueController = TextEditingController();
  bool _isIrrigatedWithCost = false;
  double _cropsZakat = 0.0;

  @override
  void dispose() {
    _cropsWeightController.dispose();
    _cropValueController.dispose();
    super.dispose();
  }

  void _calculateCropsZakat() {
    double totalValue = double.tryParse(_cropValueController.text) ?? 0.0;
    double weightKg = double.tryParse(_cropsWeightController.text) ?? 0.0;

    if (weightKg >= 653) {
      double rate = _isIrrigatedWithCost ? 0.05 : 0.10;
      setState(() => _cropsZakat = totalValue * rate);
    } else {
      setState(() => _cropsZakat = 0.0);
    }
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader("زكاة الزروع والثمار", Icons.eco),
          const SizedBox(height: 10),
          Text(
            "نصاب الزروع هو 653 كجم. النسبة 10% للمطر، و5% للتكلفة.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 13),
          ),
          const SizedBox(height: 20),
          buildTextField(
            controller: _cropsWeightController,
            label: "إجمالي وزن المحصول (كجم)",
            hint: "مثال: 700",
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 10),
          buildTextField(
            controller: _cropValueController,
            label: "القيمة المادية الإجمالية",
            hint: "بالعملة المحلية",
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 15),
          SwitchListTile(
            title: Text("سقي بتكلفة ومكائن؟", style: TextStyle(color: AppColors.textWhite)),
            subtitle: Text(
              _isIrrigatedWithCost ? "النسبة الواجبة: 5%" : "النسبة الواجبة: 10%",
              style: const TextStyle(color: Color(0xFFC0A080), fontSize: 12),
            ),
            value: _isIrrigatedWithCost,
            activeColor: const Color(0xFFC0A080),
            onChanged: (val) => setState(() => _isIrrigatedWithCost = val),
          ),
          const SizedBox(height: 20),
          buildCalculateButton("حساب زكاة الزروع", _calculateCropsZakat),
          const SizedBox(height: 25),
          buildResultCard("قيمة زكاة الزروع المستحقة", _cropsZakat.toStringAsFixed(2)),
          const SizedBox(height: 30),
          buildIslamicDecoration(),
        ],
      ),
    );
  }
}
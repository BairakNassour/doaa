import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'zakat_widgets.dart';
import 'zakat_calculators_views.dart';

class ZakatTypeItem {
  final String title;
  final String subtitle;
  final String iconAsset;
  final IconData fallbackIcon;
  final Widget calculationView;

  ZakatTypeItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.calculationView,
  });
}

class ZakatCalculatorPage extends StatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  State<ZakatCalculatorPage> createState() => _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage> {
  late List<ZakatTypeItem> zakatTypes;

  @override
  void initState() {
    super.initState();
    zakatTypes = [
      ZakatTypeItem(
        title: "زكاة المال",
        subtitle: "النقود والحسابات والأموال الأخرى",
        iconAsset: "assets/zakatcalc.png",
        fallbackIcon: Icons.attach_money,
        calculationView: const CashZakatCalculatorView(),
      ),
      ZakatTypeItem(
        title: "زكاة الذهب",
        subtitle: "حسب الوزن والعيار والسعر",
        iconAsset: "assets/gold.png",
        fallbackIcon: Icons.diamond_outlined,
        calculationView: const GoldZakatCalculatorView(),
      ),
      ZakatTypeItem(
        title: "زكاة الفضة",
        subtitle: "حسب الوزن والسعر",
        iconAsset: "assets/silver.png",
        fallbackIcon: Icons.scale_outlined,
        calculationView: const SilverZakatCalculatorView(),
      ),
      ZakatTypeItem(
        title: "زكاة الأنعام",
        subtitle: "الإبل والبقر والغنم",
        iconAsset: "assets/camel.png",
        fallbackIcon: Icons.pets_outlined,
        calculationView: const LivestockZakatCalculatorView(),
      ),
      ZakatTypeItem(
        title: "زكاة الزرع",
        subtitle: "الحبوب والثمار بحسب طريقة السقي",
        iconAsset: "assets/wheat.png",
        fallbackIcon: Icons.grass_outlined,
        calculationView: const CropsZakatCalculatorView(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerGradient = isDarkMode
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A2F), Color(0xFF2C5E4A)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C5E4A), Color(0xFF3F8F6E)],
          );

    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(gradient: headerGradient),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                centerTitle: true,
                title: Text(
                  "حاسبة الزكاة".tr,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "احسب زكاتك بصورة تقديرية حسب نوع المال الذي تملكه.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textWhite.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: zakatTypes.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      if (index == zakatTypes.length) {
                        return buildWarningCard(context);
                      }
                      return _buildZakatTypeCard(zakatTypes[index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZakatTypeCard(ZakatTypeItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Scaffold(
                backgroundColor: AppColors.secondaryDark,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: item.calculationView,
              ),
            ));
            HapticFeedback.lightImpact();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Center(
                      child: Image.asset(
                        item.iconAsset,
                        width: 35,
                        height: 35,
                        errorBuilder: (_, __, ___) => Icon(
                          item.fallbackIcon,
                          color: const Color(0xFFC0A080),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          color: AppColors.textWhite.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: AppColors.textWhite.withOpacity(0.4), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
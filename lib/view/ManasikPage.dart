import 'package:doaa/component/app_colors.dart';
import 'package:doaa/view/HomePage/ManasikMapPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManasikPage extends StatefulWidget {
   ManasikPage({super.key});

  @override
  State<ManasikPage> createState() => _ManasikPageState();
}

class _ManasikPageState extends State<ManasikPage> {
  // متغير للتحكم في عرض نوع النسك
  bool isOmraSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      // SafeArea لضمان حماية المحتوى من الحواف
      body: SafeArea(
        top: false, // لترك الـ SliverAppBar يمتد للأعلى بشكل جميل
        child: CustomScrollView(
          slivers: [
            // هيدر جذاب مع صورة ولقب الصفحة
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.secondaryDark,
              flexibleSpace: FlexibleSpaceBar(
                title:  Text(
                  'مناسك الحج والعمرة'.tr,
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
                centerTitle: true,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/makkah.jpg', fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.primaryDark.withOpacity(0.8),
                            AppColors.primaryDark,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding:  EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اختيار نوع النسك
                     Text(
                      'اختر النسك الحالي'.tr,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     SizedBox(height: 15),
                    Row(
                      children: [
                        _buildTypeCard(
                          'عمرة',
                          Icons.mosque,
                          isOmraSelected,
                          () {
                            setState(() => isOmraSelected = true);
                          },
                        ),
                         SizedBox(width: 15),
                        _buildTypeCard(
                          'حج',
                          Icons.landscape,
                          !isOmraSelected,
                          () {
                            setState(() => isOmraSelected = false);
                          },
                        ),
                      ],
                    ),

                     SizedBox(height: 30),

                    // عنوان القسم بناءً على الاختيار
                    Text(
                      isOmraSelected
                          ? 'خطوات العمرة بالتسلسل'.tr
                          : 'أعمال الحج بالتسلسل'.tr,
                      style:  TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     SizedBox(height: 25),

                    // عرض المناسك بناءً على النوع المختار
                    if (isOmraSelected)
                      ..._buildOmraSteps()
                    else
                      ..._buildHajjSteps(),

                     SizedBox(height: 40),

                    // خريطة المشاعر (إضافة لمسة تفاعلية)
                    _buildMapGuideCard(),
                     SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- خطوات العمرة ---
  List<Widget> _buildOmraSteps() {
    return [
      _buildStepItem(
        '1',
        'الإحرام',
        'النية من الميقات ولبس ملابس الإحرام وترديد التلبية.',
      ),
      _buildStepDivider(),
      _buildStepItem(
        '2',
        'الطواف',
        '7 أشواط حول الكعبة تبدأ وتنتهي عند الحجر الأسود.',
      ),
      _buildStepDivider(),
      _buildStepItem(
        '3',
        'صلاة الركعتين',
        'خلف مقام إبراهيم أو في أي مكان بالمسجد الحرام.',
      ),
      _buildStepDivider(),
      _buildStepItem('4', 'السعي', '7 أشواط بين الصفا والمروة تبدأ من الصفا.'),
      _buildStepDivider(),
      _buildStepItem('5', 'التحلل', 'الحلق أو التقصير (وبه تنتهي العمرة).'),
    ];
  }

  // --- خطوات الحج (ترتيب الأيام الشرعي) ---
  List<Widget> _buildHajjSteps() {
    return [
      _buildStepItem(
        '1',
        'الإحرام (يوم التروية)',
        'النية للحج من مكان إقامتك في مكة والتوجه لمنى.',
      ),
      _buildStepDivider(),
      _buildStepItem('2', 'الوقوف بعرفة', 'يوم 9 ذو الحجة (ركن الحج الأعظم).'),
      _buildStepDivider(),
      _buildStepItem(
        '3',
        'المبيت بمزدلفة',
        'بعد غروب شمس عرفة والجمع بين صلاتي المغرب والعشاء.',
      ),
      _buildStepDivider(),
      _buildStepItem(
        '4',
        'رمي جمرة العقبة',
        'يوم العيد (10 ذو الحجة) بسبع حصيات.',
      ),
      _buildStepDivider(),
      _buildStepItem('5', 'النحر والحلق', 'ذبح الهدي ثم حلق الرأس أو تقصيره.'),
      _buildStepDivider(),
      _buildStepItem(
        '6',
        'طواف الإفاضة',
        'النزول لمكة للطواف والسعي (سعي الحج).',
      ),
      _buildStepDivider(),
      _buildStepItem(
        '7',
        'أيام التشريق',
        'المبيت في منى ورمي الجمرات الثلاث يومياً.',
      ),
      _buildStepDivider(),
      _buildStepItem('8', 'طواف الوداع', 'آخر ما يفعله الحاج قبل مغادرة مكة.'),
    ];
  }

  // كارد اختيار نوع النسك
  Widget _buildTypeCard(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration:  Duration(milliseconds: 300),
          padding:  EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentGold : AppColors.secondaryDark,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.accentGold,
              width: isSelected ? 2 : 0.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accentGold.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.accentGold,
                size: 28,
              ),
               SizedBox(height: 8),
              Text(
                title.tr,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryDark : AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت خطوات المنسك
  Widget _buildStepItem(String number, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration:  BoxDecoration(
            color: AppColors.accentGold,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style:  TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
         SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.tr,
                style:  TextStyle(
                  color:  AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
               SizedBox(height: 6),
              Text(
                desc.tr,
                style:  TextStyle(
                  color:  AppColors.textWhite,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      margin:  EdgeInsets.only(left: 15, top: 5, bottom: 5),
      height: 25,
      width: 1.5,
      color: AppColors.accentGold.withOpacity(0.3),
    );
  }

  // كارد دليل خريطة المشاعر
  Widget _buildMapGuideCard() {
    return Container(
      width: double.infinity,
      padding:  EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                  'دليل المشاعر المقدسة'.tr,
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                 SizedBox(height: 8),
                 Text(
                  'تصفح خريطة منى، مزدلفة، وعرفة بكل سهولة.'.tr,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 13),
                ),
                 SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  ManasikMapPage(),
                      ),
                    );
                  },
                  icon:  Icon(Icons.map_outlined, size: 18),
                  label:  Text('فتح الخريطة'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGold,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
           Icon(
            Icons.location_on_rounded,
            color: AppColors.accentGold,
            size: 60,
          ),
        ],
      ),
    );
  }
}

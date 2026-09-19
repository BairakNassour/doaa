import 'package:autostart_settings/autostart_settings.dart';
import 'package:flutter/material.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/PrayerController.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// --- الوظائف الخارجية (Entry Points) ---
@pragma('vm:entry-point')
void fireAzan() async {
  const AndroidNotificationDetails azanNotificationDetails =
      AndroidNotificationDetails(
        'azan_play_channel_v5',
        'تنبيه الأذان الصوتي',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('azan'),
        ongoing: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'stop_azan_action',
            'إيقاف الأذان',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );

  await flutterLocalNotificationsPlugin.show(
    id: 202,
    title: '🕌 حان الآن موعد الصلاة',
    body: 'حي على الصلاة.. حي على الفلاح',
    notificationDetails: NotificationDetails(android: azanNotificationDetails),
  );
}

@pragma('vm:entry-point')
void resetNotificationTask() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLiveEnabled', false);
  await prefs.remove('lastEnabledDate');

  final flip = FlutterLocalNotificationsPlugin();
  await flip.cancel(id: 101);
  print("تنبيه: تم إغلاق تفعيل المواقيت تلقائياً لانتهاء اليوم.");
}

class PrayerTimesPage extends StatefulWidget {
  final PrayerController controller;
  const PrayerTimesPage({super.key, required this.controller});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  bool isLiveNotificationEnabled = false;
  Map<String, bool> prayerSettings = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _checkInitialState();
    _loadPrayerSettings();
  }

  Future<void> _loadPrayerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prayerSettings.forEach((key, value) {
        prayerSettings[key] = prefs.getBool('notif_$key') ?? true;
      });
    });
  }

  Future<void> _checkInitialState() async {
    final prefs = await SharedPreferences.getInstance();

    String? lastEnabledDate = prefs.getString('lastEnabledDate');
    String todayDate = DateTime.now().toIso8601String().split('T')[0];
    bool isStillValid = lastEnabledDate == todayDate;

    setState(() {
      if (isStillValid) {
        isLiveNotificationEnabled = prefs.getBool('isLiveEnabled') ?? false;
      } else {
        isLiveNotificationEnabled = false;
        prefs.setBool('isLiveEnabled', false);
        flutterLocalNotificationsPlugin.cancel(id: 101);
      }
    });

    bool hasHandledPermissions = prefs.getBool('permissionsHandled') ?? false;
    if (!hasHandledPermissions) {
      _handleAutoStartPermissions();
    }
  }

  Future<void> _handleAutoStartPermissions() async {
    final canOpen = await AutostartSettings.canOpen(
      autoStart: true,
      batterySafer: true,
    );

    if (canOpen && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.secondaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title:  Text(
            "تفعيل الأذان في الخلفية 🕌".tr,
            style: TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content:  Text(
            "لكي يعمل الأذان بدقة حتى عند إغلاق التطبيق، يرجى تفعيل 'التشغيل التلقائي' واختيار 'بلا قيود' للبطارية.".tr,
            style: TextStyle(color: AppColors.textWhite),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text("لاحقاً".tr, style: TextStyle(color: AppColors.textWhite)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
              ),
              onPressed: () async {
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('permissionsHandled', true);
                await AutostartSettings.open(
                  autoStart: true,
                  batterySafer: true,
                );
              },
              child:  Text(
                "اذهب للإعدادات".tr,
                style: TextStyle(color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitSettings);

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'stop_azan_action') {
          await flutterLocalNotificationsPlugin.cancel(id: 202);
          print("تم إيقاف الأذان");
        }
      },
    );
  }

// 1. وظيفة لتحويل الوقت من نظام 24 إلى 12 ساعة
String _formatTo12Hour(String time24) {
  try {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? "م" : "ص";
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute $period";
  } catch (e) {
    return time24; // في حال حدث خطأ أعد النص الأصلي
  }
}

Future<void> _showLiveNotification() async {
  final timings = widget.controller.prayerModel?.timings;
  if (timings == null) return;

  // 2. تحويل جميع الأوقات لنظام 12 ساعة
  String fajr = _formatTo12Hour(timings['Fajr']!);
  String dhuhr = _formatTo12Hour(timings['Dhuhr']!);
  String asr = _formatTo12Hour(timings['Asr']!);
  String maghrib = _formatTo12Hour(timings['Maghrib']!);
  String isha = _formatTo12Hour(timings['Isha']!);

  // 3. ترتيب النص للمحاذاة (أندرويد يعرض الإشعارات العربية RTL تلقائياً)
  // استخدمنا ترتيباً عكسياً في السلسلة النصية لضمان ظهورها من اليمين لليسار بشكل صحيح
  String rowNames = "العشاء     المغرب      العصر       الظهر        الفجر";
  String rowTimes = "$isha   $maghrib   $asr   $dhuhr   $fajr";

  // إضافة \u200f هو حرف التحكم (Right-to-Left Mark) لضمان المحاذاة العربية
  String fullTable = "\u200f$rowNames\n\u200f$rowTimes";

  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'prayer_times_royal_id',
    'مواقيت الصلاة اليومية',
    importance: Importance.max,
    priority: Priority.high,
    ongoing: true,
    autoCancel: false,
    showWhen: false,
    // تم استخدام BigTextStyleInformation لضمان ظهور الجدول كاملاً
    styleInformation: BigTextStyleInformation(
      fullTable,
      contentTitle: '🕌 مواقيت الصلاة - ${widget.controller.prayerModel?.city ?? "اليوم"}',
      summaryText: 'تطبيق دعاء',
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    id: 101,
    title: '🕌 مواقيت الصلاة اليوم',
    body: fullTable,
    notificationDetails: NotificationDetails(android: androidDetails),
  );
}

  // دالة طلب تصاريح الأندرويد الحديث (12، 13، 14)
  Future<void> _requestModernPermissions() async {
    // إذن الإشعارات
    await Permission.notification.request();
    // إذن المنبه الدقيق
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    String todayDate = DateTime.now().toIso8601String().split('T')[0];

    if (value) {
      await _requestModernPermissions();
      PermissionStatus notifyStatus = await Permission.notification.status;

      if (notifyStatus.isGranted) {
        setState(() => isLiveNotificationEnabled = true);
        await prefs.setBool('isLiveEnabled', true);
        await prefs.setString('lastEnabledDate', todayDate);
        await _schedulePrayers();
        await _showLiveNotification();
      }
    } else {
      setState(() => isLiveNotificationEnabled = false);
      await prefs.setBool('isLiveEnabled', false);
      await prefs.remove('lastEnabledDate');
      // إلغاء كافة المنبهات
      for (int i = 1; i <= 5; i++) await AndroidAlarmManager.cancel(i);
      await AndroidAlarmManager.cancel(888);
      await flutterLocalNotificationsPlugin.cancel(id: 101);
    }
  }

Future<void> _schedulePrayers() async {
    await AndroidAlarmManager.initialize();

    final p = widget.controller.prayerModel?.timings;
    if (p != null) {
      final now = DateTime.now();

      // حلقة تكرار لجدولة 3 أيام (0 تعني اليوم، 1 تعني غداً، 2 تعني بعد غد)
      for (int i = 0; i < 5; i++) {
        // حساب تاريخ اليوم المستهدف داخل الحلقة
        DateTime targetDay = now.add(Duration(days: i));

        // جدولة الصلوات الخمس لكل يوم مع تفريق الـ ID ديناميكياً
        // قمنا بضرب (i * 10) لضمان أن اليوم الأول يأخذ المعرفات (1,2,3..) واليوم الثاني (11,12,13..) وهكذا
        _scheduleSinglePrayerForDay(1 + (i * 10), 'Fajr', p['Fajr']!, targetDay);
        _scheduleSinglePrayerForDay(2 + (i * 10), 'Dhuhr', p['Dhuhr']!, targetDay);
        _scheduleSinglePrayerForDay(3 + (i * 10), 'Asr', p['Asr']!, targetDay);
        _scheduleSinglePrayerForDay(4 + (i * 10), 'Maghrib', p['Maghrib']!, targetDay);
        _scheduleSinglePrayerForDay(5 + (i * 10), 'Isha', p['Isha']!, targetDay);
      }

      // --- جدولة إيقاف الزر تلقائياً (بعد عشاء اليوم الثالث بـ 30 دقيقة) ---
      final ishaParts = p['Isha']!.split(':');
      final thirdDay = now.add(const Duration(days: 2)); // اليوم الثالث (index 2)
      
      final thirdDayIshaTime = DateTime(
        thirdDay.year,
        thirdDay.month,
        thirdDay.day,
        int.parse(ishaParts[0]),
        int.parse(ishaParts[1]),
      );

      // سيتم إطلاق دالة الإيقاف بعد عشاء اليوم الثالث بـ 30 دقيقة تماماً
      await AndroidAlarmManager.oneShotAt(
        thirdDayIshaTime.add(const Duration(minutes: 30)),
        888,
        resetNotificationTask,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      
      print("تمت جدولة الصلوات بنجاح لـ 3 أيام، وسيتم إيقاف الميزة تلقائياً بتاريخ: ${thirdDayIshaTime.add(const Duration(minutes: 30))}");
    }
  }

  /// دالة مساعدة جديدة تمرر لها التاريخ المستهدف لضمان جدولة الأيام القادمة بشكل صحيح
  /// (تأكد من تعديل دالتك الأصلية لتطابق هذا المنطق أو استبدلها بها)
  Future<void> _scheduleSinglePrayerForDay(int id, String name, String timeString, DateTime targetDate) async {
    final parts = timeString.split(':');
    final scheduledTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    // إذا كان الوقت المحسوب قد مضى لليوم (مثلاً صلاة الفجر اليوم انتهت)، نتخطى الجدول لها
    if (scheduledTime.isBefore(DateTime.now())) return;

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      id,
      fireAzan, // تأكد من أنها الدالة الممررة عندك بالأصل
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      alarmClock: true,
    );
  }

  void _scheduleSinglePrayer(int id, String key, String timeStr) async {
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('notif_$key') ?? true;

    if (!isEnabled) {
      await AndroidAlarmManager.cancel(id);
      return;
    }

    final now = DateTime.now();
    final components = timeStr.split(':');
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(components[0]),
      int.parse(components[1]),
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      id,
      fireAzan,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      alarmClock: true, // تحويله لمنبه رسمي في النظام
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final p = widget.controller.prayerModel?.timings;

        return Scaffold(
          backgroundColor: AppColors.secondaryDark,
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            leading: IconButton(
              icon:  Icon(
                Icons.arrow_back_ios,
                color: AppColors.accentGold,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title:  Text(
              'مواقيت الصلاة'.tr,
              style: TextStyle(
                color: AppColors.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeroSection(
                widget.controller.nextPrayerName ?? "جاري التحديث",
                widget.controller.remainingTime ?? "--:--",
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDark.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(35),
                    ),
                    border: Border.all(
                      color: AppColors.accentGold.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.only(top: 25),
                    children: [
                      _buildSwitchTile(),
                      const SizedBox(height: 20),
                      _buildPrayerCard(
                        'الفجر',
                        'Fajr',
                        p?['Fajr'] ?? '--:--',
                        Icons.wb_sunny_outlined,
                      ),
                      _buildPrayerCard(
                        'الظهر',
                        'Dhuhr',
                        p?['Dhuhr'] ?? '--:--',
                        Icons.wb_sunny,
                      ),
                      _buildPrayerCard(
                        'العصر',
                        'Asr',
                        p?['Asr'] ?? '--:--',
                        Icons.circle_outlined,
                        isNext: widget.controller.nextPrayerName == "العصر",
                      ),
                      _buildPrayerCard(
                        'المغرب',
                        'Maghrib',
                        p?['Maghrib'] ?? '--:--',
                        Icons.wb_twilight,
                        isNext: widget.controller.nextPrayerName == "المغرب",
                      ),
                      _buildPrayerCard(
                        'العشاء',
                        'Isha',
                        p?['Isha'] ?? '--:--',
                        Icons.nightlight_outlined,
                        isNext: widget.controller.nextPrayerName == "العشاء",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(String name, String time) {
    return Column(
      children: [
        Text(
          '$name القادم خلال'.tr,
          style:  TextStyle(color: AppColors.textGrey),
        ),
        Text(
          time,
          style:  TextStyle(
            color: AppColors.textWhite,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.2)),
      ),
      child: ListTile(
        title:  Text(
          'إشعار المواقيت الدائم (ليوم واحد)'.tr,
          style: TextStyle(color: AppColors.textWhite, fontSize: 14),
        ),
        trailing: Switch(
          value: isLiveNotificationEnabled,
          activeColor: AppColors.accentGold,
          onChanged: _toggleNotification,
        ),
      ),
    );
  }

  Widget _buildPrayerCard(
    String label,
    String key,
    String time,
    IconData icon, {
    bool isNext = false,
  }) {
    bool isEnabled = prayerSettings[key] ?? true;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? AppColors.accentGold.withOpacity(0.08) :AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNext
              ? AppColors.accentGold.withOpacity(0.5)
              :  AppColors.textWhite.withOpacity(0.05),
          width: isNext ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isNext ? AppColors.accentGold : AppColors.textGrey,
                size: 22,
              ),
              const SizedBox(width: 15),
              Text(
                label.tr,
                style: TextStyle(
                  color: isNext ? AppColors.textWhite : AppColors.textGrey,
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  color: isNext ? AppColors.accentGold : AppColors.textWhite,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 15),
              IconButton(
                icon: Icon(
                  isEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: isEnabled ? AppColors.accentGold : Colors.grey,
                  size: 20,
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    prayerSettings[key] = !isEnabled;
                  });
                  await prefs.setBool('notif_$key', !isEnabled);
                  if (isLiveNotificationEnabled) {
                    _schedulePrayers();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

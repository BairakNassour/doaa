import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:doaa/component/app_colors.dart';

class NearbyMosquesPage extends StatefulWidget {
  const NearbyMosquesPage({super.key});

  @override
  State<NearbyMosquesPage> createState() => _NearbyMosquesPageState();
}

class _NearbyMosquesPageState extends State<NearbyMosquesPage> {
  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  List<Map<String, String>> mosquesList = [];
  bool isLoading = true;
  String? errorMessage;
  LatLng? selectedLocation; // حفظ الموقع الذي تم النقر عليه

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // جلب الموقع الحالي للمستخدم
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        errorMessage = "خدمة تحديد الموقع (GPS) غير مفعلة".tr;
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          errorMessage = "تم رفض إذن الوصول للموقع".tr;
          isLoading = false;
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = position;
    });

    // جلب المساجد باستخدام الموقع الحالي
    _fetchNearbyMosquesOSM(position.latitude, position.longitude);
  }

  // الدالة التي يتم استدعاؤها عند النقر على الخريطة
  void _onMapTapped(LatLng position) {
    setState(() {
      selectedLocation = position;
      isLoading = true; // إظهار مؤشر التحميل عند النقر
    });

    // تحريك الكاميرا إلى الموقع المحدد وتكبير الخريطة قليلاً
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, 14),
    );

    // البحث عن المساجد حول الموقع الذي تم النقر عليه
    _fetchNearbyMosquesOSM(position.latitude, position.longitude);
  }

  // جلب المساجد القريبة باستخدام Overpass API المجانية
  // تم تعديل الدالة لتقبل الإحداثيات (latitude, longitude) بدلاً من كائن Position
  Future<void> _fetchNearbyMosquesOSM(double latitude, double longitude) async {
    try {
      const double radiusInMeters = 3000; // نطاق البحث (3 كم)

      // استعلام Overpass QL باستخدام الإحداثيات الممررة
      final String query = '''
        [out:json][timeout:25];
        (
          node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusInMeters,$latitude,$longitude);
          way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusInMeters,$latitude,$longitude);
        );
        out center;
      ''';

      // قائمة سيرفرات Overpass
      final List<String> endpoints = [
        'https://overpass.kumi.systems/api/interpreter',
        'https://lz4.overpass-api.de/api/interpreter',
        'https://overpass-api.de/api/interpreter',
      ];

      http.Response? response;

      // تجربة السيرفرات بالترتيب
      for (String url in endpoints) {
        try {
          final res = await http.post(
            Uri.parse(url),
            headers: {
              'User-Agent': 'DoaaIslamicApp/1.0 (MobileApp)',
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
            },
            body: {'data': query},
          ).timeout(const Duration(seconds: 10));

          if (res.statusCode == 200) {
            response = res;
            break; // نجح الطلب، خروج من الحلقة
          }
        } catch (_) {
          continue;
        }
      }

      // حماية التحديث في حال تم إغلاق الواجهة أثناء جلب البيانات
      if (!mounted) return;

      if (response != null && response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List elements = data['elements'];

        Set<Marker> tempMarkers = {};
        List<Map<String, String>> tempMosques = [];

        // إضافة علامة للموقع الذي تم النقر عليه (إذا كان موجوداً)
        if (selectedLocation != null) {
          tempMarkers.add(
            Marker(
              markerId: const MarkerId('selected_location'),
              position: selectedLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // لون مختلف لتمييزه
              infoWindow: InfoWindow(title: "الموقع المحدد".tr),
            ),
          );
        }

        for (var element in elements) {
          double lat = element['lat'] ?? element['center']?['lat'] ?? 0.0;
          double lon = element['lon'] ?? element['center']?['lon'] ?? 0.0;

          String name = element['tags']?['name'] ??
              element['tags']?['name:ar'] ??
              "مسجد".tr;

          String address = element['tags']?['addr:street'] ??
              element['tags']?['vicinity'] ??
              " بالقرب من الموقع المحدد".tr;

          tempMarkers.add(
            Marker(
              markerId: MarkerId(element['id'].toString()),
              position: LatLng(lat, lon),
              infoWindow: InfoWindow(title: name, snippet: address),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange,
              ),
            ),
          );

          tempMosques.add({'name': name, 'address': address});
        }

        setState(() {
          markers = tempMarkers;
          mosquesList = tempMosques;
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = "عذراً، تعذر جلب المساجد حالياً. أعد المحاولة.".tr;
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "تعذر الاتصال بالشبكة: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'المساجد القريبة'.tr,
          style: TextStyle(
            color: AppColors.accentGold,
            fontFamily: 'QuranFont',
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // جزء الخريطة
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: currentPosition == null
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGold,
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            currentPosition!.latitude,
                            currentPosition!.longitude,
                          ),
                          zoom: 14,
                        ),
                        onMapCreated: (controller) =>
                            mapController = controller,
                        markers: markers,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        onTap: _onMapTapped, // إضافة حدث النقر على الخريطة
                      ),
              ),
            ),
          ),

          // عرض رسالة الخطأ إن وجدت
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 30,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // عنوان القائمة و زر إعادة التعيين
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(selectedLocation != null) // إظهار زر إعادة التعيين فقط إذا تم تحديد موقع
                  TextButton.icon(
                      onPressed: (){
                         setState(() {
                           selectedLocation = null;
                         });
                         _determinePosition(); // إعادة جلب المساجد حول الموقع الحالي للمستخدم
                      },
                      icon: Icon(Icons.my_location, color: AppColors.accentGold, size: 18,),
                      label: Text(
                        "موقعي".tr,
                        style: TextStyle(color: AppColors.accentGold),
                      ),
                  )
                else const SizedBox(),
                
                Text(
                  "اكتشف المساجد من حولك".tr,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // قائمة المساجد
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentGold,
                    ),
                  )
                : mosquesList.isEmpty
                    ? Center(
                        child: Text(
                          "لم يتم العثور على مساجد قريبة في نطاق 3 كم".tr,
                          style: TextStyle(color: AppColors.textWhite),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: mosquesList.length,
                        itemBuilder: (context, index) {
                          var mosque = mosquesList[index];
                          return _buildMosqueCard(
                            name: mosque['name']!,
                            address: mosque['address']!,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosqueCard({required String name, required String address}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.textWhite.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mosque, color: AppColors.accentGold, size: 30),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.textWhite, fontSize: 13),
        ),
        trailing: Icon(Icons.directions_outlined, color: AppColors.textWhite),
        onTap: () {
          // يمكن فتح التوجيه للموقع هنا
        },
      ),
    );
  }
}
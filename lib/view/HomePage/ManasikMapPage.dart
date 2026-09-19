import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ManasikMapPage extends StatefulWidget {
   ManasikMapPage({super.key});

  @override
  State<ManasikMapPage> createState() => _ManasikMapPageState();
}

class _ManasikMapPageState extends State<ManasikMapPage> {
  late GoogleMapController mapController;

  // إحداثيات المشاعر المقدسة
  static  LatLng _center = LatLng(21.4225, 39.8262); // الكعبة المشرفة

  final Map<String, Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.clear();
      _addMarker('alharam',  LatLng(21.4225, 39.8262), 'المسجد الحرام'.tr, 'بداية الطواف والسعي'.tr);
      _addMarker('mina',  LatLng(21.4162, 39.8914), 'مشعر منى'.tr, 'المبيت ورمي الجمرات'.tr);
      _addMarker('muzda',  LatLng(21.3891, 39.9326), 'مشعر مزدلفة'.tr, 'المبيت بعد عرفة'.tr);
      _addMarker('arafa',  LatLng(21.3548, 39.9841), 'جبل عرفات'.tr, 'ركن الحج الأعظم'.tr);
    });
  }

  void _addMarker(String id, LatLng pos, String title, String snippet) {
    var marker = Marker(
      markerId: MarkerId(id),
      position: pos,
      infoWindow: InfoWindow(title: title, snippet: snippet),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
    _markers[id] = marker;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      appBar: AppBar(
        title:  Text('خريطة المناسك والمشاعر'.tr, style: TextStyle(color: AppColors.accentGold)),
        backgroundColor: AppColors.secondaryDark,
        iconTheme:  IconThemeData(color: AppColors.accentGold),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition:  CameraPosition(target: _center, zoom: 12.0),
        markers: _markers.values.toSet(),
        myLocationEnabled: true,
        mapType: MapType.hybrid, // هجين لإظهار تفاصيل الأرض والمباني
      ),
    );
  }
}
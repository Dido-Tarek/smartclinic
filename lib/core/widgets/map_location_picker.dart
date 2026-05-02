import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartclinic/core/constants/app_color.dart';
import 'package:smartclinic/core/localization/app_localization.dart';

class MapLocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapLocationPickerScreen({super.key, this.initialLocation});

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  late GoogleMapController _mapController;
  late LatLng _selectedLocation;
  Set<Marker> _markers = {};

  // Major Egyptian cities with coordinates
  static final Map<String, LatLng> _egyptianCities = {
    'Cairo': const LatLng(30.0444, 31.2357),
    'Alexandria': const LatLng(31.2001, 29.9187),
    'Giza': const LatLng(30.0131, 31.1889),
    'Qalyubia': const LatLng(30.3588, 31.1892),
    'Monufia': const LatLng(30.5466, 30.9686),
    'Dakahlia': const LatLng(31.1359, 31.4273),
    'Damietta': const LatLng(31.4166, 31.8128),
    'Port Said': const LatLng(31.2604, 31.8092),
    'Ismailia': const LatLng(30.5957, 32.2732),
    'Suez': const LatLng(29.9668, 32.5498),
    'North Sinai': const LatLng(31.1043, 33.5102),
    'South Sinai': const LatLng(28.0271, 33.7669),
    'Red Sea': const LatLng(27.2544, 33.7937),
    'Matruh': const LatLng(31.3546, 27.2426),
    'New Valley': const LatLng(25.4898, 30.5553),
    'Aswan': const LatLng(23.9699, 32.8872),
    'Luxor': const LatLng(25.6872, 32.6396),
    'Sohag': const LatLng(26.5571, 31.6948),
    'Qena': const LatLng(26.1552, 32.7256),
    'Assiut': const LatLng(27.1808, 31.1853),
    'Minya': const LatLng(28.1098, 30.7503),
    'Beni Suef': const LatLng(29.0669, 30.8935),
    'Faiyum': const LatLng(29.3084, 30.8428),
    'Sharqia': const LatLng(30.5469, 31.4872),
    'Gharbia': const LatLng(30.7751, 31.0289),
    'Kafr El-Sheikh': const LatLng(31.1134, 30.9375),
    'Beheira': const LatLng(31.0263, 30.4028),
  };

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ??
        const LatLng(30.0444, 31.2357); // Default to Cairo
    _updateMarker();
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          infoWindow: const InfoWindow(title: 'Selected Location'),
        ),
      };
    });
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _updateMarker();
    });
  }

  void _selectCity(String cityName) {
    final location = _egyptianCities[cityName];
    if (location != null) {
      setState(() {
        _selectedLocation = location;
        _updateMarker();
      });
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(location, 12));
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.textPrimary,
        title: Text(localizations.translate('select_location')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _selectedLocation,
                zoom: 10,
              ),
              markers: _markers,
              onTap: _onMapTapped,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _egyptianCities.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cityName = _egyptianCities.keys.elementAt(index);
                      return ActionChip(
                        label: Text(cityName),
                        onPressed: () => _selectCity(cityName),
                        backgroundColor: AppColors.cardBg,
                        side: const BorderSide(color: AppColors.textPrimary),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _confirmLocation,
                  child: Text(
                    localizations.translate('confirm'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

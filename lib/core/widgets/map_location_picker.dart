import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
	static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

	late LatLng _selectedLocation;

	@override
	void initState() {
		super.initState();
		_selectedLocation = widget.initialLocation ?? _defaultLocation;
	}

	void _onMapTapped(LatLng location) {
		setState(() {
			_selectedLocation = location;
		});
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
				backgroundColor: AppColors.deepNavy,
				foregroundColor: Colors.white,
				title: Text(localizations.translate('facility_location_title')),
				centerTitle: true,
			),
			body: Column(
				children: [
					Expanded(
						child: FlutterMap(
							options: MapOptions(
								initialCenter: _selectedLocation,
								initialZoom: 13,
								onTap: (_, point) => _onMapTapped(point),
							),
							children: [
								TileLayer(
									urlTemplate:
											'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
									userAgentPackageName: 'smartclinic',
								),
								MarkerLayer(
									markers: [
										Marker(
											point: _selectedLocation,
											width: 52,
											height: 52,
											child: const Icon(
												Icons.location_pin,
												size: 52,
												color: Colors.redAccent,
											),
										),
									],
								),
							],
						),
					),
					Container(
						width: double.infinity,
						padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: const BorderRadius.vertical(
								top: Radius.circular(24),
							),
							boxShadow: [
								BoxShadow(
									color: Colors.black.withValues(alpha: 0.08),
									blurRadius: 16,
									offset: const Offset(0, -4),
								),
							],
						),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								Text(
									'${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
									textAlign: TextAlign.center,
									style: const TextStyle(
										color: AppColors.textPrimary,
										fontSize: 15,
										fontWeight: FontWeight.w600,
									),
								),
								const SizedBox(height: 10),
								Text(
									localizations.translate('facility_location_subtitle'),
									textAlign: TextAlign.center,
									style: const TextStyle(
										color: AppColors.textSecondary,
										fontSize: 13,
									),
								),
								const SizedBox(height: 16),
								ElevatedButton(
									style: ElevatedButton.styleFrom(
										backgroundColor: AppColors.deepNavy,
										foregroundColor: Colors.white,
										minimumSize: const Size.fromHeight(50),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(14),
										),
									),
									onPressed: _confirmLocation,
									child: Text(
										localizations.translate('confirm'),
										style: const TextStyle(
											fontSize: 16,
											fontWeight: FontWeight.w700,
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
}

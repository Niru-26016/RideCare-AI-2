import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class VehicleMapWidget extends StatefulWidget {
  final Map<String, dynamic>? vehicleData;
  final String? vehicleId;
  final bool showServiceCenters;

  const VehicleMapWidget({
    super.key,
    this.vehicleData,
    this.vehicleId,
    this.showServiceCenters = false,
  });

  @override
  State<VehicleMapWidget> createState() => _VehicleMapWidgetState();
}

class _VehicleMapWidgetState extends State<VehicleMapWidget> {
  GoogleMapController? _mapController;

  LatLng get _vehicleLocation {
    final loc = widget.vehicleData?['location'];
    if (loc != null && loc is Map) {
      return LatLng(
        (loc['lat'] ?? 13.0827).toDouble(),
        (loc['lng'] ?? 80.2707).toDouble(),
      );
    }
    // Default: Chennai
    return const LatLng(13.0827, 80.2707);
  }

  Set<Marker> get _markers {
    final score = (widget.vehicleData?['score'] ?? 100).toDouble();
    final driverName = widget.vehicleData?['info']?['driver'] ?? 'Driver';
    final model = widget.vehicleData?['info']?['model'] ?? 'Vehicle';
    final state = widget.vehicleData?['state'] ?? 'Unknown';

    BitmapDescriptor markerColor;
    if (score >= 80) {
      markerColor = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      );
    } else if (score >= 60) {
      markerColor = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueOrange,
      );
    } else {
      markerColor = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      );
    }

    final vehicleMarker = Marker(
      markerId: MarkerId(widget.vehicleId ?? 'vehicle'),
      position: _vehicleLocation,
      icon: markerColor,
      infoWindow: InfoWindow(
        title: '$driverName — ${widget.vehicleId}',
        snippet: '$model • Score: ${score.round()} • $state',
      ),
    );

    final markers = <Marker>{vehicleMarker};

    if (widget.showServiceCenters) {
      // Hardcoded service centers around Chennai area
      final serviceCenters = [
        const LatLng(13.0800, 80.2600), // Nearby 1
        const LatLng(13.0900, 80.2800), // Nearby 2
        const LatLng(13.0750, 80.2550), // Nearby 3
      ];

      for (var i = 0; i < serviceCenters.length; i++) {
        markers.add(
          Marker(
            markerId: MarkerId('service_center_$i'),
            position: serviceCenters[i],
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: 'RideCare Service Center ${i + 1}',
              snippet: 'Open until 7:00 PM',
            ),
          ),
        );
      }
    }

    return markers;
  }

  @override
  void didUpdateWidget(VehicleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vehicleData != oldWidget.vehicleData) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_vehicleLocation));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = widget.vehicleData?['location'] != null;

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _vehicleLocation,
            zoom: 14,
          ),
          markers: _markers,
          onMapCreated: (controller) => _mapController = controller,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          style: _darkMapStyle,
        ),
        // Gradient overlay at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bg.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 14,
                  color: AppColors.indigoLight,
                ),
                const SizedBox(width: 6),
                Text(
                  hasLocation ? 'Live Location' : 'Default Location',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#121212"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "administrative.country",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#9e9e9e"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#bdbdbd"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#181818"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1b1b1b"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{"color": "#373737"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#3c3c3c"}]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry",
    "stylers": [{"color": "#4e4e4e"}]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#616161"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#3d3d3d"}]
  }
]
''';
}

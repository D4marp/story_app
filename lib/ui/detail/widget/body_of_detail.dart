import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story_app/data/model/response/detail/stories_detail.dart';
import '../../../core/components/avatar_name_widget.dart';
import '../../home/widget/image_stories.dart';

class BodyOfDetail extends StatefulWidget {
  final Story data;

  const BodyOfDetail({super.key, required this.data});

  @override
  State<BodyOfDetail> createState() => _BodyOfDetailState();
}

class _BodyOfDetailState extends State<BodyOfDetail> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  String? street;
  String? address;

  @override
  void initState() {
    super.initState();
    if (widget.data.lat != null && widget.data.lon != null) {
      _fetchLocationInfo(LatLng(widget.data.lat!, widget.data.lon!));
    }
  }

  Future<void> _fetchLocationInfo(LatLng position) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          street = place.street ?? 'Unknown Street';
          address =
              '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
          markers.clear();
          markers.add(
            Marker(
              markerId: MarkerId(widget.data.id ?? "default_id"),
              position: position,
              infoWindow: InfoWindow(title: street, snippet: address),
              onTap: () {
                mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(position, 18),
                );
              },
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch location info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const defaultLatLng = LatLng(-6.256081, 106.618755);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            markers: markers,
            initialCameraPosition: CameraPosition(
              zoom: 18,
              target: widget.data.lat != null && widget.data.lon != null
                  ? LatLng(widget.data.lat!, widget.data.lon!)
                  : defaultLatLng,
            ),
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
          ),
          if (widget.data.lat == null || widget.data.lon == null)
            const Center(
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Location not detected',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.25,
            maxChildSize: 0.65,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12.0),
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: ImageStory(
                          imageUrl: widget.data.photoUrl ?? '',
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      AvatarName(name: widget.data.name ?? '',),
                      const SizedBox(height: 16.0),
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.data.description ?? 'No description available.',
                        style:
                            theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                      ),
                      if (street != null && address != null) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.location_pin,
                                color: Colors.redAccent),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                '$street, $address',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24.0),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

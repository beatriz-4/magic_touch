import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart';
import 'package:geolocator/geolocator.dart';
// Map API key
final String _mapTilerUrl =
    'https://api.maptiler.com/maps/base-v4/{z}/{x}/{y}.png?key=5KWZ1qU530QesXBAIqZe';
class LocationPage extends StatefulWidget {
  const LocationPage({super.key});
  @override
  State<LocationPage> createState() => _LocationPageState();
}
class _LocationPageState extends State<LocationPage> {
  // Map controller
  late final MapController _map;
  late final TextEditingController _search;
  bool isSearching = false;
  // Default location for the store
  final LatLng storeLocation = const LatLng(
    1.5156858,110.3881893,
    //1.4682883037428034,
    //110.42905278648189,   letak location kedei sitok
  );
  @override
  void initState() {
    super.initState();
    _map = MapController();
    _search = TextEditingController();
  }
  @override
  void dispose() {
    _map.dispose();
    _search.dispose();
    super.dispose();
  }
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
  void _searchLocation() async {
    if (isSearching) return;
    final searchedLocation = _search.text.trim();
    if (searchedLocation.isEmpty) return;
    setState(() => isSearching = true);
    _search.clear();
    _showSnackBar('Searching for $searchedLocation...');
    final location = await FmService().getGeocode(address: searchedLocation);
    if (location?.lat != null && location?.lng != null) {
      _map.move(LatLng(location!.lat, location.lng), 16);
      _showSnackBar(
        'Found (${location.lat}, ${location.lng})',
      );
    } else {
      _showSnackBar('$searchedLocation not found');
    }
    setState(() => isSearching = false);
  }
  Future<void> _locateMe() async {
    if (isSearching) return;
    setState(() => isSearching = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services disabled');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permission denied');
        return;
      }
      Position position = await Geolocator.getCurrentPosition();
      _map.move(
        LatLng(position.latitude, position.longitude),
        16,
      );
      _showSnackBar('Our Location');
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => isSearching = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7E2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F7E2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Our Location",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // search
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ),
              onSubmitted: (_) => _searchLocation(),
            ),
            const SizedBox(height: 15),
            // container untuk map
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 350,
                child: FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: storeLocation,
                    initialZoom: 15,
                    minZoom: 14,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _mapTilerUrl,
                      userAgentPackageName: 'com.example.magic_touch',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: storeLocation,
                          width: 80,
                          height: 80,
                          child: Column(
                            children: const [
                              Icon(Icons.location_pin, color: Colors.red),
                              Text('Our Location'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Visit us at: 70, Lor 3, Tabuan Jaya, 93350 Kuching, Sarawak",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

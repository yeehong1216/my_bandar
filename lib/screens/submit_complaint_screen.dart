import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/geocoder_service.dart';
import '../theme/app_theme.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedPhotoPath;
  bool _isFetchingLocation = true;
  bool _isGeocoding = false;

  // Map state
  LatLng _currentLatLng = const LatLng(3.1570, 101.7122); // KL default
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  // ──────────────────────────────────────────────
  //  LOCATION: request permission then fetch GPS
  // ──────────────────────────────────────────────
  Future<void> _fetchLocation() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _onLocationFailed();
        return;
      }

      // 2. Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      // 3. If denied, request it (the OS popup appears here)
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionSnackBar();
          _onLocationFailed();
          return;
        }
      }

      // 4. Permanently denied — can't ask again
      if (permission == LocationPermission.deniedForever) {
        _showPermissionSnackBar();
        _onLocationFailed();
        return;
      }

      // 5. Permission granted — fetch position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 6. Reverse-geocode to a human-readable address
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = [
          p.street,
          p.subLocality,
          p.locality,
          p.postalCode,
          p.country,
        ].where((s) => s != null && s.isNotEmpty);

        setState(() {
          _currentLatLng = LatLng(position.latitude, position.longitude);
          _addressController.text = parts.join(', ');
          _isFetchingLocation = false;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentLatLng),
        );
      } else {
        _onLocationFailed();
      }
    } catch (_) {
      // Network / platform errors fall back to a mock address
      _onLocationFailed();
    }
  }

  void _onLocationFailed() {
    if (!mounted) return;
    setState(() {
      _addressController.text =
          'Jalan Tun Razak, 50400 Kuala Lumpur, Malaysia';
      _isFetchingLocation = false;
    });
  }

  // ──────────────────────────────────────────────
  //  GEOCODE: convert address text → map location
  //  Uses Maps JS API Geocoder on web (no extra API needed)
  // ──────────────────────────────────────────────
  Future<void> _geocodeAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;

    setState(() => _isGeocoding = true);

    try {
      final result = await geocodeAddress(address);

      if (result != null && result.error == null && mounted) {
        setState(() {
          _currentLatLng = LatLng(result.lat, result.lng);
          _addressController.text = result.formattedAddress;
          _isGeocoding = false;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentLatLng),
        );
        return;
      }

      // Show actual error from geocoder
      if (mounted) {
        final errorMsg = result?.error ?? 'No result';
        setState(() => _isGeocoding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Geocoder error: $errorMsg'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeocoding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exception: $e'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ──────────────────────────────────
  //  CAMERA: permission before capture
  // ──────────────────────────────────
  Future<void> _takePhoto() async {
    // 1. Check current camera permission
    var status = await Permission.camera.status;

    // 2. If not granted, request it
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) _showPermissionSnackBar();
        return;
      }
    }

    // 3. Permission granted — open camera
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      setState(() => _selectedPhotoPath = photo.path);
    }
  }

  // ──────────────────────────
  //  Shared permission snackbar
  // ──────────────────────────
  void _showPermissionSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Permission is required to use this feature.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ───────────────
  //  Bottom sheet
  // ───────────────
  void _showPhotoBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Add Photo',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              _BottomSheetOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto(); // permission-aware
                },
              ),
              const SizedBox(height: 8),
              _BottomSheetOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final photo =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (photo != null && mounted) {
                    setState(() => _selectedPhotoPath = photo.path);
                  }
                },
              ),
              const SizedBox(height: 8),
              _BottomSheetOption(
                icon: Icons.close_rounded,
                label: 'Cancel',
                isDestructive: true,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please wait for location or enter an address'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/verify',
      arguments: {
        'address': address,
        'photoPath': _selectedPhotoPath,
        'description': _descriptionController.text.trim(),
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Section
                    Text('Photo',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _showPhotoBottomSheet,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGrey,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: _selectedPhotoPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: AppTheme.primaryBlue
                                          .withValues(alpha: 0.1),
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_rounded,
                                          size: 48,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color:
                                              AppTheme.completeGreen,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check,
                                                color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text('Photo added',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Choose photo',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Description (Optional) Section ──
                    Text('Description (Optional)',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Briefly describe the issue (e.g., deep pothole, fallen tree)...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundGrey,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryBlue, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Place Section ──
                    Text('Place',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: TextField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  hintText: _isFetchingLocation
                                      ? 'Fetching location...'
                                      : 'Enter address & tap 📍 to update map',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  fillColor: Colors.transparent,
                                  filled: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                                onSubmitted: (_) => _geocodeAddress(),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (_isFetchingLocation || _isGeocoding)
                                ? null
                                : _geocodeAddress,
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: (_isFetchingLocation || _isGeocoding)
                                  ? const Padding(
                                      padding: EdgeInsets.all(14),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.location_on_rounded,
                                      color: AppTheme.primaryBlue,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Live Map Preview ──
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentLatLng,
                          zoom: 16,
                        ),
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('issue_location'),
                            position: _currentLatLng,
                          ),
                        },
                      ),
                    ),


                  ],
                ),
              ),
            ),

            // Bottom Submit Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: const Text('Submit Complaint'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.cancelRed : AppTheme.primaryBlue,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppTheme.cancelRed : AppTheme.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

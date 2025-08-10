import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../services/post_service.dart';
import '../widgets/dual_camera_widget.dart';
import '../widgets/countdown_timer.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late CameraService _cameraService;
  bool _isLoading = true;
  String? _caption;
  bool _locationEnabled = false;
  int _retakeCount = 0;

  @override
  void initState() {
    super.initState();
    _cameraService = context.read<CameraService>();
    // Defer initialization until after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  Future<void> _initializeCamera() async {
    if (!_cameraService.isInitialized && !_cameraService.isInitializing) {
      try {
        await _cameraService.initialize();
      } catch (e) {
        debugPrint('Failed to initialize camera: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Camera initialization failed: $e')),
          );
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _captureAndPost() async {
    try {
      final images = await _cameraService.captureImages();
      if (images != null && mounted) {
        final postService = context.read<PostService>();
        await postService.createPost(
          rearImage: images['rear']!,
          frontImage: images['front']!,
          caption: _caption,
          locationEnabled: _locationEnabled,
          retakeCount: _retakeCount,
        );
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

  void _retake() {
    setState(() {
      _retakeCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Take your Real'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const CountdownTimer(),
          Expanded(
            child: DualCameraWidget(
              cameraService: _cameraService,
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_retakeCount > 0)
            Text(
              'Retakes: $_retakeCount',
              style: const TextStyle(color: Colors.white70),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add a caption...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _caption = value.isEmpty ? null : value;
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _locationEnabled = !_locationEnabled;
                  });
                },
                icon: Icon(
                  _locationEnabled ? Icons.location_on : Icons.location_off,
                  color: _locationEnabled ? Colors.blue : Colors.white54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_retakeCount < 1)
                TextButton(
                  onPressed: _retake,
                  child: const Text(
                    'Retake',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ElevatedButton(
                onPressed: _captureAndPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                child: const Icon(Icons.camera_alt, size: 30),
              ),
              const SizedBox(width: 60),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService extends ChangeNotifier {
  List<CameraDescription> _cameras = [];
  CameraController? _rearController;
  CameraController? _frontController;
  bool _isInitialized = false;

  List<CameraDescription> get cameras => _cameras;
  CameraController? get rearController => _rearController;
  CameraController? get frontController => _frontController;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      
      final rearCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );

      _rearController = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _frontController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await Future.wait([
        _rearController!.initialize(),
        _frontController!.initialize(),
      ]);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      throw Exception('Failed to initialize cameras: $e');
    }
  }

  Future<Map<String, XFile>?> captureImages() async {
    if (!_isInitialized || _rearController == null || _frontController == null) {
      throw Exception('Cameras not initialized');
    }

    try {
      final futures = await Future.wait([
        _rearController!.takePicture(),
        _frontController!.takePicture(),
      ]);

      return {
        'rear': futures[0],
        'front': futures[1],
      };
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  Future<void> switchCameras() async {
    if (!_isInitialized) return;

    final tempController = _rearController;
    _rearController = _frontController;
    _frontController = tempController;
    
    notifyListeners();
  }

  @override
  void dispose() {
    _rearController?.dispose();
    _frontController?.dispose();
    super.dispose();
  }
}
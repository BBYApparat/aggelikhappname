import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class DualCameraWidget extends StatelessWidget {
  final CameraService cameraService;

  const DualCameraWidget({
    super.key,
    required this.cameraService,
  });

  @override
  Widget build(BuildContext context) {
    if (!cameraService.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      children: [
        _buildMainCamera(),
        _buildPictureInPicture(),
        _buildSwitchButton(),
      ],
    );
  }

  Widget _buildMainCamera() {
    final controller = cameraService.rearController;
    if (controller == null) return Container();

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildPictureInPicture() {
    final controller = cameraService.frontController;
    if (controller == null) return Container();

    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildSwitchButton() {
    return Positioned(
      top: 20,
      right: 20,
      child: GestureDetector(
        onTap: cameraService.switchCameras,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.flip_camera_ios,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
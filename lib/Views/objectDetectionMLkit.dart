import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:pothole_detection_realtime/Controller/MLkitController.dart';

class MLkitDetection extends StatelessWidget {
  const MLkitDetection({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(
          () {
            MLkitController controller =
                Get.put<MLkitController>(MLkitController());

            return controller.isCameraInitialized.value
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: CameraPreview(controller.cameraController),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: BoundingBoxPainter(),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  BoundingBoxPainter();

  var objects = Get.find<MLkitController>().detectedObjects;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (var detectedObject in objects) {
      final rect = detectedObject.boundingBox;

      final left = rect.left * size.width;
      final top = rect.top * size.height;
      final right = rect.right * size.width;
      final bottom = rect.bottom * size.height;

      canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

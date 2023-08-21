import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pothole_detection_realtime/Controller/detectionController.dart';
import 'dart:math' as math;

class ObjectDetection extends StatelessWidget {
  const ObjectDetection({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GetBuilder<DetectionController>(
            init: DetectionController(),
            builder: (controller) {
              return controller.isCameraInitialized.value
                  ? Stack(
                      children: [
                        CameraPreview(controller.cameraController),
                        Positioned(
                          left: math.max(0, controller.x),
                          top: math.max(0, controller.y),
                          width: controller.objWidth,
                          height: controller.objHeight,
                          child: Container(
                            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.amber,
                                width: 3.0,
                              ),
                            ),
                            child: Text(
                              "${controller.objectLabel}",
                              //  ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
                              style: const TextStyle(
                                color: Color.fromRGBO(37, 213, 253, 1.0),
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // child: Container(
                          //   // width: controller.objWidth *
                          //   //     MediaQuery.of(context).size.width,
                          //   // height: controller.objHeight *
                          //   //     MediaQuery.of(context).size.height,
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //       color: Colors.amber,
                          //       width: 3,
                          //     ),
                          //   ),
                          //   child: Column(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Container(
                          //         color: Colors.white,
                          //         child:
                          //             Text(controller.objectLabel.toString()),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ),
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    );
            }),
      ),
    );
  }
}

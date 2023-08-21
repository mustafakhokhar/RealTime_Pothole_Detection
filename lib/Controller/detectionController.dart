import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';

class DetectionController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  late CameraImage cameraImage;

  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  var x = 0.0;
  var y = 0.0;
  var objWidth = 0.0;
  var objHeight = 0.0;
  String? objectLabel = '';

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFlite();
  }

  @override
  void onClose() {
    super.onClose();
    cameraController.dispose();
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.bgra8888);
      await cameraController.initialize().then((value) {
        cameraController.startImageStream((CameraImage image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            // print('object');
            objectDetector(image);
          }
          update();
        });
      });
      isCameraInitialized(true);
      update();
    } else {
      print('Permission denied');
    }
  }

  initTFlite() async {
    Tflite.close();
    var res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/label.txt",
      isAsset: true,
      numThreads: 2,
      useGpuDelegate: false,
    );
    print("Result after loading model: $res");
  }

  objectDetector(CameraImage image) async {
    await Tflite.detectObjectOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      model: "SSDMobileNet",
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      threshold: 0.5,
      // numResults: 1,
      asynch: true,
    ).then((recognitions) {
      if (recognitions!.isNotEmpty) {
        print("recognitions: $recognitions");

        var h = recognitions.first["rect"]["h"];
        var w = recognitions.first["rect"]["w"];
        var x = recognitions.first["rect"]["x"];
        var y = recognitions.first["rect"]["y"];
        x = x * image.width;
        y = y * image.height;
        objWidth = w * image.width;
        objHeight = h * image.height;
        objectLabel = recognitions.first["detectedClass"].toString();

        // var screenH = Get.height;
        // var screenW = Get.width;
        // var previewH = math.max(image.height, image.width);
        // var previewW = math.min(image.height, image.width);
        // var scaleW = 1.0;
        // var scaleH = 1.0;
        // objectLabel = recognitions.first["detectedClass"].toString();
        // if (screenH / screenW > previewH / previewW) {
        //   scaleW = screenH / previewH * previewW;
        //   scaleH = screenH;
        //   var difW = (scaleW - screenW) / scaleW;
        //   x = (_x - difW / 2) * scaleW;
        //   objWidth = _w * scaleW;
        //   if (_x < difW / 2) objWidth -= (difW / 2 - _x) * scaleW;
        //   y = _y * scaleH;
        //   objHeight = _h * scaleH;
        // } else {
        //   scaleH = screenW / previewW * previewH;
        //   scaleW = screenW;
        //   var difH = (scaleH - screenH) / scaleH;
        //   x = _x * scaleW;
        //   objWidth = _w * scaleW;
        //   y = (_y - difH / 2) * scaleH;
        //   objHeight = _h * scaleH;
        //   if (_y < difH / 2) objHeight -= (difH / 2 - _y) * scaleH;
        // }
        // print('image height: $objHeight');
        // print('image width: $objWidth');
        // print('x: $x');
        // print('y: $y');
        // print('');
      } else {
        objHeight = 0.0;
        objWidth = 0.0;
        x = 0.0;
        y = 0.0;
        objectLabel = '';
      }
      update();
    });

    // if (detector != null) {
    //   if (detector.isNotEmpty) {
    //     print("Detector: $detector");
    //     objectLabel = detector.first["detectedClass"].toString();
    //     print(objectLabel);
    //     objHeight = detector.first["rect"]["h"];
    //     objWidth = detector.first["rect"]["w"];
    //     x = detector.first["rect"]["x"];
    //     y = detector.first["rect"]["y"];
    //   }
    //   update();
    // }
    // ---------------
    //   if (detector != null && detector.isNotEmpty) {
    //     print("Detector: $detector");
    //     objectLabel = detector.first["detectedClass"].toString();
    //     print("objectClass: ${detector.first['detectedClass']}");
    //     print("objectRect: ${detector.first['rect']}");

    //     if (detector.first["rect"] != null) {
    //       objHeight = detector.first["rect"]["h"] ?? 0.0;
    //       objWidth = detector.first["rect"]["w"] ?? 0.0;
    //       x = detector.first["rect"]["x"] ?? 0.0;
    //       y = detector.first["rect"]["y"] ?? 0.0;
    //     } else {
    //       objHeight = 0.0;
    //       objWidth = 0.0;
    //       x = 0.0;
    //       y = 0.0;
    //     }

    //     update();
    //   } else {
    //     // Handle case when no objects are detected
    //     objectLabel = '';
    //     objHeight = 0.0;
    //     objWidth = 0.0;
    //     x = 0.0;
    //     y = 0.0;
    //     update();
    //   }
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:pothole_detection_realtime/Views/CameraView.dart';
import 'package:pothole_detection_realtime/Views/ObjectPainter.dart';
import 'package:pothole_detection_realtime/Helper/assetsPicker.dart';

class ObjectDetectorView extends StatefulWidget {
  const ObjectDetectorView({super.key});

  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  ObjectDetector? _objectDetector;
  final DetectionMode _mode = DetectionMode.stream;
  bool _canProcess = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  final _cameraLensDirection = CameraLensDirection.back;
  int _modelOption = 0;
  final _modelOptions = {
    'default': '',
    'EfficientDet': 'efficientnet_lite4_int8_2.tflite',
    'modelA_int8': 'modelA_int8.tflite',
    'modelB': 'modelB.tflite',
    'model_int8': 'model_int8.tflite',
    'model': 'model.tflite',
    'EffNet0': 'effecientNet0_multiclass_int8.tflite',
    'MobNet2': 'model_mobilenetv2twoclasses_tuned.tflite',
  };
  final Set<int> _detectedObjectIds = {};

  @override
  void dispose() {
    _canProcess = false;
    _objectDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // Display Camera and Process Frames
            CameraView(
              customPaint: _customPaint,
              onImage: _processImage,
              onCameraFeedReady: _initializeDetector,
              initialCameraLensDirection: _cameraLensDirection,
            ),
            // Bottom Bar Menu for Models Choice
            Positioned(
              bottom: 19.2,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.blue.withOpacity(0.6),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    // Drop Down Sheet for Models
                    child: DropdownButton<int>(
                      value: _modelOption,
                      icon: const Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                      elevation: 16,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: Colors.blue.withOpacity(0.6),
                      onChanged: (int? option) {
                        if (option != null) {
                          setState(() {
                            _modelOption = option;
                            _initializeDetector();
                          });
                        }
                      },
                      items: List<int>.generate(_modelOptions.length, (i) => i)
                          .map<DropdownMenuItem<int>>((option) {
                        return DropdownMenuItem<int>(
                          value: option,
                          child: Text(_modelOptions.keys.toList()[option]),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildDropdown() => DropdownButton<int>(
  //       value: _modelOption,
  //       icon: const Icon(
  //         Icons.arrow_upward,
  //         color: Colors.white,
  //       ),
  //       elevation: 16,
  //       style: const TextStyle(color: Colors.white),
  //       dropdownColor: Colors.blue.withOpacity(0.6),
  //       onChanged: (int? option) {
  //         if (option != null) {
  //           setState(() {
  //             _modelOption = option;
  //             _initializeDetector();
  //           });
  //         }
  //       },
  //       items: List<int>.generate(_modelOptions.length, (i) => i)
  //           .map<DropdownMenuItem<int>>((option) {
  //         return DropdownMenuItem<int>(
  //           value: option,
  //           child: Text(_modelOptions.keys.toList()[option]),
  //         );
  //       }).toList(),
  //     );

  void _initializeDetector() async {
    _objectDetector?.close();
    _objectDetector = null;
    print('Set detector in mode: $_mode');

    if (_modelOption == 0) {
      // use the default model
      print('use the default model');
      final options = ObjectDetectorOptions(
        mode: _mode,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ObjectDetector(options: options);

      // Use Custom Models
    } else if (_modelOption > 0 && _modelOption <= _modelOptions.length) {
      final option =
          _modelOptions[_modelOptions.keys.toList()[_modelOption]] ?? '';
      final modelPath = await getAssetPath('assets/$option');

      print('use custom model path: $modelPath');

      final options = LocalObjectDetectorOptions(
          mode: _mode,
          modelPath: modelPath,
          classifyObjects: true,
          multipleObjects: true,
          confidenceThreshold: 0.9,
          maximumLabelsPerObject: 2);
      _objectDetector = ObjectDetector(options: options);
    }

    // uncomment next lines if you want to use a remote model
    // make sure to add model to firebase
    // final modelName = 'bird-classifier';
    // final response =
    //     await FirebaseObjectDetectorModelManager().downloadModel(modelName);
    // print('Downloaded: $response');
    // final options = FirebaseObjectDetectorOptions(
    //   mode: _mode,
    //   modelName: modelName,
    //   classifyObjects: true,
    //   multipleObjects: true,
    // );
    // _objectDetector = ObjectDetector(options: options);

    _canProcess = true;
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_objectDetector == null) return;
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {});

    final objects = await _objectDetector!.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      // Send the Data to Painter {for bounding box and Txt}
      final painter = ObjectPainter(
        objects,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );

      _customPaint = CustomPaint(painter: painter);

      // String text = 'Objects found: ${objects.length}\n\n';
      // for (final object in objects) {
      //   text +=
      //       'Object:  trackingId: ${object.trackingId} - ${object.labels.map((e) => e.text)}\n\n';
      //   // print(text);
      // }

      // Tracking id is unique for each object

      // Filter out already detected objects based on their tracking IDs
      final newObjects = objects
          .where((object) => !_detectedObjectIds.contains(object.trackingId))
          .toList();
      _detectedObjectIds.addAll(newObjects.map((object) => object.trackingId!));

      if (newObjects.length > 100) {
        // clear the list newObjects
        newObjects.clear();
      } 

      // Use the Data to send to the server
      for (DetectedObject detectedObject in newObjects) {
        if (detectedObject.labels.isNotEmpty) {
          final label = detectedObject.labels
              .reduce((a, b) => a.confidence > b.confidence ? a : b);
          if (label.text != 'Entity') {
            // Draw
            // Send Data to Database

            print('Label: ${label.text} - Confidence: ${label.confidence} - '
                'Index: ${label.index} - EntityId: ${detectedObject.trackingId.toString()} \n}');
          }
          // print('Label: ${label.text} - Confidence: ${label.confidence} - '
          //     'Index: ${label.index} - EntityId: ${detectedObject.trackingId.toString()} \n}');
        }
      }
    } else {
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

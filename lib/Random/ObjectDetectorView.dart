import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:pothole_detection_realtime/Random/Camera.dart';
import 'package:pothole_detection_realtime/Widgets/ObjectPainter.dart';

class ObjectDetectorView extends StatefulWidget {
  @override
  State<ObjectDetectorView> createState() => _ObjectDetectorView();
}

class _ObjectDetectorView extends State<ObjectDetectorView> {
  ObjectDetector? _objectDetector;
  DetectionMode _mode = DetectionMode.stream;
  bool _canProcess = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  var _cameraLensDirection = CameraLensDirection.back;
  int _modelOption = 0;
  final _modelOptions = {
    'default': '',
    'object_custom': 'object_labeler.tflite',
    'fruits': 'object_labeler_fruits.tflite',
    'flowers': 'object_labeler_flowers.tflite',
    'birds': 'lite-model_aiy_vision_classifier_birds_V1_3.tflite',
    // https://tfhub.dev/google/lite-model/aiy/vision/classifier/birds_V1/3

    'food': 'lite-model_aiy_vision_classifier_food_V1_1.tflite',
    // https://tfhub.dev/google/lite-model/aiy/vision/classifier/food_V1/1

    'plants': 'lite-model_aiy_vision_classifier_plants_V1_3.tflite',
    // https://tfhub.dev/google/lite-model/aiy/vision/classifier/plants_V1/3

    'mushrooms': 'lite-model_models_mushroom-identification_v1_1.tflite',
    // https://tfhub.dev/bohemian-visual-recognition-alliance/lite-model/models/mushroom-identification_v1/1

    'landmarks':
        'lite-model_on_device_vision_classifier_landmarks_classifier_north_america_V1_1.tflite',
    // https://tfhub.dev/google/lite-model/on_device_vision/classifier/landmarks_classifier_north_america_V1/1
  };

  @override
  void dispose() {
    _canProcess = false;
    _objectDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
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
                    child: _buildDropdown(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() => DropdownButton<int>(
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
      );

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
    }
    // else if (_option > 0 && _option <= _options.length) {
    //   // use a custom model
    //   // make sure to add tflite model to assets/ml
    //   final option = _options[_options.keys.toList()[_option]] ?? '';
    //   final modelPath = await getAssetPath('assets/ml/$option');
    //   print('use custom model path: $modelPath');
    //   final options = LocalObjectDetectorOptions(
    //     mode: _mode,
    //     modelPath: modelPath,
    //     classifyObjects: true,
    //     multipleObjects: true,
    //   );
    //   _objectDetector = ObjectDetector(options: options);
    // }

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
    // print('Objects found: ${objects.length}\n\n');
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = ObjectDetectorPainter(
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
      //   print(text);
      // }
    } else {
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}

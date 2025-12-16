import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../widgets/background1.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  TestPageState createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  CameraController? _cameraController;
  Interpreter? _interpreter;
  bool _isPredicting = false;
  String _prediction = "";
  String _selectedSign = "";
  bool _isLoading = true;
  int _frameCount = 0;

  late List<int> _inputShape;
  final List<String> _signs = ["A", "B", "C", "D", "Yes"];

  @override
  void initState() {
    super.initState();
    _initializeCameraAndModel();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _initializeCameraAndModel() async {
    setState(() => _isLoading = true);
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();

      _interpreter =
          await Interpreter.fromAsset('assets/model_unquant.tflite');
      print("✅ Model loaded successfully");

      var inputTensor = _interpreter!.getInputTensor(0);
      _inputShape = inputTensor.shape;
      print("Input shape: $_inputShape");

      _startPrediction();
    } catch (e) {
      print("Initialization error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startPrediction() {
    _cameraController!.startImageStream((CameraImage cameraImage) async {
      _frameCount++;
      if (_frameCount % 10 != 0) return;
      if (_isPredicting || _selectedSign.isEmpty) return;

      _isPredicting = true;
      try {
        final pred = _predict(cameraImage);
        setState(() {
          _prediction = pred;
        });
      } catch (e) {
        print("Prediction error: $e");
      } finally {
        _isPredicting = false;
      }
    });
  }
  
  // Helper function to convert CameraImage to img.Image
  img.Image convertCameraImageToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final img.Image image = img.Image(width: width, height: height);

    final Plane planeY = cameraImage.planes[0];
    final Plane planeU = cameraImage.planes[1];
    final Plane planeV = cameraImage.planes[2];

    final int yRowStride = planeY.bytesPerRow;
    final int uvRowStride = planeU.bytesPerRow;
    final int uvPixelStride = planeU.bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex =
            (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
        final int yIndex = y * yRowStride + x;

        final int yp = planeY.bytes[yIndex];
        final int up = planeU.bytes[uvIndex];
        final int vp = planeV.bytes[uvIndex];

        // Convert YUV to RGB
        int r = (yp + 1.402 * (vp - 128)).round().clamp(0, 255);
        int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round().clamp(0, 255);
        int b = (yp + 1.772 * (up - 128)).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return image;
  }

  String _predict(CameraImage cameraImage) {
    if (_interpreter == null) return "Model not loaded";

    try {
      final img.Image rgbImage = convertCameraImageToImage(cameraImage);

      // Resize and flip
      int inputH = _inputShape[1];
      int inputW = _inputShape[2];
      final resized = img.copyResize(rgbImage, width: inputW, height: inputH);
      final flipped = img.flipHorizontal(resized);

      // Prepare float input [1, H, W, 3], normalized 0-1
      var input = List.generate(
          1,
          (_) => List.generate(
              inputH,
              (y) => List.generate(inputW, (x) {
                    final px = flipped.getPixel(x, y);
                    return [
                      px.r / 255.0,
                      px.g / 255.0,
                      px.b / 255.0,
                    ];
                  })));

      var output = List.generate(1, (_) => List.filled(_signs.length, 0.0));

      _interpreter!.run(input, output);

      List<double> predictions = List<double>.from(output[0]);
      double maxVal = predictions.reduce((a, b) => a > b ? a : b);
      int maxIndex = predictions.indexOf(maxVal);

      String predictedLabel =
          maxIndex < _signs.length ? _signs[maxIndex] : "Unknown";

      String result = "$predictedLabel (${(maxVal * 100).toStringAsFixed(1)}%)";

      if (_selectedSign.isNotEmpty) {
        result = _selectedSign == predictedLabel
            ? "Correct! $result"
            : "Wrong! Predicted $result";
      }

      return result;
    } catch (e) {
      print("Prediction error: $e");
      return "Error during prediction";
    }
  }

  void _restartTest() {
    setState(() {
      _prediction = "";
      _selectedSign = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Sign Language Test",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                hint: const Text("Select a Sign"),
                value: _selectedSign.isEmpty ? null : _selectedSign,
                onChanged: (value) {
                  setState(() {
                    _selectedSign = value!;
                    _prediction = "";
                  });
                },
                items: _signs
                    .map((sign) => DropdownMenuItem(
                          value: sign,
                          child: Text(sign),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              if (_selectedSign.isNotEmpty)
                Text(
                  "Selected Sign: $_selectedSign",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
              const SizedBox(height: 20),
              Container(
                width: 328,
                height: 328,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: CameraPreview(_cameraController!),
              ),
              const SizedBox(height: 20),
              Text(
                _selectedSign.isEmpty
                    ? "Please select a sign"
                    : (_prediction.isEmpty ? "Detecting..." : _prediction),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _restartTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF219D4A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text("Restart Test",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
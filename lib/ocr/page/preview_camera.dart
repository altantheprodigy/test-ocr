import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

class CameraPreviewScreen extends StatefulWidget {
  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isCameraInitialized =
      false; // Tambahkan flag untuk memeriksa inisialisasi kamera

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      // final firstCamera = cameras.first;
      final backCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back);

      _cameraController = CameraController(
        _cameras[0],
        // backCamera,
        enableAudio: false,
        ResolutionPreset.max,
      );

      _initializeControllerFuture = _cameraController.initialize();

      await _initializeControllerFuture;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Error menginisialisasi kamera: $e');
    }
  }

  double _getCameraRotation() {
    final camera = _cameraController.description;
    switch (camera.lensDirection) {
      case CameraLensDirection.back:
        return 90 *
            (3.141592653589793 /
                180); // Rotasi 90 derajat untuk kamera belakang
      case CameraLensDirection.front:
        return -90 *
            (3.141592653589793 / 180); // Rotasi -90 derajat untuk kamera depan
      default:
        return 0; // Tidak ada rotasi untuk kamera lainnya
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = 300;
    // final deviceRatio = size.width / size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview Kamera'),
      ),
      body: _isCameraInitialized
          ? Center(
              child: Transform.rotate(
                angle: _getCameraRotation(),
                child: AspectRatio(
                  aspectRatio: _cameraController.value.aspectRatio,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      // Transform.scale(
                      //   scale: 1 / _cameraController.value.aspectRatio,
                      //   child: Center(
                      //     child: AspectRatio(
                      //       aspectRatio: _cameraController.value.aspectRatio,
                      //       child: CameraPreview(_cameraController),
                      //     ),
                      //   ),
                      // )
                      SizedBox(
                        height: 400,
                        width: 400,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CameraPreview(_cameraController)),
                      ),
                      // ClipRect(
                      //     child: OverflowBox(
                      //       alignment: Alignment.center,
                      //       child: FittedBox(
                      //           fit: BoxFit.fitWidth,
                      //           child: Container(
                      //               width: size,
                      //               height: size / _cameraController.value.aspectRatio,
                      //               child: AspectRatio(
                      //                 aspectRatio: _cameraController.value.aspectRatio,
                      //                 child: CameraPreview(_cameraController),
                      //               ))),
                      //     )),
                      // Transform.rotate(
                      //   angle: -90 * (3.141592653589793 / 180),
                      //   child: Image.asset(
                      //     "assets/images/outline_icon_ktp1.png",
                      //     height: 200,
                      //     fit: BoxFit.fitHeight,
                      //   ),
                      // )
                      Image.asset(
                        "assets/images/outline_icon_ktp1.png",
                        height: 380,
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child:
                  CircularProgressIndicator()), // Tampilkan loading indicator jika belum diinisialisasi
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Pastikan kamera sudah diinisialisasi sebelum mengambil gambar
            if (!_isCameraInitialized) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kamera belum siap')),
              );
              return;
            }

            // Ambil gambar
            final image = await _cameraController.takePicture();

            // Kembali ke halaman sebelumnya dengan path gambar
            Navigator.pop(context, image.path);
          } catch (e) {
            print('Error mengambil gambar: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal mengambil gambar: $e')),
            );
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}

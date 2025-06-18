import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<Camera> {
  late List<CameraDescription> cameras;
  CameraController? cameraController;
  int direction = 0;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras[direction],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await cameraController!.initialize();
      setState(() {
        isCameraReady = true;
      });
    } catch (e) {
      print("Gagal menghubungkan kamera: $e");
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady || cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(cameraController!),
          GestureDetector(
            onTap: () {
              setState(() {
                direction = direction == 0 ? 1 : 0;
                initializeCamera();
              });
            },
            child: button(
              Icons.flip_camera_android_outlined,
              Alignment.bottomLeft,
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                final XFile file = await cameraController!.takePicture();
                final imageBytes = await file.readAsBytes();

                if (mounted) {
                  print('Foto tersimpan di file ${file.path}');
                  Navigator.pop(context, imageBytes);
                }
              } catch (e) {
                print("Gagal mengambil gambar: $e");
              }
            },
            child: button(Icons.camera_alt_outlined, Alignment.bottomCenter),
          ),
        ],
      ),
    );
  }

  Widget button(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black, size: 30),
      ),
    );
  }
}

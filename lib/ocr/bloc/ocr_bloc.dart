import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

part 'ocr_event.dart';
part 'ocr_state.dart';

class OcrBloc extends Bloc<OcrEvent, OcrState> {
  OcrBloc() : super(OcrInitial()) {
    on<PickImageFromCamera>((event, emit) async {
      await _processImage(ImageSource.camera, emit);
    });

    on<PickImageFromGallery>((event, emit) async {
      await _processImage(ImageSource.gallery, emit);
    });

    on<PickImageFromCameraPreview>((event, emit) async {
      await _processImageFromPath(event.imagePath, emit);
    });
  }

  Future<void> _processImage(ImageSource source, Emitter<OcrState> emit) async {
    emit(OcrLoading());

    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        await _processImageFromPath(pickedFile.path, emit);
      } else {
        emit(OcrFailure('Gagal mengambil gambar'));
      }
    } catch (e) {
      emit(OcrFailure('Terjadi kesalahan: $e'));
    }
  }

  Future<void> _processImageFromPath(String imagePath, Emitter<OcrState> emit) async {
    try {
      final File imageFile = File(imagePath);

      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final inputImage = InputImage.fromFile(imageFile);

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String nik = _extractNikFromText(recognizedText.text);
      print("Hasil OCR Mentah: ${recognizedText.text}");
      print("Hasil OCR: $nik");

      if (nik.isNotEmpty) {
        emit(OcrSuccess(nik, imageFile: imageFile));
      } else {
        emit(OcrFailure('NIK tidak ditemukan'));
      }

      textRecognizer.close();
    } catch (e) {
      emit(OcrFailure('Terjadi kesalahan: $e'));
    }
  }

  String _extractNikFromText(String text) {
    final RegExp nikRegExp = RegExp(r'\b\d{16}\b');
    final Match? match = nikRegExp.firstMatch(text);
    return match?.group(0) ?? '';
  }
}
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:meta/meta.dart';
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
  }

  Future<void> _processImage(ImageSource source, Emitter<OcrState> emit) async {
    emit(OcrLoading()); // Mengirim state loading

    try {
      // Mengambil gambar dari kamera atau galeri
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        // Menginisialisasi text recognizer dari google_ml_kit
        final textRecognizer = GoogleMlKit.vision.textRecognizer(script: TextRecognitionScript.latin);

        // Membuat InputImage dari file
        final inputImage = InputImage.fromFile(imageFile);

        // Memproses gambar untuk mengenali teks
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        // Mengekstrak NIK dari teks yang dikenali
        String nik = _extractNikFromText(recognizedText.text);
        // String nik = recognizedText.text;
        print("Hasil OCR Mentah: ${recognizedText.text}");
        print("Hasil OCR: ${nik}");

        if (nik.isNotEmpty) {
          emit(OcrSuccess(nik, imageFile: imageFile)); // Mengirim state success dengan NIK dan gambar
        } else {
          emit(OcrFailure('NIK tidak ditemukan')); // Mengirim state failure jika NIK tidak ditemukan
        }

        // Jangan lupa untuk menutup text recognizer setelah selesai
        textRecognizer.close();
      } else {
        emit(OcrFailure('Gagal mengambil gambar')); // Mengirim state failure jika gambar tidak diambil
      }
    } catch (e) {
      emit(OcrFailure('Terjadi kesalahan: $e')); // Mengirim state failure jika terjadi error
    }
  }

  // Fungsi untuk mengekstrak NIK dari teks
  String _extractNikFromText(String text) {
    // Contoh regex untuk mengekstrak NIK (16 digit angka)
    final RegExp nikRegExp = RegExp(r'\b\d{16}\b');
    final Match? match = nikRegExp.firstMatch(text);
    return match?.group(0) ?? ''; // Mengembalikan NIK jika ditemukan, atau string kosong jika tidak
  }


}
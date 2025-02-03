part of 'ocr_bloc.dart';

abstract class OcrState {}

class OcrInitial extends OcrState {}

class OcrLoading extends OcrState {}

class OcrSuccess extends OcrState {
  final String nik;
  final File? imageFile;

  OcrSuccess(this.nik, {this.imageFile});
}

class OcrFailure extends OcrState {
  final String error;

  OcrFailure(this.error);
}
part of 'ocr_bloc.dart';

abstract class OcrEvent {}

class PickImageFromCamera extends OcrEvent {}

class PickImageFromGallery extends OcrEvent {}
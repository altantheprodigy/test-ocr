import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ocr/bloc/ocr_bloc.dart';
import 'ocr/page/ocr_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => OcrBloc(),
        child: OcrScreen(),
      ),
    );
  }
}
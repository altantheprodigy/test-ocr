import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ocr_bloc.dart';

class OcrScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR NIK dari KTP'),
      ),
      body: BlocConsumer<OcrBloc, OcrState>(
        listener: (context, state) {
          if (state is OcrFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is OcrLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is OcrSuccess) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.imageFile != null)
                      Image.file(
                        width: 300,
                        height: 300,
                        state.imageFile!,
                        fit: BoxFit.fill,
                      ),
                    SizedBox(height: 20),
                    Text('NIK: ${state.nik}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OcrBloc>().add(PickImageFromCamera());
                      },
                      child: Text('Ambil Gambar dari Kamera'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OcrBloc>().add(PickImageFromGallery());
                      },
                      child: Text('Ambil Gambar dari Galeri'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<OcrBloc>().add(PickImageFromCamera());
                    },
                    child: Text('Ambil Gambar dari Kamera'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OcrBloc>().add(PickImageFromGallery());
                    },
                    child: Text('Ambil Gambar dari Galeri'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
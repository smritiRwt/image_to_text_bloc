import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_to_text/bloc/image_ocr_bloc.dart';
import 'image_ocr_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCR App',
      home: BlocProvider(
        create: (_) => ImageOcrBloc(),
        child: const ImageOcrView(),
      ),
    );
  }
}

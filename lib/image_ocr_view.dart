import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_to_text/bloc/image_ocr_bloc.dart';
import 'package:image_to_text/event/image_ocr_event.dart';
import 'package:image_to_text/state/image_ocr_state.dart';

class ImageOcrView extends StatelessWidget {
  const ImageOcrView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Scanner")),
      body: BlocBuilder<ImageOcrBloc, ImageOcrState>(
        builder: (context, state) {
          if (state is ImageOcrLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ImageOcrImagePicked) {
            return _Preview(imagePath: state.imagePath);
          } else if (state is ImageOcrSuccess) {
            return _Result(imagePath: state.imagePath, text: state.scannedText);
          } else if (state is ImageOcrFailure) {
            return _Error(message: state.message);
          }
          return _PickButton();
        },
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => context.read<ImageOcrBloc>().add(PickImageEvent()),
        icon: const Icon(Icons.image_search),
        label: const Text("Pick Image"),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final String imagePath;
  const _Preview({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (File(imagePath).existsSync())
          Image.file(File(imagePath), height: 200),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.crop),
          label: const Text("Crop & Scan"),
          onPressed: () => context.read<ImageOcrBloc>().add(CropImageEvent(imagePath)),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.search),
          label: const Text("Scan Without Crop"),
          onPressed: () => context.read<ImageOcrBloc>().add(PerformOcrEvent(imagePath)),
        ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  final String imagePath, text;
  const _Result({required this.imagePath, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Image.file(File(imagePath), height: 200),
        const SizedBox(height: 16),
        Text(text.isEmpty ? 'No text found' : text),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => context.read<ImageOcrBloc>().add(PickImageEvent()),
          icon: const Icon(Icons.image_search),
          label: const Text("Pick Another"),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  const _Error({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            onPressed: () => context.read<ImageOcrBloc>().add(PickImageEvent()),
          )
        ],
      ),
    );
  }
}

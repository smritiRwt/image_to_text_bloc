// image_text_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_to_text/bloc/image_ocr_bloc.dart';
import 'package:image_to_text/event/image_ocr_event.dart';
import 'package:image_to_text/state/image_ocr_state.dart';
import 'package:crop_image/crop_image.dart';
import 'package:image_picker/image_picker.dart';

class ImageTextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImageTextBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Crop & OCR')),
        body: BlocBuilder<ImageTextBloc, ImageTextState>(
          builder: (context, state) {
            if (state.status == ImageTextStatus.initial) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => context.read<ImageTextBloc>()
                    .add(const PickImageEvent(ImageSource.gallery)),
                  child: const Text('Pick Image'),
                ),
              );
            } else if (state.imageFile != null) {
              return Column(
                children: [
                  Expanded(
                    child: CropImage(
                      controller: context.read<ImageTextBloc>().cropController,
                      image: Image.file(state.imageFile!),
                    ),
                  ),
                  if (state.status == ImageTextStatus.processing)
                    const CircularProgressIndicator(),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ImageTextBloc>().add(CropAndRecognizeEvent()),
                    child: const Text('Crop & Recognize Text'),
                  ),
                  if (state.status == ImageTextStatus.done)
                    Expanded(child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(state.recognizedText, style: TextStyle(fontSize: 16)),
                    )),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

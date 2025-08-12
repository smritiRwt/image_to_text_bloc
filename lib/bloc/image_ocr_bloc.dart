import 'dart:io';
import 'package:image/image.dart' as img; // For real pixel cropping
import 'package:bloc/bloc.dart';
import 'package:crop_image/crop_image.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_text/event/image_ocr_event.dart';
import 'package:image_to_text/state/image_ocr_state.dart';

class ImageTextBloc extends Bloc<ImageTextEvent, ImageTextState> {
  final ImagePicker _picker = ImagePicker();
  final CropController cropController = CropController();

  ImageTextBloc() : super(ImageTextState.initial()) {
    on<PickImageEvent>(_onPickImage);
    on<CropAndRecognizeEvent>(_onCropAndRecognize);
  }

  Future<void> _onPickImage(
      PickImageEvent event, Emitter<ImageTextState> emit) async {
    // Show uploading loader
    emit(state.copyWith(status: ImageTextStatus.uploading));

    // Delay for 2 seconds to show loader animation
    await Future.delayed(const Duration(seconds: 2));

    // Pick image
    final XFile? file = await _picker.pickImage(source: event.source);
    if (file == null) {
      emit(state.copyWith(status: ImageTextStatus.initial));
      return;
    }

    emit(state.copyWith(
      imageFile: File(file.path),
      status: ImageTextStatus.picked,
    ));
  }

  Future<void> _onCropAndRecognize(
      CropAndRecognizeEvent event, Emitter<ImageTextState> emit) async {
    if (state.imageFile == null) return;
    emit(state.copyWith(status: ImageTextStatus.processing));

    // Get crop rectangle
    final rect = cropController.crop;
    final bytes = await state.imageFile!.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      emit(state.copyWith(
        status: ImageTextStatus.error,
        errorMessage: 'Could not decode image',
      ));
      return;
    }

    // Calculate crop area in pixels
    final cropX = (rect.left * originalImage.width).round();
    final cropY = (rect.top * originalImage.height).round();
    final cropWidth = (rect.width * originalImage.width).round();
    final cropHeight = (rect.height * originalImage.height).round();

    final croppedImage = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Save cropped image to temp file
    final croppedFile = File('${Directory.systemTemp.path}/cropped.png')
      ..writeAsBytesSync(img.encodePng(croppedImage));

    // OCR with ML Kit
    final input = InputImage.fromFilePath(croppedFile.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(input);

    emit(state.copyWith(
      recognizedText: result.text,
      status: ImageTextStatus.done,
    ));
  }
}

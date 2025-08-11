import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_to_text/event/image_ocr_event.dart' show ImageOcrEvent, CropImageEvent, PickImageEvent, PerformOcrEvent;
import 'package:image_to_text/state/image_ocr_state.dart';
import 'package:permission_handler/permission_handler.dart';


class ImageOcrBloc extends Bloc<ImageOcrEvent, ImageOcrState> {
  final ImagePicker _picker = ImagePicker();

  ImageOcrBloc() : super(ImageOcrInitial()) {
    on<PickImageEvent>(_onPickImage);
    on<CropImageEvent>(_onCropImage);
    on<PerformOcrEvent>(_onPerformOcr);
  }

  Future<void> _onPickImage(PickImageEvent event, Emitter<ImageOcrState> emit) async {
    emit(ImageOcrLoading());

    if (!await _requestPermissions()) {
      emit(ImageOcrFailure('Permissions not granted'));
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null && File(image.path).existsSync()) {
      emit(ImageOcrImagePicked(image.path));
    } else {
      emit(ImageOcrFailure('Image not found or invalid path'));
    }
  }

  Future<void> _onCropImage(CropImageEvent event, Emitter<ImageOcrState> emit) async {
    emit(ImageOcrLoading());

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: event.imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(toolbarTitle: 'Crop Image'),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedFile != null && File(croppedFile.path).existsSync()) {
      add(PerformOcrEvent(croppedFile.path));
    } else {
      emit(ImageOcrImagePicked(event.imagePath));
    }
  }

  Future<void> _onPerformOcr(PerformOcrEvent event, Emitter<ImageOcrState> emit) async {
    emit(ImageOcrLoading());

    if (!File(event.imagePath).existsSync()) {
      emit(ImageOcrFailure('File path not found'));
      return;
    }

    try {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(event.imagePath);
      final result = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      emit(ImageOcrSuccess(imagePath: event.imagePath, scannedText: result.text));
    } catch (_) {
      emit(ImageOcrFailure('Failed to recognize text'));
    }
  }

  Future<bool> _requestPermissions() async {
    var statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }
}

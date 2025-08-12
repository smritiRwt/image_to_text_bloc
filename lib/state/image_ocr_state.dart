import 'dart:io';
import 'package:equatable/equatable.dart';

enum ImageTextStatus { initial,uploading, picked, processing, done, error }

class ImageTextState extends Equatable {
  final File? imageFile;
  final String recognizedText;
  final ImageTextStatus status;
  final String? errorMessage;

  const ImageTextState({
    this.imageFile,
    this.recognizedText = '',
    required this.status,
    this.errorMessage,
  });

  factory ImageTextState.initial() =>
      const ImageTextState(status: ImageTextStatus.initial);

  ImageTextState copyWith({
    File? imageFile,
    String? recognizedText,
    ImageTextStatus? status,
    String? errorMessage,
  }) {
    return ImageTextState(
      imageFile: imageFile ?? this.imageFile,
      recognizedText: recognizedText ?? this.recognizedText,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [imageFile, recognizedText, status, errorMessage];
}

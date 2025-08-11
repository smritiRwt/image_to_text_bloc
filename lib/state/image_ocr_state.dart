abstract class ImageOcrState {}

class ImageOcrInitial extends ImageOcrState {}

class ImageOcrLoading extends ImageOcrState {}

class ImageOcrImagePicked extends ImageOcrState {
  final String imagePath;
  ImageOcrImagePicked(this.imagePath);
}

class ImageOcrSuccess extends ImageOcrState {
  final String imagePath;
  final String scannedText;
  ImageOcrSuccess({required this.imagePath, required this.scannedText});
}

class ImageOcrFailure extends ImageOcrState {
  final String message;
  ImageOcrFailure(this.message);
}

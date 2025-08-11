abstract class ImageOcrEvent {}

class PickImageEvent extends ImageOcrEvent {}

class CropImageEvent extends ImageOcrEvent {
  final String imagePath;
  CropImageEvent(this.imagePath);
}

class PerformOcrEvent extends ImageOcrEvent {
  final String imagePath;
  PerformOcrEvent(this.imagePath);
}

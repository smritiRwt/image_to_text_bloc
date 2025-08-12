import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImageTextEvent extends Equatable {
  const ImageTextEvent();
  @override
  List<Object?> get props => [];
}

class PickImageEvent extends ImageTextEvent {
  final ImageSource source;
  const PickImageEvent(this.source);
  @override
  List<Object?> get props => [source];
}

class CropAndRecognizeEvent extends ImageTextEvent {}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heroicons/heroicons.dart';
import 'package:image_to_text/bloc/image_ocr_bloc.dart' show ImageTextBloc;
import 'package:image_to_text/components/dashed_container.dart';
import 'package:image_to_text/event/image_ocr_event.dart';
import 'package:image_to_text/state/image_ocr_state.dart' show ImageTextState, ImageTextStatus;
import 'package:crop_image/crop_image.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     
      debugShowCheckedModeBanner: false,
      title: 'OCR Cropper',
      theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(), 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => ImageTextBloc(),
        child: const ImageTextPage(),
      ),
    );
  }
}

class ImageTextPage extends StatelessWidget {
  const ImageTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 121, 155, 240),
        title: const Text('Snap & Extract',style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: BlocBuilder<ImageTextBloc, ImageTextState>(
        builder: (context, state) {
       switch (state.status) {
  case ImageTextStatus.initial:
    return _buildPickUI(context);
  case ImageTextStatus.uploading:
    return _buildUploadingUI(); // 👈 New loader UI
  case ImageTextStatus.picked:
    return _buildCropUI(context, state);
  case ImageTextStatus.processing:
    return const Center(child: CircularProgressIndicator());
  case ImageTextStatus.done:
    return _buildResultUI(context, state);
  case ImageTextStatus.error:
    return _buildErrorUI(state.errorMessage ?? 'Unknown error');
}

        },
      ),
    );
  }


  Widget _buildUploadingUI() {
  return Container(
    color: Colors.black.withOpacity(0.1),
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 121, 155, 240)),
            strokeWidth: 4,
          ),
          SizedBox(height: 16),
          Text(
            'Uploading image...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}


  /// Step 1 — Pick UI
  Widget _buildPickUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Upload an Image',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text( 'Select an image from your gallery or take a new photo to crop and extract text.',
            style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 112, 111, 111),fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: DashedBorderContainer(
            color: const Color.fromARGB(255, 121, 155, 240),
            strokeWidth: 1.5,
            dashLength: 4,
            gapLength: 3,
            cornerRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context
                        .read<ImageTextBloc>()
                        .add(const PickImageEvent(ImageSource.gallery)),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 121, 155, 240),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: HeroIcon(
                        HeroIcons.cloudArrowUp,
                        size: 38,
                        color:  Colors.white
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                 const Text('Tap to upload image',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400,color: Color.fromARGB(255, 21, 146, 248)),
                  ),
                  const Text('PNG, JPG, or JPEG',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400,color: Color.fromARGB(255, 122, 123, 123)),
                  ),
                  const SizedBox(height: 16),
                  Text("OR"),
                    const SizedBox(height: 16),
                    ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromARGB(255, 104, 144, 247),
                  ),
                  onPressed: () => context
                  .read<ImageTextBloc>()
                  .add(const PickImageEvent(ImageSource.camera)), child: const Text("Open Camera",style: TextStyle(fontSize: 16,color: Colors.white),)),
                  const SizedBox(height: 16),
                ],
            ),
                    ),
          ),
        ],
      ),
    );
  }

  /// Step 2 — Crop UI
  Widget _buildCropUI(BuildContext context, ImageTextState state) {
    final bloc = context.read<ImageTextBloc>();
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CropImage(
                controller: bloc.cropController,
                image: Image.file(state.imageFile!, fit: BoxFit.contain),
                gridColor: Colors.white.withOpacity(0.7),
                alwaysShowThirdLines: true,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: const Color.fromARGB(255, 104, 144, 247),
            ),  
            icon: const Icon(Icons.crop),
            label: const Text("Crop & proceed",
                style: TextStyle(fontSize: 16, color: Colors.white)),
            
            onPressed: () =>
                context.read<ImageTextBloc>().add(CropAndRecognizeEvent()),
          ),
        ),
      ],
    );
  }

  /// Step 3 — Result UI
  Widget _buildResultUI(BuildContext context, ImageTextState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                state.recognizedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Another"),
                  onPressed: () => context
                      .read<ImageTextBloc>()
                      .add(const PickImageEvent(ImageSource.gallery)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Error UI
  Widget _buildErrorUI(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          "Error: $message",
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

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
import 'package:flutter/services.dart';

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
    return const Center(child: CircularProgressIndicator(color: Colors.blue),);
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
    color: Colors.black.withAlpha(10),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Upload an Image',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose an image from your gallery or take a new photo to extract text.',
          style: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 112, 111, 111),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        DashedBorderContainer(
          color: const Color.fromARGB(255, 121, 155, 240),
          strokeWidth: 1.5,
          dashLength: 6,
          gapLength: 3,
          cornerRadius: 12,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            children: [
              // Gallery Upload
              GestureDetector(
                onTap: () => context
                    .read<ImageTextBloc>()
                    .add(const PickImageEvent(ImageSource.gallery)),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6A95F5),
                            Color(0xFF4E7FF5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withAlpha(20),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: HeroIcon(
                        HeroIcons.photo,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Choose your image',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Supports PNG & JPG formats',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Divider with OR
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Camera Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6890F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  label: const Text(
                    "Open Camera",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => context
                      .read<ImageTextBloc>()
                      .add(const PickImageEvent(ImageSource.camera)),
                ),
              ),
            ],
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
            padding: const EdgeInsets.all(15.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CropImage(
                controller: bloc.cropController,
                image: Image.file(state.imageFile!, fit: BoxFit.contain),
                gridColor: Colors.white.withAlpha(10),
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
            icon: const Icon(Icons.crop,color: Colors.white,),
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
  return Container(
    color: const Color(0xFFFfffff), // Soft background
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
          child: Text(
            "Recognized Text",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        // Main Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: DashedBorderContainer(
                      color: const Color(0xFF789AF0),
                      strokeWidth: 1.5,
                      dashLength: 6,
                      gapLength: 4,
                      cornerRadius: 12,
                      padding: const EdgeInsets.all(18),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: double.infinity, // Full width text
                          child: SelectableText(
                            state.recognizedText.isNotEmpty
                                ? state.recognizedText
                                : "No text recognized.",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating Copy Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {
                      if (state.recognizedText.isNotEmpty) {
                        Clipboard.setData(
                          ClipboardData(text: state.recognizedText),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Text copied to clipboard"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.copy, size: 22, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Action Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            height: 55,
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6890F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.refresh, color: Colors.white, size: 22),
              label: const Text(
                "Try Another",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () =>   context.read<ImageTextBloc>().emit(ImageTextState.initial())
            ),
          ),
        ),
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

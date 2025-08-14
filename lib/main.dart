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
      backgroundColor: Colors.white,
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
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.grey.shade50,
          Colors.white,
        ],
      ),
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          
          const SizedBox(height: 8),

          // Upload Options
          DashedBorderContainer(
            color: const Color.fromARGB(255, 121, 155, 240),
            strokeWidth: 1,
            dashLength: 8,
            gapLength: 4,
            cornerRadius: 16,
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // Gallery Upload Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context
                          .read<ImageTextBloc>()
                          .add(const PickImageEvent(ImageSource.gallery)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6A95F5),
                                    Color(0xFF4E7FF5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6A95F5).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: HeroIcon(
                                HeroIcons.photo,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Choose from Gallery',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Select an existing image from your device',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider with OR
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.grey.shade300,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.grey.shade300,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Camera Button
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6890F7),
                          Color(0xFF4E7FF5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4E7FF5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6890F7).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context
                            .read<ImageTextBloc>()
                            .add(const PickImageEvent(ImageSource.camera)),
                        child: const Icon(
                          Icons.camera_alt_rounded, 
                          color: Colors.white, 
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Features Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.speed_rounded,
                  title: 'Fast OCR',
                  subtitle: 'Quick text extraction',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.high_quality_rounded,
                  title: 'High Quality',
                  subtitle: 'Accurate results',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFeatureItem(
                  icon: Icons.content_copy_rounded,
                  title: 'Easy Copy',
                  subtitle: 'One-tap copying',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

// Helper method for feature items
Widget _buildFeatureItem({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
    height: 110, // Increased height to prevent overflow
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade100),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF6890F7).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF6890F7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Flexible(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey.shade600,
              height: 1.2,
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

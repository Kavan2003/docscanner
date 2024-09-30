import 'dart:io';
import 'package:docscanner/pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  List<XFile?> _selectedImages = [];
  bool isloading = false;
  bool isloading2 = false;
  @override
  void initState() {
    _selectedImages = [];
    super.initState();
  }

  void _pickImages() async {
    setState(() {
      isloading2 = true;
    });
    // Allow multiple image selection
    final List<XFile?> pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages != null) {
      setState(() {
        _selectedImages = pickedImages;
        isloading2 = false;
      });
    } else {
      // Handle user cancellation or error
      print('Image selection cancelled or error occurred.');
    }
  }

  Future<String> convertopdf() async {
    try {
      // Create a new PDF document
      final doc = pw.Document();

      // Create a temporary directory to store the PDF
      final dir = await getApplicationDocumentsDirectory();
      final pdfFile = File(
          '${dir.path}/_image_to_pdf_by_kavan${DateTime.now().millisecondsSinceEpoch}.pdf');

      // Iterate through selected images
      for (final image in _selectedImages) {
        // Handle potential errors like invalid image path
        try {
          final bytes = await File(image!.path).readAsBytes();
          final img.Image? imgSrc = img.decodeImage(bytes);
          if (imgSrc != null) {
            final pageFormat = PdfPageFormat(
                imgSrc.width.toDouble(), imgSrc.height.toDouble());
            doc.addPage(pw.Page(
              pageFormat: pageFormat,
              build: (pw.Context context) => pw.Image(pw.MemoryImage(bytes)),
            ));
          }
        } catch (error) {
          print('Error processing image ${image!.path}: $error');
        }
      }

      // Save the PDF to the temporary file
      await doc.save().then((value) {
        pdfFile.writeAsBytes(value);
      });

      // Display a success message or offer user options (e.g., share, open)
      print('PDF saved successfully: ${pdfFile.path}');
      return pdfFile.path;
    } catch (error) {
      print('Error converting images to PDF: $error');
      showAboutDialog(
        context: context,
        applicationName: 'Error',
        applicationVersion: 'Error',
        applicationIcon: const Icon(Icons.error),
        children: [Text('Error converting images to PDF: $error')],
      );
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF Converter'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: isloading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                          ),
                        ),
                        onPressed: _pickImages,
                        child: const Text('Gallery',
                            style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _selectedImages.isNotEmpty && !isloading2
                      ? SingleChildScrollView(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.file(
                                      File(_selectedImages[index]!.path)),
                                );
                              },
                            ),
                          ),
                        )
                      : isloading2
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const Text('No images selected'),
                ],
              ),
      ),
      bottomNavigationBar: isloading
          ? const BottomAppBar()
          : BottomAppBar(
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  if (_selectedImages.isNotEmpty)
                    setState(() {
                      isloading = true;
                    });
                  print('Convert to PDF button pressed.');
                  if (_selectedImages.isNotEmpty)
                    convertopdf().then((pdfPath) {
                      setState(() {
                        isloading = false;
                        // clear list
                        _selectedImages = [];
                      });
                      OpenFilex.open(pdfPath);
                    });
                },
                child: const Text('Convert to PDF',
                    style: TextStyle(fontSize: 15)),
              ),
            ),
    );
  }
}

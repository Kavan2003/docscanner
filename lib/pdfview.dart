import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class PdfViewerPage extends StatelessWidget {
  final String pdfPath;

  const PdfViewerPage({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated PDF'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your PDF is ready!'),
            const SizedBox(height: 20),
            Text(
              'Path: $pdfPath',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await OpenFilex.open(pdfPath);
              },
              child: const Text('Open PDF'),
            ),
          ],
        ),
      ),
    );
  }
}

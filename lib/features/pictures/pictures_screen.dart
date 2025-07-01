import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dailyme/utils/storage/util_hive.dart';
import 'package:google_fonts/google_fonts.dart';

class PicturesScreen extends StatefulWidget {
  const PicturesScreen({super.key});

  @override
  State<PicturesScreen> createState() => _PicturesScreenState();
}

class _PicturesScreenState extends State<PicturesScreen> {
  List<String> _picturePaths = [];

  @override
  void initState() {
    super.initState();
    _loadPictures();
  }

  Future<void> _loadPictures() async {
    final today = DateTime.now();
    final entry = await HiveDayStorage.retrieveDay(today);
    setState(() {
      _picturePaths = entry != null ? List<String>.from(entry['pictures'] ?? []) : [];
    });
  }

  Future<void> _addPicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final today = DateTime.now();
      final entry = await HiveDayStorage.retrieveDay(today) ?? {'date': today, 'note': '', 'rating': null, 'pictures': <String>[]};
      final updatedPictures = List<String>.from(entry['pictures'] ?? []);
      updatedPictures.add(pickedFile.path);
      entry['pictures'] = updatedPictures;
      await HiveDayStorage.storeDay(today, entry);
      setState(() {
        _picturePaths = updatedPictures;
      });
    }
  }

  Future<void> _removePicture(int index) async {
    final today = DateTime.now();
    final entry = await HiveDayStorage.retrieveDay(today) ?? {'date': today, 'note': '', 'rating': null, 'pictures': <String>[]};
    final updatedPictures = List<String>.from(entry['pictures'] ?? []);
    if (index >= 0 && index < updatedPictures.length) {
      updatedPictures.removeAt(index);
      entry['pictures'] = updatedPictures;
      await HiveDayStorage.storeDay(today, entry);
      setState(() {
        _picturePaths = updatedPictures;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pictures',
          style: GoogleFonts.libreBaskerville(
            textStyle: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        actionsIconTheme: Theme.of(context).appBarTheme.actionsIconTheme,
        toolbarHeight: Theme.of(context).appBarTheme.toolbarHeight,
        // Add more if you want to match more settings
      ),
      body: _picturePaths.isEmpty
          ? const Center(child: Text('No pictures added for today.'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _picturePaths.length,
              itemBuilder: (context, index) {
                final path = _picturePaths[index];
                return Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePicture(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add Picture',
        onPressed: _addPicture,
        icon: const Icon(Icons.add_a_photo, color: Colors.black87, size: 28),
        label: const Text(
          'Add Picture',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
        splashColor: Colors.black12,
      ),
    );
  }
}
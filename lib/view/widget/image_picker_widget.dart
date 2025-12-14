import 'dart:io';

import 'package:flutter/material.dart';
import 'package:havenly/view/widget/costum_button.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  ImagePickerWidget({this.text});
  String? text;
  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? file;
  getImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    //final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // Capture a photo.
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      file = File(photo.path);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          MaterialButton(
            onPressed: () async {
              await getImage();
            },
            child: Text('${widget.text}'),
          ),
          if (file != null) Image.file(file!, width: 50, height: 25),
        ],
      ),
    );
  }
}

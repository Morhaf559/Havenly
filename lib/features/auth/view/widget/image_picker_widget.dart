import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:havenly/features/auth/view/widget/costum_button.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  ImagePickerWidget({this.text, this.onImagePicked});
  String? text;
  final ValueChanged<String>? onImagePicked;
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
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      file = File(photo.path);
      widget.onImagePicked!(file!.path);
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
            child: Text(
              '${widget.text}',
              style: TextStyle(color: Color(0xff001733)),
            ),
          ),
          if (file != null) Image.file(file!, width: 50, height: 25),
        ],
      ),
    );
  }
}

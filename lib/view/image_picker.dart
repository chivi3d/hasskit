import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/logger.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File _image;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      log.d("_image path ${_image.path} uri ${_image.uri}");
//      if (!gd.backgroundImage.contains(image.path))
//        gd.backgroundImage.add(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      RaisedButton(
        onPressed: getImage,
        child: Text("Select Background"),
      )
    ]));
  }
}

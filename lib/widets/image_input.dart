import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class ImageInput extends StatefulWidget {
  final Function pickedImage;
  ImageInput(this.pickedImage);
  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _storedImage;

  Future<void> _takePicture(String sourceType) async {
    ImageSource source = ImageSource.camera;
    switch (sourceType) {
      case 'camera':
        source = ImageSource.camera;
        break;
      case 'gallery':
        source = ImageSource.gallery;
        break;
      default:
        source = ImageSource.camera;
    }
    final imageFile = await ImagePicker.pickImage(
      source: source,
      maxWidth: 600,
    );

    if (imageFile == null) {
      return;
    }
    setState(() {
      _storedImage = imageFile;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final imageName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${appDir.path}/$imageName');
    widget.pickedImage(savedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
              border: Border.all(
            width: 1,
            color: Colors.grey,
          )),
          child: _storedImage == null
              ? Text(
                  'No image Taken',
                  textAlign: TextAlign.center,
                )
              : Image.file(
                  _storedImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
          alignment: Alignment.center,
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.camera),
              label: Text(
                'Take picture',
              ),
              textColor: Theme.of(context).primaryColor,
              onPressed: () {
                _takePicture('camera');
              },
            ),
            SizedBox(
              height: 5,
            ),
            FlatButton.icon(
              icon: Icon(Icons.file_upload),
              label: Text(
                'Pick picture',
              ),
              textColor: Theme.of(context).primaryColor,
              onPressed: () {
                _takePicture('gallery');
              },
            ),
          ],
        )
      ],
    );
  }
}

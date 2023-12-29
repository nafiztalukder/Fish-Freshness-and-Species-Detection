import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  late File _image;
  final imagepicker = ImagePicker();
  List _predictions = [];
  bool _isSpeciesDetection = false;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) => setState(() {}));
  }

  loadModel() async {
    await Tflite.loadModel(
      model: _isSpeciesDetection
          ? 'assets/model_species.tflite'
          : 'assets/model_unquant.tflite',
      labels: _isSpeciesDetection
          ? 'assets/labels_species.txt'
          : 'assets/labels.txt',
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  detectImage(File image) async {
    var predictions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _loading = false;
      if (predictions != null) {
        _predictions = predictions;
      }
    });
  }

  _loadImageGallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectImage(_image);
  }

  _loadImageCamera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectImage(_image);
  }

  _toggleDetectionType() {
    setState(() {
      _isSpeciesDetection = !_isSpeciesDetection;
      _loading = true;
      loadModel().then((value) => setState(() {}));
    });
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Information'),
          content: const Text(
            'This app detects fish freshness or species based on the selected model. '
            'You can choose an image from your camera or gallery for detection. '
            'The detection results include the label and confidence level.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearImage() {
    setState(() {
      _loading = true;
      _image = File(''); 
    });
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSpeciesDetection
              ? 'Fish Species Detection'
              : 'Fish Freshness Detection',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 254, 254, 254),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 28, 100, 183),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'info') {
                _showInfoDialog(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 8),
                      Text('Info'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        height: h,
        width: w,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(252, 254, 237, 209),
              Color.fromARGB(255, 240, 240, 240),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              height: 200,
              width: 200,
              padding: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Transform.scale(
                scale: 1.35,
                child: Image.asset('assets/fish3.png'),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            if (!_loading)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.file(_image),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _clearImage,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_loading)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _loadImageCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 0, 121, 107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.black, // Add shadow color
                      elevation: 5, // Add elevation for shadow effect
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      'TAKE PHOTO',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      _loadImageGallery();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 230, 74, 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.black, 
                      elevation: 5, 
                    ),
                    icon: const Icon(Icons.image),
                    label: Text(
                      'UPLOAD IMAGE',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleDetectionType,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 255, 193, 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.black,
                      elevation: 5, 
                    ),
                    child: Text(
                      _isSpeciesDetection
                          ? 'SWITCH TO FRESHNESS DETECTION'
                          : 'SWITCH TO SPECIES DETECTION',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(25),
                    child: Text(
                      _isSpeciesDetection
                            ? 'Note: Upload or take the photo of the fish for detection'
                            : 'Note: Upload or take the photo of the gills for detection',
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 9, 0, 0)),
                    ),
                  ),
                ],
              ),
            if (!_loading)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      _predictions[0]['label'].toString().substring(2),
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(_predictions[0]['confidence'] * 100).toStringAsFixed(2)}%',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),  
          ],
        ),
      ),
    );
  }
}

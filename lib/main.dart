// Main class

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:dropdown_search/dropdown_search.dart';

import 'package:talentlair_compress/widgets/exit_dialog.dart';

void main() {
  // Locking only Portraint up mode.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xfffb9f26),
        accentColor: const Color(0xfffbb826),
        scaffoldBackgroundColor: Colors.white,
      ),
      title: 'TalentLair Compress',
      debugShowCheckedModeBanner: false,
      home: TalentLairCompress(),
    ),
  );
}

class TalentLairCompress extends StatefulWidget {
  @override
  _TalentLairCompressState createState() => _TalentLairCompressState();
}

class _TalentLairCompressState extends State<TalentLairCompress> {
  /// List of all available encoders.
  final List<String> encoders = [
    'fontconfig',
    'freetype',
    'fribidi',
    'gmp',
    'gnutls',
    'kvazaar',
    'lame',
    'libaom',
    'libass',
    'libiconv',
    'libilbc',
    'libtheora',
    'libvorbis',
    'libvpx',
    'libwebp',
    'libxml2',
    'opencore-amr',
    'opus',
    'shine',
    'snappy',
    'soxr',
    'speex',
    'twolame',
    'vid.stab',
    'vo-amrwbenc',
    'wavpack',
    'x264',
    'x265',
    'xvidcore'
  ];

  /// List of available presets
  ///
  /// Preset is used as a tradeoff between quality and time required for compression.
  final List<String> presets = [
    'veryslow',
    'slow',
    'medium',
    'fast',
    'faster',
    'veryfast',
    'superfast',
    'ultrafast'
  ];

  /// Video encoder library
  ///
  /// Default `libx264`
  String encoder = 'libx264';

  /// Constant Rate Factor
  ///
  /// Valid range `0-51`
  ///
  /// Default value `23`
  int crf = 23;

  /// Video input path
  String inputPath = '';

  /// Video output path
  ///
  /// Default path `application_documents_directory/output.mp4`
  String outputPath;

  /// Preset is used as a tradeoff between quality and time required for compression.
  ///
  /// Default `medium`
  String preset = 'medium';

  /// Variable to store the chosen video file.
  File file;

  /// Variable used to track if the video compression is in progress
  bool progressVisibility = false;

  /// Text to be displayed under the folder image
  String text = "Choose file";

  @override
  initState() {
    super.initState();

    // Sorting all encoders for dropdown list.
    setState(() {
      encoders.sort();
    });

    // Initializing default value of the output video path as output directory.
    getApplicationDocumentsDirectory().then((applicationDirectory) {
      setState(() {
        outputPath = "${applicationDirectory.path}/output.mp4";
      });
    });
  }

  /// Function to choose a file from your device
  Future<void> chooseFile() async {
    ImagePicker.pickVideo(source: ImageSource.gallery).then((videoFile) {
      setState(() {
        file = videoFile;
        text = videoFile.path;
      });
    });
  }

  /// Function to compress video according to the custom parameters.
  void processVideo({@required context}) async {
    setState(() {
      progressVisibility = true;
    });

    /// Path of cache directory
    final Directory _appDocDir = await getTemporaryDirectory();

    /// Path of directory inside cache to store all the chosen videos.
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/trimmed_videos/');
    String newPath;

    // If directory does not already exist, create directory.
    if (await _appDocDirFolder.exists()) {
      newPath = _appDocDirFolder.path;
    } else {
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      newPath = _appDocDirNewFolder.path;
    }

    // Required to generate unique file name for the processed video.
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('hh-mm-ss-dd-MM-yyyy').format(now);

    /// Input video path
    String path = file.path;

    /// Output video path
    String outputPath = newPath + formattedDate + 'trimmed.mp4';

    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();

    /// Start time of the video
    double s = 0;

    /// End time of the video
    double d = 30 / 1;
    // double d = videoPlayerController.value.duration.inSeconds / 1;

    print(
        "Executing FlutterFFMpeg command: '-i $path -ss $s -t $d -c:v libx264 -preset ultrafast -crf 30 $outputPath'");

    /// Executing the encoding with the selected params.
    _flutterFFmpeg
        .execute(
            '-i $path -ss $s -t $d -c:v libx264 -preset ultrafast -crf 30 $outputPath')
        .then((value) async {
      /// Compressed file

      file.length().then((uncompressedLength) {
        File(outputPath).length().then((compressedLength) {
          setState(() {
            text =
                "Uncompressed size: ${uncompressedLength / 1000}KB\nCompressed Size: ${compressedLength / 1000}KB";
          });
        });
      });

      setState(() {
        progressVisibility = true;
        file = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: Colors.white,
            elevation: 0.0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                FlutterIcons.chevron_left_oct,
                color: Colors.black,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ExitDialog(),
                );
              },
            ),
            title: Text(
              'TalentLair Compress',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(18.0),
                height: 25.0,
                width: 25.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/assets/images/folder.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () async {
                    await chooseFile();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('lib/assets/images/folder.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Text(
                        "$text",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30.0,
                    horizontal: 15.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownSearch(
                        label: "Select Encoder",
                        items: encoders,
                        selectedItem: encoder,
                        onChanged: (value) => setState(() {
                          encoder = value.toString();
                        }),
                      ),
                      DropdownSearch(
                        items: presets,
                        label: "Select preset",
                        selectedItem: preset,
                        onChanged: (value) => setState(() {
                          preset = value.toString();
                        }),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Select CRF value",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12.0,
                                  ),
                                ),
                                Text(
                                  crf.toString(),
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            label: crf.toString(),
                            activeColor: const Color(0xfffbb826),
                            value: double.parse(crf.toString()),
                            onChanged: (value) => setState(() {
                              crf = value.toInt();
                            }),
                            min: 0,
                            max: 51,
                            divisions: 50,
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text(
                            "Compress",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            primary: const Color(0xfffb9f26),
                          ),
                          onPressed: () {
                            if (file != null)
                              processVideo(context: context);
                            else
                              Fluttertoast.showToast(msg: "Choose a file");
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

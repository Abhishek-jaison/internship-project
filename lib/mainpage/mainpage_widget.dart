import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:tailorapp_assignment/display/display_widget.dart';
import 'package:tailorapp_assignment/flutter_flow/flutter_flow_theme.dart';
import 'package:tailorapp_assignment/flutter_flow/flutter_flow_util.dart';
import 'package:tailorapp_assignment/flutter_flow/flutter_flow_widgets.dart';
import 'mainpage_model.dart';
export 'mainpage_model.dart';
import 'package:tailorapp_assignment/display/display_model.dart';


class MainpageWidget extends StatefulWidget {
  const MainpageWidget({super.key});

  @override
  State<MainpageWidget> createState() => _MainpageWidgetState();
}

class _MainpageWidgetState extends State<MainpageWidget> {
  late MainpageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  PlatformFile? _pickedVideo;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainpageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 chars
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }
Future<Uint8List> _readBytesFromFile(PlatformFile file) async {
  try {
    if (file.readStream != null) {
      final bytes = await file.readStream!.reduce((a, b) => [...a, ...b]);
      return Uint8List.fromList(bytes);
    } else {
      throw Exception('File read stream is null or empty');
    }
  } catch (e) {
    print('Error reading bytes from file: $e');
    throw e; // Rethrow the exception to propagate it up
  }
}

Future<void> pickVideoAndComputeHash() async {
  try {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
  
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      
      try {
        final bytes = await _readBytesFromFile(file);
        final hash = sha256.convert(bytes);
        final videoMetadata = {
          'name': file.name,
          'location': file.path,
          'type': file.extension,
          'size': file.size,
          'hash': hash.toString(),
        };
        print('Video Metadata: $videoMetadata');
      } catch (e) {
        print('Error processing file: $e');
      }
    } else {
      print('No file picked or result is null');
    }
  } catch (e) {
    print('Error picking file: $e');
  }
}




  Future<Uint8List> generatePdf(String name, String encryptedPassword) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Name: $name'),
                pw.Text('Encrypted Password: $encryptedPassword'),
              ],
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> saveDataToMongoDB(
      String name, String encryptedPassword, Map<String, dynamic> videoMetadata) async {
    final data = {
      'name': name,
      'password': encryptedPassword,
      'videoDetails': videoMetadata,
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/saveData'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved to MongoDB')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data')),
      );
    }
  }

  Future<void> showDataFromMongoDB() async {
    final response = await http.get(Uri.parse('http://localhost:3000/getData'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DisplayWidget(data: data)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'Tailor Apps',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                  child: TextFormField(
                    controller: _model.textController1,
                    focusNode: _model.textFieldFocusNode1,
                    autofocus: true,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0.0,
                              ),
                      hintStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0.0,
                              ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).error,
                          width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).error,
                          width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          letterSpacing: 0.0,
                        ),
                    validator:
                        _model.textController1Validator.asValidator(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 20.0, 8.0, 0.0),
                  child: TextFormField(
                    controller: _model.textController2,
                    focusNode: _model.textFieldFocusNode2,
                    autofocus: true,
                    obscureText: !_model.passwordVisibility,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0.0,
                              ),
                      hintStyle:
                          FlutterFlowTheme.of(context).labelMedium.override(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0.0,
                              ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).alternate,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).primary,
                          width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).error,
                          width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).error,
                          width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: InkWell(
                        onTap: () => setState(
                          () => _model.passwordVisibility =
                              !_model.passwordVisibility,
                        ),
                        focusNode: FocusNode(skipTraversal: true),
                        child: Icon(
                          _model.passwordVisibility
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 20.0,
                        ),
                      ),
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          letterSpacing: 0.0,
                        ),
                    validator:
                        _model.textController2Validator.asValidator(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: pickVideoAndComputeHash,
                    text: 'Pick Video and Compute Hash',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_model.textController1.text.isEmpty ||
                          _model.textController2.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Name and Password cannot be empty'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final encryptedPassword =
                          encryptPassword(_model.textController2.text);

                      final pdfBytes = await generatePdf(
                        _model.textController1.text,
                        encryptedPassword,
                      );

                      print('Generated PDF: $pdfBytes');
                    },
                    text: 'Convert data to pdf',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (_model.textController1.text.isEmpty ||
                          _model.textController2.text.isEmpty ||
                          _pickedVideo == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Name, Password and Video cannot be empty'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final encryptedPassword =
                          encryptPassword(_model.textController2.text);

                      final videoMetadata = {
                        'name': _pickedVideo!.name,
                        'location': _pickedVideo!.path,
                        'type': _pickedVideo!.extension,
                        'size': _pickedVideo!.size,
                        'hash': sha256.convert(
                                _pickedVideo!.bytes ?? await _pickedVideo!.readStream!.first)

                            .toString(),
                      };

                      await saveDataToMongoDB(
                        _model.textController1.text,
                        encryptedPassword,
                        videoMetadata,
                      );
                    },
                    text: 'Upload to MongoDB',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: showDataFromMongoDB,
                    text: 'Show data',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 3.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

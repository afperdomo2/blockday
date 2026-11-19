import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

abstract class BackupFileService {
  Future<String?> pickBackupContent();

  Future<bool> saveBackupContent(String content, String fileName);
}

class FilePickerBackupFileService implements BackupFileService {
  @override
  Future<String?> pickBackupContent() async {
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Seleccionar copia de seguridad',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return null;
    final bytes = await files.single.readAsBytes();
    return utf8.decode(bytes);
  }

  @override
  Future<bool> saveBackupContent(String content, String fileName) async {
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Guardar copia de seguridad',
      fileName: fileName,
      mimeType: 'application/json',
      bytes: Uint8List.fromList(utf8.encode(content)),
    );
    return uri != null;
  }
}

class FakeBackupFileService implements BackupFileService {
  String? contentToPick;
  bool pickCancelled = false;
  bool saveResult = true;
  String? lastSavedContent;
  String? lastSavedName;

  @override
  Future<String?> pickBackupContent() async {
    if (pickCancelled) return null;
    return contentToPick;
  }

  @override
  Future<bool> saveBackupContent(String content, String fileName) async {
    lastSavedContent = content;
    lastSavedName = fileName;
    return saveResult;
  }
}

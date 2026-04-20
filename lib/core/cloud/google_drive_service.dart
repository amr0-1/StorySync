import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

const String _backupFileName = 'storysync_backup.json';

const List<String> _scopes = ['https://www.googleapis.com/auth/drive.appdata'];

final googleDriveServiceProvider = Provider<GoogleDriveService>((ref) {
  return GoogleDriveService();
});

class GoogleDriveService {
  GoogleSignIn? _googleSignIn;
  DriveApi? _driveApi;
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  Future<bool> signIn() async {
    try {
      _googleSignIn = GoogleSignIn(
        scopes: _scopes,
        signInOption: SignInOption.standard,
      );

      final GoogleSignInAccount? user = await _googleSignIn!.signIn();

      if (user == null) {
        _isSignedIn = false;
        return false;
      }

      final httpClient = await _googleSignIn!.authenticatedClient();
      if (httpClient == null) {
        _isSignedIn = false;
        return false;
      }
      _driveApi = DriveApi(httpClient);
      _isSignedIn = true;

      return true;
    } catch (e) {
      _isSignedIn = false;
      _driveApi = null;
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
      _isSignedIn = false;
      _driveApi = null;
    } catch (e) {
      // Ignore errors during sign out
    }
  }

  Future<bool> uploadBackup(String jsonString) async {
    if (_driveApi == null || !_isSignedIn) {
      return false;
    }

    try {
      final existingFile = await _findBackupFile();

      final media = Media(
        Stream.fromIterable([utf8.encode(jsonString)]),
        utf8.encode(jsonString).length,
        contentType: 'application/json',
      );

      if (existingFile != null) {
        final driveFile = File()..name = _backupFileName;
        if (existingFile.parents?.isNotEmpty == true) {
          driveFile.parents = [existingFile.parents!.first];
        }

        await _driveApi!.files.update(
          driveFile,
          existingFile.id!,
          uploadMedia: media,
        );
      } else {
        final driveFile = File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];

        await _driveApi!.files.create(driveFile, uploadMedia: media);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> downloadBackup() async {
    if (_driveApi == null || !_isSignedIn) {
      return null;
    }

    try {
      final existingFile = await _findBackupFile();

      if (existingFile == null || existingFile.id == null) {
        return null;
      }

      final response = await _driveApi!.files.get(
        existingFile.id!,
        downloadOptions: DownloadOptions.fullMedia,
      );

      if (response is Media) {
        final bytes = await response.stream.toList();
        final buffer = StringBuffer();
        for (final chunk in bytes) {
          buffer.write(utf8.decode(chunk));
        }
        return buffer.toString();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<File?> _findBackupFile() async {
    if (_driveApi == null) return null;

    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName'",
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<DateTime?> getLastBackupTime() async {
    if (_driveApi == null || !_isSignedIn) {
      return null;
    }

    try {
      final file = await _findBackupFile();
      if (file?.modifiedTime != null) {
        return file!.modifiedTime;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

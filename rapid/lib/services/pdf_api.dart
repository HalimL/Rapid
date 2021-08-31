import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/widgets.dart';
import 'package:rapid/model/certificate.dart';
import 'package:rapid/repository/firestore_repo.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required Document pdf,
    required Certificate certificate,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file
        .writeAsBytes(bytes)
        .whenComplete(() async => await FireStoreRepo().addCertificate(
              certificate.testID,
              false,
              certificate.userID,
              '${certificate.testID}.pdf',
              certificate.expiringDate,
            ));

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }
}

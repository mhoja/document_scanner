import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Where scanned pages come from and how they are shown.
///
/// On phones pages come from the document scanner and live on disk. The
/// scanner has no web implementation, so in a browser pages are picked as
/// images and referenced by blob URL instead.
class PageSource {
  PageSource._();

  static Future<List<String>?> capture({required int maxPages}) async {
    if (!kIsWeb) {
      return CunningDocumentScanner.getPictures(noOfPages: maxPages, isGalleryImportAllowed: true);
    }

    final picker = ImagePicker();
    if (maxPages == 1) {
      final image = await picker.pickImage(source: ImageSource.gallery);
      return image == null ? null : [image.path];
    }
    final images = await picker.pickMultiImage();
    return images.map((i) => i.path).toList();
  }

  static Widget image(
    String path, {
    BoxFit? fit,
    double? width,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    return kIsWeb
        ? Image.network(path, fit: fit, width: width, errorBuilder: errorBuilder)
        : Image.file(File(path), fit: fit, width: width, errorBuilder: errorBuilder);
  }
}

/// Supported file types for sync
enum FileType {
  /// Image files (jpg, jpeg, png, gif, bmp, webp)
  image,

  /// Video files (mp4, mov, avi, mkv, webm)
  video,

  /// Document files (pdf, doc, docx, txt, rtf)
  document,
}

/// Extension methods for FileType
extension FileTypeX on FileType {
  /// Get supported file extensions for this type
  List<String> get extensions {
    switch (this) {
      case FileType.image:
        return [
          '.jpg',
          '.jpeg',
          '.png',
          '.gif',
          '.bmp',
          '.webp',
          '.heic',
          '.tiff',
        ];
      case FileType.video:
        return [
          '.mp4',
          '.mov',
          '.avi',
          '.mkv',
          '.webm',
          '.m4v',
          '.3gp',
          '.wmv',
        ];
      case FileType.document:
        return [
          '.pdf',
          '.doc',
          '.docx',
          '.txt',
          '.rtf',
          '.xls',
          '.xlsx',
          '.ppt',
          '.pptx',
        ];
    }
  }

  /// Get display name for this file type
  String get displayName {
    switch (this) {
      case FileType.image:
        return 'Images';
      case FileType.video:
        return 'Videos';
      case FileType.document:
        return 'Documents';
    }
  }
}
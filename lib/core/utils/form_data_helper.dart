import 'dart:io';
import 'package:dio/dio.dart';

/// FormData Helper
/// Utility class for building FormData for media uploads
/// Supports single and multiple file uploads
/// 
/// Example usage:
/// ```dart
/// // Single file upload
/// final formData = FormDataHelper.single(
///   file: File('path/to/image.jpg'),
///   fieldName: 'medium',
///   fields: {'type': '1', 'for': 'personal-photo'},
/// );
/// 
/// // Multiple files upload
/// final formData = FormDataHelper.multiple(
///   files: [File('path/to/image1.jpg'), File('path/to/image2.jpg')],
///   fieldsPerFile: [
///     {'type': '1', 'for': 'id-photo'},
///     {'type': '1', 'for': 'personal-photo'},
///   ],
///   fieldNamePattern: 'media[{{index}}][medium]',
/// );
/// ```
class FormDataHelper {
  /// Build FormData for single file upload
  /// 
  /// [file] - File to upload
  /// [fieldName] - Form field name for the file (default: 'medium')
  /// [fields] - Additional form fields (type, for, etc.)
  /// 
  /// Returns [FormData] ready for upload
  static FormData single({
    required File file,
    String fieldName = 'medium',
    Map<String, dynamic>? fields,
  }) {
    final formData = FormData();
    
    // Add file
    formData.files.add(
      MapEntry(
        fieldName,
        MultipartFile.fromFileSync(
          file.path,
          filename: file.path.split('/').last,
        ),
      ),
    );

    // Add additional fields
    if (fields != null) {
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    return formData;
  }

  /// Build FormData for multiple files upload
  /// 
  /// [files] - List of files to upload
  /// [fieldNamePattern] - Pattern for field names (default: 'media[{{index}}][medium]')
  ///   Use {{index}} as placeholder for file index
  /// [fieldsPerFile] - List of additional fields for each file (optional)
  ///   If provided, length must match [files] length
  /// 
  /// Returns [FormData] ready for upload
  /// 
  /// Throws [ArgumentError] if [fieldsPerFile] length doesn't match [files] length
  static FormData multiple({
    required List<File> files,
    String fieldNamePattern = 'media[{{index}}][medium]',
    List<Map<String, dynamic>>? fieldsPerFile,
  }) {
    if (files.isEmpty) {
      throw ArgumentError('Files list cannot be empty');
    }

    if (fieldsPerFile != null && fieldsPerFile.length != files.length) {
      throw ArgumentError(
        'fieldsPerFile length (${fieldsPerFile.length}) must match files length (${files.length})',
      );
    }

    final formData = FormData();

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      
      // Replace {{index}} in pattern
      final fieldName = fieldNamePattern.replaceAll('{{index}}', i.toString());
      
      // Add file
      formData.files.add(
        MapEntry(
          fieldName,
          MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );

      // Add fields for this file
      if (fieldsPerFile != null && fieldsPerFile[i] != null) {
        final fields = fieldsPerFile[i]!;
        fields.forEach((key, value) {
          // Replace {{index}} in field name if needed
          final fieldKey = key.contains('{{index}}')
              ? key.replaceAll('{{index}}', i.toString())
              : key;
          
          // For array fields like 'media[0][type]', use the pattern
          if (fieldKey == 'type' || fieldKey == 'for') {
            formData.fields.add(
              MapEntry('media[$i][$fieldKey]', value.toString()),
            );
          } else {
            formData.fields.add(MapEntry(fieldKey, value.toString()));
          }
        });
      }
    }

    return formData;
  }

  /// Build FormData with custom structure
  /// 
  /// [files] - Map of field names to files
  /// [fields] - Additional form fields
  /// 
  /// Returns [FormData] ready for upload
  static FormData custom({
    Map<String, File>? files,
    Map<String, dynamic>? fields,
  }) {
    final formData = FormData();

    // Add files
    if (files != null) {
      files.forEach((fieldName, file) {
        formData.files.add(
          MapEntry(
            fieldName,
            MultipartFile.fromFileSync(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      });
    }

    // Add fields
    if (fields != null) {
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    return formData;
  }
}

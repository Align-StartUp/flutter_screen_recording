import 'dart:convert';
import 'dart:io';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const baseUrl =
      'https://3ootu2jau9.execute-api.ap-southeast-1.amazonaws.com/prod/api/mobile';

  // String baseUrl = ApiUrl.baseUrl;
  // final log = logger(StorageService);

  Future<dynamic> getPresignedUrl() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get-presigned-url'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      return jsonResponse;
    } else {
      throw Exception('Failed to get presigned URL');
    }
  }

  Future<String> uploadFile(String path) async {
    try {
      if (path.isEmpty) {
        return '';
      }
      // Tạo File object từ đường dẫn tệp
      final file = File(path);

      // Lấy URL đã ký trước (presigned URL)
      final presignedUrl = await getPresignedUrl() as Map<String, dynamic>;
      final uploadUrl = presignedUrl['presignedUrl'] as String;
      final fileKey = presignedUrl['key'] as String;

      // Ghi log để biết URL và key
      // log
      //   ..d('Presigned URL: $uploadUrl')
      //   ..d('File key: $fileKey');
      print('Presigned URL: $uploadUrl');
      print('File key: $fileKey');

      // Tiến hành tải lên file
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': 'video/mp4',
        },
        body: await file.readAsBytes(),
      );

      // Kiểm tra kết quả phản hồi
      // log
      //   ..d('Mã trạng thái phản hồi: ${response.statusCode}')
      //   ..d('Tiêu đề phản hồi: ${response.headers}')
      //   ..d('Nội dung phản hồi: ${response.body}');

      print('Mã trạng thái phản hồi: ${response.statusCode}');
      print('Tiêu đề phản hồi: ${response.headers}');
      print('Nội dung phản hồi: ${response.body}');

      return 'https://align-storage.s3.ap-southeast-1.amazonaws.com/$fileKey';
    } catch (e) {
      print('Lỗi tải lên: $e');
      return '';
    }
  }

  Future<void> startRecordScreen(String title) async {
    await FlutterScreenRecording.startRecordScreen(title);
  }

  Future<String> stopRecordScreen() async {
    final path = await FlutterScreenRecording.stopRecordScreen;
    return path;
  }
}

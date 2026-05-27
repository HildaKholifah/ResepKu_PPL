import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_storage.dart';

class HttpService {
  final String baseUrl = "http://192.168.100.12:8000/api/";
  final TokenStorage tokenStorage = TokenStorage();

  // PUBLIK (BUKAN PRIVATE)
  Future<Map<String, String>> getHeaders() async {
    final token = await tokenStorage.getToken();
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders();

    final response = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));

    log('GET $endpoint => ${response.statusCode}');
    log(response.body);
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await getHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await http
        .post(url, headers: headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 40));

    log('POST $endpoint => ${response.statusCode}');
    log(response.body);
    return response;
  }

  Future<http.Response> postWithFile(
    String endpoint,
    Map<String, String> fields,
    File? file,
    String fileFieldName,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = await getHeaders();

    final request = http.MultipartRequest('POST', url);

    // header
    request.headers.addAll(headers);

    // form-data
    request.fields.addAll(fields);

    // file
    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileFieldName, file.path),
      );
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 40),
    );

    final response = await http.Response.fromStream(streamedResponse);

    log('POST $endpoint (with file) => ${response.statusCode}');
    log(response.body);

    return response;
  }
}

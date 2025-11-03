import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:convert';

import 'package:radhe/utils/constants.dart';
import 'package:http_parser/http_parser.dart';

class Service {
  final BASE_URL = "https://radhetilesworld.in/api/";

  // generateHeaders() async {
  //   String _token = await SharedPref.readString(AUTH_TOKEN);
  //   return {
  //     'Authorization': 'Bearer $_token',
  //   };
  // }

  Future<Map<String, dynamic>> post(
    String url,
    bool isPassHeader,
    Map<String, dynamic> params,
  ) async {
    final fullUrl = Uri.parse(BASE_URL + url);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (isPassHeader)
        // 'Authorization': 'Bearer ${AppConstants.authID}', // Uncomment when needed
        'Authorization':
            'Bearer ${AppConstants.LOGIN_TOKEN}', // Use login token
    };

    print('POST URL => $fullUrl');
    print('Headers => $headers');
    print('Params => $params');

    try {
      final response = await http.post(
        fullUrl,
        headers: headers,
        body: jsonEncode(params),
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonBody = json.decode(response.body);

      print('Response Code => $statusCode');
      print('Response Body => $jsonBody');

      Map<String, dynamic> result = {
        ...jsonBody,
        'code': statusCode,
        'success': jsonBody['success'] ?? true,
      };

      // Optional: handle token expiration
      if (statusCode == 401) {
        // TODO: Navigate to login or show session expired dialog
        // navigatorKey.currentState?.pushNamedAndRemoveUntil(LOGIN, (_) => false);
        print('Session expired. Code 401.');
      }

      return result;
    } catch (e) {
      print('POST ERROR => $e');
      return {'success': false, 'message': 'Request failed: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> postWithImages(
    String url,
    Map<String, dynamic> params,
    String imageKey,
    List<File> imageFiles,
  ) async {
    final uri = Uri.parse(BASE_URL + url);

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${AppConstants.LOGIN_TOKEN}',
    };

    print('BASE_URL => $BASE_URL');
    print('Endpoint URL => $url');
    print('Params => $params');

    final request = http.MultipartRequest("POST", uri)..headers.addAll(headers);

    // Add fields
    request.fields.addAll(
      params.map((key, value) => MapEntry(key, value.toString())),
    );

    // Add multiple images
    for (var i = 0; i < imageFiles.length; i++) {
      final imageFile = imageFiles[i];

      if (imageFile.path.isNotEmpty) {
        final mimeType = lookupMimeType(imageFile.path);
        //
        // final fileName = 'upload.${mimeType?.split('/').last ?? 'jpg'}';
        final random = Random();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final randomInt = random.nextInt(
          100000,
        ); // Random number to avoid collision

        final extension = mimeType?.split('/').last ?? 'jpg';
        final fileName = 'img_${timestamp}_$randomInt.$extension';

        final file = await http.MultipartFile.fromPath(
          'estimate_image[]',
          imageFile.path,
          filename: fileName,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        );

        request.files.add(file);
        print('Attached image: $fileName');
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonBody = json.decode(response.body);

      print('Response Code => $statusCode');
      print('Response Body => $jsonBody');

      Map<String, dynamic> result = {
        ...jsonBody,
        'code': statusCode,
        'success': jsonBody['success'] ?? true,
      };

      return result;
    } catch (e) {
      print('Upload Error => $e');
      return {'success': false, 'message': 'Upload failed: ${e.toString()}'};
    }
  }

  // Future<Map<String, dynamic>> postWithImage(
  //   String url,
  //   Map<String, dynamic> params,
  //   String imageKey,
  //   File imageFile,
  // ) async {
  //   final uri = Uri.parse(BASE_URL + url);

  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Accept': 'application/json',
  //     'Authorization': 'Bearer ${AppConstants.LOGIN_TOKEN}',
  //   };

  //   print('BASE_URL => $BASE_URL');
  //   print('Endpoint URL => $url');
  //   print('Params => $params');

  //   final request = http.MultipartRequest("POST", uri)..headers.addAll(headers);

  //   // Add fields
  //   request.fields.addAll(
  //     params.map((key, value) => MapEntry(key, value.toString())),
  //   );

  //   // Add image if valid
  //   if (imageFile.path.isNotEmpty) {
  //     final mimeType = lookupMimeType(imageFile.path);
  //     final fileName = 'upload.${mimeType?.split('/').last ?? 'jpg'}';

  //     final file = await http.MultipartFile.fromPath(
  //       imageKey,
  //       imageFile.path,
  //       // contentType: mimeType != null ? MediaType.parse(mimeType) : null,
  //       filename: fileName,
  //     );

  //     request.files.add(file);
  //     print('Attached image: $fileName');
  //   }

  //   try {
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);

  //     final int statusCode = response.statusCode;
  //     final Map<String, dynamic> jsonBody = json.decode(response.body);

  //     print('Response Code => $statusCode');
  //     print('Response Body => $jsonBody');

  //     Map<String, dynamic> result = {
  //       ...jsonBody,
  //       'code': statusCode,
  //       'success': jsonBody['success'] ?? true,
  //     };

  //     if (statusCode == 401) {
  //       print('Unauthorized access. Token might be expired.');
  //       // Handle session expiration if needed
  //     }

  //     return result;
  //   } catch (e) {
  //     print('Upload Error => $e');
  //     return {'success': false, 'message': 'Upload failed: ${e.toString()}'};
  //   }
  // }

  // Future<Map<String, dynamic>> post(
  //   String _url,
  //   bool isPassHeader,
  //   Map _params,
  // ) {
  //   print('_url => $_url');
  //   Map<String, String> requestHeaders = {};

  //   if (isPassHeader) {
  //     requestHeaders = {
  //       'Accept': 'application/json',
  //       // 'Authorization': 'Bearer ${AppConstants.authID}',
  //     };
  //   } else {
  //     requestHeaders = {
  //       "content-type": "application/json",
  //       //  "accept" : "application/json",
  //       "accept": "*/*",
  //     };
  //   }

  //   // print(requestHeaders);

  //   print('BASE_URL => $BASE_URL');
  //   print('_params => $_params');
  //   return http
  //       .post(
  //         Uri.parse(BASE_URL + _url),
  //         headers: requestHeaders,
  //         body: json.encode(_params),
  //       )
  //       .then((response) {
  //         print(response);
  //         final code = response.statusCode;
  //         print('response code => $code');
  //         final body = response.body;
  //         final jsonBody = json.decode(body);
  //         print('response body => $body');
  //         Map<String, dynamic> _resDic;
  //         if (code == 200) {
  //           _resDic = Map<String, dynamic>.from(jsonBody);
  //           _resDic['success'] = _resDic['success'] == false;
  //           if (!_resDic['success']) {
  //             // if (_resDic[IS_TOKEN_EXPIRED] == 0) {
  //             //   _resDic[HTTP_CODE] = 401;
  //             // }
  //           }
  //         } else {
  //           _resDic = Map<String, dynamic>();
  //           _resDic['success'] = false;
  //           // _resDic[IS_TOKEN_EXPIRED] = 0;
  //           _resDic['message'] = jsonBody['message'] != null
  //               ? jsonBody['message']
  //               : 'Something went wrong';
  //           _resDic['code'] = code;
  //         }
  //         if (_resDic['code'] == 401) {
  //           // unAuthAlertDialog(
  //           //   navigatorKey.currentState,
  //           //   'Alert',
  //           //   _resDic[MESSAGE],
  //           //   () => {
  //           //     navigatorKey.currentState!.pushNamedAndRemoveUntil(
  //           //       LOGIN,
  //           //       (route) => false,
  //           //     ),
  //           // },
  //           // );
  //         }
  //         print('===>> Response : $_resDic');
  //         return _resDic;
  //       });
  // }

  Future<Map<String, dynamic>> get(String url, bool isPassHeader) async {
    final Uri fullUrl = Uri.parse(BASE_URL + url);
    final Map<String, String> headers = isPassHeader
        ? {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConstants.LOGIN_TOKEN}',
          }
        : {'Content-Type': 'application/json', 'Accept': 'application/json'};

    print('Request URL => $fullUrl');
    print('Headers => $headers');

    try {
      final response = await http.get(fullUrl, headers: headers);
      final int code = response.statusCode;
      final Map<String, dynamic> jsonBody = json.decode(response.body);

      print('Response Code => $code');
      print('Response Body => $jsonBody');

      Map<String, dynamic> result = {};

      if (code == 200) {
        result = {...jsonBody, 'success': jsonBody['success'] ?? true};
      } else {
        result = {
          'success': false,
          'message': jsonBody['message'] ?? 'Something went wrong',
          'code': code,
        };
      }

      print('Parsed Response => $result');

      return result;
    } catch (e) {
      print('Request Error => $e');
      return {'success': false, 'message': 'Request failed: $e'};
    }
  }

  // Future<Map<String, dynamic>> get(String _url, bool isPassHeader) {
  //   Map<String, String> requestHeaders = Map();
  //   print('_url => $_url');
  //   if (isPassHeader) {
  //     requestHeaders = {
  //       'Accept': 'application/json',
  //       // 'Authorization': 'Bearer ${AppConstants.authID}',
  //     };
  //   } else {
  //     requestHeaders = {
  //       "Content-Type": "application/json",
  //       "Accept": "application/json",
  //     };
  //   }
  //   print('BASE_URL => $BASE_URL');

  //   return http.get(Uri.parse(BASE_URL + _url), headers: requestHeaders).then((
  //     response,
  //   ) {
  //     print(response);
  //     final code = response.statusCode;
  //     final body = response.body;
  //     final jsonBody = json.decode(body);
  //     print('response code => $code');
  //     Map<String, dynamic> _resDic;
  //     if (code == 200) {
  //       _resDic = Map<String, dynamic>.from(jsonBody);
  //       _resDic['success'] = _resDic['success'] == false;
  //       if (!_resDic['success']) {
  //         // if (_resDic[IS_TOKEN_EXPIRED] == 0) {
  //         //   _resDic[HTTP_CODE] = 401;
  //         // }
  //       }
  //     } else {
  //       _resDic = Map<String, dynamic>();
  //       _resDic['success'] = false;
  //       // _resDic[IS_TOKEN_EXPIRED] = 0;
  //       _resDic['message'] = jsonBody['message'] != null
  //           ? jsonBody['message']
  //           : 'Something went wrong';
  //       _resDic['code'] = code;
  //     }
  //     // if (_resDic[HTTP_CODE] == 401) {
  //     //   unAuthAlertDialog(
  //     //     navigatorKey.currentContext,
  //     //     'Alert',
  //     //     _resDic[MESSAGE],
  //     //     () => {
  //     //       Navigator.pushNamedAndRemoveUntil(
  //     //         navigatorKey.currentContext!,
  //     //         LOGIN,
  //     //         (r) => false,
  //     //       ),
  //     //     },
  //     //   );
  //     //   return _resDic;
  //     // }
  //     print('===>> Response : $_resDic');
  //     return _resDic;
  //   });
  // }

  // Future<Map<String, dynamic>> delete(
  //   String _url,
  //   Map<String, String> _headers,
  // ) {
  //   print('_url => $_url');
  //   if (_headers != null) {
  //     print('_headers => $_headers');
  //   }

  //   return http
  //       .delete(
  //         Uri.parse(BASE_URL + _url),
  //         headers: (_headers != null) ? _headers : {},
  //       )
  //       .then((response) {
  //         final code = response.statusCode;
  //         final body = response.body;
  //         final jsonBody = json.decode(body);
  //         print('response code => $code');
  //         print('response body => $body');
  //         Map<String, dynamic> _resDic;
  //         if (code == 200) {
  //           _resDic = Map<String, dynamic>.from(jsonBody);
  //           _resDic[STATUS] = _resDic[STATUS] == 1;
  //           if (!_resDic[STATUS]) {
  //             if (_resDic[IS_TOKEN_EXPIRED] == 1) {
  //               _resDic[HTTP_CODE] = 401;
  //             }
  //           }
  //         } else {
  //           _resDic = Map<String, dynamic>();
  //           _resDic[STATUS] = false;
  //           _resDic[IS_TOKEN_EXPIRED] = 0;
  //           _resDic[MESSAGE] = jsonBody[MESSAGE] != null
  //               ? jsonBody[MESSAGE]
  //               : 'Something went wrong';
  //           _resDic[HTTP_CODE] = code;
  //         }

  //         if (_resDic[HTTP_CODE] == 401) {
  //           unAuthAlertDialog(
  //             navigatorKey.currentState,
  //             'Alert',
  //             _resDic[MESSAGE],
  //             () => {
  //               Navigator.pushNamedAndRemoveUntil(
  //                 navigatorKey.currentContext!,
  //                 LOGIN,
  //                 (r) => false,
  //               ),
  //             },
  //           );
  //           return _resDic;
  //         }

  //         print('===>> Response : $_resDic');
  //         return _resDic;
  //       });
  // }

  // Future<Map<String, dynamic>> postWithImage(
  //   String _url,
  //   // Map<String, String> _headers,
  //   Map<String, String> _params,
  //   String _imageKey,
  //   File _imageFile,
  // ) async {
  //   // if (_headers != null) {
  //   //   print('_headers => $_headers');
  //   // }
  //   Map<String, String> requestHeaders = Map();
  //   requestHeaders = {
  //     'Accept': 'application/json',
  //     'Content-Type': 'multipart/form-data',
  //     // 'Authorization': 'Bearer ${AppConstants.authID}',
  //   };
  //   print('BASE_URL => $BASE_URL');
  //   print('_params => $_params');

  //   print('_url => $_url');
  //   var request = http.MultipartRequest("POST", Uri.parse(BASE_URL + _url));
  //   if (requestHeaders != null) {
  //     request.headers.addAll(requestHeaders);
  //   }
  //   if (_params != null) {
  //     request.fields.addAll(_params);
  //   }
  //   if (!_imageFile.path.isEmpty) {
  //     final _type = lookupMimeType(_imageFile.path);
  //     print(_imageFile.path);
  //     final _name = 'mmOperator.${_type?.split('/').last}';
  //     // '${DateTime.now().toIso8601String()}.png';
  //     print(_name);
  //     final _partFile = http.MultipartFile(
  //       _imageKey,
  //       _imageFile.readAsBytes().asStream(),
  //       _imageFile.lengthSync(),
  //       filename: _name,
  //     );
  //     request.files.add(_partFile);

  //     print('request files: ${request.files}');
  //   }
  //   var response = await request.send();
  //   final code = response.statusCode;
  //   print('response code => $code');
  //   final responseBody = await http.Response.fromStream(response);
  //   final body = responseBody.body;
  //   print('response ==> $body');
  //   final jsonBody = json.decode(body);

  //   print('response body => $jsonBody');
  //   Map<String, dynamic> _resDic;
  //   if (code == 200) {
  //     _resDic = Map<String, dynamic>.from(jsonBody);
  //     _resDic[STATUS] = _resDic[STATUS] == false;
  //   } else {
  //     _resDic = Map<String, dynamic>();
  //     _resDic[STATUS] = false;
  //     _resDic[IS_TOKEN_EXPIRED] = 0;
  //     _resDic[MESSAGE] = jsonBody[MESSAGE] != null
  //         ? jsonBody[MESSAGE]
  //         : 'Something went wrong';
  //   }
  //   _resDic[HTTP_CODE] = code;
  //   print('===>> Response : $_resDic');

  //   if (_resDic['HTTP_CODE'] == 401) {
  //     unAuthAlertDialog(
  //       navigatorKey.currentState,
  //       'Alert',
  //       _resDic[MESSAGE],
  //       () => {
  //         Navigator.pushNamedAndRemoveUntil(
  //           navigatorKey.currentContext!,
  //           LOGIN,
  //           (r) => false,
  //         ),
  //       },
  //     );
  //     return _resDic;
  //   }

  //   return _resDic;
  // }
}

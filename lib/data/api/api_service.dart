import 'dart:convert';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:story_app/data/model/requests/login_request_model.dart';
import 'package:story_app/data/model/requests/register_request_model.dart';
import 'package:story_app/data/model/response/auth/auth_response.dart';
import 'package:story_app/data/model/response/detail/stories_detail_response.dart';
import 'package:story_app/data/preferences/token.dart';

import '../../core/constants/variables.dart';
import '../model/response/default/default_response.dart';
import '../model/response/stories/stories_response.dart';

class ApiService {
  Future<Either<String, AuthResponse>> login(
      LoginRequestModel loginRequestModel) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/login');
      final header = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      final body = jsonEncode(loginRequestModel.toJson());

      final response = await http.post(
        url,
        headers: header,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseBody);
        return Right(authResponse);
      } else {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorJson['message'] ?? 'Unknown error occurred';
        return Left(errorMessage);
      }
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<String, DefaultResponse>> register(
      RegisterRequestModel registerRequestModel) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/register');
      final header = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      final body = jsonEncode(registerRequestModel.toJson());

      final response = await http.post(
        url,
        headers: header,
        body: body,
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final defaultResponse = DefaultResponse.fromJson(responseBody);
        return Right(defaultResponse);
      } else {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorJson['message'] ?? 'Unknown error occurred';
        return Left(errorMessage);
      }
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<String, StoryResponse>> getStories({
    int? page,
    int? size,
    int? location,
  }) async {
    try {
      final authData = await TokenPreference().getAuthData();

      final queryParameters = {
        if (page != null) 'page': page.toString(),
        if (size != null) 'size': size.toString(),
        if (location != null) 'location': location.toString(),
      };

      final url = Uri.parse('${Variables.baseUrl}/stories')
          .replace(queryParameters: queryParameters);

      final header = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.loginResults.token}',
      };

      final response = await http.get(
        url,
        headers: header,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final storyResponse = StoryResponse.fromJson(responseBody);
        return Right(storyResponse);
      } else {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorJson['message'] ?? 'Unknown error occurred';
        return Left(errorMessage is String ? errorMessage : 'Unknown error');
      }
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<String, StoryDetailResponse>> getStoryDetail(String id) async {
    try {
      final authData = await TokenPreference().getAuthData();

      final url = Uri.parse('${Variables.baseUrl}/stories/$id');

      final header = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authData?.loginResults.token}',
      };

      final response = await http.get(
        url,
        headers: header,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final storyDetailResponse = StoryDetailResponse.fromJson(responseBody);
        return Right(storyDetailResponse);
      } else {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorJson['message'] ?? 'Unknown error occurred';
        return Left(errorMessage is String ? errorMessage : 'Unknown error');
      }
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<String, DefaultResponse>> addNewStory(
    List<int> bytes,
    String fileName,
    String description,
    double? lat,
    double? lon,
  ) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/stories');
      final authData = await TokenPreference().getAuthData();

      var request = http.MultipartRequest('POST', url);

      final multiPartFile = http.MultipartFile.fromBytes(
        "photo",
        bytes,
        filename: fileName,
      );

      final Map<String, String> fields = {
        "description": description,
        if (lat != null) "lat": lat.toString(),
        if (lon != null) "lon": lon.toString(),
      };

      final Map<String, String> headers = {
        "Authorization": "Bearer ${authData?.loginResults.token}",
      };

      request.files.add(multiPartFile);
      request.fields.addAll(fields);
      request.headers.addAll(headers);

      final http.StreamedResponse streamedResponse = await request.send();
      final int statusCode = streamedResponse.statusCode;

      final Uint8List responseList = await streamedResponse.stream.toBytes();
      final String responseData = String.fromCharCodes(responseList);

      if (statusCode == 201) {
        final responseBody = jsonDecode(responseData);
        final defaultResponse = DefaultResponse.fromJson(responseBody);
        return Right(defaultResponse);
      } else {
        final errorJson = jsonDecode(responseData) as Map<String, dynamic>;
        final errorMessage = errorJson['message'] ?? 'Unknown error occurred';
        return Left(errorMessage);
      }
    } catch (e) {
      return Left('Exception: $e');
    }
  }
}

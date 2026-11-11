import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:job_hive/features/home/models/cred_model.dart';

class HomeService {
  HomeService({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  static const _mockResponsePath = 'assets/mock/home_response.json';

  final AssetBundle _assetBundle;

  Future<RegisterRequestModel> fetchHomeData() async {
    final jsonString = await _assetBundle.loadString(_mockResponsePath);
    final decodedJson = jsonDecode(jsonString) as Map<String, dynamic>;
    return RegisterRequestModel.fromJson(decodedJson);
  }
}

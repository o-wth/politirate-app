import 'dart:convert';
import "dart:async";
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import "../configs/endpoints.dart";

Future<List<dynamic>> getAPIResponseFromEndpoint(
    {@required endpoint, @required queryParams}) async {
  assert(endpoint != null);
  assert(queryParams != null);
  Uri uri = Uri.https(BASE_API_URI, endpoint, queryParams);
  var response = await http.get(uri);
  return json.decode(response.body);
}

Future<String> getTwitterProfileImage(String username) async {
  var query = {
    "username": username
  };
  Uri uri = Uri.https(BASE_API_URI, PROFILE_IMAGE_ENDPOINT, query);
  var response = await http.get(uri);
  var image = json.decode(response.body);
  return image["image"];
}


import 'dart:convert';
import "dart:async";
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import "../configs/endpoints.dart";

Future<List<dynamic>> getPoliticianNames(String name) async {
  var queryParams = {
    "name": name
  };
  Uri uri = Uri.https(BASE_API_URI, GET_POLITICIAN_ENDPOINT, queryParams);
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

Future<Map<String, dynamic>> getTweets(var username) async {
  Map<String, String> query = {
    "username": username
  };
  Uri uri = Uri.https(BASE_API_URI, TWEETS_ENDPOINT, query);
  var response = await http.get(uri);
  Map<String, dynamic> body = json.decode(response.body);
  return body;
}

Future<Map<String, dynamic>> getNews(var name) async {
  Map<String, String> query = {
    "q": name
  };
  Uri uri = Uri.https(BASE_API_URI, NEWS_ENDPOINT, query);
  var response = await http.get(uri);
  Map<String, dynamic> body = json.decode(response.body);
  return body;
}
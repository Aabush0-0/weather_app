// import 'package:dio/dio.dart';

// class ApiServices {
//   ApiServices.internal() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: "https://wwww.weatherapi.com/",
//         connectTimeout: const Duration(seconds: 10),
//         receiveTimeout: const Duration(seconds: 10),
//         headers: {'Content-Type': 'application/json'},
//       ),
//     );
//   }

//   static final ApiServices _instance = ApiServices.internal();

//   late Dio _dio;

//   static Dio get dio => _instance._dio;
// }

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

const String apiKey = "4ef0baf541804ad988573832250411";

class ApiServices {
  final String _baseUrl = "https://api.weatherapi.com/v1";
  Future<Map<String, dynamic>> getHourlyForecast(String location) async {
    final url = Uri.parse(
      "$_baseUrl/forecast.json?key=$apiKey&q=$location&days=7",
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch data: ${res.body}');
    }
    final data = json.decode(res.body);

    if (data.containsKey('error')) {
      throw Exception(data['error']['message'] ?? 'Invalid location');
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> getPastSevenDaysWeather(
    String location,
  ) async {
    final List<Map<String, dynamic>> pastWeather = [];
    final today = DateTime.now();
    for (int i = 1; i <= 7; i++) {
      final data = today.subtract(Duration(days: i));
      final formattedDate =
          "${data.year}-${data.month.toString().padLeft(2, "0")}-${data.day.toString().padLeft(2, '0')}";

      final url = Uri.parse(
        "$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedDate",
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        if (data.containsKey('error')) {
          throw Exception(data['error']['message'] ?? 'Invalid location');
        }
        if (data['forecast']?['forecastday'] != null) {
          pastWeather.add(data);
        }
      } else {
        debugPrint('Failed to fetch past data for $formattedDate: ${res.body}');
      }
    }

    return pastWeather;
  }
}

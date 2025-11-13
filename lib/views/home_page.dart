import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sim_weather/Provider/theme_provider.dart';
import 'package:sim_weather/core/network/api_services.dart';
import 'package:sim_weather/widgets/csearch_bar.dart';
import 'package:sim_weather/widgets/today_forecast_section.dart';
import 'package:sim_weather/widgets/weather_info_item.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _apiService = ApiServices();
  String city = "Kathmandu";
  String country = "";
  Map<String, dynamic> currentValue = {};
  List<dynamic> hourly = [];
  List<dynamic> pastWeek = [];
  List<dynamic> next7days = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCity();
  }

  Future<void> _loadSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('last_city');
    if (savedCity != null && savedCity.isNotEmpty) {
      city = savedCity;
    }
    _fetchWeather();
  }

  Future<void> _saveCity(String cityName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_city', cityName);
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final forecast = await _apiService.getHourlyForecast(city);
      final past = await _apiService.getPastSevenDaysWeather(city);

      setState(() {
        currentValue = forecast['current'] ?? {};
        hourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];
        next7days = forecast['forecast']?['forecastday'] ?? [];
        pastWeek = past;
        city = forecast['location']?['name'] ?? city;
        country = forecast['location']?['country'] ?? '';
        isLoading = false;
      });

      _saveCity(city);
    } catch (e) {
      setState(() {
        currentValue = {};
        hourly = [];
        pastWeek = [];
        next7days = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'City not found or invalid. Please enter valid city name.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    String iconPath = currentValue['condition']?['icon'] ?? '';
    String imageUrl = iconPath.isNotEmpty ? "https:$iconPath" : "";

    Widget imageWidget = imageUrl.isNotEmpty
        ? Image.network(imageUrl, height: 200, width: 200, fit: BoxFit.cover)
        : const SizedBox();

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: SafeArea(
          child: CSearchBar(
            onSubmitted: (value) {
              city = value;
              _fetchWeather();
            },
          ),
        ),
        actions: [
          GestureDetector(
            onTap: notifier.toggleTheme,
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.black : Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 15,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (currentValue.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "$city${country.isNotEmpty ? ',$country' : ''}",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 40,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    "${currentValue['temp_c']}°C",
                    style: TextStyle(
                      fontSize: 50,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${currentValue['condition']['text']}",
                    style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  imageWidget,
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      height: 100,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary,
                            offset: const Offset(1, 1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          WeatherInfoItem(
                            iconUrl:
                                "https://cdn-icons-png.flaticon.com/512/4148/4148460.png",
                            value: "${currentValue['humidity']}%",
                            label: "Humidity",
                          ),
                          WeatherInfoItem(
                            iconUrl:
                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRPgiKKEG6CmJQVBCFowhcN1E_iBbVgCO3rvA&s",
                            value: "${currentValue['wind_kph']} kph",
                            label: "Wind",
                          ),
                          WeatherInfoItem(
                            iconUrl:
                                "https://cdn-icons-png.flaticon.com/512/6281/6281340.png",
                            value:
                                "${hourly.isNotEmpty ? hourly.map((h) => h['temp_c']).reduce((a, b) => a > b ? a : b) : "N/A"}°C",
                            label: "Max Temp.",
                          ),
                        ],
                      ),
                    ),
                  ),

                  TodayForecastSection(
                    hourly: hourly,
                    pastWeek: pastWeek,
                    next7days: next7days,
                    currentValue: currentValue,
                    city: city,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

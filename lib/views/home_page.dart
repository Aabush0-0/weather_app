import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sim_weather/Provider/theme_provider.dart';
import 'package:sim_weather/core/network/api_services.dart';
import 'package:sim_weather/views/weekly.dart';
import 'package:sim_weather/widgets/csearch_bar.dart';
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
    _fetchWeather();
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
            'City not found or invalid. Please enter valid city name',
          ),
        ),
      );
    }
  }

  String formatTime(String timeString) {
    DateTime time = DateTime.parse(timeString);
    return DateFormat.j().format(time);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    String iconPath = currentValue['condition']?['icon'] ?? '';
    String imageUrl = iconPath.isNotEmpty ? "https:$iconPath" : "";

    Widget imageWidgets = imageUrl.isNotEmpty
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
            else ...[
              if (currentValue.isNotEmpty)
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
                    imageWidgets,
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
                    Container(
                      height: 250,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Today's Forecast",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Weekly(
                                          currentValue: currentValue,
                                          city: city,
                                          pastWeek: pastWeek,
                                          next7days: next7days,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Weekly Forecast",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          SizedBox(
                            height: 160,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: hourly.length,
                              itemBuilder: (context, index) {
                                final hour = hourly[index];
                                final now = DateTime.now();
                                final hourTime = DateTime.parse(hour['time']);
                                final isCurrentHour =
                                    now.hour == hourTime.hour &&
                                    now.day == hourTime.day;
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    height: 70,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isCurrentHour
                                          ? Colors.orangeAccent
                                          : Colors.black38,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 10,
                                      children: [
                                        Text(
                                          isCurrentHour
                                              ? "Now"
                                              : formatTime(hour['time']),
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Image.network(
                                          "https:${hour['condition']?['icon']}",
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                        Text(
                                          "${hour["temp_c"]}°C",
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;

  //dataFetch korar jonno MAP create....

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

//lat lon position er jonno ei function

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;
    print("latitude is ${lat} ${lon}");
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=14d9dd467325cfc7fd60eb30058dc5bb";
    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=14d9dd467325cfc7fd60eb30058dc5bb";

    var weatherResponse = await http.get(Uri.parse(weatherApi));

    var forecastResponse = await http.get(Uri.parse(forecastApi));
    print("Result is ${forecastResponse.body}");
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    });
  }

  var lat;
  var lon;
  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 350,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 24, 41, 25),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      35,
                    ),
                  ),
                ),
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${Jiffy(DateTime.now()).format('MMM do yy, h:mm a')}",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Text("${weatherMap!["name"]}"),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Image.asset(
                          weatherMap!["main"]["feels_like"] == "clear sky"
                              ? "images/rainy.png"
                              : weatherMap!["main"]["feels_like"] == "rainy"
                                  ? "images/rainy.png"
                                  : "images/rainy.png",
                        ),
                        Text(
                          "${weatherMap!["main"]["temp"]}°",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Feels Like : ${weatherMap!["main"]["feels_like"]}",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Feels Like : ${weatherMap!["weather"][0]["main"]}",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Humidity : ${weatherMap!["main"]["humidity"]}, Pressure :${weatherMap!["main"]["pressure"]}",
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Sunrise${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm:a")} : , Sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm:a")}:",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: forecastMap!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 60,
                        margin: EdgeInsets.only(right: 8),
                        color: Color.fromARGB(255, 255, 226, 226),
                        width: 120,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset(
                                weatherMap!["main"]["feels_like"] == "clear sky"
                                    ? "images/rainy.png"
                                    : weatherMap!["main"]["feels_like"] ==
                                            "rainy"
                                        ? "images/rainy.png"
                                        : "images/rainy.png",
                              ),
                            ),
                            Text(
                                "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE h:mm")}"),
                            Text(
                                "${forecastMap!["list"][index]["main"]["temp_min"]} / ${forecastMap!["list"][index]["main"]["temp_max"]}"),
                            Text(
                                "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE h:mm")}"),
                            Text(
                              "${forecastMap!["list"][index]["weather"][0]["description"]}",
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

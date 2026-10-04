import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:womensafety/widgets/home_widgets/live_safe/BusStationCard.dart';
import 'package:womensafety/widgets/home_widgets/live_safe/HospitalCard.dart';
import 'package:womensafety/widgets/home_widgets/live_safe/PharmacyCard.dart';
import 'package:womensafety/widgets/home_widgets/live_safe/PoliceStationCard.dart';

class LiveSafe extends StatelessWidget{
  static Future<void> openMap(String location)async {
    String googleUrl ='https://www.google.com/maps/search/$location';
    final Uri _url = Uri.parse(googleUrl);
    try{
      await launchUrl(_url);
    }catch (e) {
      Fluttertoast.showToast(
        msg: 'Something went wrong! Call emergency number',
      );
    }
  }
  @override
  Widget build(BuildContext context) {
return SizedBox(
  height: 108,
  width: MediaQuery.of(context).size.width,
  child: ListView(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    physics: const BouncingScrollPhysics(),
    scrollDirection: Axis.horizontal,
    children: [
      PoliceStationCard(onMapFunction: openMap),
      HospitalCard(onMapFunction: openMap),
      PharmacyCard(onMapFunction: openMap),
      BusStationCard(onMapFunction: openMap)
    ],
  ),
);
  }

}

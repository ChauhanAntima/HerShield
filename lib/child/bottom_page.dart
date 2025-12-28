import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/fab_bar_bottom.dart';
import '../profile_mode/settings.dart';
import 'bottom_screens/add_contacts.dart';
import 'bottom_screens/chat_page.dart';
import 'bottom_screens/child_home_page.dart';
import 'bottom_screens/review_page.dart';

class BottomPage extends StatefulWidget {
  const BottomPage({Key? key}) : super(key: key);

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex = 0;

  final List<Widget> pages = [
    HomeScreen(),
    AddContactsPage(),
    CheckUserStatusBeforeChat(),
    ReviewPage(),
     SettingsPage()
  ];

  void onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: FABBottomAppBar(
          backgroundColor: Colors.white,                 //  bar color
          selectedColor: const Color(0xFFF06292),        //  ACTIVE ICON PINK
          unselectedColor: Colors.grey,                  //  INACTIVE ICON
          onTabSelected: onTapped,
          items: [
            FABBottomAppBarItem(
              iconData: Icons.home,
              text: "Home",
            ),
            FABBottomAppBarItem(
              iconData: Icons.contacts,
              text: "Contacts",
            ),
            FABBottomAppBarItem(
              iconData: Icons.chat,
              text: "Chat",
            ),
            FABBottomAppBarItem(
              iconData: Icons.rate_review,
              text: "Ratings",
            ),
            FABBottomAppBarItem(
              iconData: Icons.settings,
              text: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}

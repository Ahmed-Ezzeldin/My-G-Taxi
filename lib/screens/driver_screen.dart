import 'package:flutter/material.dart';
import 'package:g_taxi/screens/tabs/earning_tab.dart';
import 'package:g_taxi/screens/tabs/home_tab.dart';
import 'package:g_taxi/screens/tabs/profile_tab.dart';
import 'package:g_taxi/screens/tabs/rating_tab.dart';
import 'package:g_taxi/style/my_colors.dart';

class DriverScreen extends StatefulWidget {
  static const String routeName = 'driver_screen';

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> with SingleTickerProviderStateMixin {
  TabController tabController;
  int selectedIndex = 0;
  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomeTab(),
          EarningTab(),
          RatingTab(),
          ProfileTab(),
        ],
        controller: tabController,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        unselectedItemColor: MyColors.textLight,
        selectedItemColor: MyColors.green,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Earning'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Rating'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        onTap: onItemClicked,
      ),
    );
  }
}

import 'package:ecomerce_vendor_store/views/screens/nav_screens/earnings_screen.dart';
import 'package:ecomerce_vendor_store/views/screens/nav_screens/edit_screen.dart';
import 'package:ecomerce_vendor_store/views/screens/nav_screens/orders_screen.dart';
import 'package:ecomerce_vendor_store/views/screens/nav_screens/profile_screen.dart';
import 'package:ecomerce_vendor_store/views/screens/nav_screens/upload_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainVendorScreen extends StatefulWidget {
  const MainVendorScreen({super.key});

  @override
  State<MainVendorScreen> createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    const EarningsScreen(),
    const UploadScreen(),
    const EditScreen(),
    const OrdersScreen(),
    const ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _pageIndex,
          onTap: (value) {
            setState(() {
              _pageIndex = value;
            });
          },
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.purple,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.money_dollar),
              label: "Earnings",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.upload_circle),
              label: "Upload",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Edit"),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shopping_cart),
              label: "Orders",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ]),
      body: _pages[_pageIndex],
    );
  }
}

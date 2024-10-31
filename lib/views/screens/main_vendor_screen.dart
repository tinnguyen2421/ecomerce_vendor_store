import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainVendorScreen extends StatefulWidget {
  const MainVendorScreen({super.key});

  @override
  State<MainVendorScreen> createState() => _MainVendorScreenState();
}

class _MainVendorScreenState extends State<MainVendorScreen> {
  int _pageIndex = 0;
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
                icon: Icon(CupertinoIcons.money_dollar), label: "Earnings"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.upload_circle), label: "Upload"),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: "Edit"),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.shopping_cart), label: "Orders"),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
          ]),
    );
  }
}

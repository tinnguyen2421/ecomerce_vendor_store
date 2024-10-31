import 'package:ecomerce_vendor_store/provider/vendor_provider.dart';
import 'package:ecomerce_vendor_store/views/screens/authencation/login_screen.dart';
import 'package:ecomerce_vendor_store/views/screens/main_vendor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> _checkTokenAndSetUser(WidgetRef ref) async {
      //Obtain an instance of sharePreference
      SharedPreferences preferences = await SharedPreferences.getInstance();
      //retrive the authentication token and user data stored locally
      String? token = preferences.getString('auth_token');
      String? vendorJson = preferences.getString('vendor');
      //if both the token and date are avaiable, update the vendor state
      if (token != null && vendorJson != null) {
        ref.read(vendorProvider.notifier).setVendor(vendorJson);
      } else {
        ref.read(vendorProvider.notifier).SignOut();
      }
    }

    return MaterialApp(
      home: FutureBuilder(
        future: _checkTokenAndSetUser(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final vendor = ref.watch(vendorProvider);
          return vendor != null ? const MainVendorScreen() : LoginScreen();
        },
      ),
    );
  }
}

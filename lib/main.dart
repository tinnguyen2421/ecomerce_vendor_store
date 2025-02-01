import 'package:ecomerce_vendor_store/controllers/vendor_auth_controller.dart';
import 'package:ecomerce_vendor_store/provider/vendor_provider.dart';
import 'package:ecomerce_vendor_store/views/screens/authencation/login_screen.dart';
import 'package:ecomerce_vendor_store/views/screens/main_vendor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> checkTokenAndSetUser(WidgetRef ref, context) async {
      await VendorAuthController().getUserData(context, ref);
      ref.watch(vendorProvider);
    }

    return MaterialApp(
      home: FutureBuilder(
        future: checkTokenAndSetUser(ref, context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final vendor = ref.watch(vendorProvider);
          return vendor!.token.isNotEmpty
              ? const MainVendorScreen()
              : LoginScreen();
        },
      ),
    );
  }
}

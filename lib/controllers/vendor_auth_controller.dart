import 'dart:convert';

import 'package:ecomerce_vendor_store/models/vendor.dart';
import 'package:ecomerce_vendor_store/provider/vendor_provider.dart';
import 'package:ecomerce_vendor_store/services/manage_http_respone.dart';
import 'package:ecomerce_vendor_store/global_variables.dart';
import 'package:ecomerce_vendor_store/views/screens/main_vendor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final providerContainer = ProviderContainer();

class VendorAuthController {
  Future<void> signUpVendor(
      {required String fullName,
      required String email,
      required String password,
      required context}) async {
    try {
      Vendor vendor = Vendor(
          id: '',
          fullName: fullName,
          email: email,
          state: '',
          city: '',
          locality: '',
          role: '',
          password: password);
      http.Response response = await http.post(
        Uri.parse("$uri/api/vendor/signup"),
        body: vendor.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );
      manageHttpRespond(
          response: response,
          context: context,
          onSuccess: () {
            showSnackBar(context, 'Vendor account created');
          });
    } catch (e) {}
  }

  //function to consume the backend vendor signin api
  Future<void> signInVendor(
      {required String email,
      required String password,
      required context}) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/vendor/signin'),
        body: jsonEncode({"email": email, "password": password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );
      manageHttpRespond(
          response: response,
          context: context,
          onSuccess: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            String token = jsonDecode(response.body)['token'];
            //store the authencation token securely in SharePreference
            preferences.setString('auth_token', token);
            //Endcode the user data recived from the backend as json
            final vendorJson = jsonEncode(jsonDecode(response.body)['vendor']);
            //update the application state with the user data using riverpod
            providerContainer
                .read(vendorProvider.notifier)
                .setVendor(vendorJson);

            //store the data in sharePreference
            await preferences.setString('vendor', vendorJson);
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) {
              return MainVendorScreen();
            }), (route) => false);
            showSnackBar(context, 'Logged in successfully');
          });
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }
}

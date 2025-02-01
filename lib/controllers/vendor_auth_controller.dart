import 'dart:convert';
import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:ecomerce_vendor_store/models/vendor.dart';
import 'package:ecomerce_vendor_store/provider/vendor_provider.dart';
import 'package:ecomerce_vendor_store/services/manage_http_respone.dart';
import 'package:ecomerce_vendor_store/global_variables.dart';
import 'package:ecomerce_vendor_store/views/screens/authencation/login_screen.dart';
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
          password: password,
          token: '');
      http.Response response = await http.post(
        Uri.parse("$uri/api/v2/vendor/signup"),
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
  Future<void> signInVendor({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      http.Response response = await http.post(
        Uri.parse('$uri/api/v2/vendor/signin'),
        body: jsonEncode({"email": email, "password": password}),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
      );
      manageHttpRespond(
          response: response,
          context: context,
          onSuccess: () async {
            //Access sharedPreferences for token and user data storage
            SharedPreferences preferences =
                await SharedPreferences.getInstance();

            //Extract the authentication token from the response body
            String token = jsonDecode(response.body)['token'];

            //STORE the authentication token securely in sharedPreferences

            preferences.setString('auth_token', token);

            //Encode the user data recived from the backend as json
            final userJson = jsonEncode(jsonDecode(response.body));

            //update the application state with the user data using Riverpod
            ref.read(vendorProvider.notifier).setVendor(response.body);

            //store the data in sharePreference  for future use

            await preferences.setString('user', userJson);

            if (ref.read(vendorProvider)!.token.isNotEmpty) {
              Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (context) {
                return const MainVendorScreen();
              }), (route) => false);
            }
            showSnackBar(context, 'Logged in');
          });
    } catch (e) {
      showSnackBar(context, '$e');
    }
  }

  Future<void> signOutUser(
      {required BuildContext context, required WidgetRef ref}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.remove('auth_token');
      await preferences.remove('user');
      //ref.read(orderProvider.notifier).dispose();
      ref.read(vendorProvider.notifier).signOut();
      //ref.read(orderProvider.notifier).signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
      showSnackBar(context, 'Signed out successfully');
    } catch (e) {
      showSnackBar(context, "Error signing out");
    }
  }

  getUserData(context, WidgetRef ref) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString('auth_token');
      if (token == null) {
        preferences.setString('auth_token', '');
      }
      var tokenResponse = await http.post(
        Uri.parse('$uri/vendor-tokenIsValid'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );
      var response = jsonDecode(tokenResponse.body);
      if (response == true) {
        http.Response userResponse = await http.get(
          Uri.parse('$uri/get-vendor'),
          headers: <String, String>{
            "Content-Type": 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );
        ref.read(vendorProvider.notifier).setVendor(userResponse.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateVendorData({
    required context,
    required String id,
    required File? storeImage,
    required String storeDescription,
    required WidgetRef ref,
  }) async {
    try {
      final cloudinary = CloudinaryPublic("deotwffdz", "mcjdyao7");
      CloudinaryResponse imageResponses = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(storeImage!.path,
            identifier: 'pickedImage', folder: 'storeImage'),
      );
      String image = imageResponses.secureUrl;
      //Make an HTTP PUT request to update user's state, city and locality
      final http.Response response = await http.put(
        Uri.parse('$uri/api/vendor/$id'),
        //set the header for the request to specify   that the content  is Json
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8'
        },
        //Encode the update data(state, city and locality) AS  Json object
        body: jsonEncode({
          'storeImage': image,
          'storeDescription': storeDescription,
        }),
      );

      manageHttpRespond(
          response: response,
          context: context,
          onSuccess: () async {
            final updatedUser = jsonDecode(response.body);
            final userJson = jsonEncode(updatedUser);
            ref.read(vendorProvider.notifier).setVendor(userJson);
          });
    } catch (e) {
      //catch any error that occure during the proccess
      //show an error message to the user if the update fails
      showSnackBar(context, 'Error updating location');
    }
  }
}

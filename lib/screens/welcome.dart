/// Welcome screen that displays a splash while checking internet connectivity, then navigates to Home or shows No Connectivity screen.

library;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../common/colors.dart';
import '../common/widgets/no_connectivity.dart';
import 'home/home.dart';


class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  bool? _hasInternet;

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<bool> getInternetStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  Future<void> checkConnectivity() async {
    bool connected = await getInternetStatus();
    setState(() {
      _hasInternet = connected;
    });

    if (connected) {
      // Wait 2 seconds for splash effect, then navigate
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasInternet == null) {
      // Loading spinner while checking connectivity
      return Scaffold(
        backgroundColor: AppColors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (_hasInternet == false) {
      return const NoConnectivity();
    }

    // If connected, show splash screen while waiting for navigation
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: size.height * 0.40),
            SizedBox(
              width: 130,
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: size.height * 0.5),
          ],
        ),
      ),
    );
  }
}
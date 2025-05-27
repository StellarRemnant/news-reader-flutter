/// A stateful widget that displays a full-screen message when offline,
/// allowing users to retry their internet connection.

library;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app/common/colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:news_app/screens/home/home.dart';


class NoConnectivity extends StatefulWidget {
  const NoConnectivity({super.key});

  @override
  State<NoConnectivity> createState() => _NoConnectivityState();
}

class _NoConnectivityState extends State<NoConnectivity> {
  bool _isChecking = false;

  Future<void> _retryConnection() async {
    setState(() {
      _isChecking = true;
    });

    final connectivityResult = await Connectivity().checkConnectivity();

    await Future.delayed(const Duration(seconds: 2)); // Simulate loading effect

    if (connectivityResult != ConnectivityResult.none) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.signal_wifi_off_rounded,
              size: 80,
              color: AppColors.black,
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              "Oops!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              "There is no internet connection.\nPlease check your internet settings.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            
            // Show loading spinner when checking connectivity
            if (_isChecking)
              const CircularProgressIndicator(),

            SizedBox(height: size.height * 0.01),

            ElevatedButton(
              onPressed: _isChecking ? null : _retryConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                _isChecking ? "Checking..." : "Try Again",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_hbb/mobile/pages/home_page.dart';

abstract class KVMRoutingUtils {

  static void goToRustDeskHomePage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage(),
      ),
    );
  }
}

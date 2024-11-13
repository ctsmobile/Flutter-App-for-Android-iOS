import 'dart:io';

import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final Color color;
  const Loader({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator.adaptive(
        backgroundColor: Platform.isIOS ? color : null,
        valueColor: AlwaysStoppedAnimation<Color>(color));
  }
}

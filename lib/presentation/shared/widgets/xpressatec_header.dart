import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class XpressatecHeader extends StatelessWidget {
  const XpressatecHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/imagen.svg',
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

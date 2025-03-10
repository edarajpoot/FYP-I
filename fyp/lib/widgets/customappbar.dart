import 'package:flutter/material.dart';
import 'package:fyp/utils/quotes.dart';

class CustomAppBar extends StatelessWidget {
  // const CustomAppBar({super.key});
  final Function? onTap;
  final int? quoteIndex;
  CustomAppBar({this.onTap,this.quoteIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector( //gestureD is used for hideing the cliking effects
      onTap: () {
        onTap!();
      },
      child: Container(
        child: Text(
          sweetSayings[quoteIndex!],
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
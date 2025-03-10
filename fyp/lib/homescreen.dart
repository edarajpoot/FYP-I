import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fyp/widgets/customappbar.dart';
import 'package:fyp/widgets/customcarousel.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // const HomeScreen({super.key});
  int qIndex = 0;

  getRandomQuote(){
    Random random = Random();
    setState(() {
      qIndex=random.nextInt(6);
    });
  }

// initState is when app firstly open or refresh it will change random quote without clicking.
  @override
  void initState() {     
    getRandomQuote();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomAppBar(
                quoteIndex: qIndex,
                onTap: () {
                  getRandomQuote();
                } 
              ),
              CustomCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}
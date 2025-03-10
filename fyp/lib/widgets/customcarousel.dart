import 'package:flutter/material.dart' hide CarouselController;  
import 'package:carousel_slider/carousel_slider.dart'; 
import 'package:fyp/utils/quotes.dart';


class CustomCarousel extends StatelessWidget {
  const CustomCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(
        options :CarouselOptions(
          aspectRatio: 2.0,
          autoPlay: true,
          enlargeCenterPage: true
        ),
        items: List.generate(ImageSliders.length,
         (index) => Card(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(ImageSliders[index]),
              fit: BoxFit.cover,
            ),
            ) ,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ])
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8,left: 8),
                  child: Text(articalTitle[index],
                  style: TextStyle(fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width*0.05,),
                  ),
                ),
              ),
            ),
          ),
         ),
        ),
      ),
    );
  }
}
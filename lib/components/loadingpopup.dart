import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loadingpopup extends StatelessWidget {
  const Loadingpopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    size: 60, 
                    color:Color.fromRGBO(209, 69, 255, 1),),),),
      ),
    );
  }
}
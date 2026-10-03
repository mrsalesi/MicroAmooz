import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'Page02.dart';

class Page01 extends StatelessWidget {
  const Page01({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const SizedBox(
          height: 100,
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          margin: const EdgeInsets.all(30),
          child: InkWell(
            child: Image.asset(
              "images/01_small.png",
            ),
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: const Page02(),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}

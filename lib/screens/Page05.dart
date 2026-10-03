import 'package:behkavoshapp/widgets/CustopAppBar.dart';
import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import 'Page02.dart';
import 'Page03.dart';
import 'Page04.dart';

class Page05 extends StatelessWidget {
  const Page05({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xffb2b2b2),
          centerTitle: true,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Image(
                  image: AssetImage(
                    'images/Logo.png',
                  ),
                  height: 35,
                ),
              ),
            ],
          )),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffb2b2b2), Color(0xff1291a7)],
              stops: [0.5, 0.5],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(children: [
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Image.asset(
                "images/02_small.png",
              ),
            ),
            Container(
                width: 400,
                height: 300,
                margin: const EdgeInsets.only(left: 40, right: 40, top: 0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                                height: 30,
                                margin: const EdgeInsets.all(3),
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '',
                                    contentPadding: EdgeInsets.only(left: 10),
                                  ),
                                  textDirection: TextDirection.rtl,
                                  initialValue: "",
                                  textAlignVertical: TextAlignVertical.top,
                                  validator: (value) {
                                    return '';
                                  },
                                )),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "نام ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Color(0xff1291a7),
                        thickness: 1,
                      ),
                      Container(
                        height: 30,
                        margin: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding: EdgeInsets.only(right: 10),
                                ),
                                textDirection: TextDirection.rtl,
                                initialValue: "",
                                textAlignVertical: TextAlignVertical.top,
                                validator: (value) {
                                  return '';
                                },
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "نام خانوادگی",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Color(0xff1291a7),
                        thickness: 1,
                      ),
                      Container(
                        height: 30,
                        margin: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding: EdgeInsets.only(left: 10),
                                ),
                                textDirection: TextDirection.ltr,
                                initialValue: "",
                                keyboardType: TextInputType.phone,
                                textAlignVertical: TextAlignVertical.top,
                                validator: (value) {
                                  return '';
                                },
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "شماره همراه",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Color(0xff1291a7),
                        thickness: 1,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: const Page03(),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          width: 120,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            color: Colors.black45,
                          ),
                          child: const Text(
                            "ثبت نام",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ]),
        ),
      ),
    );
  }
}

import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/score.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game play'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(builder: (context) => Score(0)));
              },
              icon: const Icon(Icons.close))
        ],
      ),
      body: const Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  late AnimationController countdownAnimationController;

  int score = 0;
  int gameDuration = 15;
  int deathPoint = 5;
  int winPoint = 5;
  Random random = Random();
  late int currentSt;
  late int currentNd;
  String checkLabel = 'Correct';
  Color checkbgColor = Colors.green.shade100;
  Color checkfgColor = Colors.green;
  IconData checkIcon = Icons.star;
  bool checking = false;
  late FlipCardController controller1;
  late FlipCardController controller2;
  List<String> cards = [
    '9S',
    '8S',
    '7S',
    '6S',
    '5S',
    '4S',
    '3S',
    '2S',
    'AS',
    'KS',
    'QS',
    'JS',
    '0S'
  ];
  void setSkipData() {
    checkLabel = 'Skip...';
    checkbgColor = Colors.amber.shade100;
    checkfgColor = Colors.amber;
    checkIcon = Icons.fast_forward;
  }

  void setCorrectData() {
    checkLabel = 'Right';
    checkbgColor = Colors.green.shade100;
    checkfgColor = Colors.green;
    checkIcon = Icons.star;
  }

  void setunCorrectData() {
    checkLabel = 'False';
    checkbgColor = Colors.red.shade100;
    checkfgColor = Colors.red;
    checkIcon = Icons.heart_broken;
  }

  void checkResult(st, nd, state) async {
    countdownAnimationController.reset();
    openUpnd();
    checking = true;
    setState(() {});
    setCorrectData();
    int result = nd - st;
    if (result > 0 && state == 'big') {
      score++;
    } else if (result == 0 && state == 'equal') {
      score += 2;
    } else if (result < 0 && state == 'small') {
      score++;
    } else if (state == 'skip') {
      setSkipData();
    } else {
      score--;
      setunCorrectData();
    }
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {});
    if (score <= -deathPoint || score >= winPoint) {
      Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => Score(score)));
      return;
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    openUpnd();
    controller1.toggleCard();
    await Future.delayed(const Duration(milliseconds: 1000));
    generateNumber();
    checking = false;
    setState(() {});
    controller1.toggleCard();

    countdownAnimationController.forward();
  }

  void generateNumber() {
    currentSt = randomNumber(random);
    currentNd = randomNumber(random);
  }

  void openUpnd() {
    controller2.toggleCard();
  }

  @override
  void initState() {
    super.initState();
    cards = cards.reversed.toList();
    controller1 = FlipCardController();
    controller2 = FlipCardController();
    generateNumber();

    countdownAnimationController = AnimationController(
        vsync: this, duration: Duration(seconds: gameDuration));
    mCount();
    countdownAnimationController.addListener(() {
      if (countdownAnimationController.status == AnimationStatus.completed) {
        checkResult(1, 1, 'skip');
      }
    });
  }

  void mCount() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    countdownAnimationController.forward();
  }

  @override
  void dispose() {
    countdownAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            mLifeText(score, deathPoint),
            AnimatedBuilder(
                animation: countdownAnimationController,
                builder: (context, child) {
                  int seconds = (gameDuration -
                          countdownAnimationController.value * gameDuration)
                      .ceil();
                  return mCountText(seconds);
                }),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: Row(
            children: [
              Expanded(
                child: FlipCard(
                  controller: controller1,
                  flipOnTouch: false,
                  side: CardSide.BACK,
                  autoFlipDuration: const Duration(seconds: 1),
                  front:
                      Image.asset('images/flip_cards/${cards[currentSt]}.png'),
                  back: Image.asset('images/flip_cards/back.png'),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: FlipCard(
                  controller: controller2,
                  flipOnTouch: false,
                  side: CardSide.BACK,
                  front:
                      Image.asset('images/flip_cards/${cards[currentNd]}.png'),
                  back: Image.asset('images/flip_cards/back.png'),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          child: checking
              ? ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(checkIcon),
                  label: Text(checkLabel),
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(checkbgColor),
                      foregroundColor: WidgetStatePropertyAll(checkfgColor)),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    myButton(() {
                      checkResult(currentSt, currentNd, 'small');
                    }, 'Small'),
                    myButton(() {
                      checkResult(currentSt, currentNd, 'equal');
                    }, 'Equal'),
                    myButton(() {
                      checkResult(currentSt, currentNd, 'big');
                    }, 'Large')
                  ],
                ),
        ),
      ],
    );
  }
}

int randomNumber(Random random, [card1 = 1]) {
  return random.nextInt(12);
}

// ignore: must_be_immutable, camel_case_types
class myButton extends StatelessWidget {
  Function onpress;
  String caption;
  myButton(this.onpress, this.caption, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(onPressed: () => onpress(), child: Text(caption)),
    );
  }
}

// ignore: must_be_immutable, camel_case_types
class mCountText extends StatelessWidget {
  int data;

  mCountText(this.data, {super.key});
  Color textColor = Colors.green;
  Color bgColor = Colors.green.shade100;

  @override
  Widget build(Object context) {
    if (data < 10) {
      textColor = Colors.orange;
      bgColor = Colors.orange.shade100;
    } else if (data < 5) {
      textColor = Colors.red.shade900;
      bgColor = Colors.red.shade100;
    }
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 5,
          ),
          Icon(
            Icons.timer_sharp,
            color: textColor,
            size: 30,
          ),
          const SizedBox(
            width: 5,
          ),
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 30),
              child: Text(
                '$data',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              )),
          const SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }
}

// ignore: must_be_immutable, camel_case_types
class mLifeText extends StatelessWidget {
  int data;
  int dp;
  mLifeText(this.data, this.dp, {super.key});
  Color textColor = Colors.black;
  Color bgColor = Colors.grey.shade200;
  IconData icon = Icons.star;
  late int mn;
  @override
  Widget build(Object context) {
    if (data > 0) {
      textColor = Colors.green;
      bgColor = Colors.green.shade100;
    } else if (data < 0 && data > -3) {
      textColor = Colors.orange;
      bgColor = Colors.orange.shade100;
      icon = Icons.heart_broken;
    } else if (data < -2) {
      textColor = Colors.red.shade900;
      bgColor = Colors.red.shade100;
      icon = Icons.heart_broken_outlined;
    }
    if (data >= 0) {
      mn = data;
    } else {
      mn = dp + data;
    }
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(10), topRight: Radius.circular(10))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 5,
          ),
          Icon(
            icon,
            color: textColor,
            size: 30,
          ),
          const SizedBox(
            width: 5,
          ),
          ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 30),
              child: Text(
                '$mn',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              )),
          const SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }
}

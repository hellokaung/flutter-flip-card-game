import 'package:flutter/material.dart';
import 'package:flutter_flip_card/game.dart';

// ignore: must_be_immutable
class Score extends StatelessWidget {
  int data;
  Score(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your score'),
      ),
      body: Body(data: data),
    );
  }
}

// ignore: must_be_immutable
class Body extends StatelessWidget {
  Body({
    super.key,
    required this.data,
  });

  final int data;
  String status = 'Win';
  Color textColor = Colors.green;
  @override
  Widget build(BuildContext context) {
    if (data == 0) {
      status = 'End';
      textColor = Colors.orange;
    } else if (data < 0) {
      status = 'Lose';
      textColor = Colors.red;
    }
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Center(
            child: Text(
          status,
          style: TextStyle(
              fontSize: 50, fontWeight: FontWeight.bold, color: textColor),
        )),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const GamePage())),
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green)),
          child: const Text(
            "Play Again",
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.amber.shade50)),
          child: const Text(
            "Exit",
            style: TextStyle(color: Colors.amber),
          ),
        ),
      ],
    );
  }
}

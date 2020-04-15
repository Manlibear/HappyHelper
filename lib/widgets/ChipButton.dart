import 'package:flutter/material.dart';

class ChipButtonToggle extends StatefulWidget {
  ChipButtonToggle({this.label, this.backgroundColour});

  final String label;
  final Color backgroundColour;

  @override
  _ChipButtonToggleState createState() =>
      _ChipButtonToggleState(this.label, this.backgroundColour);
}

class _ChipButtonToggleState extends State<ChipButtonToggle> {
  _ChipButtonToggleState(this.label, this.backgroundColour);

  String label;
  Color backgroundColour;
  bool state = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        onTap: () => {
          setState(() {
            state = !state;
          })
        },
        child: Chip(
          padding: const EdgeInsets.all(0),
          label: Text(label),
          backgroundColor: state ? backgroundColour : Colors.grey,
        ),
      ),
    );
  }
}

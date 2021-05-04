import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';

class TextDivider extends StatelessWidget {
  final String text;

  const TextDivider({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.grey, thickness: 1.2),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          text,
          style: GoogleFonts.lato().copyWith(
              fontSize: 18,
              color: Colors.grey),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Divider(
            color: Colors.grey,
            thickness: 1.2,
          ),
        )
      ],
    );
  }
}

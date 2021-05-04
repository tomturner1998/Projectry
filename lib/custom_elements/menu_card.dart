import 'package:flutter/material.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';

class MenuCard extends StatefulWidget {
  final IconData icon;
  final String text;
  final String path;
  final bool isStudent;

  const MenuCard({Key key, this.icon, this.text, this.path, this.isStudent})
      : super(key: key);

  @override
  _MenuCardState createState() => _MenuCardState();
}

class _MenuCardState extends State<MenuCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, widget.path);
      },
      child: Container(
        width: MediaQuery.of(context).size.height > 800 ? MediaQuery.of(context).size.width * 0.38 : 120,
        height: MediaQuery.of(context).size.height > 800 ? MediaQuery.of(context).size.height * 0.2 : 150,
        padding: EdgeInsets.all(5),
        child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          size: 50,
                          color: currentTheme.isDark
                              ? mediumChampagne
                              : indianYellow,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          widget.text,
                          style: Theme.of(context).textTheme.headline6,
                          textAlign: TextAlign.center,
                        )
                      ],
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

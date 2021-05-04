import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_finder/config.dart';
import 'package:project_finder/graphics/colours.dart';
import 'package:project_finder/messaging_utils/message_models.dart';

class MessageBubble extends StatefulWidget {
  final MessageDataModel message;
  final bool self;
  final bool previousSelf;

  MessageBubble({Key key, this.message, this.self, this.previousSelf})
      : super(key: key);

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.only(top: widget.previousSelf ? 0.0 : 15.0),
        margin: EdgeInsets.only(left: 12.0, right: 12.0, top: 1.0),
        alignment: widget.self ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          children: [
            Row(
              textDirection:
                  widget.self ? TextDirection.ltr : TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Wrap(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: widget.self
                              ? currentTheme.isDark
                                  ? indianYellow
                                  : mediumChampagne
                              : Theme.of(context).splashColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5.0),
                              topLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0),
                              topRight: Radius.circular(5.0))),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(14.0, 10.0, 12.0, 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.65),
                                child: Text(widget.message.content,
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.lato().copyWith(
                                        fontSize: 18,
                                        color: widget.self
                                            ? rosewood
                                            : currentTheme.isDark
                                                ? Colors.white
                                                : Colors.black)),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 8,
                ),
                Icon(
                  Icons.person,
                  size: 35,
                  color:
                      currentTheme.isDark ? mediumChampagne : deepSpaceSparkle,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

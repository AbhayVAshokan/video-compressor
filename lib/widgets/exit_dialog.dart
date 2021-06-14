import "package:flutter/material.dart";
import "package:flutter/services.dart";

/// Prompt the user to exit the application or not.
class ExitDialog extends StatefulWidget {
  @override
  _ExitDialogState createState() => _ExitDialogState();
}

class _ExitDialogState extends State<ExitDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(left: 20, top: 45 + 20, right: 20, bottom: 20),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Exit TalentLair Compress?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Are you sure you want to exit TalentLair Compress?",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    onPressed: () => SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop'),
                    child: Text(
                      "Yes",
                      style: TextStyle(fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45,
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(45),
              ),
              child: Image.asset(
                "../assets/images/logo.png",
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class NookCard extends StatelessWidget {
  NookCard(
      {Key key,
      this.imageFolder,
      this.imageKey,
      this.onTapFunc,
      this.callbackParam,
      this.extraPadding = 0})
      : super(key: key);

  final String imageKey;
  final Function onTapFunc;
  final dynamic callbackParam;
  final String imageFolder;
  final double extraPadding;

  @override
  Widget build(BuildContext context) {
    return _buildCard(context, imageFolder, imageKey, onTapFunc, callbackParam);
  }

  Widget _buildCard(BuildContext ctx, String imageFolder, String imageKey,
      Function onTapFunc, dynamic callbackParam) {
    double padding = extraPadding + 10;

    return GestureDetector(
      onTap: () => onTapFunc(callbackParam),
      child: new Material(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.white,
        child: Stack(fit: StackFit.expand, children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6),
            child: Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Color(0xFFEDDFB8),
                child: ClipRRect(
                  borderRadius: new BorderRadius.circular(8.0),
                  child: Image(
                    image: AssetImage("assets/images/acorns.png"),
                    repeat: ImageRepeat.repeatY,
                    color: Color.fromARGB(10, 0, 0, 0),
                  ),
                )),
          ),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Image(
                image: AssetImage(
                    "assets/images/" + imageFolder + "/" + imageKey + ".png")),
          )
        ]),
      ),
    );
  }
}

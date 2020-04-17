import 'package:flutter/material.dart';

class NookCard extends StatelessWidget {
  NookCard(
      {Key key,
      this.onTapFunc,
      this.builder,
      this.contentPadding = 10,
      this.backgroundColour = const Color(0xFFEDDFB8)})
      : super(key: key);

  final Function onTapFunc;
  final double contentPadding;
  final WidgetBuilder builder;
  final Color backgroundColour;

  @override
  Widget build(BuildContext context) {
    return _buildCard(context);
  }

  Widget _buildCard(BuildContext ctx) {
    return GestureDetector(
      onTap: () => {if (onTapFunc != null) onTapFunc()},
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
                color: backgroundColour,
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
            padding: EdgeInsets.all(contentPadding),
            child: builder(ctx),
            // child: Image(image: AssetImage("assets/images/" + image)),
          )
        ]),
      ),
    );
  }
}

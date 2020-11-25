import 'package:flutter/material.dart';

class BuildBottomSheetContainer extends StatelessWidget {
  final double bottomPaddingHeight;
  final Widget widget;
  BuildBottomSheetContainer(this.bottomPaddingHeight, this.widget);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        height: bottomPaddingHeight,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0.7, 0.7),
            )
          ],
        ),
        child: widget,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BuildPanelContainer extends StatefulWidget {
  final double height;
  final Widget widget;
  BuildPanelContainer(this.height, this.widget);

  @override
  _BuildPanelContainerState createState() => _BuildPanelContainerState();
}

class _BuildPanelContainerState extends State<BuildPanelContainer> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      right: 0,
      child: AnimatedSize(
        vsync: this,
        duration: Duration(milliseconds: 700),
        curve: Curves.easeOut,
        child: Container(
          height: widget.height,
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
          child: widget.widget,
        ),
      ),
    );
  }
}

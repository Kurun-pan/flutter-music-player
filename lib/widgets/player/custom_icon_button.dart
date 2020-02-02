import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final VoidCallback _onTap;
  final IconData iconData;

  CustomIconButton(this.iconData, this._onTap);

  @override
  Widget build(BuildContext context) {
    return new IconButton(
      onPressed: _onTap,
      iconSize: 50.0,
      icon: new Icon(iconData),
      color: Theme.of(context).buttonColor,
    );
  }
}

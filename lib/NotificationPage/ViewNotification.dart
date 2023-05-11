import 'package:flutter/material.dart';

class ViewNotifications extends StatefulWidget {
   final String msg;
   const ViewNotifications({Key? key,required this.msg}) : super(key: key);

  @override
  State<ViewNotifications> createState() => _ViewNotificationsState();
  }

class _ViewNotificationsState extends State<ViewNotifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.msg),
      ),
    );
  }
}

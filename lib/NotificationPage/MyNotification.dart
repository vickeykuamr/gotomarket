import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer';
import 'ViewNotification.dart';

FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

 class InitNotification{

  static Future<void> initializeSettings(ctx)async{
    AndroidInitializationSettings androidSettings = const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings iosSettings = const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestCriticalPermission: true,
        requestSoundPermission: true
    );
    InitializationSettings initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings
    );

    bool? initialized = await notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          log(response.payload.toString());
          String pay=response.payload.toString();
          Navigator.push(ctx, MaterialPageRoute(builder: (context)=>ViewNotifications(msg: pay,)));
        }
    );
    log('message');
    log("Notifications: $initialized");
  }

  static void payloadNotification(ctx) async {
    NotificationAppLaunchDetails? details = await notificationsPlugin.getNotificationAppLaunchDetails();
    if(details != null) {
      if(details.didNotificationLaunchApp) {
        NotificationResponse? response = details.notificationResponse;
        String? pay = 'response.payload';
        Navigator.push(ctx, MaterialPageRoute(builder: (context)=>ViewNotifications(msg: pay,)));
        if(response != null) {
          // String? payload = response.payload;
        }
      }
    }
  }

 }
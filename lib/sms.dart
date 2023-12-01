import 'dart:async';

// import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

bool sendDirect = true;

Future<void> sms(List<String>? recipients, String msg) async {
  if (recipients != null) {
    try {
      String result = await sendSMS(
        message: msg,
        recipients: recipients,
        sendDirect: sendDirect,
      );
      print(result);
    } catch (error) {
      print(error.toString());
    }
  }
}

Future<void> _canSendSMS() async {
  bool result = await canSendSMS();
  print(result);
}

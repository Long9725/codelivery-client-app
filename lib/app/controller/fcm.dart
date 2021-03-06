import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:codelivery/app/controller/match.dart';
import 'package:codelivery/app/controller/web_view.dart';
import 'package:codelivery/app/controller/dialog.dart';

import 'package:codelivery/app/ui/match/match.dart';
import 'package:codelivery/app/ui/accept_match/accpet_match.dart';
import 'package:webview_flutter/webview_flutter.dart';

// provider로 이동하는 게 맞지 않을까? 푸시 알람은 UI를 컨트롤하는 부분이 없는 것 같은데...
// 해봐야 눌렀을 때 페이지 이동 정도?
class FcmController extends GetxController {
  static FcmController get to => Get.find();

  final Rxn<RemoteMessage> message = Rxn<RemoteMessage>();
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late RemoteNotification? notification;
  late String? token;

  Future<bool> initialize() async {
    // Firebase 초기화부터 해야 Firebase Messaging 을 사용할 수 있다.
    print("before");
    await Firebase.initializeApp();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    token = await FirebaseMessaging.instance.getToken();
    // String? email = "test";
    // try {
    //   final response = await http.get(Uri.parse(
    //       "http://192.168.55.51:8080/api/fcm/user?email=$email&token=$token"));
    //   print("response: " + response.body);
    // } catch (e) {
    //   print("user initial error: " + e.toString());
    // }
    // print("after");
    // Android용 새 Notification Channel
    const AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      'high_importance_channel', // 임의의 id
      'High Importance Notifications', // 설정에 보일 채널명
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    // Notification Channel을 디바이스에 생성
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    // Android 에서는 별도의 확인 없이 리턴되지만, requestPermission()을 호출하지 않으면 수신되지 않는다.
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    // foreground 상태는 FlutterLocalNotificationsPlugin.initialize() 의 파라미터인 onSelectNotification() 에서 이동.
    // background 상태는 FirebaseMessaging.onMessageOpenedApp.listen() 에서 처리.
    // terminated 상태는 앱 실행 시에 FirebaseMessaging.instance.getInitialMessage() 를 호출해서 도착한 메시지가 있는지 확인하고 이동.
    // 현 코드로도 terminated 처리가 된다...?

    // foreground push notification
    await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: IOSInitializationSettings()),
        // handle action when press notification
        onSelectNotification: (String? payload) async {
      _handleMessage(message.value);
    });

    // background push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
      message.value = remoteMessage;
      print("onMessage: ${message.value?.data.toString()}");
      notification = remoteMessage.notification;
      AndroidNotification? android = remoteMessage.notification?.android;

      bool isIOS =
          (foundation.defaultTargetPlatform == foundation.TargetPlatform.iOS &&
                  notification != null)
              ? true
              : false;
      bool isAndroid = (foundation.defaultTargetPlatform ==
                  foundation.TargetPlatform.android &&
              notification != null &&
              android != null)
          ? true
          : false;

      if (isIOS || isAndroid) {
        _handleMessage(message.value);
      }
    });

    // print(await FirebaseMessaging.instance.getToken());
    return true;
  }

  Future<void> sendMessage(
      {required String email,
      required String title,
      required String body}) async {
    try {
      final response = await http.get(Uri.parse(
          "http://10.0.2.2:8080/api/fcm/send?email=$email&title=$title&body=$body"));
      print("response: " + response.body);
    } catch (e) {
      print("user initial error: " + e.toString());
    }
    return;
  }

  void _handleMessage(
    RemoteMessage? message,
  ) {
    print("handleMessage: " + (message?.data['type'] ?? "null"));
    switch (message?.data['event']) {
      case 'find match':
        MatchController.to.matchId = int.parse(message?.data['matchId']);
        MatchController.to.user_num = int.parse(message?.data['user_num']);
        ToWebView(
            double.parse(message?.data['my_latitude']),
            double.parse(message?.data['my_longitude']),
            message?.data['other_nickname'],
            double.parse(message?.data['other_latitude']),
            double.parse(message?.data['my_longitude']));

        // 매칭 결과 메시지
        flutterLocalNotificationsPlugin.show(
          0,
          notification?.title,
          notification?.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              // AndroidNotificationChannel()에서 생성한 ID
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              // other properties...
            ),
          ),
        );
        break;
      case 'match fail':
        Get.until((route) {
          if (Get.currentRoute == '/match') {
            MatchController.to.setTimer();
            return true;
          } else {
            return false;
          }
        });
        break;
      case 'match success':
        MatchController.to.isMatchSuccess = true;
        WebController.to.cancelTimer();
        WebController.to.isMiddlePointLoading = true;

        break;
      case 'match':
        Get.to(() => MatchPage());
        break;
      case 'match':
        Get.to(() => MatchPage());
        break;
      default:
        return;
    }
  }
// // userToken에 해당하는 user에게 푸쉬 알람을 보냄.
// Future<void> sendMessage({
//   required String userToken,
//   required String title,
//   required String body,
// }) async {
//   final String _serverKey = dotenv.env['FCM_SERVER_KEY'] ?? "";
//   http.Response response;
//
//   NotificationSettings settings =
//       await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: false,
//   );
//   // permission - 항상 허용
//   // provisional permission - 앱을 사용하는 동안 허용
//   // 나머지 거절
//   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//     print('User granted permission');
//   } else if (settings.authorizationStatus ==
//       AuthorizationStatus.provisional) {
//     print('User granted provisional permission');
//   } else {
//     print('User declined or has not accepted permission');
//   }
//
//   try {
//     response = await http.post(Uri.parse(dotenv.env['FCM_API_URL'] ?? ""),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'key=$_serverKey'
//         },
//         body: jsonEncode({
//           'notification': {'title': title, 'body': body, 'sound': 'false'},
//           'ttl': '60s',
//           "content_available": true,
//           'data': {
//             'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//             'id': '1',
//             'status': 'done',
//             "action": '테스트',
//           },
//           // 상대방 토큰 값, to -> 단일, registration_ids -> 여러명
//           'to': userToken
//           // 'registration_ids': tokenList
//         }));
//   } catch (e) {
//     print('error $e');
//   }
// }
}

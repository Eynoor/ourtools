import 'package:coba1/components/Borrow/borrowUserComponent.dart';
import 'package:coba1/size_config.dart';
import 'package:flutter/material.dart';

class BorrowUserscreens extends StatelessWidget {
  static String routeName = '/borrowuser';
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // Ambil roomId dari arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int? roomId = args != null ? args['roomId'] as int? : null;
    if (roomId == null) {
      return Scaffold(
        body: Center(
            child: Text(
                'Room ID tidak ditemukan')), // Error handling jika roomId tidak ada
      );
    }
    return Scaffold(
      body: BorrowUsercomponent(roomId: roomId),
    );
  }
}

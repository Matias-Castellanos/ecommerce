import 'package:flutter/material.dart';
import '../models/user/user_info_dto.dart';
import 'client_home_screen.dart';
import 'company_home_screen.dart';

class HomeScreen extends StatelessWidget {
  final UserInfoDto user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.role == 1) {
      return CompanyHomeScreen(user: user);
    } else {
      return ClientHomeScreen(user: user);
    }
  }
}

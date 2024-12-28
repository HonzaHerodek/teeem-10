import 'package:flutter/material.dart';
import 'network_section.dart';

class ProfileNetworkView extends StatelessWidget {
  const ProfileNetworkView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: NetworkSection(),
    );
  }
}

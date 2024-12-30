import 'package:flutter/material.dart';
import '../profile_bloc/profile_state.dart';
import 'profile_traits_view.dart';
import 'profile_network_view.dart';

class ProfileTraitsNetworkSection extends StatelessWidget {
  final ProfileState state;
  final bool showTraits;
  final bool showNetwork;
  final bool isAddingTrait;

  const ProfileTraitsNetworkSection({
    Key? key,
    required this.state,
    required this.showTraits,
    required this.showNetwork,
    required this.isAddingTrait,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state.user == null) {
      return const SizedBox.shrink();
    }

    if (showTraits) {
      return WillPopScope(
        onWillPop: () async => false,
        child: ProfileTraitsView(
          userId: state.user!.id,
          isLoading: isAddingTrait,
        ),
      );
    }

    if (showNetwork) {
      return WillPopScope(
        onWillPop: () async => false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: const ProfileNetworkView(),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

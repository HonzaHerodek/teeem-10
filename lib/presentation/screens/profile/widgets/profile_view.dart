import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../profile_bloc/profile_bloc.dart';
import '../profile_bloc/profile_state.dart';
import '../profile_bloc/profile_event.dart';
import '../controllers/profile_scroll_controller.dart';
import '../controllers/profile_view_controller.dart';
import '../../../widgets/error_view.dart';
import 'profile_header_section.dart';
import 'profile_traits_network_section.dart';
import 'profile_posts_section.dart';
import 'profile_action_buttons.dart';
import 'profile_bottom_sections.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileViewController(
      scrollController: ProfileScrollController().scrollController,
    );
    _controller.loadSettings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && !_controller.isAddingTrait) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          );
        }

        if (state.user == null) {
          return ErrorView(
            message: state.error ?? 'Failed to load profile',
            onRetry: () {
              context.read<ProfileBloc>().add(const ProfileStarted());
            },
          );
        }

        return SingleChildScrollView(
          controller: _controller.scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              ProfileHeaderSection(
                state: state,
                onTraitsPressed: () => setState(() => _controller.handleTraitsPressed()),
                onNetworkPressed: () => setState(() => _controller.handleNetworkPressed()),
                showTraits: _controller.showTraits,
                showNetwork: _controller.showNetwork,
              ),
              ProfileTraitsNetworkSection(
                state: state,
                showTraits: _controller.showTraits,
                showNetwork: _controller.showNetwork,
                isAddingTrait: _controller.isAddingTrait,
              ),
              if (_controller.showTraits || _controller.showNetwork) 
                const SizedBox(height: 16),
              if (!_controller.showTraits && !_controller.showNetwork) ...[
                Text(
                  state.user?.username ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              const Divider(color: Colors.white24),
              ProfilePostsSection(state: state),
              const SizedBox(height: 32),
              ProfileActionButtons(
                showSettings: _controller.showSettings,
                showAddIns: _controller.showAddIns,
                showAccounts: _controller.showAccounts,
                onSettingsPressed: () => setState(() => _controller.handleSettingsPressed()),
                onAddInsPressed: () => setState(() => _controller.handleAddInsPressed()),
                onAccountsPressed: () => setState(() => _controller.handleAccountsPressed()),
              ),
              const SizedBox(height: 16),
              ProfileBottomSections(
                showSettings: _controller.showSettings,
                showAddIns: _controller.showAddIns,
                showAccounts: _controller.showAccounts,
                settings: _controller.settings,
                addIns: _controller.addIns,
                accounts: _controller.accounts,
                settingsKey: _controller.settingsKey,
                addInsKey: _controller.addInsKey,
                accountsKey: _controller.accountsKey,
                onSettingsChanged: (settings) => setState(() => _controller.saveSettings(settings)),
                onAddInsChanged: (addIns) => setState(() => _controller.addIns = addIns),
                onAccountSwitch: (accountId) => setState(() => _controller.handleAccountSwitch(accountId)),
                onAddAccount: () {},
                onLogout: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

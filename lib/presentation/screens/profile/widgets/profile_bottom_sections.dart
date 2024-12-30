import 'package:flutter/material.dart';
import '../../../../data/models/profile_settings_model.dart';
import '../../../../data/models/profile_addins_model.dart';
import '../../../../data/models/profile_accounts_model.dart';
import 'profile_settings_view.dart';
import 'profile_addins_view.dart';
import 'profile_accounts_view.dart';

class ProfileBottomSections extends StatelessWidget {
  final bool showSettings;
  final bool showAddIns;
  final bool showAccounts;
  final ProfileSettingsModel settings;
  final ProfileAddInsModel addIns;
  final ProfileAccountsModel accounts;
  final GlobalKey settingsKey;
  final GlobalKey addInsKey;
  final GlobalKey accountsKey;
  final Function(ProfileSettingsModel) onSettingsChanged;
  final Function(ProfileAddInsModel) onAddInsChanged;
  final Function(String) onAccountSwitch;
  final VoidCallback onAddAccount;
  final VoidCallback onLogout;

  const ProfileBottomSections({
    Key? key,
    required this.showSettings,
    required this.showAddIns,
    required this.showAccounts,
    required this.settings,
    required this.addIns,
    required this.accounts,
    required this.settingsKey,
    required this.addInsKey,
    required this.accountsKey,
    required this.onSettingsChanged,
    required this.onAddInsChanged,
    required this.onAccountSwitch,
    required this.onAddAccount,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showSettings)
          Container(
            key: settingsKey,
            child: ProfileSettingsView(
              settings: settings,
              onSettingsChanged: onSettingsChanged,
            ),
          ),
        if (showAddIns)
          Container(
            key: addInsKey,
            child: ProfileAddInsView(
              addIns: addIns,
              onAddInsChanged: onAddInsChanged,
            ),
          ),
        if (showAccounts)
          Container(
            key: accountsKey,
            child: ProfileAccountsView(
              accounts: accounts,
              onAccountSwitch: onAccountSwitch,
              onAddAccount: onAddAccount,
              onLogout: onLogout,
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

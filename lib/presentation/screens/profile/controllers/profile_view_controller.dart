import 'package:flutter/material.dart';
import '../../../../data/models/profile_settings_model.dart';
import '../../../../data/models/profile_addins_model.dart';
import '../../../../data/models/profile_accounts_model.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../../core/di/injection.dart';

class ProfileViewController {
  final ScrollController scrollController;
  final GlobalKey settingsKey = GlobalKey();
  final GlobalKey addInsKey = GlobalKey();
  final GlobalKey accountsKey = GlobalKey();

  bool showTraits = false;
  bool showNetwork = false;
  bool showSettings = false;
  bool showAddIns = false;
  bool showAccounts = false;
  bool isAddingTrait = false;
  late ProfileSettingsModel settings;
  late ProfileAddInsModel addIns;
  late ProfileAccountsModel accounts;

  ProfileViewController({required this.scrollController}) {
    _initializeData();
  }

  void _initializeData() {
    settings = const ProfileSettingsModel();
    accounts = ProfileAccountsModel(
      accounts: [
        AccountModel(
          id: '1',
          username: 'Current User',
          email: 'user@example.com',
          isActive: true,
        ),
        AccountModel(
          id: '2',
          username: 'Work Account',
          email: 'work@example.com',
        ),
      ],
    );
    addIns = ProfileAddInsModel(
      categories: [
        AddInCategory(
          id: 'integrations',
          name: 'Integrations',
          items: [],
        ),
        AddInCategory(
          id: 'features',
          name: 'Features',
          items: [],
        ),
      ],
    );
  }

  void scrollToContent(GlobalKey key) {
    if (key.currentContext != null) {
      final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final targetScroll = scrollController.position.pixels + 
                       position.dy - 
                       120;

      scrollController.animateTo(
        targetScroll.clamp(
          0.0,
          scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> loadSettings() async {
    try {
      final settingsData = await getIt<SettingsRepository>().loadSettings();
      if (settingsData != null) {
        settings = ProfileSettingsModel.fromJson(settingsData);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> saveSettings(ProfileSettingsModel newSettings) async {
    try {
      await getIt<SettingsRepository>().saveSettings(newSettings.toJson());
      settings = newSettings;
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  void handleSettingsPressed() {
    showSettings = !showSettings;
    if (showSettings) {
      showAddIns = false;
      showAccounts = false;
      showTraits = false;
      showNetwork = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToContent(settingsKey);
      });
    }
  }

  void handleAddInsPressed() {
    showAddIns = !showAddIns;
    if (showAddIns) {
      showSettings = false;
      showAccounts = false;
      showTraits = false;
      showNetwork = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToContent(addInsKey);
      });
    }
  }

  void handleAccountsPressed() {
    showAccounts = !showAccounts;
    if (showAccounts) {
      showSettings = false;
      showAddIns = false;
      showTraits = false;
      showNetwork = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToContent(accountsKey);
      });
    }
  }

  void handleAccountSwitch(String accountId) {
    final updatedAccounts = accounts.accounts.map((account) {
      return account.copyWith(isActive: account.id == accountId);
    }).toList();
    accounts = accounts.copyWith(accounts: updatedAccounts);
  }

  void handleTraitsPressed() {
    showTraits = !showTraits;
    showNetwork = false;
    if (showSettings) showSettings = false;
  }

  void handleNetworkPressed() {
    showNetwork = !showNetwork;
    showTraits = false;
    if (showSettings) showSettings = false;
  }

  void dispose() {
    scrollController.dispose();
  }
}

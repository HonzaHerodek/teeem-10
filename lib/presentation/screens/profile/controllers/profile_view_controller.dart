import 'package:flutter/material.dart';
import '../../../../data/models/profile_settings_model.dart';
import '../../../../data/models/profile_addins_model.dart';
import '../../../../data/models/profile_accounts_model.dart';
import '../../../../domain/repositories/settings_repository.dart';
import '../../../../core/di/injection.dart';
import 'profile_scroll_controller.dart';

class ProfileViewController {
  final ProfileScrollController scrollController;
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
    scrollController.scrollToWidget(key);
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

  bool _isTransitioning = false;

  Future<void> _handleSectionTransition(VoidCallback stateUpdates, {GlobalKey? scrollTarget}) async {
    if (_isTransitioning) return;
    
    try {
      _isTransitioning = true;
      
      // Update state
      stateUpdates();

      // Wait for state to propagate
      await Future.delayed(const Duration(milliseconds: 50));

      // If we need to scroll, wait for layout to stabilize then scroll
      if (scrollTarget != null) {
        // Wait for animations to complete
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (scrollTarget.currentContext != null) {
          await scrollController.scrollToWidget(
            scrollTarget,
            duration: const Duration(milliseconds: 500),
          );
        }
      }
    } finally {
      _isTransitioning = false;
    }
  }

  Future<void> handleSettingsPressed() async {
    await _handleSectionTransition(
      () {
        showSettings = !showSettings;
        if (showSettings) {
          showAddIns = false;
          showAccounts = false;
          showTraits = false;
          showNetwork = false;
        }
      },
      scrollTarget: showSettings ? settingsKey : null,
    );
  }

  Future<void> handleAddInsPressed() async {
    await _handleSectionTransition(
      () {
        showAddIns = !showAddIns;
        if (showAddIns) {
          showSettings = false;
          showAccounts = false;
          showTraits = false;
          showNetwork = false;
        }
      },
      scrollTarget: showAddIns ? addInsKey : null,
    );
  }

  Future<void> handleAccountsPressed() async {
    await _handleSectionTransition(
      () {
        showAccounts = !showAccounts;
        if (showAccounts) {
          showSettings = false;
          showAddIns = false;
          showTraits = false;
          showNetwork = false;
        }
      },
      scrollTarget: showAccounts ? accountsKey : null,
    );
  }

  Future<void> handleAccountSwitch(String accountId) async {
    await _handleSectionTransition(() {
      final updatedAccounts = accounts.accounts.map((account) {
        return account.copyWith(isActive: account.id == accountId);
      }).toList();
      accounts = accounts.copyWith(accounts: updatedAccounts);
    });
  }

  Future<void> handleTraitsPressed() async {
    await _handleSectionTransition(() {
      showTraits = !showTraits;
      showNetwork = false;
      if (showSettings) showSettings = false;
    });
  }

  Future<void> handleNetworkPressed() async {
    await _handleSectionTransition(() {
      showNetwork = !showNetwork;
      showTraits = false;
      if (showSettings) showSettings = false;
    });
  }

  Future<void> handleAddInsChanged(ProfileAddInsModel newAddIns) async {
    await _handleSectionTransition(() {
      addIns = newAddIns;
    });
  }

  void dispose() {
    // No need to dispose the scroll controller here as it's managed by ProfileView
  }
}

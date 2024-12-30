import 'package:flutter/material.dart';

class ProfileActionButtons extends StatelessWidget {
  final bool showSettings;
  final bool showAddIns;
  final bool showAccounts;
  final VoidCallback onSettingsPressed;
  final VoidCallback onAddInsPressed;
  final VoidCallback onAccountsPressed;

  const ProfileActionButtons({
    Key? key,
    required this.showSettings,
    required this.showAddIns,
    required this.showAccounts,
    required this.onSettingsPressed,
    required this.onAddInsPressed,
    required this.onAccountsPressed,
  }) : super(key: key);

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.white,
          size: isSelected ? 32 : 28,
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.settings,
          onPressed: onSettingsPressed,
          isSelected: showSettings,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.extension,
          onPressed: onAddInsPressed,
          isSelected: showAddIns,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.account_circle,
          onPressed: onAccountsPressed,
          isSelected: showAccounts,
        ),
      ],
    );
  }
}

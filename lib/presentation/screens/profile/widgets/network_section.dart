import 'package:flutter/material.dart';
import '../../../widgets/sliding_panel.dart';
import '../../../../data/models/user_model.dart';
import '../../../screens/feed/widgets/group_chip.dart';
import '../../../screens/feed/widgets/profile_miniature_chip.dart';

class NetworkGroup {
  final String name;
  final List<UserModel> members;
  final bool isMandatory;

  const NetworkGroup({
    required this.name,
    required this.members,
    this.isMandatory = false,
  });
}

class NetworkSection extends StatefulWidget {
  const NetworkSection({super.key});

  @override
  State<NetworkSection> createState() => _NetworkSectionState();
}

class _NetworkSectionState extends State<NetworkSection> {
  final List<NetworkGroup> _groups = [
    NetworkGroup(
      name: 'Following',
      members: [], // TODO: Populate from user data
      isMandatory: true,
    ),
    NetworkGroup(
      name: 'Followers',
      members: [], // TODO: Populate from user data
      isMandatory: true,
    ),
  ];

  void _handleGroupTap(NetworkGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SlidingPanel(
        isOpen: true,
        child: GroupDetailsPanel(
          group: group,
          onEdit: group.isMandatory ? null : _handleEditGroup,
          onDelete: group.isMandatory ? null : _handleDeleteGroup,
          onAddMember: _handleAddMember,
          onRemoveMember: _handleRemoveMember,
        ),
      ),
    );
  }

  void _handleEditGroup(NetworkGroup group, String newName) {
    setState(() {
      final index = _groups.indexOf(group);
      if (index != -1) {
        _groups[index] = NetworkGroup(
          name: newName,
          members: group.members,
          isMandatory: group.isMandatory,
        );
      }
    });
    Navigator.pop(context); // Close sliding panel
  }

  void _handleDeleteGroup(NetworkGroup group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Group',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${group.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _groups.remove(group);
              });
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close sliding panel
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddMember(NetworkGroup group, UserModel member) {
    setState(() {
      final index = _groups.indexOf(group);
      if (index != -1 && !_groups[index].members.contains(member)) {
        _groups[index] = NetworkGroup(
          name: group.name,
          members: [...group.members, member],
          isMandatory: group.isMandatory,
        );
      }
    });
  }

  void _handleRemoveMember(NetworkGroup group, UserModel member) {
    setState(() {
      final index = _groups.indexOf(group);
      if (index != -1) {
        _groups[index] = NetworkGroup(
          name: group.name,
          members: group.members.where((m) => m != member).toList(),
          isMandatory: group.isMandatory,
        );
      }
    });
  }

  void _handleAddGroup() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Create New Group',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter group name',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white38),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _groups.add(NetworkGroup(
                    name: name,
                    members: [],
                    isMandatory: false,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChips() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Add group button styled like a group chip
          GestureDetector(
            onTap: _handleAddGroup,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'New Group',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ..._groups.map((group) => GroupChip(
                groupName: group.name,
                profiles: group.members.isEmpty 
                    ? [] // Show no profiles if empty
                    : group.members.map((member) => GroupProfileInfo(
                        imageUrl: member.profileImage ?? '',
                        username: member.username,
                      )).toList(),
                onTap: () => _handleGroupTap(group),
                isSelected: false,
                showAddPeople: group.members.isEmpty, // Show add people button when empty
              )),
        ],
      ),
    );
  }

  Widget _buildUserChips() {
    // Sample users for demonstration
    final users = [
      ('alex_morgan', 'Alex Morgan'),
      ('sophia.lee', 'Sophia Lee'),
      ('james_walker', 'James Walker'),
      ('olivia_chen', 'Olivia Chen'),
      ('ethan_brown', 'Ethan Brown'),
      ('mia_patel', 'Mia Patel'),
      ('lucas_kim', 'Lucas Kim'),
      ('emma_davis', 'Emma Davis'),
    ];

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Add person button styled like a profile miniature
          ProfileMiniatureChip(
            label: 'Add Person',
            onTap: () {
              // TODO: Handle adding new person
            },
            isSelected: false,
            spacing: 20,
            isAddButton: true,
          ),
          ...users.map((user) {
            final (username, _) = user;
            return ProfileMiniatureChip(
              label: username,
              onTap: () {
                // TODO: Handle user selection
              },
              isSelected: false,
              spacing: 20,
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGroupChips(),
          const SizedBox(height: 16),
          _buildUserChips(),
          const SizedBox(height: 16), // Bottom padding
        ],
      ),
    );
  }
}

class GroupDetailsPanel extends StatelessWidget {
  final NetworkGroup group;
  final Function(NetworkGroup, String)? onEdit;
  final Function(NetworkGroup)? onDelete;
  final Function(NetworkGroup, UserModel) onAddMember;
  final Function(NetworkGroup, UserModel) onRemoveMember;

  const GroupDetailsPanel({
    super.key,
    required this.group,
    this.onEdit,
    this.onDelete,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!group.isMandatory)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: onEdit != null
                          ? () => _showEditDialog(context)
                          : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: onDelete != null
                          ? () => onDelete!(group)
                          : null,
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: group.members.length + 1, // +1 for add member button
            itemBuilder: (context, index) {
              if (index == group.members.length) {
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.add),
                  ),
                  title: const Text(
                    'Add Member',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () => _showAddMemberDialog(context),
                );
              }

              final member = group.members[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.profileImage != null
                      ? NetworkImage(member.profileImage!)
                      : null,
                  child: member.profileImage == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(
                  member.username,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.white),
                  onPressed: () => onRemoveMember(group, member),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: group.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Edit Group Name',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter group name',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white38),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = textController.text.trim();
              if (newName.isNotEmpty && newName != group.name) {
                onEdit?.call(group, newName);
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final searchController = TextEditingController();
    final searchResults = ValueNotifier<List<UserModel>>([]);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add Member',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.search, color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white38),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement actual user search
                  // For now, show sample results
                  if (value.isNotEmpty) {
                    searchResults.value = [
                      UserModel(
                        id: '1',
                        username: 'john_doe',
                        email: 'john@example.com',
                      ),
                      UserModel(
                        id: '2',
                        username: 'jane_smith',
                        email: 'jane@example.com',
                      ),
                    ];
                  } else {
                    searchResults.value = [];
                  }
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<List<UserModel>>(
                valueListenable: searchResults,
                builder: (context, results, _) {
                  if (results.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No users found',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final user = results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : null,
                          child: user.profileImage == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          user.username,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          onAddMember(group, user);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

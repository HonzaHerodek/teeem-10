class AccountModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final bool isActive;

  const AccountModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.isActive = false,
  });

  AccountModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    bool? isActive,
  }) {
    return AccountModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
    };
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

class ProfileAccountsModel {
  final List<AccountModel> accounts;

  const ProfileAccountsModel({
    this.accounts = const [],
  });

  ProfileAccountsModel copyWith({
    List<AccountModel>? accounts,
  }) {
    return ProfileAccountsModel(
      accounts: accounts ?? this.accounts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accounts': accounts.map((account) => account.toJson()).toList(),
    };
  }

  factory ProfileAccountsModel.fromJson(Map<String, dynamic> json) {
    return ProfileAccountsModel(
      accounts: (json['accounts'] as List<dynamic>)
          .map((account) => AccountModel.fromJson(account as Map<String, dynamic>))
          .toList(),
    );
  }
}

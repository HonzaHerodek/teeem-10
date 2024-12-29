import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/services/rating_service.dart';
import '../../../data/models/profile_settings_model.dart';
import '../../../data/models/profile_addins_model.dart';
import '../../../data/models/profile_accounts_model.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'widgets/profile_settings_view.dart';
import 'widgets/profile_addins_view.dart';
import 'widgets/profile_accounts_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/profile_posts_grid.dart';
import 'widgets/profile_header_section.dart';
import 'widgets/profile_traits_view.dart';
import 'widgets/profile_network_view.dart';
import 'controllers/profile_scroll_controller.dart';
import 'profile_bloc/profile_bloc.dart';
import 'profile_bloc/profile_event.dart';
import 'profile_bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: getIt<UserRepository>(),
        postRepository: getIt<PostRepository>(),
        ratingService: getIt<RatingService>(),
      )..add(const ProfileStarted()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withOpacity(0.75),
              Colors.black.withOpacity(0.65),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              spreadRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SafeArea(
              child: ProfileView(),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _showTraits = false;
  bool _showNetwork = false;
  bool _showSettings = false;
  bool _showAddIns = false;
  bool _showAccounts = false;
  bool _isAddingTrait = false;
  late ProfileSettingsModel _settings;
  late ProfileAddInsModel _addIns;
  late ProfileAccountsModel _accounts;
  final ProfileScrollController _scrollController = ProfileScrollController();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _addInsKey = GlobalKey();
  final GlobalKey _accountsKey = GlobalKey();

  void _scrollToContent(GlobalKey key) {
    if (key.currentContext != null) {
      final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final targetScroll = _scrollController.scrollController.position.pixels + 
                         position.dy - 
                         120; // Offset to show some content above

      _scrollController.scrollController.animateTo(
        targetScroll.clamp(
          0.0,
          _scrollController.scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _settings = const ProfileSettingsModel();
    _accounts = ProfileAccountsModel(
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
    _addIns = ProfileAddInsModel(
      categories: [
        AddInCategory(
          id: 'integrations',
          name: 'Integrations',
          items: [
            AddInItem(
              id: 'github',
              name: 'GitHub',
              description: 'Connect and share your GitHub projects',
              enabled: false,
            ),
            AddInItem(
              id: 'figma',
              name: 'Figma',
              description: 'Share your design work from Figma',
              enabled: false,
            ),
          ],
        ),
        AddInCategory(
          id: 'features',
          name: 'Features',
          items: [
            AddInItem(
              id: 'analytics',
              name: 'Analytics',
              description: 'Track your profile performance',
              enabled: false,
            ),
            AddInItem(
              id: 'scheduler',
              name: 'Post Scheduler',
              description: 'Schedule posts for automatic publishing',
              enabled: false,
            ),
          ],
        ),
      ],
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsData = await getIt<SettingsRepository>().loadSettings();
      if (settingsData != null) {
        setState(() {
          _settings = ProfileSettingsModel.fromJson(settingsData);
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings(ProfileSettingsModel newSettings) async {
    try {
      await getIt<SettingsRepository>().saveSettings(newSettings.toJson());
      setState(() {
        _settings = newSettings;
      });
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Widget _buildContent(BuildContext context, ProfileState state) {
    if (state.user == null) {
      return const SizedBox.shrink();
    }

    if (_showTraits) {
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            _showTraits = false;
          });
          return false;
        },
        child: ProfileTraitsView(
          userId: state.user!.id,
          isLoading: _isAddingTrait,
        ),
      );
    } else if (_showNetwork) {
      return WillPopScope(
        onWillPop: () async {
          setState(() {
            _showNetwork = false;
          });
          return false;
        },
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
        if (state.isLoading && !_isAddingTrait) {
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

        return CustomScrollView(
          controller: _scrollController.scrollController,
          physics: _scrollController.physics,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProfileHeaderSection(
                    state: state,
                    onTraitsPressed: () {
                      setState(() {
                        _showTraits = !_showTraits;
                        _showNetwork = false;
                        if (_showSettings) {
                          _showSettings = false;
                        }
                      });
                    },
                    onNetworkPressed: () {
                      setState(() {
                        _showNetwork = !_showNetwork;
                        _showTraits = false;
                        if (_showSettings) {
                          _showSettings = false;
                        }
                      });
                    },
                    showTraits: _showTraits,
                    showNetwork: _showNetwork,
                  ),
                  _buildContent(context, state),
                  if (_showTraits || _showNetwork) const SizedBox(height: 16),
                  if (!_showTraits && !_showNetwork) ...[
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
                  if (state.userPosts.isNotEmpty)
                    ProfilePostsGrid(
                      posts: state.userPosts,
                      currentUserId: state.user!.id,
                      onLike: (post) {
                        // TODO: Implement like functionality
                      },
                      onComment: (post) {
                        // TODO: Implement comment functionality
                      },
                      onShare: (post) {
                        // TODO: Implement share functionality
                      },
                      onRate: (rating, post) {
                        context.read<ProfileBloc>().add(
                              ProfileRatingReceived(
                                rating,
                                state.user!.id,
                                userId: state.user!.id,
                              ),
                            );
                      },
                    ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: _showSettings ? 32 : 28,
                          ),
                          onPressed: () {
                            setState(() {
                              _showSettings = !_showSettings;
                              if (_showSettings) {
                                _showAddIns = false;
                                _showAccounts = false;
                                _showTraits = false;
                                _showNetwork = false;
                                // Wait for the next frame to ensure the content is rendered
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scrollToContent(_settingsKey);
                                });
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.extension,
                            color: Colors.white,
                            size: _showAddIns ? 32 : 28,
                          ),
                          onPressed: () {
                            setState(() {
                              _showAddIns = !_showAddIns;
                              if (_showAddIns) {
                                _showSettings = false;
                                _showAccounts = false;
                                _showTraits = false;
                                _showNetwork = false;
                                // Wait for the next frame to ensure the content is rendered
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scrollToContent(_addInsKey);
                                });
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: _showAccounts ? 32 : 28,
                          ),
                          onPressed: () {
                            setState(() {
                              _showAccounts = !_showAccounts;
                              if (_showAccounts) {
                                _showSettings = false;
                                _showAddIns = false;
                                _showTraits = false;
                                _showNetwork = false;
                                // Wait for the next frame to ensure the content is rendered
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _scrollToContent(_accountsKey);
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_showSettings)
                    Container(
                      key: _settingsKey,
                      child: ProfileSettingsView(
                        settings: _settings,
                        onSettingsChanged: _saveSettings,
                      ),
                    ),
                  if (_showAddIns)
                    Container(
                      key: _addInsKey,
                      child: ProfileAddInsView(
                        addIns: _addIns,
                        onAddInsChanged: (newAddIns) {
                          setState(() {
                            _addIns = newAddIns;
                          });
                        },
                      ),
                    ),
                  if (_showAccounts)
                    Container(
                      key: _accountsKey,
                      child: ProfileAccountsView(
                        accounts: _accounts,
                        onAccountSwitch: (accountId) {
                          final updatedAccounts = _accounts.accounts.map((account) {
                            return account.copyWith(
                              isActive: account.id == accountId,
                            );
                          }).toList();
                          setState(() {
                            _accounts = _accounts.copyWith(accounts: updatedAccounts);
                          });
                        },
                        onAddAccount: () {
                          // TODO: Navigate to add account screen
                        },
                        onLogout: () {
                          // TODO: Handle logout
                        },
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (state.userPosts.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No posts yet',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

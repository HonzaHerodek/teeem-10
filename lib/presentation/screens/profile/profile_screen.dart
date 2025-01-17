import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/services/rating_service.dart';
import '../../../data/models/profile_settings_model.dart';
import '../../../data/models/profile_addins_model.dart';
import '../../../domain/repositories/settings_repository.dart';
import 'widgets/profile_settings_view.dart';
import 'widgets/profile_addins_view.dart';
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
      child: const ProfileView(),
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
  bool _isAddingTrait = false;
  late ProfileSettingsModel _settings;
  late ProfileAddInsModel _addIns;
  final ProfileScrollController _scrollController = ProfileScrollController();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _addInsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _settings = const ProfileSettingsModel();
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
      if (settingsData != null && mounted) {
        setState(() {
          _settings = ProfileSettingsModel.fromJson(settingsData);
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings(ProfileSettingsModel newSettings) async {
    try {
      await getIt<SettingsRepository>().saveSettings(newSettings.toJson());
      if (mounted) {
        setState(() {
          _settings = newSettings;
        });
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  void _toggleSection(String section) {
    if (!mounted) return;
    
    setState(() {
      switch (section) {
        case 'traits':
          _showTraits = !_showTraits;
          if (_showTraits) {
            _showNetwork = false;
            _showSettings = false;
            _showAddIns = false;
          }
          break;
        case 'network':
          _showNetwork = !_showNetwork;
          if (_showNetwork) {
            _showTraits = false;
            _showSettings = false;
            _showAddIns = false;
          }
          break;
        case 'settings':
          _showSettings = !_showSettings;
          if (_showSettings) {
            _showTraits = false;
            _showNetwork = false;
            _showAddIns = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.scrollToWidget(_settingsKey);
            });
          }
          break;
        case 'addins':
          _showAddIns = !_showAddIns;
          if (_showAddIns) {
            _showTraits = false;
            _showNetwork = false;
            _showSettings = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.scrollToWidget(_addInsKey);
            });
          }
          break;
      }
    });
  }

  Widget _buildContent(BuildContext context, ProfileState state) {
    if (state.user == null) {
      return const SizedBox.shrink();
    }

    if (_showTraits) {
      return WillPopScope(
        onWillPop: () async {
          _toggleSection('traits');
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
          _toggleSection('network');
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
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.75),
            Colors.black.withOpacity(0.65),
          ],
        ),
      ),
      child: BlocConsumer<ProfileBloc, ProfileState>(
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
                      onTraitsPressed: () => _toggleSection('traits'),
                      onNetworkPressed: () => _toggleSection('network'),
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
                            onPressed: () => _toggleSection('settings'),
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
                            onPressed: () => _toggleSection('addins'),
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
                            if (mounted) {
                              setState(() {
                                _addIns = newAddIns;
                              });
                            }
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
      ),
    );
  }
}

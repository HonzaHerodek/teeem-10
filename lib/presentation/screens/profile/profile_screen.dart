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
    // Create ProfileBloc lazily only when the screen is actually built
    return BlocProvider(
      create: (context) => ProfileBloc(
        userRepository: getIt<UserRepository>(),
        postRepository: getIt<PostRepository>(),
        ratingService: getIt<RatingService>(),
      ),
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

  @override
  void initState() {
    super.initState();
    _settings = const ProfileSettingsModel();
    _addIns = const ProfileAddInsModel(categories: []);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          }
          break;
        case 'addins':
          _showAddIns = !_showAddIns;
          if (_showAddIns) {
            _showTraits = false;
            _showNetwork = false;
            _showSettings = false;
          }
          break;
      }
    });
  }

  Widget _buildLoadingIndicator(ProfileLoadingStage stage) {
    String message = '';
    double progress = 0.0;
    
    switch (stage) {
      case ProfileLoadingStage.initial:
        message = 'Preparing...';
        progress = 0.1;
        break;
      case ProfileLoadingStage.userData:
        message = 'Loading profile...';
        progress = 0.25;
        break;
      case ProfileLoadingStage.posts:
        message = 'Loading posts...';
        progress = 0.5;
        break;
      case ProfileLoadingStage.ratings:
        message = 'Loading ratings...';
        progress = 0.75;
        break;
      case ProfileLoadingStage.traits:
        message = 'Loading traits...';
        progress = 0.9;
        break;
      case ProfileLoadingStage.complete:
        message = 'Complete';
        progress = 1.0;
        break;
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: progress,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              strokeWidth: 8,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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

        // Start loading when the widget is first built
        if (state.loadingStage == ProfileLoadingStage.initial) {
          context.read<ProfileBloc>().add(const ProfileStarted());
        }
      },
      builder: (context, state) {
        // Show loading indicator until complete
        if (state.loadingStage != ProfileLoadingStage.complete && !_isAddingTrait) {
          return _buildLoadingIndicator(state.loadingStage);
        }

        if (state.user == null) {
          return ErrorView(
            message: state.error ?? 'Failed to load profile',
            onRetry: () {
              context.read<ProfileBloc>().add(const ProfileStarted());
            },
          );
        }

        // Main content with optimized scrolling
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Prevent scroll notifications from bubbling up
            return true;
          },
          child: CustomScrollView(
            controller: _scrollController.scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Basic profile info
                    ProfileHeaderSection(
                      state: state,
                      onTraitsPressed: () => _toggleSection('traits'),
                      onNetworkPressed: () => _toggleSection('network'),
                      showTraits: _showTraits,
                      showNetwork: _showNetwork,
                    ),

                    // Active section - only build the active section
                    if (_showTraits)
                      ProfileTraitsView(
                        userId: state.user!.id,
                        isLoading: _isAddingTrait,
                      )
                    else if (_showNetwork)
                      const ProfileNetworkView()
                    else if (_showSettings)
                      ProfileSettingsView(
                        settings: _settings,
                        onSettingsChanged: (newSettings) {
                          if (mounted) setState(() => _settings = newSettings);
                        },
                      )
                    else if (_showAddIns)
                      ProfileAddInsView(
                        addIns: _addIns,
                        onAddInsChanged: (newAddIns) {
                          if (mounted) setState(() => _addIns = newAddIns);
                        },
                      )
                    // Posts section
                    else
                      Column(
                        children: [
                          Text(
                            state.user?.username ?? '',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),
                          if (state.userPosts.isNotEmpty)
                            ProfilePostsGrid(
                              posts: state.userPosts,
                              currentUserId: state.user!.id,
                              onLike: (post) {},
                              onComment: (post) {},
                              onShare: (post) {},
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
                        ],
                      ),

                    // Bottom buttons
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

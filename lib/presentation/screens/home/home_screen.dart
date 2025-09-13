// lib/presentation/screens/home/home_screen.dart - نسخة متجاوبة محسنة
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/language_provider.dart';
import '../../../data/models/path_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/paths_provider.dart';
import '../../providers/saved_paths_provider.dart';
import '../paths/widgets/path_card.dart';
import 'widgets/featured_paths_carousel.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/home_category_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingPaths = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingPaths = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoadingPaths = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    final localizations = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final pathsProvider = Provider.of<PathsProvider>(context);
    final featuredPaths = pathsProvider.featuredPaths;
    final suggestedPaths = pathsProvider.paths.take(3).toList();
    final savedPathsProvider = Provider.of<SavedPathsProvider>(context);
    final savedPaths = savedPathsProvider.savedPaths.take(2).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // شريط التطبيق المتجاوب
            SliverAppBar(
              expandedHeight: context.adaptive(120),
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: context.adaptive(32),
                  ),
                  SizedBox(width: context.xs),
                  Flexible(
                    child: Text(
                      localizations.get('app_name'),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: context.fontSize(20),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                // زر تغيير اللغة
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.adaptive(8),
                      vertical: context.adaptive(4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      languageProvider.isArabic ? 'EN' : 'ع',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: context.fontSize(12),
                      ),
                    ),
                  ),
                  onPressed: () {
                    final newLanguage = languageProvider.isArabic ? 'en' : 'ar';
                    languageProvider.changeLanguage(newLanguage);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          languageProvider.isArabic
                              ? 'Language changed to English'
                              : 'تم تغيير اللغة إلى العربية',
                          style: TextStyle(fontSize: context.fontSize(14)),
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                // زر الإشعارات
                if (!context.isSmallPhone)
                  IconButton(
                    icon: Stack(
                      children: [
                        Icon(
                          PhosphorIcons.bell,
                          color: AppColors.textPrimary,
                          size: context.iconSize(),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            languageProvider.getText(
                              'لا توجد إشعارات جديدة',
                              'No new notifications',
                            ),
                            style: TextStyle(fontSize: context.fontSize(14)),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                // زر الإعدادات
                IconButton(
                  icon: Icon(
                    PhosphorIcons.gear,
                    color: AppColors.textPrimary,
                    size: context.iconSize(),
                  ),
                  onPressed: () {
                    context.go('/profile/settings');
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.only(
                    top: context.adaptive(90),
                    left: context.sm,
                    right: context.sm,
                  ),
                  child: user != null
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: context.adaptive(22),
                              backgroundColor: AppColors.primary,
                              child: user.profileImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: Image.network(
                                        user.profileImageUrl!,
                                        width: context.adaptive(44),
                                        height: context.adaptive(44),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text(
                                      user.name.substring(0, 1).toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: context.fontSize(16),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                            SizedBox(width: context.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    languageProvider.getText(
                                      'مرحباً، ${user.name}',
                                      'Hello, ${user.name}',
                                    ),
                                    style: TextStyle(
                                      fontSize: context.fontSize(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    languageProvider.getText(
                                      'استمتع باستكشاف فلسطين اليوم!',
                                      'Enjoy exploring Palestine today!',
                                    ),
                                    style: TextStyle(
                                      fontSize: context.fontSize(12),
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),

            // شريط البحث والأزرار السريعة
            SliverToBoxAdapter(
              child: Padding(
                padding: context.responsivePadding(
                  horizontal: context.isSmallPhone ? 12 : 16,
                  vertical: context.isSmallPhone ? 12 : 16,
                ),
                child: Column(
                  children: [
                    const SearchBarWidget(),
                    SizedBox(height: context.sm),

                    // الأزرار السريعة
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _QuickActionChip(
                            icon: PhosphorIcons.compass,
                            label: localizations.get('explore'),
                            onTap: () => context.go('/explore'),
                          ),
                          _QuickActionChip(
                            icon: PhosphorIcons.map_trifold,
                            label: localizations.get('paths'),
                            onTap: () => context.go('/paths'),
                          ),
                          _QuickActionChip(
                            icon: PhosphorIcons.mountains,
                            label: localizations.get('climbing'),
                            onTap: () {
                              context.go('/paths');
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () {
                                  final pathsProvider = Provider.of<PathsProvider>(
                                    context,
                                    listen: false,
                                  );
                                  pathsProvider.setActivityFilter(ActivityType.climbing);
                                },
                              );
                            },
                          ),
                          if (!context.isSmallPhone) ...[
                            _QuickActionChip(
                              icon: PhosphorIcons.campfire,
                              label: localizations.get('camping'),
                              onTap: () {
                                context.go('/paths');
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    final pathsProvider = Provider.of<PathsProvider>(
                                      context,
                                      listen: false,
                                    );
                                    pathsProvider.setActivityFilter(ActivityType.camping);
                                  },
                                );
                              },
                            ),
                            _QuickActionChip(
                              icon: PhosphorIcons.tree,
                              label: localizations.get('nature'),
                              onTap: () {
                                context.go('/paths');
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    final pathsProvider = Provider.of<PathsProvider>(
                                      context,
                                      listen: false,
                                    );
                                    pathsProvider.setActivityFilter(ActivityType.nature);
                                  },
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // المسارات المميزة
            SliverToBoxAdapter(
              child: Column(
                children: [
                  HomeCategoryHeader(
                    title: localizations.get('featured_paths'),
                    onViewAll: () => context.go('/paths'),
                  ),
                  if (_isLoadingPaths)
                    SizedBox(
                      height: context.adaptive(200),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else
                    FeaturedPathsCarousel(paths: featuredPaths),
                ],
              ),
            ),

            // المسارات المحفوظة
            if (savedPaths.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    HomeCategoryHeader(
                      title: localizations.get('saved'),
                      onViewAll: () => context.go('/profile/saved'),
                    ),
                    Container(
                      height: context.adaptive(220),
                      padding: EdgeInsets.only(left: context.sm),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: savedPaths.length,
                        itemBuilder: (context, index) {
                          final path = savedPaths[index];
                          return Container(
                            width: context.adaptive(280),
                            padding: EdgeInsets.only(right: context.sm),
                            child: PathCard(
                              path: path,
                              onTap: () => context.go('/paths/${path.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // مغامرات مقترحة
            SliverToBoxAdapter(
              child: Column(
                children: [
                  HomeCategoryHeader(
                    title: localizations.get('suggested_adventures'),
                    onViewAll: () => context.go('/paths'),
                  ),
                  if (_isLoadingPaths)
                    SizedBox(
                      height: context.adaptive(200),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else
                    Padding(
                      padding: context.responsivePadding(horizontal: 16),
                      child: Column(
                        children: suggestedPaths.map((path) {
                          return PathCard(
                            path: path,
                            onTap: () => context.go('/paths/${path.id}'),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: context.adaptive(100)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: context.xs),
        padding: context.responsivePadding(
          horizontal: context.isSmallPhone ? 12 : 16,
          vertical: context.isSmallPhone ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: context.iconSize(),
              color: AppColors.primary,
            ),
            SizedBox(width: context.xs),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: context.fontSize(14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
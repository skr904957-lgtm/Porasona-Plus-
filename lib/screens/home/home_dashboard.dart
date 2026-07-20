import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/course_model.dart';
import '../../widgets/course_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_list.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final student = auth.student;
    final firstName = (student?.name.isNotEmpty ?? false) ? student!.name.split(' ').first : 'Student';
    final firestore = FirestoreService();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              title: Text('Hi, $firstName 👋', style: const TextStyle(fontWeight: FontWeight.w600)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.search),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _BannerCarousel(firestore: firestore),
              ),
            ),
            SliverToBoxAdapter(
              child: _StreakCard(streak: student?.studyStreak ?? 0, points: student?.totalPoints ?? 0),
            ),
            _SectionHeader(title: 'Continue Learning', onSeeAll: () => Navigator.pushNamed(context, AppRoutes.bookmarks)),
            SliverToBoxAdapter(child: _CourseRow(firestore: firestore, purchasedOnly: true)),
            _SectionHeader(title: 'Explore Courses', onSeeAll: null),
            SliverToBoxAdapter(child: _CourseRow(firestore: firestore, purchasedOnly: false)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            if (onSeeAll != null)
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  final FirestoreService firestore;
  const _BannerCarousel({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestore.banners(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 150, child: LoadingList(count: 1, height: 150));
        }
        final banners = snapshot.data!;
        if (banners.isEmpty) {
          return const SizedBox.shrink(); // No banner set up yet — nothing fake shown.
        }
        return SizedBox(
          height: 150,
          child: PageView.builder(
            itemCount: banners.length,
            controller: PageController(viewportFraction: 0.92),
            itemBuilder: (_, i) {
              final b = banners[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: b['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: AppColors.secondary),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  final int points;
  const _StreakCard({required this.streak, required this.points});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$streak day streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('$points points earned', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.8)),
          ],
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final FirestoreService firestore;
  final bool purchasedOnly;
  const _CourseRow({required this.firestore, required this.purchasedOnly});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return StreamBuilder<List<CourseModel>>(
      stream: firestore.courses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 210, child: LoadingList(count: 1, height: 200));
        }
        var courses = snapshot.data!;
        if (purchasedOnly) {
          final purchasedIds = auth.student?.purchasedCourseIds ?? [];
          courses = courses.where((c) => purchasedIds.contains(c.id)).toList();
        }
        if (courses.isEmpty) {
          return SizedBox(
            height: 140,
            child: EmptyState(
              icon: purchasedOnly ? Icons.play_lesson_outlined : Icons.menu_book_outlined,
              title: purchasedOnly ? 'No courses in progress yet' : 'No courses published yet',
              subtitle: purchasedOnly ? 'Enroll in a course to see it here.' : 'Check back soon — new courses are on the way.',
            ),
          );
        }
        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => CourseCard(
              course: courses[i],
              onTap: () => Navigator.pushNamed(context, AppRoutes.courseDetails, arguments: courses[i].id),
            ),
          ),
        );
      },
    );
  }
}

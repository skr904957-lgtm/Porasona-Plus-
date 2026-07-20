import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../services/firestore_service.dart';
import '../../models/course_model.dart';
import '../../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _firestore = FirestoreService();
  List<CourseModel> _results = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
      });
      return;
    }
    setState(() => _loading = true);
    final results = await _firestore.searchCourses(query.trim());
    setState(() {
      _results = results;
      _loading = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search courses, subjects, topics...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_searched
              ? const EmptyState(icon: Icons.search, title: 'Search Porasona Plus', subtitle: 'Find courses by name, subject or category')
              : _results.isEmpty
                  ? const EmptyState(icon: Icons.search_off, title: 'No results found', subtitle: 'Try a different keyword')
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final c = _results[i];
                        return ListTile(
                          leading: const Icon(Icons.menu_book_outlined),
                          title: Text(c.title),
                          subtitle: Text('${c.subject} • ${c.category}'),
                          trailing: c.isPremium ? const Icon(Icons.workspace_premium, color: Colors.amber) : null,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.courseDetails, arguments: c.id),
                        );
                      },
                    ),
    );
  }
}

// File: lib/screens/review_screen.dart
// Kaam: Star rating + category chips se review submit karna
// Last 7 days ke reviews dikhana + reply feature

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  final _firebase = FirebaseService();
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  late TabController _tabController;

  // Write review state
  int _selectedRating = 0;
  final List<String> _selectedCategories = [];
  final _reviewCtrl = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;

  // View reviews state
  List<Map<String, dynamic>> _reviews = [];
  bool _loadingReviews = true;

  final List<String> _categories = [
    'Tasks',
    'Withdrawal',
    'Earning Coins',
    'App Design',
    'Customer Support',
    'Spin Wheel',
    'Invite System',
    'Overall',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    final reviews = await _firebase.getReviews();
    setState(() {
      _reviews = reviews;
      _loadingReviews = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reviews'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Write Review'),
            Tab(text: 'All Reviews'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWriteReview(),
          _buildAllReviews(),
        ],
      ),
    );
  }

  // ─── Write Review Tab ──────────────────────────────────────────────────────
  Widget _buildWriteReview() {
    if (_submitted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            const Text('Thank you for your review!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Your feedback helps us improve.',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _submitted = false;
                  _selectedRating = 0;
                  _selectedCategories.clear();
                  _reviewCtrl.clear();
                });
                _tabController.animateTo(1);
              },
              child: const Text('See All Reviews'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Star Rating
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              const Text('Rate your experience',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _selectedRating;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        color: filled ? AppColors.gold : AppColors.textSecondary,
                        size: 44,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _ratingLabel(_selectedRating),
                style: TextStyle(
                  color: _selectedRating > 0
                      ? AppColors.gold
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Categories
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What are you reviewing?',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategories.contains(cat);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedCategories.remove(cat);
                        } else {
                          _selectedCategories.add(cat);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Text review
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Write your review (optional)',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 10),
              TextField(
                controller: _reviewCtrl,
                maxLines: 4,
                maxLength: 300,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText:
                      'Share your experience with Nex Earn Pro...',
                  border: InputBorder.none,
                  counterStyle:
                      TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submitReview,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Submit Review'),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ─── All Reviews Tab ───────────────────────────────────────────────────────
  Widget _buildAllReviews() {
    if (_loadingReviews) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_reviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('⭐', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('No reviews yet',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
            SizedBox(height: 4),
            Text('Be the first to review!',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    // Average rating
    final avg = _reviews
            .map((r) => (r['rating'] ?? 0) as int)
            .fold(0, (a, b) => a + b) /
        _reviews.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Average rating card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 48,
                        fontWeight: FontWeight.w800),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < avg.round()
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: AppColors.gold,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('${_reviews.length} reviews',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final star = 5 - i;
                    final count = _reviews
                        .where((r) => (r['rating'] ?? 0) == star)
                        .length;
                    final pct =
                        _reviews.isEmpty ? 0.0 : count / _reviews.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text('$star',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                          const SizedBox(width: 6),
                          Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 12),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppColors.divider,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        AppColors.gold),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('$count',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...(_reviews.map((r) => _reviewCard(r)).toList()),
      ],
    );
  }

  Widget _reviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] ?? 0) as int;
    final date = review['created_at'] != null
        ? DateTime.tryParse(review['created_at'])
        : null;
    final categories = (review['categories'] as List?)?.cast<String>() ?? [];
    final isMyReview = review['uid'] == _uid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMyReview
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  Helpers.getInitials(review['username'] ?? '?'),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['username'] ?? 'Anonymous',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    Text(
                      date != null ? Helpers.timeAgo(date) : '',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.gold,
                    size: 14,
                  ),
                ),
              ),
              if (isMyReview)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('You',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),

          if (categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: categories
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(c,
                            style: const TextStyle(
                                color: AppColors.accent, fontSize: 11)),
                      ))
                  .toList(),
            ),
          ],

          if ((review['text'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review['text'],
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ],

          const SizedBox(height: 8),
          // Reply button
          GestureDetector(
            onTap: () => _showReplyDialog(review['id'] ?? ''),
            child: const Text('Reply',
                style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─── Actions ───────────────────────────────────────────────────────────────
  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      Helpers.showSnackBar(context, 'Please select a star rating',
          isError: true);
      return;
    }

    setState(() => _submitting = true);

    final user = FirebaseAuth.instance.currentUser;
    await _firebase.submitReview({
      'uid': _uid,
      'username':
          user?.email?.split('@')[0] ?? 'Anonymous',
      'rating': _selectedRating,
      'categories': _selectedCategories,
      'text': _reviewCtrl.text.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });

    setState(() {
      _submitting = false;
      _submitted = true;
    });
    _loadReviews();
  }

  void _showReplyDialog(String reviewId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text('Reply to Review',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Write your reply...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await _firebase.replyToReview(reviewId, {
                'uid': _uid,
                'text': ctrl.text.trim(),
                'created_at': DateTime.now().toIso8601String(),
              });
              Navigator.pop(context);
              Helpers.showSnackBar(context, 'Reply posted!');
            },
            child: const Text('Post Reply'),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1: return 'Poor 😔';
      case 2: return 'Fair 😐';
      case 3: return 'Good 🙂';
      case 4: return 'Great 😊';
      case 5: return 'Excellent 🤩';
      default: return 'Tap a star to rate';
    }
  }
}

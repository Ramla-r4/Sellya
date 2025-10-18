// Updated version of ProductDetailScreen with modern UI
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../screens/chat_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final Color primaryColor = const Color.fromARGB(255, 59, 86, 63);
  final Color backgroundGray = const Color(0xFFF2F2F2);
  bool isFavorited = false;
  String? wishlistDocId;
  int currentImageIndex = 0;
  final _reviewFormKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 0;
  List<Map<String, dynamic>> reviews = [];
  bool showReviewForm = false;

  Future<void> _loadReviews() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('reviews')
              .where('productId', isEqualTo: widget.product.id)
              .get();

      final loadedReviews =
          snapshot.docs
              .where(
                (doc) =>
                    doc.data().containsKey('timestamp') &&
                    doc['timestamp'] != null,
              )
              .map(
                (doc) => {
                  'userId': doc['userId'],
                  'rating': doc['rating'],
                  'comment': doc['comment'],
                  'timestamp': doc['timestamp'],
                },
              )
              .toList();

      loadedReviews.sort((a, b) {
        final aTimestamp = a['timestamp'] as Timestamp;
        final bTimestamp = b['timestamp'] as Timestamp;
        return bTimestamp.compareTo(aTimestamp);
      });

      setState(() => reviews = loadedReviews);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load reviews: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfFavorited();
    _loadReviews();
  }

  Future<void> _checkIfFavorited() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('wishlist')
            .where('userId', isEqualTo: userId)
            .where('productId', isEqualTo: widget.product.id)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        isFavorited = true;
        wishlistDocId = snapshot.docs.first.id;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    if (isFavorited && wishlistDocId != null) {
      // Remove from wishlist
      await FirebaseFirestore.instance
          .collection('wishlist')
          .doc(wishlistDocId)
          .delete();
      setState(() {
        isFavorited = false;
        wishlistDocId = null;
      });
    } else {
      // Add to wishlist
      final docRef = await FirebaseFirestore.instance
          .collection('wishlist')
          .add({'userId': userId, 'productId': widget.product.id});
      setState(() {
        isFavorited = true;
        wishlistDocId = docRef.id;
      });
    }
  }

  Future<void> _submitReview() async {
    if (!_reviewFormKey.currentState!.validate() || _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a rating and comment')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('reviews').add({
      'productId': widget.product.id,
      'userId': user.uid,
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _commentController.clear();
    setState(() {
      _rating = 0;
      showReviewForm = false;
    });

    _loadReviews();
  }

  Widget buildReviewForm() {
    return Visibility(
      visible: showReviewForm,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _reviewFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leave a Review',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color:
                            index < _rating ? Colors.amber : Colors.grey[400],
                      ),
                      onPressed: () => setState(() => _rating = index + 1.0),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Write your comment...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator:
                      (val) =>
                          val == null || val.trim().isEmpty
                              ? 'Comment required'
                              : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Submit Review'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.imageUrls;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundGray,
        elevation: 0,
        titleSpacing: 0, // Removes default padding
        title: Row(
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),

            // Spacing between back and search
            const SizedBox(width: 8),

            // Search box
            SizedBox(
              width: 260, // Adjust this to your desired width
              height: 46,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 19,
            ), // space from right corner
            child: Center(
              child: ElevatedButton(
                onPressed:
                    () => setState(() => showReviewForm = !showReviewForm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(8), // smaller padding
                  minimumSize: const Size(48, 48), // force button size
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Icon(
                  Icons.feedback,
                  size: 25, // smaller icon
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image viewer and page dots
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    itemCount: images.length,
                    onPageChanged:
                        (index) => setState(() => currentImageIndex = index),
                    itemBuilder: (context, index) {
                      return Image.network(
                        images[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 10,
                    child: Row(
                      children: List.generate(
                        images.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                currentImageIndex == index
                                    ? Colors.white
                                    : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '\$${widget.product.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 59, 86, 63),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : Colors.grey,
                        ),
                        onPressed: _toggleWishlist,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    widget.product.title,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 7),
                  Text(widget.product.description),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 720,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final currentUserId =
                              FirebaseAuth.instance.currentUser!.uid;
                          final sellerId = widget.product.ownerId;

                          final sellerDoc =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(sellerId)
                                  .get();

                          if (!sellerDoc.exists) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Seller not found')),
                            );
                            return;
                          }

                          final sellerData = sellerDoc.data()!;
                          final sellerName = sellerData['name'] ?? 'User';
                          final sellerImageUrl = sellerData['imageUrl'] ?? '';

                          final chatId = getChatId(currentUserId, sellerId);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ChatScreen(
                                    chatId: chatId,
                                    chatUserId: chatId,
                                    otherUserId: sellerId,
                                    chatUserName: sellerName,
                                    chatUserImageUrl: sellerImageUrl,
                                  ),
                            ),
                          );
                        } catch (e) {
                          debugPrint('❌ Error in Message Seller Button: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Something went wrong: $e')),
                          );
                        }
                      },
                      label: const Text(
                        'Message Seller',
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            buildReviewForm(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Customer Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'No reviews yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...reviews.map((review) {
                    final userId = review['userId'];
                    final comment = review['comment'];
                    final rating = review['rating'];
                    final timestamp = review['timestamp'] as Timestamp?;
                    final date =
                        timestamp != null
                            ? DateTime.fromMillisecondsSinceEpoch(
                              timestamp.millisecondsSinceEpoch,
                            )
                            : null;

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(userId)
                              .get(),
                      builder: (context, snapshot) {
                        final userData =
                            snapshot.data?.data() as Map<String, dynamic>?;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User Avatar
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                      userData?['imageUrl'] != null
                                          ? NetworkImage(userData!['imageUrl'])
                                          : null,
                                  backgroundColor: Colors.grey[300],
                                  child:
                                      userData?['imageUrl'] == null
                                          ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 12),
                                // Review Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData?['name'] ?? 'Anonymous',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(5, (i) {
                                          return Icon(
                                            i < rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 16,
                                            color: Colors.orange,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      if (date != null)
                                        Text(
                                          '${date.day}/${date.month}/${date.year}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

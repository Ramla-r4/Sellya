import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ownsell/screens/add_product_screen.dart';
import 'package:ownsell/screens/product_detail_screen.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';
  int selectedIndex = 0;

  final List<String> categories = [
    'All',
    'Electronics',
    'Clothing',
    'Furniture',
    'Books',
    'Toys',
  ];

  final Color primaryColor = const Color.fromARGB(255, 71, 129, 82);
  final Color highlightColor = const Color(0xFF00BCD4);
  final Color ctaYellow = const Color(0xFFFFEB3B);
  final Color backgroundGray = const Color(0xFFF2F2F2);
  final Color textColor = const Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + Title (LEFT)
                  Row(
                    children: [
                      Container(
                        width: 40, // keep container small
                        height: 40,
                        padding:
                            EdgeInsets
                                .zero, // remove padding so image fills more space
                        decoration: BoxDecoration(
                          color: backgroundGray,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // match container rounding
                          child: Image.asset(
                            'assets/images/logo copy.png',
                            fit:
                                BoxFit
                                    .cover, // make image fill container completely
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),
                      const Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Gabarito',
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),

                  // Sell Button (RIGHT)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddProductScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Now Purple
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "Sell Now ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        fontFamily: 'Gabarito',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged:
                    (val) => setState(() => searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedCategory = cat),
                      selectedColor: primaryColor.withOpacity(0.2),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? primaryColor : textColor,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Product Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  final products =
                      docs
                          .map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            // Fallback: If imageUrls is not present, convert single imageUrl to list
                            final imageUrls =
                                (data['imageUrls'] as List?)?.cast<String>() ??
                                (data['imageUrl'] != null
                                    ? [data['imageUrl']]
                                    : []);

                            return ProductModel(
                              id: doc.id,
                              title: data['title'] ?? '',
                              description: data['description'] ?? '',
                              price: (data['price'] as num?)?.toDouble() ?? 0.0,
                              category: data['category'] ?? '',
                              ownerId: data['ownerId'] ?? '',
                              imageUrls:
                                  (data['imageUrls'] as List?)
                                      ?.cast<String>() ??
                                  [],
                              condition: data['condition'] ?? 'New',
                              sellerName: data['sellerName'] ?? '',
                              sellerImageUrl: data['sellerImageUrl'] ?? '',
                              createdAt:
                                  DateTime.tryParse(data['createdAt'] ?? '') ??
                                  DateTime.now(),
                            );
                          })
                          .where((p) {
                            final matchesSearch = p.title
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase());
                            final matchesCategory =
                                selectedCategory == 'All' ||
                                p.category == selectedCategory;
                            return matchesSearch && matchesCategory;
                          })
                          .toList();

                  if (products.isEmpty) {
                    return const Center(child: Text('No products found'));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: Image.network(
                                  product.imageUrls.first,
                                  width: double.infinity,
                                  height: 150,

                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\$${product.price}',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
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
                },
              ),
            ),
          ],
        ),
      ),

      // // 🔽 Floating Bottom Nav
      // bottomNavigationBar: ConvexAppBar(
      //   style: TabStyle.reactCircle,
      //   backgroundColor: Colors.white,
      //   activeColor: primaryColor,
      //   color: Colors.grey,
      //   elevation: 2,
      //   items: const [
      //     TabItem(icon: Icons.home, title: 'Home'),
      //     TabItem(icon: Icons.favorite_border, title: 'Wishlist'),
      //     TabItem(icon: Icons.person_outline, title: 'Profile'),
      //   ],
      //   initialActiveIndex: selectedIndex,
      //   onTap: (int i) => setState(() => selectedIndex = i),
      // ),
    );
  }
}

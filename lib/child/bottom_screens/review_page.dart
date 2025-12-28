import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../components/PrimaryButton.dart';
import '../../components/custom_textfield.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController locationC = TextEditingController();
  final TextEditingController viewsC = TextEditingController();

  bool isSaving = false;
  double ratings = 1.0;

  /// 🌸 SAME COLOR FOR SAVE + ADD + STARS
  static const Color kPrimaryPink = Color(0xFFF06292);

  /// ---------------- SHOW ADD REVIEW DIALOG ----------------
  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(8),
          title: const Text("Review your place"),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  hintText: 'Enter location',
                  controller: locationC,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: viewsC,
                  hintText: 'Enter review',
                  maxLines: 3,
                ),
                const SizedBox(height: 15),

                /// ⭐ RATING INPUT
                RatingBar.builder(
                  initialRating: ratings,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  unratedColor: Colors.grey.shade300,
                  itemPadding:
                  const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: kPrimaryPink),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratings = rating;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            /// 💗 SAVE BUTTON
            PrimaryButton(
              title: "SAVE",
              onPressed: () async {
                Navigator.pop(context);
                await saveReview();
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  /// ---------------- SAVE REVIEW ----------------
  Future<void> saveReview() async {
    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'location': locationC.text.trim(),
        'views': viewsC.text.trim(),
        'ratings': ratings,
        'createdAt': Timestamp.now(),
      });

      Fluttertoast.showToast(msg: 'Review uploaded successfully');
      locationC.clear();
      viewsC.clear();
      ratings = 1.0;
    } catch (_) {
      Fluttertoast.showToast(msg: 'Failed to upload review');
    }

    setState(() {
      isSaving = false;
    });
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// ➕ ADD BUTTON (SAME AS SAVE)
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryPink, // ✅ SAME COLOR
        onPressed: () => showAlert(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Recent Reviews",
                style:
                TextStyle(fontSize: 25, color: Colors.black),
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No reviews yet"));
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (_, __) =>
                    const Divider(),
                    itemBuilder: (context, index) {
                      final data =
                      snapshot.data!.docs[index].data()
                      as Map<String, dynamic>;

                      final double rating =
                          (data['ratings'] as num?)
                              ?.toDouble() ??
                              1.0;

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding:
                          const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Location : ${data['location'] ?? ''}",
                                style: const TextStyle(
                                    fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Comments : ${data['views'] ?? ''}",
                                style: const TextStyle(
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 8),

                              /// ⭐ STAR DISPLAY
                              RatingBar.builder(
                                initialRating: rating,
                                minRating: 1,
                                direction:
                                Axis.horizontal,
                                itemCount: 5,
                                ignoreGestures: true,
                                unratedColor:
                                Colors.grey.shade300,
                                itemPadding:
                                const EdgeInsets.symmetric(
                                    horizontal: 4.0),
                                itemBuilder:
                                    (context, _) =>
                                const Icon(
                                  Icons.star,
                                  color: kPrimaryPink,
                                ),
                                onRatingUpdate: (_) {},
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
    );
  }
}

/// A styled news card displaying article details, including title, image, author, 
/// bookmark toggle, and publication time.

library;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:skeletons/skeletons.dart';
import 'package:provider/provider.dart';
import '../../../common/colors.dart';
import '../../../models/news_model.dart';
import '../../../screens/news_info/news_info.dart';
import '../../../providers/bookmark_provider.dart';


class NewsCard extends StatelessWidget {
  final News article;
  final VoidCallback? onBookmarkToggled;

  const NewsCard({
    super.key,
    required this.article,
    this.onBookmarkToggled,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => NewsInfo(news: article),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          elevation: 0.2,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article Image with Skeleton Loader
                Image.network(
                  article.urlToImage.toString(),
                  fit: BoxFit.contain,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    if (frame == null) {
                      return Center(
                        child: Skeleton(
                          isLoading: true,
                          skeleton: SkeletonParagraph(),
                          child: const Text(''),
                        ),
                      );
                    }
                    return child;
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    article.title.toString(),
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Author & Bookmark Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.black, size: 20),
                        SizedBox(
                          width: size.width / 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              article.author.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Bookmark Toggle with Consumer for Dynamic Updates
                    Consumer<BookmarkProvider>(
                      builder: (context, bookmarkProvider, child) {
                        bool isBookmarked = bookmarkProvider.isBookmarked(article.title ?? "");

                        return IconButton(
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            bookmarkProvider.toggleBookmark(article);
                            if (onBookmarkToggled != null) {
                              onBookmarkToggled!();
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
                // Published Time
                Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.black, size: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        Jiffy.parse(article.publishedAt.toString()).fromNow().toString(),
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: AppColors.black,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // article opening
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    article.description.toString(),
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/// Displays bookmarked news articles, updating dynamically using Provider for state management.

library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/widgets/news_card.dart';
import '../../providers/bookmark_provider.dart';


class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bookmarks",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          final bookmarkedArticles = bookmarkProvider.bookmarkedArticles;

          if (bookmarkedArticles.isEmpty) {
            return Center(
              child: Text(
                "No bookmarks to show.",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: bookmarkedArticles.length,
            itemBuilder: (context, index) {
              final article = bookmarkedArticles[index];
              return NewsCard(article: article);
            },
          );
        },
      ),
    );
  }
}
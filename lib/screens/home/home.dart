/// Main screen displaying categorized, searchable, and paginated news articles.

library;
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import '../../common/colors.dart';
import '../../common/common.dart';
import '../../common/widgets/no_connectivity.dart';
import '../../models/listdata_model.dart';
import '../../models/news_model.dart' as m;
import '../../providers/news_provider.dart';
import 'widgets/category_item.dart';
import 'widgets/news_card.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../news_info/news_info.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology'
  ];

  int activeCategory = 0; // Tracks the currently selected news category
  int page = 1; // Keeps track of pagination for fetching more articles
  bool isFinish = false; // Indicates whether all articles have been loaded
  bool data = false; // Indicates whether news data has been successfully fetched.
  bool isSearchActive = false; // Determines if search mode is active
  TextEditingController searchController = TextEditingController();  // Handles user search input

  List<m.News> articles = [];
  List<m.News> allArticles = [];
  List<String> searchSuggestions = [];
  Map<String, int> articleClicks = {};

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  // Checks internet connection and handles offline behavio
  Future<void> checkConnectivity() async {
    if (await getInternetStatus()) {
      getNewsData();
    } else {
      Navigator.of(context, rootNavigator: true)
          .push(
            MaterialPageRoute(
              builder: (context) => const NoConnectivity(),
            ),
          )
          .then((value) => checkConnectivity());
    }
  }

  // Fetches articles and updates pagination
  Future<bool> getNewsData() async {
    ListData listData = await NewsProvider()
        .GetEverything(categories[activeCategory].toString(), page++);

    if (listData.status) {
      List<m.News> items = listData.data as List<m.News>;
      data = true;

      if (items.length == listData.totalContent) {
        isFinish = true;
      }

      for (var item in items) {
        articleClicks[item.title ?? ""] = articleClicks[item.title ?? ""] ?? 0;
      }

      allArticles.addAll(items);
      articles.addAll(items);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  // Filters articles based on search input
  void filterArticles(String query) {
    List<m.News> filteredArticles = allArticles.where((article) {
      return (article.title?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    setState(() {
      articles = filteredArticles;
    });
  }

  // Provides dynamic search suggestions
  void getSearchSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        searchSuggestions = [];
      });
      return;
    }

    List<String> suggestions = allArticles
        .where((article) => article.title?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .map((article) => article.title ?? '')
        .toSet()
        .toList();

    setState(() {
      searchSuggestions = suggestions;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 5,
        titleSpacing: 0,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.contain,
            color: AppColors.white,
          ),
        ),
        actions: [
          isSearchActive
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      isSearchActive = false;
                      searchController.clear();
                      articles = allArticles;
                      searchSuggestions = [];
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearchActive = true;
                    });
                  },
                ),
          IconButton(
            icon: const Icon(Icons.bookmark, color: AppColors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarksScreen()),
              );
            },
          ),
        ],
        title: isSearchActive
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 16),
                  hintText: "Search...",
                  hintStyle: TextStyle(color: AppColors.white),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  getSearchSuggestions(query);
                },
                onSubmitted: (query) {
                  filterArticles(query); // apply search on submit
                  setState(() {
                    searchSuggestions = [];
                    isSearchActive = false;
                  });
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            if (isSearchActive)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.transparent,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                height: searchController.text.isEmpty
                  ? 0 // no suggestions box if nothing typed
                  : searchSuggestions.isEmpty
                      ? 60 // no matches, small height for message
                      : (searchSuggestions.length * 60.0).clamp(50.0, 150.0),
                child: searchController.text.isEmpty
                  ? const SizedBox.shrink()
                  : searchSuggestions.isEmpty
                      ? Center(
                          child: Text(
                            "No matches found",
                            style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightGray,
                            )
                          ),
                        )
                      : ListView.builder(  // builds suggestions 
                          itemCount: searchSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = searchSuggestions[index];
                            return ListTile(
                              title: Text(suggestion),
                              onTap: () {
                                searchController.text = suggestion;
                                filterArticles(suggestion);
                                setState(() {
                                  searchSuggestions = [];
                                  isSearchActive = false;
                                });

                                final matchedArticle = allArticles.firstWhere(
                                  (article) => article.title == suggestion,
                                  orElse: () => m.News(),
                                );

                                if (matchedArticle.title != null && matchedArticle.title!.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsInfo(news: matchedArticle),  // redirects to news info screen
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),

              ),

            Container( // categories 
              margin: EdgeInsets.only(top: searchController.text.isNotEmpty && isSearchActive? 15:0, bottom: 15.0),
              child: SizedBox(
                height: 50,
                width: size.width,
                child: ListView.builder(
                  itemCount: categories.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) => CategoryItem(
                    index: index,
                    categoryName: categories[index],
                    activeCategory: activeCategory,
                    onClick: () {
                      setState(() {
                        activeCategory = index;
                        articles = [];
                        page = 1;
                        isFinish = false;
                        data = false;
                      });
                      getNewsData();
                    },
                  ),
                ),
              ),
            ),
              
              SizedBox(
                height: size.height,
                child: LoadMore(
                  isFinish: isFinish,
                  onLoadMore: getNewsData,
                  whenEmptyLoad: true,
                  delegate: const DefaultLoadMoreDelegate(),
                  textBuilder: DefaultLoadMoreTextBuilder.english,
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) => NewsCard(
                      article: articles[index]
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

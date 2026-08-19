class ComicModel {
  final String mangaId;
  final String title;
  final String coverImageUrl;
  final String? alternativeTitle;
  final double userRate;
  final String? latestChapterNumber;
  final String? latestChapterTime;
  final String? updatedAt;
  final String? type;
  final int viewCount;

  ComicModel({
    required this.mangaId,
    required this.title,
    required this.coverImageUrl,
    this.alternativeTitle,
    this.type,
    required this.userRate,
    this.latestChapterNumber,
    this.latestChapterTime,
    this.updatedAt,
    required this.viewCount,
  });

  factory ComicModel.fromJson(Map<String, dynamic> json) {
    // 1. Extract Slug / Manga ID
    String slug = '';
    if (json['slug'] != null && json['slug'].toString().isNotEmpty) {
      slug = json['slug'].toString();
    } else {
      final rawLink = json['link'] ??
          json['href'] ??
          json['detailUrl'] ??
          json['url'] ??
          json['manga_id'] ??
          json['id'] ??
          '';
      String str = rawLink.toString().trim();
      while (str.endsWith('/')) {
        str = str.substring(0, str.length - 1);
      }
      if (str.contains('/')) {
        str = str.substring(str.lastIndexOf('/') + 1);
      }
      slug = str;
    }

    // 2. Extract Cover Image
    final cover = json['image'] ??
        json['thumbnail'] ??
        json['cover'] ??
        json['cover_image_url'] ??
        json['cover_url'] ??
        json['poster'] ??
        '';

    // 3. Extract Latest Chapter
    String? chTitle;
    if (json['chapter'] != null) {
      chTitle = json['chapter'].toString();
    } else if (json['latest_chapter_number'] != null) {
      chTitle = json['latest_chapter_number'].toString();
    } else if (json['latestChapter'] is Map &&
        json['latestChapter']['title'] != null) {
      chTitle = json['latestChapter']['title'].toString();
    }

    // 4. Extract Rating
    double rate = 0.0;
    if (json['user_rate'] != null) {
      rate = (json['user_rate'] as num).toDouble();
    } else if (json['rating'] != null) {
      rate = (json['rating'] as num?)?.toDouble() ?? 0.0;
    } else if (json['trending_score'] != null) {
      rate = (json['trending_score'] as num?)?.toDouble() ?? 0.0;
    }

    // 5. Extract Time
    final timeStr = json['time_ago'] ??
        json['latest_chapter_time'] ??
        json['updated_at'] ??
        json['stats']?.toString();

    // 6. Extract Type
    final typeStr = json['type']?.toString();

    return ComicModel(
      mangaId: slug,
      title: json['title'] as String? ?? '',
      coverImageUrl: cover.toString(),
      alternativeTitle: json['altTitle'] as String? ??
          json['alternative_title'] as String? ??
          json['title_indonesian'] as String?,
      type: typeStr,
      userRate: rate,
      latestChapterNumber: chTitle,
      latestChapterTime: timeStr?.toString(),
      updatedAt: json['updated_at']?.toString(),
      viewCount: json['view_count'] as int? ?? 0,
    );
  }
}

class ComicDetailModel {
  final String mangaId;
  final String title;
  final String coverImageUrl;
  final String description;
  final String? status;
  final String? author;
  final String? type;
  final List<String> genres;
  final List<ComicChapterModel> chapters;

  ComicDetailModel({
    required this.mangaId,
    required this.title,
    required this.coverImageUrl,
    required this.description,
    this.status,
    this.author,
    this.type,
    required this.genres,
    required this.chapters,
  });

  factory ComicDetailModel.fromJson(Map<String, dynamic> json) {
    // 1. Slug
    String slug = json['slug']?.toString() ??
        json['manga_id']?.toString() ??
        json['id']?.toString() ??
        '';

    // 2. Cover image
    final cover = json['image'] ??
        json['cover'] ??
        json['thumbnail'] ??
        json['cover_image_url'] ??
        '';

    // 3. Description / Synopsis
    final desc = json['synopsis'] ??
        json['synopsis_full'] ??
        json['summary'] ??
        json['description'] ??
        '';

    // 4. Metadata
    final meta = json['metadata'] as Map<String, dynamic>?;
    final type = meta?['type']?.toString() ?? json['type']?.toString();
    final author = meta?['author']?.toString() ?? json['author']?.toString();
    final status = meta?['status']?.toString() ?? json['status']?.toString();

    // 5. Genres
    var genreList = json['genres'] as List? ?? json['genreList'] as List? ?? [];
    List<String> parsedGenres = [];
    for (var g in genreList) {
      if (g is Map) {
        final name = g['name'] ?? g['title'] ?? g['slug'] ?? '';
        if (name.toString().isNotEmpty) parsedGenres.add(name.toString());
      } else if (g != null && g.toString().isNotEmpty) {
        parsedGenres.add(g.toString());
      }
    }

    // 6. Chapters
    var rawChapters = json['chapters'] as List? ??
        json['chapterList'] as List? ??
        json['data'] as List? ??
        [];
    List<ComicChapterModel> parsedChapters = rawChapters
        .map((c) => ComicChapterModel.fromJson(c as Map<String, dynamic>))
        .toList();

    return ComicDetailModel(
      mangaId: slug,
      title: json['title'] as String? ?? '',
      coverImageUrl: cover.toString(),
      description: desc.toString(),
      status: status,
      author: author,
      type: type,
      genres: parsedGenres,
      chapters: parsedChapters,
    );
  }
}

class ComicChapterModel {
  final String chapterId;
  final String chapterNumber;
  final String? chapterTitle;
  final String? createdAt;

  ComicChapterModel({
    required this.chapterId,
    required this.chapterNumber,
    this.chapterTitle,
    this.createdAt,
  });

  factory ComicChapterModel.fromJson(Map<String, dynamic> json) {
    // 1. Chapter Slug / ID
    String slug = '';
    if (json['slug'] != null && json['slug'].toString().isNotEmpty) {
      slug = json['slug'].toString();
    } else {
      final rawLink = json['link'] ??
          json['url'] ??
          json['chapter_id'] ??
          json['id'] ??
          '';
      String str = rawLink.toString().trim();
      while (str.endsWith('/')) {
        str = str.substring(0, str.length - 1);
      }
      if (str.contains('/')) {
        str = str.substring(str.lastIndexOf('/') + 1);
      }
      slug = str;
    }

    // 2. Chapter Title / Number
    final title = json['chapter'] ??
        json['chapter_title'] ??
        json['title'] ??
        json['chapter_number'] ??
        '';

    final date = json['date'] ?? json['created_at'] ?? json['time'];

    return ComicChapterModel(
      chapterId: slug,
      chapterNumber: title.toString(),
      chapterTitle: title.toString(),
      createdAt: date?.toString(),
    );
  }
}

class ComicChapterImagesModel {
  final String chapterId;
  final String? mangaTitle;
  final String? chapterTitle;
  final List<String> images;
  final ComicChapterNavigationModel? navigation;

  ComicChapterImagesModel({
    required this.chapterId,
    this.mangaTitle,
    this.chapterTitle,
    required this.images,
    this.navigation,
  });

  factory ComicChapterImagesModel.fromJson(Map<String, dynamic> json) {
    final imageList = json['imagesproxy'] as List? ??
        json['images'] as List? ??
        json['pages'] as List? ??
        [];

    ComicChapterNavigationModel? nav;
    if (json['navigation'] is Map<String, dynamic>) {
      nav = ComicChapterNavigationModel.fromJson(
          json['navigation'] as Map<String, dynamic>);
    }

    return ComicChapterImagesModel(
      chapterId: (json['chapter_id'] ?? json['id'] ?? json['slug'] ?? '').toString(),
      mangaTitle: json['manga_title'] as String?,
      chapterTitle: json['chapter_title'] as String? ?? json['chapter'] as String?,
      images: imageList.map((img) {
        if (img is Map) {
          return (img['image_url'] ?? img['url'] ?? '').toString();
        }
        return img.toString();
      }).toList(),
      navigation: nav,
    );
  }
}

class ComicChapterNavigationModel {
  final String? prevSlug;
  final String? nextSlug;
  final String? currentChapter;

  ComicChapterNavigationModel({
    this.prevSlug,
    this.nextSlug,
    this.currentChapter,
  });

  factory ComicChapterNavigationModel.fromJson(Map<String, dynamic> json) {
    String? cleanSlug(dynamic val) {
      if (val == null) return null;
      String s = val.toString().trim();
      if (s.isEmpty) return null;
      while (s.endsWith('/')) {
        s = s.substring(0, s.length - 1);
      }
      if (s.contains('/')) {
        s = s.substring(s.lastIndexOf('/') + 1);
      }
      return s;
    }

    return ComicChapterNavigationModel(
      prevSlug: cleanSlug(json['previousChapter'] ?? json['prev_slug'] ?? json['prev']),
      nextSlug: cleanSlug(json['nextChapter'] ?? json['next_slug'] ?? json['next']),
      currentChapter: json['currentChapter'] as String?,
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../models/anime_model.dart';
import '../models/anime_detail_model.dart';
import '../models/batch_model.dart';
import '../models/episode_detail_model.dart';
import '../models/genre_model.dart';
import '../models/home_model.dart';
import '../models/pagination_model.dart';
import '../models/schedule_model.dart';
import '../models/komik_model.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ),
    );

    if (kDebugMode) {
      final logger = LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => debugPrint(obj.toString()),
      );
      _dio.interceptors.add(logger);
    }
  }

  // ─── HOME ─────────────────────────────────────────────
  Future<HomeModel> getHome() async {
    try {
      final response = await _dio.get(ApiConstants.home);
      final data = response.data['data'] as Map<String, dynamic>;
      return HomeModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ONGOING ANIME ────────────────────────────────────
  Future<({List<AnimeModel> animeList, PaginationModel? pagination})>
      getOngoingAnime({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.ongoingAnime,
        queryParameters: {'page': page},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final animeList = (data['animeList'] as List)
          .map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
          .toList();
      final pagination = response.data['pagination'] != null
          ? PaginationModel.fromJson(
              response.data['pagination'] as Map<String, dynamic>)
          : null;
      return (animeList: animeList, pagination: pagination);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── COMPLETE ANIME ───────────────────────────────────
  Future<({List<AnimeModel> animeList, PaginationModel? pagination})>
      getCompleteAnime({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.completeAnime,
        queryParameters: {'page': page},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final animeList = (data['animeList'] as List)
          .map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
          .toList();
      final pagination = response.data['pagination'] != null
          ? PaginationModel.fromJson(
              response.data['pagination'] as Map<String, dynamic>)
          : null;
      return (animeList: animeList, pagination: pagination);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }



  // ─── GENRES ───────────────────────────────────────────
  Future<List<GenreModel>> getGenres() async {
    try {
      final response = await _dio.get(ApiConstants.genre);
      final data = response.data['data'] as Map<String, dynamic>;
      return (data['genreList'] as List)
          .map((g) => GenreModel.fromJson(g as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── GENRE ANIME ──────────────────────────────────────
  Future<({List<AnimeModel> animeList, PaginationModel? pagination})>
      getGenreAnime(String slug, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.genreBySlug(slug),
        queryParameters: {'page': page},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final animeList = (data['animeList'] as List)
          .map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
          .toList();
      final pagination = response.data['pagination'] != null
          ? PaginationModel.fromJson(
              response.data['pagination'] as Map<String, dynamic>)
          : null;
      return (animeList: animeList, pagination: pagination);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── SEARCH ───────────────────────────────────────────
  Future<List<AnimeModel>> searchAnime(String keyword) async {
    try {
      final response = await _dio.get(ApiConstants.search(keyword));
      final data = response.data['data'] as Map<String, dynamic>;
      return (data['animeList'] as List)
          .map((a) => AnimeModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── SCHEDULE ─────────────────────────────────────────
  Future<List<ScheduleModel>> getSchedule() async {
    try {
      final response = await _dio.get(ApiConstants.schedule);
      final data = response.data['data'] as List;
      return data
          .map((s) => ScheduleModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ANIME DETAIL ─────────────────────────────────────
  Future<AnimeDetailModel> getAnimeDetail(String slug) async {
    try {
      final response = await _dio.get(ApiConstants.animeDetail(slug));
      final data = response.data['data'] as Map<String, dynamic>;
      return AnimeDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── EPISODE DETAIL ───────────────────────────────────
  Future<EpisodeDetailModel> getEpisodeDetail(String slug) async {
    try {
      final response = await _dio.get(ApiConstants.episodeDetail(slug));
      final data = response.data['data'] as Map<String, dynamic>;
      return EpisodeDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── SERVER URL ───────────────────────────────────────
  Future<String> getServerUrl(String serverId) async {
    try {
      final response = await _dio.get(ApiConstants.server(serverId));
      final data = response.data['data'] as Map<String, dynamic>;
      return data['url'] as String? ?? '';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── BATCH ────────────────────────────────────────────
  Future<BatchModel> getBatch(String slug) async {
    try {
      final response = await _dio.get(ApiConstants.batch(slug));
      final data = response.data['data'] as Map<String, dynamic>;
      return BatchModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ERROR HANDLER ────────────────────────────────────
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Koneksi timeout. Silakan coba lagi.');
      case DioExceptionType.connectionError:
        return Exception('Tidak ada koneksi internet.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Data tidak ditemukan.');
        } else if (statusCode == 500) {
          return Exception('Server sedang bermasalah.');
        }
        return Exception('Terjadi kesalahan (kode: $statusCode).');
      default:
        return Exception('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  // ─── COMIC METHODS ────────────────────────────────────
  List<ComicModel> _parseComicList(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json.map((x) => ComicModel.fromJson(x as Map<String, dynamic>)).toList();
    }
    if (json is Map) {
      final list = json['comics'] ??
          json['data'] ??
          json['trending'] ??
          json['popular'] ??
          json['latest'] ??
          json['recommendations'] ??
          json['comicList'] ??
          json['mangaList'] ??
          [];
      if (list is List) {
        return list.map((x) => ComicModel.fromJson(x as Map<String, dynamic>)).toList();
      }
    }
    return [];
  }

  Future<List<ComicModel>> getComicLatest({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.comicTerbaru,
        queryParameters: {'page': page, 'limit': 20},
      );
      return _parseComicList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ComicModel>> getComicPopuler({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.comicPopuler,
        queryParameters: {'page': page, 'limit': 20},
      );
      return _parseComicList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ComicModel>> getComicTrending() async {
    try {
      final response = await _dio.get(ApiConstants.comicTrending);
      return _parseComicList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ComicModel>> getComicPustaka({int page = 1}) async {
    try {
      final response = await _dio.get(ApiConstants.comicPustaka(page));
      final data = response.data;
      if (data is Map && data['results'] != null) {
        final list = data['results'] as List;
        return list
            .map((x) => ComicModel.fromJson(x as Map<String, dynamic>))
            .toList();
      }
      return _parseComicList(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComicDetailModel> getComicDetail(String slug) async {
    try {
      final response = await _dio.get(ApiConstants.comicDetail(slug));
      final data = response.data as Map<String, dynamic>;
      final comicJson = data['data'] ?? data;
      return ComicDetailModel.fromJson(comicJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComicChapterImagesModel> getComicChapterImages(String slug) async {
    try {
      final response = await _dio.get(ApiConstants.comicChapter(slug));
      final data = response.data as Map<String, dynamic>;
      final chapterJson = data['data'] ?? data;
      return ComicChapterImagesModel.fromJson(chapterJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ComicChapterNavigationModel> getComicChapterNavigation(String slug) async {
    try {
      final response = await _dio.get(ApiConstants.comicChapterNavigation(slug));
      final data = response.data as Map<String, dynamic>;
      final navJson = data['data'] ?? data;
      return ComicChapterNavigationModel.fromJson(navJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ComicModel>> searchComic(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.comicSearch(query),
        queryParameters: {'page': page, 'limit': 20},
      );
      return _parseComicList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ComicModel>> getComicByType(String type, {int page = 1}) async {
    final lowerType = type.toLowerCase().trim();
    if (lowerType == 'terbaru' || lowerType == 'all' || lowerType.isEmpty) {
      return getComicLatest(page: page);
    }

    try {
      // Fetch 3 pages of pustaka in parallel per page batch to ensure plenty of items per type
      final startPustakaPage = (page - 1) * 3 + 1;
      final futures = [
        getComicPustaka(page: startPustakaPage),
        getComicPustaka(page: startPustakaPage + 1),
        getComicPustaka(page: startPustakaPage + 2),
      ];

      final resultsList = await Future.wait(futures);
      final List<ComicModel> combined = [];
      for (final list in resultsList) {
        for (final item in list) {
          if (item.type != null &&
              item.type!.toLowerCase().trim() == lowerType) {
            combined.add(item);
          }
        }
      }

      // If page 1 and results are sparse, also merge from genre endpoint if matching
      if (page == 1 && combined.length < 5) {
        try {
          final genreComics = await getComicByGenre(lowerType);
          for (final g in genreComics) {
            if (!combined.any((c) => c.mangaId == g.mangaId)) {
              combined.add(g);
            }
          }
        } catch (_) {}
      }

      return combined;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ComicModel>> getComicByGenre(String genre, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.comicGenre(genre),
        queryParameters: {'page': page, 'limit': 20},
      );
      return _parseComicList(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

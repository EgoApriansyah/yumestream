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
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
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
}

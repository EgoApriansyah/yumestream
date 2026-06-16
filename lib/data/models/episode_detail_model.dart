import 'episode_model.dart';
import 'server_model.dart';

class EpisodeDetailModel {
  final String title;
  final String animeId;
  final String? releaseTime;
  final String? defaultStreamingUrl;
  final bool hasPrevEpisode;
  final EpisodeNavModel? prevEpisode;
  final bool hasNextEpisode;
  final EpisodeNavModel? nextEpisode;
  final EpisodeServerData? server;
  final EpisodeDownloadData? downloadUrl;
  final EpisodeInfoModel? info;

  const EpisodeDetailModel({
    required this.title,
    required this.animeId,
    this.releaseTime,
    this.defaultStreamingUrl,
    required this.hasPrevEpisode,
    this.prevEpisode,
    required this.hasNextEpisode,
    this.nextEpisode,
    this.server,
    this.downloadUrl,
    this.info,
  });

  factory EpisodeDetailModel.fromJson(Map<String, dynamic> json) {
    return EpisodeDetailModel(
      title: json['title'] as String? ?? '',
      animeId: json['animeId'] as String? ?? '',
      releaseTime: json['releaseTime'] as String?,
      defaultStreamingUrl: json['defaultStreamingUrl'] as String?,
      hasPrevEpisode: json['hasPrevEpisode'] as bool? ?? false,
      prevEpisode: json['prevEpisode'] != null
          ? EpisodeNavModel.fromJson(
              json['prevEpisode'] as Map<String, dynamic>)
          : null,
      hasNextEpisode: json['hasNextEpisode'] as bool? ?? false,
      nextEpisode: json['nextEpisode'] != null
          ? EpisodeNavModel.fromJson(
              json['nextEpisode'] as Map<String, dynamic>)
          : null,
      server: json['server'] != null
          ? EpisodeServerData.fromJson(json['server'] as Map<String, dynamic>)
          : null,
      downloadUrl: json['downloadUrl'] != null
          ? EpisodeDownloadData.fromJson(
              json['downloadUrl'] as Map<String, dynamic>)
          : null,
      info: json['info'] != null
          ? EpisodeInfoModel.fromJson(json['info'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EpisodeNavModel {
  final String title;
  final String episodeId;
  final String href;

  const EpisodeNavModel({
    required this.title,
    required this.episodeId,
    required this.href,
  });

  factory EpisodeNavModel.fromJson(Map<String, dynamic> json) {
    return EpisodeNavModel(
      title: json['title'] as String? ?? '',
      episodeId: json['episodeId'] as String? ?? '',
      href: json['href'] as String? ?? '',
    );
  }
}

class EpisodeServerData {
  final List<QualityModel> qualities;

  const EpisodeServerData({required this.qualities});

  factory EpisodeServerData.fromJson(Map<String, dynamic> json) {
    return EpisodeServerData(
      qualities: json['qualities'] != null
          ? (json['qualities'] as List)
              .map((q) => QualityModel.fromJson(q as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class EpisodeDownloadData {
  final List<DownloadQualityModel> qualities;

  const EpisodeDownloadData({required this.qualities});

  factory EpisodeDownloadData.fromJson(Map<String, dynamic> json) {
    return EpisodeDownloadData(
      qualities: json['qualities'] != null
          ? (json['qualities'] as List)
              .map((q) =>
                  DownloadQualityModel.fromJson(q as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class EpisodeInfoModel {
  final String? credit;
  final String? encoder;
  final String? duration;
  final String? type;
  final List<EpisodeModel> episodeList;

  const EpisodeInfoModel({
    this.credit,
    this.encoder,
    this.duration,
    this.type,
    required this.episodeList,
  });

  factory EpisodeInfoModel.fromJson(Map<String, dynamic> json) {
    return EpisodeInfoModel(
      credit: json['credit'] as String?,
      encoder: json['encoder'] as String?,
      duration: json['duration'] as String?,
      type: json['type'] as String?,
      episodeList: json['episodeList'] != null
          ? (json['episodeList'] as List)
              .map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class ServerModel {
  final String title;
  final String serverId;
  final String href;

  const ServerModel({
    required this.title,
    required this.serverId,
    required this.href,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      title: (json['title'] as String? ?? '').trim(),
      serverId: json['serverId'] as String? ?? '',
      href: json['href'] as String? ?? '',
    );
  }
}

class QualityModel {
  final String title;
  final List<ServerModel> serverList;

  const QualityModel({
    required this.title,
    required this.serverList,
  });

  factory QualityModel.fromJson(Map<String, dynamic> json) {
    return QualityModel(
      title: json['title'] as String? ?? '',
      serverList: json['serverList'] != null
          ? (json['serverList'] as List)
              .map((s) => ServerModel.fromJson(s as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class DownloadUrlModel {
  final String title;
  final String url;

  const DownloadUrlModel({
    required this.title,
    required this.url,
  });

  factory DownloadUrlModel.fromJson(Map<String, dynamic> json) {
    return DownloadUrlModel(
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

class DownloadQualityModel {
  final String title;
  final String? size;
  final List<DownloadUrlModel> urls;

  const DownloadQualityModel({
    required this.title,
    this.size,
    required this.urls,
  });

  factory DownloadQualityModel.fromJson(Map<String, dynamic> json) {
    return DownloadQualityModel(
      title: json['title'] as String? ?? '',
      size: json['size'] as String?,
      urls: json['urls'] != null
          ? (json['urls'] as List)
              .map((u) => DownloadUrlModel.fromJson(u as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

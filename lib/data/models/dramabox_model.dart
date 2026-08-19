class DramaBoxBookModel {
  final String bookId;
  final String bookName;
  final String coverWap;
  final int chapterCount;
  final String introduction;
  final List<String> tags;
  final String? shelfTime;

  const DramaBoxBookModel({
    required this.bookId,
    required this.bookName,
    required this.coverWap,
    required this.chapterCount,
    required this.introduction,
    required this.tags,
    this.shelfTime,
  });

  factory DramaBoxBookModel.fromJson(Map<String, dynamic> json) {
    return DramaBoxBookModel(
      bookId: (json['bookId'] ?? '').toString(),
      bookName: json['bookName'] as String? ?? '',
      coverWap: json['coverWap'] as String? ?? '',
      chapterCount: json['chapterCount'] as int? ?? 0,
      introduction: json['introduction'] as String? ?? '',
      tags: (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      shelfTime: json['shelfTime'] as String?,
    );
  }
}

class DramaBoxEpisodeModel {
  final String chapterId;
  final int chapterIndex;
  final String chapterName;
  final String chapterImg;
  final List<DramaBoxCdnModel> cdnList;

  const DramaBoxEpisodeModel({
    required this.chapterId,
    required this.chapterIndex,
    required this.chapterName,
    required this.chapterImg,
    required this.cdnList,
  });

  factory DramaBoxEpisodeModel.fromJson(Map<String, dynamic> json) {
    return DramaBoxEpisodeModel(
      chapterId: (json['chapterId'] ?? '').toString(),
      chapterIndex: json['chapterIndex'] as int? ?? 0,
      chapterName: json['chapterName'] as String? ?? '',
      chapterImg: json['chapterImg'] as String? ?? '',
      cdnList: (json['cdnList'] as List?)
              ?.map((c) => DramaBoxCdnModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DramaBoxCdnModel {
  final String cdnDomain;
  final int isDefault;
  final List<DramaBoxVideoPathModel> videoPathList;

  const DramaBoxCdnModel({
    required this.cdnDomain,
    required this.isDefault,
    required this.videoPathList,
  });

  factory DramaBoxCdnModel.fromJson(Map<String, dynamic> json) {
    return DramaBoxCdnModel(
      cdnDomain: json['cdnDomain'] as String? ?? '',
      isDefault: json['isDefault'] as int? ?? 0,
      videoPathList: (json['videoPathList'] as List?)
              ?.map((v) => DramaBoxVideoPathModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class DramaBoxVideoPathModel {
  final int quality;
  final String videoPath;
  final int isDefault;

  const DramaBoxVideoPathModel({
    required this.quality,
    required this.videoPath,
    required this.isDefault,
  });

  factory DramaBoxVideoPathModel.fromJson(Map<String, dynamic> json) {
    return DramaBoxVideoPathModel(
      quality: json['quality'] as int? ?? 0,
      videoPath: json['videoPath'] as String? ?? '',
      isDefault: json['isDefault'] as int? ?? 0,
    );
  }
}

class DramaBoxDecryptedModel {
  final bool success;
  final String message;
  final String streamUrl;

  const DramaBoxDecryptedModel({
    required this.success,
    required this.message,
    required this.streamUrl,
  });

  factory DramaBoxDecryptedModel.fromJson(Map<String, dynamic> json) {
    return DramaBoxDecryptedModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      streamUrl: json['streamUrl'] as String? ?? '',
    );
  }
}

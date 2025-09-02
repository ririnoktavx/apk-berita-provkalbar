import '../../domain/entity/berita.dart';

class BeritaModel extends Berita {
  BeritaModel({
    required String id,
    required String title,
    required String author,
    required String date,
    required String thumbnail,
    required String url,
    required String content,
    String thumbnailLocal = '',
    String contentLocal = '',
  }) : super(
          id: '$title-$date', 
          title: title,
          author: author,
          date: date,
          thumbnail: thumbnail,
          thumbnailLocal: thumbnailLocal,
          url: url,
          content: content,
          contentLocal: contentLocal,
        );

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? '';
    final date = json['date'] ?? '';
    final id = json['id'] ?? '$title-$date';

    return BeritaModel(
      id: id,
      title: title,
      author: json['author'] ?? '',
      date: date,
       thumbnail: fixThumbnailUrl(json['thumbnail'] ?? ''),
      thumbnailLocal: json['thumbnailLocal'] ?? '',
      url: json['url'] ?? '',
      content: json['content'] ?? '',
      contentLocal: json['contentLocal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'date': date,
      'thumbnail': thumbnail,
      'thumbnailLocal': thumbnailLocal,
      'url': url,
      'content': content,
      'contentLocal': contentLocal,
    };
  }

  Berita toEntity() {
    return Berita(
      id: id,
      title: title,
      author: author,
      date: date,
      thumbnail: thumbnail,
      thumbnailLocal: thumbnailLocal,
      url: url,
      content: content,
      contentLocal: contentLocal,
    );
  }

  factory BeritaModel.fromEntity(Berita entity) {
    return BeritaModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      date: entity.date,
      thumbnail: entity.thumbnail,
      thumbnailLocal: entity.thumbnailLocal,
      url: entity.url,
      content: entity.content,
      contentLocal: entity.contentLocal,
    );
  }

  
}

String fixThumbnailUrl(String thumbnail) {
  if (!thumbnail.startsWith('http')) {
    return 'https://' + thumbnail;
  }
  return thumbnail;
}

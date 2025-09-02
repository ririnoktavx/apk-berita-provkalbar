class Berita {
  final String id; 
  final String title;
  final String author;
  final String date;
  final String content;
  final String contentLocal;
  final String thumbnail;
  final String thumbnailLocal; 
  final String url;


  Berita({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.content,
    required this.contentLocal,
    required this.thumbnail,
    required this.thumbnailLocal, 
    required this.url,
  });

  Berita copyWith({
    String? id,
    String? title,
    String? author,
    String? date,
    String? thumbnail,
    String? thumbnailLocal,
    String? url,
    String? content,
    String? contentLocal,
  }) {
    return Berita(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      date: date ?? this.date,
      thumbnail: thumbnail ?? this.thumbnail,
      thumbnailLocal: thumbnailLocal ?? this.thumbnailLocal,
      url: url ?? this.url,
      content: content ?? this.content,
      contentLocal: contentLocal ?? this.contentLocal,
    );
  }
  
}

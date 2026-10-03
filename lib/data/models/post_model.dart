/// RASA Models — Post, Reply, ChatMsg.
/// fromMap/toMap disamakan dengan struktur Firestore (lihat SETUP.md).
library;

class RasaPost {
  final String id;
  final String text;
  final String mood; // id mood: hancur/sedih/flat/lumayan/seneng
  final String authorId;
  final String alias;
  final DateTime createdAt;
  final int hugCount;
  final int meTooCount;
  final int replyCount;
  final bool hugged; // status lokal: user ini sudah peluk?
  final bool meToo;
  final String? aiReply;

  const RasaPost({
    required this.id,
    required this.text,
    required this.mood,
    required this.authorId,
    required this.alias,
    required this.createdAt,
    this.hugCount = 0,
    this.meTooCount = 0,
    this.replyCount = 0,
    this.hugged = false,
    this.meToo = false,
    this.aiReply,
  });

  RasaPost copyWith({
    int? hugCount,
    int? meTooCount,
    int? replyCount,
    bool? hugged,
    bool? meToo,
    String? aiReply,
  }) {
    return RasaPost(
      id: id,
      text: text,
      mood: mood,
      authorId: authorId,
      alias: alias,
      createdAt: createdAt,
      hugCount: hugCount ?? this.hugCount,
      meTooCount: meTooCount ?? this.meTooCount,
      replyCount: replyCount ?? this.replyCount,
      hugged: hugged ?? this.hugged,
      meToo: meToo ?? this.meToo,
      aiReply: aiReply ?? this.aiReply,
    );
  }

  factory RasaPost.fromMap(String id, Map<String, dynamic> m) {
    return RasaPost(
      id: id,
      text: (m['text'] ?? '') as String,
      mood: (m['mood'] ?? 'flat') as String,
      authorId: (m['authorId'] ?? '') as String,
      alias: (m['alias'] ?? 'Anon') as String,
      createdAt: DateTime.tryParse('${m['createdAt']}') ?? DateTime.now(),
      hugCount: (m['hugCount'] ?? 0) as int,
      meTooCount: (m['meTooCount'] ?? 0) as int,
      replyCount: (m['replyCount'] ?? 0) as int,
      aiReply: m['aiReply'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'mood': mood,
        'authorId': authorId,
        'alias': alias,
        'createdAt': createdAt.toIso8601String(),
        'hugCount': hugCount,
        'meTooCount': meTooCount,
        'replyCount': replyCount,
        'aiReply': aiReply,
      };
}

class RasaReply {
  final String id;
  final String postId;
  final String text;
  final String alias;
  final bool isAI;
  final String authorId;
  final DateTime createdAt;

  const RasaReply({
    required this.id,
    required this.postId,
    required this.text,
    required this.alias,
    required this.authorId,
    required this.createdAt,
    this.isAI = false,
  });

  factory RasaReply.fromMap(String id, String postId, Map<String, dynamic> m) {
    return RasaReply(
      id: id,
      postId: postId,
      text: (m['text'] ?? '') as String,
      alias: (m['alias'] ?? 'Anon') as String,
      authorId: (m['authorId'] ?? '') as String,
      createdAt: DateTime.tryParse('${m['createdAt']}') ?? DateTime.now(),
      isAI: (m['isAI'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'alias': alias,
        'authorId': authorId,
        'createdAt': createdAt.toIso8601String(),
        'isAI': isAI,
      };
}

/// Pesan chat 1-on-1 (AI Teman & Biliar Chat).
class ChatMsg {
  final String text;
  final bool mine;
  final DateTime at;
  const ChatMsg(this.text, this.mine, this.at);
}

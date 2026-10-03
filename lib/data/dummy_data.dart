import 'models/post_model.dart';

/// Data dummy buat DEMO_MODE — biar buyer langsung lihat feed rame
/// tanpa setup Firebase. Diputar fresh tiap app dibuka.
List<RasaPost> dummyPosts() {
  final now = DateTime.now();
  return [
    RasaPost(
      id: 'p1',
      text: 'Capek banget hari ini. Kerjaan numpuk, chat numpuk, yang nanya kabar nol. Kadang pengen hilang sehari aja gitu.',
      mood: 'sedih',
      authorId: 'u1',
      alias: 'Senja Mendung',
      createdAt: now.subtract(const Duration(minutes: 8)),
      hugCount: 24,
      meTooCount: 11,
      replyCount: 3,
      aiReply: 'Denger ceritamu berasa berat banget ya. Makasih udah berani cerita di sini. Hari yang berat bukan berarti kamu gagal — istirahat itu juga produktif lho. 🫂',
    ),
    RasaPost(
      id: 'p2',
      text: 'Hari ini genap 30 hari aku journaling tiap malam. Nggak nyangka hal sekecil nulis bisa bikin kepala jauh lebih tenang. Buat yang lagi mulai: gas terus ya ✨',
      mood: 'seneng',
      authorId: 'u2',
      alias: 'Embun Pagi',
      createdAt: now.subtract(const Duration(minutes: 42)),
      hugCount: 56,
      meTooCount: 8,
      replyCount: 5,
    ),
    RasaPost(
      id: 'p3',
      text: 'Overthinking lagi. Tadi salah ngomong dikit di grup kantor, sekarang kepikiran terus. Padahal orang lain mungkin udah lupa. Ada yang sama?',
      mood: 'flat',
      authorId: 'u3',
      alias: 'Kopi Susu',
      createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
      hugCount: 18,
      meTooCount: 32,
      replyCount: 6,
      aiReply: 'Wah, overthinking kayak gitu tuh manusiawi banget. Coba tes realita 10 detik: kalau temenmu yang salah ngomong, kamu bakal inget sampe besok nggak? Kemungkinan besar enggak. Kamu aman. 💛',
    ),
    RasaPost(
      id: 'p4',
      text: 'Baru diputusin setelah 3 tahun. Rasanya kayak semua rencana masa depan ke-reset. Buat yang pernah lewatin ini, berapa lama sampai baikan?',
      mood: 'hancur',
      authorId: 'u4',
      alias: 'Hujan Rintik',
      createdAt: now.subtract(const Duration(hours: 3)),
      hugCount: 89,
      meTooCount: 21,
      replyCount: 12,
      aiReply: 'Turut ngerasain sakitnya. 3 tahun itu bukan waktu sebentar, wajar kalau rasanya kayak kehilangan arah. Pelan-pelan ya, nggak ada target harus sembuh kapan. Satu hari satu langkah. 🌙',
    ),
    RasaPost(
      id: 'p5',
      text: 'Small win hari ini: berani nolak lembur dan pulang on-time. Ternyata dunia nggak kiamat. Besok mau coba lagi 😌',
      mood: 'lumayan',
      authorId: 'u5',
      alias: 'Komet Lewat',
      createdAt: now.subtract(const Duration(hours: 5)),
      hugCount: 41,
      meTooCount: 15,
      replyCount: 4,
    ),
    RasaPost(
      id: 'p6',
      text: 'Skripsi bab 4 revisi ke-6. Dosen cuma bales "coba baca lagi". Baca apanya pak 😭 ada pejuang skripsi lain di sini? Kita bisa!',
      mood: 'sedih',
      authorId: 'u6',
      alias: 'Kucing Galau',
      createdAt: now.subtract(const Duration(hours: 8)),
      hugCount: 33,
      meTooCount: 27,
      replyCount: 9,
    ),
    RasaPost(
      id: 'p7',
      text: 'Tadi pagi ibu nelpon cuma buat bilang "jangan lupa makan". Sesederhana itu tapi langsung mewek di kos. Sehat-sehat ya semua ibu di dunia 🤍',
      mood: 'lumayan',
      authorId: 'u7',
      alias: 'Daun Gugur',
      createdAt: now.subtract(const Duration(hours: 12)),
      hugCount: 102,
      meTooCount: 19,
      replyCount: 7,
    ),
    RasaPost(
      id: 'p8',
      text: 'Ngerasa ketinggalan dari temen-temen. Mereka udah nikah, karir naik, aku masih gini-gini aja di umur 26. Logikanya ngerti tiap orang jalannya beda, tapi hatinya susah nerima.',
      mood: 'sedih',
      authorId: 'u8',
      alias: 'Bulan Sabit',
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      hugCount: 67,
      meTooCount: 44,
      replyCount: 11,
      aiReply: 'Perasaan itu berat, dan valid. Tapi inget: yang kamu lihat dari orang lain itu highlight reel, bukan behind the scene-nya. Umur 26 masih bab awal banget. Kamu nggak telat, kamu lagi di jalanmu sendiri. 🌱',
    ),
  ];
}

/// Balasan dummy per postingan.
Map<String, List<RasaReply>> dummyReplies() {
  final now = DateTime.now();
  RasaReply r(String id, String postId, String text, String alias, Duration ago, {bool isAI = false}) {
    return RasaReply(
      id: id,
      postId: postId,
      text: text,
      alias: isAI ? '✨ RASA AI' : alias,
      authorId: isAI ? 'ai' : 'ux-$alias',
      createdAt: now.subtract(ago),
      isAI: isAI,
    );
  }

  return {
    'p1': [
      r('r11', 'p1', 'Peluk jauh kak 🫂 aku juga lagi di fase ini. Kita lewatin bareng ya.', 'Ombak Tenang', const Duration(minutes: 5)),
      r('r12', 'p1', 'Saran kecil: matiin notif 1 jam sebelum tidur. Ngaruh banget ke aku.', 'Angin Malam', const Duration(minutes: 2)),
    ],
    'p4': [
      r('r41', 'p4', 'Aku butuh 4 bulan buat beneran baikan. Tiap orang beda, jangan dipaksa cepet ya.', 'Senja Mendung', const Duration(hours: 2)),
      r('r42', 'p4', 'Hapus chat boleh, blokir boleh, nangis tiap malem juga boleh. Semua fase itu normal.', 'Komet Lewat', const Duration(hours: 1)),
    ],
    'p3': [
      r('r31', 'p3', 'SAMA BANGET. Aku sampe replay omongan di kepala 10x. Ternyata atasan aja lupa 😭', 'Kucing Galau', const Duration(minutes: 50)),
    ],
    'p6': [
      r('r61', 'p6', 'Pejuang bab 4 juga bang ✊ revisi ke-8 di sini. Semangat kita wisuda bareng tahun ini!', 'Hujan Rintik', const Duration(hours: 6)),
      r('r62', 'p6', 'Tips: kirim revisi pagi-pagi, dosen biasanya lagi good mood 😆', 'Kopi Susu', const Duration(hours: 4)),
    ],
  };
}

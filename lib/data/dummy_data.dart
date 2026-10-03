import 'models/post_model.dart';

/// Data dummy buat DEMO_MODE — biar buyer langsung lihat feed rame
/// tanpa setup Firebase. Diputar fresh tiap app dibuka.
List<RasaPost> dummyPosts() {
  final now = DateTime.now();
  return [
    RasaPost(
      id: 'p1',
      text: 'Capek sekali hari ini. Pekerjaan menumpuk, pesan menumpuk, tapi tidak ada yang menanyakan kabar. Kadang rasanya ingin menghilang sehari saja.',
      mood: 'sedih',
      authorId: 'u1',
      alias: 'Senja Mendung',
      createdAt: now.subtract(const Duration(minutes: 8)),
      hugCount: 24,
      meTooCount: 11,
      replyCount: 3,
      aiReply: 'Terima kasih sudah berbagi. Hari yang berat bukan berarti kamu gagal, istirahat juga bentuk produktivitas. Ceritakan lebih lanjut jika kamu mau, saya mendengarkan.',
    ),
    RasaPost(
      id: 'p2',
      text: 'Hari ini genap 30 hari saya journaling setiap malam. Tidak menyangka hal sekecil menulis bisa membuat pikiran jauh lebih tenang. Untuk yang baru mulai: lanjutkan.',
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
      text: 'Overthinking lagi. Tadi salah bicara sedikit di grup kantor, sekarang kepikiran terus. Padahal orang lain mungkin sudah lupa. Ada yang sama?',
      mood: 'flat',
      authorId: 'u3',
      alias: 'Kopi Susu',
      createdAt: now.subtract(const Duration(hours: 1, minutes: 15)),
      hugCount: 18,
      meTooCount: 32,
      replyCount: 6,
      aiReply: 'Overthinking seperti itu manusiawi sekali. Coba uji realita sebentar: jika temanmu yang salah bicara, apakah kamu akan mengingatnya sampai besok? Kemungkinan besar tidak. Kamu aman.',
    ),
    RasaPost(
      id: 'p4',
      text: 'Baru putus setelah 3 tahun. Rasanya seperti semua rencana masa depan ter-reset. Untuk yang pernah melewati ini, berapa lama sampai membaik?',
      mood: 'hancur',
      authorId: 'u4',
      alias: 'Hujan Rintik',
      createdAt: now.subtract(const Duration(hours: 3)),
      hugCount: 89,
      meTooCount: 21,
      replyCount: 12,
      aiReply: 'Turut merasakan kehilanganmu. Tiga tahun bukan waktu yang sebentar, wajar jika rasanya seperti kehilangan arah. Pelan-pelan saja, tidak ada target harus pulih kapan pun.',
    ),
    RasaPost(
      id: 'p5',
      text: 'Small win hari ini: berani menolak lembur dan pulang tepat waktu. Ternyata dunia tidak kiamat. Besok coba lagi.',
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
      text: 'Skripsi bab 4 revisi keenam. Dosen hanya membalas "coba baca lagi". Ada pejuang skripsi lain di sini? Kita pasti bisa.',
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
      text: 'Tadi pagi ibu menelepon hanya untuk bilang "jangan lupa makan". Sesederhana itu tapi langsung berkaca-kaca di kos. Sehat-sehat untuk semua ibu di dunia.',
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
      text: 'Rasanya tertinggal dari teman-teman. Mereka sudah menikah, karier naik, saya masih begini-begini saja di umur 26. Logikanya paham setiap orang jalannya beda, tapi hatinya sulit menerima.',
      mood: 'sedih',
      authorId: 'u8',
      alias: 'Bulan Sabit',
      createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      hugCount: 67,
      meTooCount: 44,
      replyCount: 11,
      aiReply: 'Perasaan itu berat, dan valid. Tapi ingat: yang kamu lihat dari orang lain adalah pencapaian yang terlihat, bukan proses di baliknya. Umur 26 masih sangat awal. Kamu tidak terlambat.',
    ),
  ];
}

/// Tanggapan dummy per cerita.
Map<String, List<RasaReply>> dummyReplies() {
  final now = DateTime.now();
  RasaReply r(String id, String postId, String text, String alias, Duration ago,
      {bool isAI = false}) {
    return RasaReply(
      id: id,
      postId: postId,
      text: text,
      alias: isAI ? 'RASA AI' : alias,
      authorId: isAI ? 'ai' : 'ux-$alias',
      createdAt: now.subtract(ago),
      isAI: isAI,
    );
  }

  return {
    'p1': [
      r('r11', 'p1', 'Peluk jauh. Saya juga sedang di fase ini. Kita lewati bersama ya.',
          'Ombak Tenang', const Duration(minutes: 5)),
      r('r12', 'p1', 'Saran kecil: matikan notifikasi satu jam sebelum tidur. Sangat berpengaruh untuk saya.',
          'Angin Malam', const Duration(minutes: 2)),
    ],
    'p4': [
      r('r41', 'p4', 'Saya butuh 4 bulan sampai benar-benar membaik. Setiap orang berbeda, jangan dipaksa cepat ya.',
          'Senja Mendung', const Duration(hours: 2)),
      r('r42', 'p4', 'Menghapus chat boleh, menangis tiap malam juga boleh. Semua fase itu normal.',
          'Komet Lewat', const Duration(hours: 1)),
    ],
    'p3': [
      r('r31', 'p3', 'Sama persis. Saya sampai memutar ulang omongan di kepala berkali-kali. Ternyata atasan pun lupa.',
          'Kucing Galau', const Duration(minutes: 50)),
    ],
    'p6': [
      r('r61', 'p6', 'Pejuang bab 4 juga. Revisi kedelapan di sini. Semangat, kita wisuda bareng tahun ini.',
          'Hujan Rintik', const Duration(hours: 6)),
      r('r62', 'p6', 'Tips: kirim revisi pagi-pagi, dosen biasanya sedang suasana baik.',
          'Kopi Susu', const Duration(hours: 4)),
    ],
  };
}

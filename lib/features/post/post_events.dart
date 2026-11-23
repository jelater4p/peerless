import 'package:flutter_riverpod/flutter_riverpod.dart';

/// İçerik eklendiğinde/silindiğinde/kaldırıldığında artan sayaç.
/// Listeler bunu dinler ve kendini yeniler.
class PostsVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final postsVersionProvider = NotifierProvider<PostsVersion, int>(PostsVersion.new);

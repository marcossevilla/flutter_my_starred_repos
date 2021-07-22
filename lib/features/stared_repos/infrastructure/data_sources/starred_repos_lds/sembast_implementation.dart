import 'package:meta/meta.dart';
import 'package:sembast/sembast.dart';

import '../../../domain/page.dart';
import '../../converters/page.dart';
import '../../dtos/github_repo.dart';
import 'interface.dart';

class StarredReposLDSImp extends StarredReposLDS {
  StarredReposLDSImp({
    required Database sembastDatabase,
  })  : _db = sembastDatabase,
        _store = StoreRef(storeName);

  final Database _db;

  final StoreRef<int, Map<String, dynamic>> _store;

  @visibleForTesting
  static const storeName = 'starred_repos';

  @override
  Future<void> set({
    required int page,
    required Page<GithubRepoDto> starredReposPage,
  }) async {
    await _store.record(page).put(
          _db,
          starredReposPage.toJson(
            (repoDto) => repoDto.toJson(),
          ),
        );
  }

  @override
  Future<Page<GithubRepoDto>?> get({
    required int page,
  }) async {
    final starredReposPageJson = await _store.record(page).get(_db);
    if (starredReposPageJson == null) return null;
    return ConvertiblePage.fromJson(
      starredReposPageJson,
      (repoJson) => GithubRepoDto.fromJson(repoJson),
    );
  }
}

import 'package:fordev/data/usecases/load_surveys/local_load_surveys.dart';
import 'package:fordev/data/usecases/load_surveys/remote_load_surveys.dart';

import '../../../domain/usecases/usecases.dart';
import '../../composites/composites.dart';
import '../factories.dart';

RemoteLoadSurveys makeRemoteLoadSurveys() => RemoteLoadSurveys(
  httpClient: makeAuthorizeHttpClientDecorator(),
  url: makeApiUrl('surveys')
);

LocalLoadSurveys makeLocalLoadSurveys() => LocalLoadSurveys(
  cacheStorage: makeLocalStorageAdapter()
);

LoadSurveys makeRemoteLoadSurveysWithLocalFallback() => RemoteLoadSurveysWithLocalFallback(
  remote: makeRemoteLoadSurveys(),
  local: makeLocalLoadSurveys()
);
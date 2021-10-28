import 'package:fordev/data/http/http_client.dart';
import 'package:fordev/data/http/http_error.dart';
import 'package:fordev/data/use_cases/remote_authentication.dart';
import 'package:fordev/domain/helpers/domain_error.dart';
import 'package:fordev/domain/use_cases/authentication.dart';

import 'package:faker/faker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;
  late AuthenticationParams params;
  late Map apiResult;

  setUp(() {
    params = AuthenticationParams(
        email: faker.internet.email(), secret: faker.internet.password());
    url = faker.internet.httpUrl();

    httpClient = HttpClientSpy();

    sut = RemoteAuthentication(httpClient: httpClient, url: url);
  });

  test('Should call HttpClient with correct values', () async {
    await sut.auth(params);

    verify(() => httpClient.request(
        url: url,
        method: 'post',
        body: {'email': params.email, 'password': params.secret}));
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    httpClient.mockRequestError(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    httpClient.mockRequestError(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 500', () async {
    httpClient.mockRequestError(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw InvalidCredentialsError if HttpClient returns 401',
          () async {
        httpClient.mockRequestError(HttpError.unauthorized);

        final future = sut.auth(params);

        expect(future, throwsA(DomainError.invalidCredentials));
      });

  test('Should return an Account if HttpClient returns 200', () async {
    final account = await sut.auth(params);

    expect(account.token, apiResult['accessToken']);
  });

  test(
      'Should throw UnexpectedError if HttpClient returns 200 with invalid data',
          () async {
        httpClient.mockRequest({'invalid_key': 'invalid_value'});

        final future = sut.auth(params);

        expect(future, throwsA(DomainError.unexpected));
      });
}

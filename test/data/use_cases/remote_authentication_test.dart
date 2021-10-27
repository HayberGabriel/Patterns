import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:patterns/domain/data/http/http_client.dart';
import 'package:patterns/domain/data/http/http_error.dart';
import 'package:patterns/domain/data/use_cases/remote_authentication.dart';
import 'package:patterns/domain/helpers/domain_error.dart';
import 'package:patterns/domain/use_cases/authentication.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;
  late AuthenticationParams params;

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
        email: faker.internet.email(), secret: faker.internet.password());
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    when(httpClient.request(
            url: anyNamed("url").toString(),
            method: anyNamed('method').toString(),
            body: {"oi": "oi"}))
        .thenThrow(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    when(httpClient.request(
        url: anyNamed("url").toString(),
        method: anyNamed('method').toString(),
        body: {"oi": "oi"}))
        .thenThrow(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
  test('Should throw UnexpectedError if HttpClient returns 500', () async {
    when(httpClient.request(
        url: anyNamed("url").toString(),
        method: anyNamed('method').toString(),
        body: {"oi": "oi"}))
        .thenThrow(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });

  test('Should throw UnexpectedError if HttpClient returns 401', () async {
    when(httpClient.request(
        url: anyNamed("url").toString(),
        method: anyNamed('method').toString(),
        body: {"oi": "oi"}))
        .thenThrow(HttpError.unauthorized);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.invalidCredencials));
  });
}

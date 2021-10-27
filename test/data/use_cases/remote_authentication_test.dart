import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:patterns/data/http/http_client.dart';
import 'package:patterns/data/http/http_error.dart';
import 'package:patterns/data/use_cases/remote_authentication.dart';
import 'package:patterns/domain/helpers/domain_error.dart';
import 'package:patterns/domain/use_cases/authentication.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  late RemoteAuthentication sut;
  late HttpClientSpy httpClient;
  late String url;
  late AuthenticationParams params;

  setUp(() {
    params = AuthenticationParams(
        email: faker.internet.email(), secret: faker.internet.password());
    url = faker.internet.httpUrl();
    httpClient = HttpClientSpy();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    when(httpClient.request(
        url: 'url',
        method: 'method',
        body: {"test": "test"}))
        .thenThrow(HttpError.badRequest);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    when(httpClient.request(
        url: 'url',
        method: 'method',
        body: {"test": "test"}))
        .thenThrow(HttpError.notFound);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
  test('Should throw UnexpectedError if HttpClient returns 500', () async {
    when(httpClient.request(
        url: 'url',
        method: 'method',
        body: {"test": "test"}))
        .thenThrow(HttpError.serverError);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
  test('Should throw InvalidCredentialsError if HttpClient returns 401', () async {
    when(httpClient.request(
        url: 'url',
        method: 'method',
        body: {"test": "test"}))
        .thenThrow(HttpError.unauthorized);

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.invalidCredencials));
  });
  test('Should return an Account if HttpClient returns 200', () async {
    final accessToken = faker.guid.guid();
    when(httpClient.request(
        url: 'url',
        method: 'method',
        body: {"test": "test"}))
        .thenAnswer((_) async =>{'accessToken': accessToken, 'name': faker.person.name()});

    final account = await sut.auth(params);

    expect(account.token, accessToken);
  });
  test('Should throw UnexpectedError if HttpClient returns 200 with invalid data', () async {
    when(httpClient.request(
            url: 'url',
            method: 'method',
            body: {"test": "test"}))
        .thenAnswer((_) async => {'invalid_key': 'invalid_value'});

    final future = sut.auth(params);

    expect(future, throwsA(DomainError.unexpected));
  });
}

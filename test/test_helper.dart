import 'dart:io';
import 'dart:async';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || invocation.memberName == #openUrl) {
      return Future.value(MockHttpClientRequest());
    }
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(MockHttpClientResponse());
    }
    if (invocation.memberName == #headers) {
      return MockHttpHeaders();
    }
    return null;
  }
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse implements HttpClientResponse {
  static const List<int> _transparentImage = [
    0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00,
    0x01, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00,
    0xff, 0xff, 0xff, 0x21, 0xf9, 0x04, 0x01, 0x00,
    0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00,
    0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x02, 0x4c,
    0x01, 0x00, 0x3b
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #statusCode) return 200;
    if (invocation.memberName == #contentLength) return _transparentImage.length;
    if (invocation.memberName == #compressionState) return HttpClientResponseCompressionState.notCompressed;
    if (invocation.memberName == #reasonPhrase) return "OK";
    if (invocation.memberName == #persistentConnection) return true;
    if (invocation.memberName == #headers) return MockHttpHeaders();
    if (invocation.memberName == #cookies) return <Cookie>[];
    if (invocation.memberName == #listen) {
      final callback = invocation.positionalArguments[0] as void Function(List<int>);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      final onError = invocation.namedArguments[#onError] as Function?;
      return Stream<List<int>>.fromIterable([_transparentImage]).listen(
        callback,
        onError: onError,
        onDone: onDone,
      );
    }
    return null;
  }
}

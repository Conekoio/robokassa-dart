# robokassa_dart

SDK для интеграции с платёжной системой **Robokassa** на Dart.
Позволяет создавать платёжные ссылки (включая JWT-интерфейс), **рекуррентные списания** (`/Merchant/Recurring`), проверять статус платежа, получать доступные способы оплаты и работать с фискальными чеками.

HTTP-транспорт — **Dio** (можно заменить на любой другой через `RobokassaHttpClient`).
Пакет не читает секреты самостоятельно: логин и пароли передаются только через `RobokassaConfig`.

## Установка

Добавьте в `pubspec.yaml`:

```yaml
dependencies:
  robokassa_dart: ^0.2.0
```

и выполните `dart pub get` (или `flutter pub get`).

## Быстрый старт

```dart
import 'package:robokassa_dart/robokassa_dart.dart';

Future<void> main() async {
  final robokassa = Robokassa(
    const RobokassaConfig(
      login: 'your_shop_login',
      password1: 'your_password_1',
      password2: 'your_password_2',
    ),
  );

  final url = await robokassa.payment.sendJwt(
    const JwtPaymentRequest(
      invId: 133765623,
      outSum: 10,
      description: 'Оплата тестового заказа',
      invoiceItems: [
        InvoiceItem(
          name: 'Тестовый товар',
          quantity: 1,
          cost: 10,
          tax: 'vat0',
          paymentMethod: 'full_payment',
          paymentObject: 'commodity',
        ),
      ],
    ),
  );

  print('Ссылка на оплату: $url');
}
```

## Конфигурация

Весь доступ к учётным данным идёт через `RobokassaConfig`. Откуда берутся секреты
(`.env`, Vault, аргументы CLI, Firebase Remote Config и т.д.) — определяет приложение.

```dart
const config = RobokassaConfig(
  login: 'shop',
  password1: 'prod_password_1',
  password2: 'prod_password_2',
  testPassword1: 'test_password_1',
  testPassword2: 'test_password_2',
  isTest: false,
  hashType: HashType.md5,
);
```

### Переопределение эндпоинтов

Для локальных стендов или мок-серверов можно передать свой `RobokassaEndpoints`:

```dart
const config = RobokassaConfig(
  login: 'shop',
  password1: 'p1',
  password2: 'p2',
  endpoints: RobokassaEndpoints(
    paymentUrl: 'https://mock.local/Merchant/Index/',
    paymentCurl: 'https://mock.local/Indexjson.aspx',
    jwtApiUrl: 'https://mock.local/CreateInvoice',
    webServiceUrl: 'https://mock.local/WebService/Service.asmx',
    invoiceInformationUrl: 'https://mock.local/GetInvoiceInformationList',
    secondCheckUrl: 'https://mock.local/Receipt/Attach',
    checkStatusUrl: 'https://mock.local/Receipt/Status',
  ),
);
```

## Сервисы

| Сервис                           | Метод                                                | Описание                                               |
| -------------------------------- | ---------------------------------------------------- | ------------------------------------------------------ |
| `robokassa.payment.sendJwt`      | `Future<String>`                                     | Рекомендуемый способ, возвращает ссылку на оплату.     |
| `robokassa.payment.sendCurl`     | `Future<String>`                                     | Создание ссылки через `Indexjson.aspx` или классический `Index.aspx` ([CurlPaymentTarget]). |
| `robokassa.payment.sendRecurringChild` | `Future<RecurringPaymentResult>`                 | Дочерний рекуррентный платёж (`PreviousInvoiceID`), см. [доку](https://docs.robokassa.ru/ru/recurring-payments). |

### Рекуррентные платежи (самостоятельная интеграция)

1. **Согласовать** услугу с Robokassa (иначе ошибки вида «рекуррент не разрешён»).
2. **Первый (материнский) платёж** — `sendCurl` с `recurring: true` и `target: CurlPaymentTarget.indexClassic` (как в официальной форме на `Merchant/Index.aspx`); в ответе ожидается редирект с `Location` на страницу оплаты.
3. **Повторные списания** — `sendRecurringChild(RecurringPaymentRequest(...))`; в подпись входит только **новый** `invoiceId`, не `previousInvoiceId`. Ответ `OK+…` означает создание операции — финальный статус смотрите по Result URL / `OpState`.

| `robokassa.webService.getPaymentMethods` | `Future<Map<String, Object?>>`               | Список доступных способов оплаты.                      |
| `robokassa.webService.opState`   | `Future<Map<String, Object?>>`                       | Состояние оплаты по `InvoiceID` (`OpStateExt`).        |
| `robokassa.status.getInvoiceInformationList` | `Future<Map<String, Object?>>`           | Список выставленных счетов с фильтрами.                |
| `robokassa.receipt.sendSecondCheck` | `Future<String>`                                  | Отправка второго чека в RoboFiscal.                    |
| `robokassa.receipt.getCheckStatus`  | `Future<Map<String, Object?>>`                    | Статус фискализации чека.                              |

## Замена HTTP-клиента

По умолчанию используется `DioRobokassaHttpClient`. Свой клиент подключается через
реализацию `RobokassaHttpClient`:

```dart
class MyHttpClient implements RobokassaHttpClient {
  @override
  Future<RobokassaHttpResponse> get(String url, {Map<String, String>? headers}) {
    // ...
  }

  @override
  Future<RobokassaHttpResponse> post(
    String url, {
    required Object body,
    Map<String, String>? headers,
    bool followRedirects = true,
  }) {
    // ...
  }
}

final robokassa = Robokassa(config, httpClient: MyHttpClient());
```

Своя реализация должна прокидывать `followRedirects` в нижележащий клиент и заполнять `RobokassaHttpResponse.headers` (в т.ч. `location` при `followRedirects: false` для классического `Index.aspx`).

Кастомный `Dio` можно пробросить в существующую реализацию:

```dart
final dio = Dio()..interceptors.add(LogInterceptor(responseBody: true));
final robokassa = Robokassa(
  config,
  httpClient: DioRobokassaHttpClient(dio: dio),
);
```

## Тестовый режим

При `isTest: true` SDK подставляет `testPassword1` / `testPassword2` и добавляет
`IsTest=1` в запросы через `Indexjson.aspx`.

## Примеры

В папке `example/` лежат самодостаточные примеры для каждого сервиса. Для запуска
задайте переменные окружения `ROBOKASSA_LOGIN`, `ROBOKASSA_PASSWORD1`,
`ROBOKASSA_PASSWORD2` и выполните:

```bash
dart run example/send_payment_jwt.dart
dart run example/send_recurring_child.dart
```

## Лицензия

MIT

import 'exceptions.dart';
import 'signature/hash_type.dart';

class RobokassaEndpoints {
  final String paymentUrl;
  final String paymentCurl;
  final String jwtApiUrl;
  final String webServiceUrl;
  final String invoiceInformationUrl;
  final String secondCheckUrl;
  final String checkStatusUrl;

  const RobokassaEndpoints({
    this.paymentUrl = 'https://auth.robokassa.ru/Merchant/Index/',
    this.paymentCurl = 'https://auth.robokassa.ru/Merchant/Indexjson.aspx',
    this.jwtApiUrl = 'https://services.robokassa.ru/InvoiceServiceWebApi/api/CreateInvoice',
    this.webServiceUrl = 'https://auth.robokassa.ru/Merchant/WebService/Service.asmx',
    this.invoiceInformationUrl = 'https://services.robokassa.ru/InvoiceServiceWebApi/api/GetInvoiceInformationList',
    this.secondCheckUrl = 'https://ws.roboxchange.com/RoboFiscal/Receipt/Attach',
    this.checkStatusUrl = 'https://ws.roboxchange.com/RoboFiscal/Receipt/Status',
  });
}

class RobokassaConfig {
  final String login;
  final String password1;
  final String password2;
  final String? testPassword1;
  final String? testPassword2;
  final bool isTest;
  final HashType hashType;
  final RobokassaEndpoints endpoints;

  const RobokassaConfig({
    required this.login,
    required this.password1,
    required this.password2,
    this.testPassword1,
    this.testPassword2,
    this.isTest = false,
    this.hashType = HashType.md5,
    this.endpoints = const RobokassaEndpoints(),
  });

  String get activePassword1 => isTest ? (testPassword1 ?? password1) : password1;

  String get activePassword2 => isTest ? (testPassword2 ?? password2) : password2;

  void validate() {
    if (login.isEmpty) {
      throw const RobokassaException('Param login is not defined');
    }
    if (password1.isEmpty) {
      throw const RobokassaException('Param password1 is not defined');
    }
    if (password2.isEmpty) {
      throw const RobokassaException('Param password2 is not defined');
    }
    if (isTest) {
      if (testPassword1 == null || testPassword1!.isEmpty) {
        throw const RobokassaException('Param testPassword1 is not defined');
      }
      if (testPassword2 == null || testPassword2!.isEmpty) {
        throw const RobokassaException('Param testPassword2 is not defined');
      }
    }
  }
}

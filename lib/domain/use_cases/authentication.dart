import 'package:flutter/cupertino.dart';
import 'package:patterns/domain/entities/account_entity.dart';

abstract class Authentication {

  Future<AccountEntity> auth({@required String email, @required String password});

}
import 'package:test/test.dart';
import 'package:errand_share/util/utils.dart';

void main(){
  test('checkLanguage(text) throws exception if text has banned words', () {
    expect(() => checkLanguage('oh crap'), throwsException);
    expect(() => checkLanguage('A lot of text then s hit a bad word.'), throwsException);
    expect(() => checkLanguage('Some words that are not bad'), isNot(throwsException));
  });
}

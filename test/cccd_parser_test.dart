import 'package:flutter_test/flutter_test.dart';
import 'package:nhatro_management/core/utils/cccd_parser.dart';

void main() {
  group('CccdParser Tests', () {
    test('Phân tích đúng chuỗi QR CCCD có CMND cũ', () {
      const raw = '079095012345|025812345|NGUYỄN HOÀNG SANG|23081996|Nam|Phường Linh Trung, TP. Thủ Đức, TP. Hồ Chí Minh|10052021';
      final result = CccdParser.parse(raw);

      expect(result.cccdNumber, '079095012345');
      expect(result.cmndNumber, '025812345');
      expect(result.fullName, 'Nguyễn Hoàng Sang');
      expect(result.birthDate, '23/08/1996');
      expect(result.gender, 'Nam');
      expect(result.address, 'Phường Linh Trung, TP. Thủ Đức, TP. Hồ Chí Minh');
      expect(result.issueDate, '10/05/2021');
    });

    test('Phân tích đúng chuỗi QR CCCD không có CMND cũ', () {
      const raw = '001201012345||TRẦN THỊ MAI|05012000|Nữ|Ba Đình, Hà Nội|15122022';
      final result = CccdParser.parse(raw);

      expect(result.cccdNumber, '001201012345');
      expect(result.cmndNumber, isNull);
      expect(result.fullName, 'Trần Thị Mai');
      expect(result.birthDate, '05/01/2000');
      expect(result.gender, 'Nữ');
      expect(result.address, 'Ba Đình, Hà Nội');
      expect(result.issueDate, '15/12/2022');
    });

    test('Ném ngoại lệ FormatException khi quét chuỗi không hợp lệ', () {
      expect(() => CccdParser.parse('https://example.com'), throwsA(isA<FormatException>()));
      expect(() => CccdParser.parse('invalid|data'), throwsA(isA<FormatException>()));
    });
  });
}

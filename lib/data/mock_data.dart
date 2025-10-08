import '../models/service.dart';
import '../models/stylist.dart';
import '../models/booking.dart';

class MockData {
  static final services = [
    Service(
      id: 1,
      name: 'Cắt tóc nam',
      price: 120000,
      duration: '30 phút',
      rating: 4.8,
      image: 'https://i.imgur.com/TkIrScD.png',
    ),
    Service(
      id: 2,
      name: 'Gội đầu massage',
      price: 80000,
      duration: '20 phút',
      rating: 4.6,
      image: 'https://i.imgur.com/b2EAg1W.png',
    ),
    Service(
      id: 3,
      name: 'Nhuộm tóc thời trang',
      price: 350000,
      duration: '60 phút',
      rating: 4.9,
      image: 'https://i.imgur.com/Kv3H3wZ.png',
    ),
  ];

  static final stylists = [
    Stylist(
      id: 1,
      name: 'Nguyễn Văn A',
      image: 'https://i.imgur.com/2nCt3Sbl.jpg',
      rating: 4.7,
      experience: '3 năm kinh nghiệm',
    ),
    Stylist(
      id: 2,
      name: 'Trần Thị B',
      image: 'https://i.imgur.com/0y8Ftya.jpg',
      rating: 4.9,
      experience: '5 năm kinh nghiệm',
    ),
  ];

  static final bookings = [
    Booking(
      id: 1,
      service: services[0],
      stylist: stylists[0],
      dateTime: DateTime.now().add(Duration(days: 1, hours: 2)),
      status: 'Đã xác nhận',
      note: 'Cắt ngắn, tạo kiểu side part',
    ),
    Booking(
      id: 2,
      service: services[2],
      stylist: stylists[1],
      dateTime: DateTime.now().add(Duration(days: 3)),
      status: 'Đang chờ xác nhận',
    ),
  ];
}

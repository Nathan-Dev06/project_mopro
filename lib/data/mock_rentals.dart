// Simple in-memory mock rental records for reporting
class MockRentals {
  /// Example rental records: map with keys: id, title, date, price
  static final List<Map<String, dynamic>> records = [
    {
      'id': 'R001',
      'title': 'Sailor Moon Outfit',
      'date': DateTime.now().subtract(Duration(days: 0)),
      'price': 75000,
    },
    {
      'id': 'R002',
      'title': 'Naruto Costume',
      'date': DateTime.now().subtract(Duration(days: 1)),
      'price': 90000,
    },
    {
      'id': 'R003',
      'title': 'Sailor Moon Outfit',
      'date': DateTime.now().subtract(Duration(days: 2)),
      'price': 75000,
    },
    {
      'id': 'R004',
      'title': 'Demon Slayer Kimono',
      'date': DateTime.now().subtract(Duration(days: 30)),
      'price': 120000,
    },
    {
      'id': 'R005',
      'title': 'Naruto Costume',
      'date': DateTime.now().subtract(Duration(days: 3)),
      'price': 90000,
    },
    {
      'id': 'R006',
      'title': 'Link Tunic',
      'date': DateTime.now().subtract(Duration(days: 15)),
      'price': 80000,
    },
    {
      'id': 'R007',
      'title': 'Sailor Moon Outfit',
      'date': DateTime.now().subtract(Duration(days: 40)),
      'price': 75000,
    },
  ];
}

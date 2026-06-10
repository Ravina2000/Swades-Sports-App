class AppUser {
  const AppUser({required this.id, required this.name});

  final String id;
  final String name;

  static const options = [
    AppUser(id: 'user-1', name: 'Alice Sharma'),
    AppUser(id: 'user-2', name: 'Bob Patel'),
    AppUser(id: 'user-3', name: 'Charlie Mehta'),
  ];
}

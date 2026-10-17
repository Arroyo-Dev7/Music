/// Lista de reproducción. Guarda solo los IDs de las canciones.
class Playlist {
  Playlist({required this.id, required this.name, List<int>? songIds})
      : songIds = songIds ?? [];

  final String id;
  String name;
  final List<int> songIds;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        songIds: (json['songIds'] as List).map((e) => e as int).toList(),
      );
}

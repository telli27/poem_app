import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/poet_provider.dart';

class PoetListScreen extends ConsumerWidget {
  const PoetListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poets = ref.watch(filteredPoetsProvider);
    final searchTerm = ref.watch(searchTermProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şairler'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Şair ara...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              onChanged: (value) {
                ref.read(searchTermProvider.notifier).state = value;
              },
              controller: TextEditingController(text: searchTerm),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: poets.length,
              itemBuilder: (context, index) {
                final poet = poets[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(
                        poet.imageUrl ?? 'assets/images/placeholder.jpg'),
                  ),
                  title: Text(poet.name),
                  subtitle: Text(
                    '${poet.birthYear} - ${poet.deathYear ?? 'Günümüz'}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PoetDetailScreen(poetId: poet.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PoetDetailScreen extends StatelessWidget {
  final String poetId;

  const PoetDetailScreen({super.key, required this.poetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şair Detayı'),
      ),
      body: Center(
        child: Text('$poetId ID\'li şairin detayları burada gösterilecek'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'feature_placeholder_bloc.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: BlocBuilder<FeaturePlaceholderBloc, FeaturePlaceholderState>(
          builder: (context, state) => Text(state.info.title),
        ),
      ),
      body: BlocBuilder<FeaturePlaceholderBloc, FeaturePlaceholderState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.info.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    if (state.info.todoItems.isNotEmpty)
                      const Text(
                        '后续待办：',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ...state.info.todoItems
                        .map(
                          (item) => ListTile(
                            leading: const Icon(Icons.check_circle_outline),
                            title: Text(item),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

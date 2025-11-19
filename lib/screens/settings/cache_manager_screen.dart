import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asmrapp/presentation/viewmodels/settings/cache_manager_viewmodel.dart';

class CacheManagerScreen extends StatelessWidget {
  const CacheManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CacheManagerViewModel()..loadCacheSize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cache Manager'),
        ),
        body: Consumer<CacheManagerViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Text(
                  viewModel.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            return ListView(
              children: [
                // 音频缓存
                ListTile(
                  title: const Text('Audio Cache'),
                  subtitle: Text(viewModel.audioCacheSizeFormatted),
                  trailing: TextButton(
                    onPressed: viewModel.isLoading 
                      ? null 
                      : () => viewModel.clearAudioCache(),
                    child: const Text('Clear'),
                  ),
                ),
                const Divider(),
                
                // 字幕缓存
                ListTile(
                  title: const Text('Subtitle Cache'),
                  subtitle: Text(viewModel.subtitleCacheSizeFormatted),
                  trailing: TextButton(
                    onPressed: viewModel.isLoading 
                      ? null 
                      : () => viewModel.clearSubtitleCache(),
                    child: const Text('Clear'),
                  ),
                ),
                const Divider(),
                
                // 总缓存大小
                ListTile(
                  title: const Text('Total Cache Size'),
                  subtitle: Text(viewModel.totalCacheSizeFormatted),
                  trailing: TextButton(
                    onPressed: viewModel.isLoading 
                      ? null 
                      : () => viewModel.clearAllCache(),
                    child: const Text('Clear All Cache'),
                  ),
                ),
                const Divider(),
                
                // 缓存说明
                const ListTile(
                  title: const Text('About Cache'),
                  subtitle: const Text(
                    'Cache is used to store recently played audio and subtitle files to improve playback speed. '
                    'The system will automatically clean up expired or excessive cache.' 
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 

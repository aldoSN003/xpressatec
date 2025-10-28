import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:xpressatec/data/models/phrase_model.dart';

class RecentPhrasesList extends StatelessWidget {
  final List<PhraseModel> phrases;

  const RecentPhrasesList({Key? key, required this.phrases}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (phrases.isEmpty) {
      return _buildEmptyState();
    }

    // Show last 10 phrases
    final recentPhrases = phrases.take(10).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentPhrases.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[200],
        ),
        itemBuilder: (context, index) {
          final phrase = recentPhrases[index];
          return _PhraseListItem(phrase: phrase);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'No hay frases recientes',
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }
}

class _PhraseListItem extends StatefulWidget {
  final PhraseModel phrase;

  const _PhraseListItem({required this.phrase});

  @override
  State<_PhraseListItem> createState() => _PhraseListItemState();
}

class _PhraseListItemState extends State<_PhraseListItem> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (widget.phrase.audioUrl == null || widget.phrase.audioUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio no disponible')),
      );
      return;
    }

    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(UrlSource(widget.phrase.audioUrl!));

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => _isPlaying = false);
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
      if (mounted) {
        setState(() => _isPlaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al reproducir audio')),
        );
      }
    }
  }

  void _stopAudio() {
    _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        widget.phrase.phrase,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: widget.phrase.words.map((word) {
              return Chip(
                label: Text(
                  word,
                  style: const TextStyle(fontSize: 11),
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Text(
            dateFormatter.format(widget.phrase.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      trailing: widget.phrase.audioUrl != null && widget.phrase.audioUrl!.isNotEmpty
          ? IconButton(
        icon: Icon(
          _isPlaying ? Icons.stop : Icons.play_arrow,
          color: Colors.blue,
        ),
        onPressed: _isPlaying ? _stopAudio : _playAudio,
      )
          : null,
    );
  }
}
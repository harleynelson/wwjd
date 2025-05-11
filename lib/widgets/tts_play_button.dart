// lib/widgets/tts_play_button.dart
// Path: lib/widgets/tts_play_button.dart

import 'package:flutter/material.dart';
import 'package:wwjd_app/services/text_to_speech_service.dart';

typedef TextProvider = Future<String?> Function();
typedef ScriptProvider<T> = Future<T?> Function();

class TtsPlayButton<T> extends StatefulWidget {
  final TextProvider? textProvider;
  final ScriptProvider<T>? scriptProvider;
  final Function(TextToSpeechService service, T scriptData)? speakScriptFunction;
  final bool isPremiumFeature;
  final bool hasPremiumAccess;
  final VoidCallback? onPremiumLockTap; // Called when a locked premium feature is tapped
  final Color? iconColor;
  final double iconSize;
  final String premiumDisabledTooltip;
  final String playingTooltip;
  final String playTooltip;

  const TtsPlayButton({
    super.key,
    this.textProvider,
    this.scriptProvider,
    this.speakScriptFunction,
    this.isPremiumFeature = false,
    required this.hasPremiumAccess,
    this.onPremiumLockTap,
    this.iconColor,
    this.iconSize = 28.0,
    this.premiumDisabledTooltip = "Unlock Premium for Audio",
    this.playingTooltip = "Stop Reading",
    this.playTooltip = "Read Aloud",
  }) : assert(textProvider != null || (scriptProvider != null && speakScriptFunction != null));

  @override
  State<TtsPlayButton<T>> createState() => _TtsPlayButtonState<T>();
}

class _TtsPlayButtonState<T> extends State<TtsPlayButton<T>> {
  final TextToSpeechService _ttsService = TextToSpeechService();
  bool _showAsPlayingOptimistic = false;
  bool _isPreparingContent = false;
  bool _isProcessingAction = false;
  late final VoidCallback _ttsSpeakingStateListener;

  @override
  void initState() {
    super.initState();
    _showAsPlayingOptimistic = _ttsService.isSpeakingNotifier.value;
    _ttsSpeakingStateListener = () {
      if (!mounted) return;
      final bool serviceIsActuallySpeaking = _ttsService.isSpeakingNotifier.value;
      if (_showAsPlayingOptimistic != serviceIsActuallySpeaking) {
        setState(() {
          _showAsPlayingOptimistic = serviceIsActuallySpeaking;
        });
      }
      if (!serviceIsActuallySpeaking) {
        if (_isPreparingContent) setState(() => _isPreparingContent = false);
        // If service stopped, we are no longer processing a play/stop action that originated from a user tap
        // This helps re-enable the button if stop was called, for example.
        if (_isProcessingAction) setState(() => _isProcessingAction = false);
      }
    };
    _ttsService.isSpeakingNotifier.addListener(_ttsSpeakingStateListener);
  }

  @override
  void dispose() {
    _ttsService.isSpeakingNotifier.removeListener(_ttsSpeakingStateListener);
    super.dispose();
  }

  Future<void> _handleTap() async {
    // If it's a premium feature, user doesn't have access, and a lock tap handler exists
    if (widget.isPremiumFeature && !widget.hasPremiumAccess) {
      widget.onPremiumLockTap?.call();
      return; // Do not proceed with play/stop logic
    }

    // Prevent re-entrant calls if an action is already being processed.
    // Exception: if it's currently playing (_showAsPlayingOptimistic is true), allow a "stop" command.
    if (_isProcessingAction && !_showAsPlayingOptimistic) {
        return;
    }


    if (!mounted) return;

    final bool desireToPlay = !_showAsPlayingOptimistic;

    setState(() {
      _showAsPlayingOptimistic = desireToPlay; // Optimistic UI update
      _isProcessingAction = true; // Mark that an action is being processed
    });

    try {
      if (desireToPlay) {
        if (mounted) setState(() { _isPreparingContent = true; });

        String? textToSpeak;
        T? scriptData;
        bool providerSuccess = false;

        try {
          if (widget.textProvider != null) {
            textToSpeak = await widget.textProvider!();
            if (textToSpeak != null && textToSpeak.isNotEmpty) providerSuccess = true;
          } else if (widget.scriptProvider != null) {
            scriptData = await widget.scriptProvider!();
            if (scriptData != null) providerSuccess = true;
          }
        } catch (e) {
          print("Error in TtsPlayButton provider: $e");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error preparing content: ${e.toString()}")));
          providerSuccess = false;
        } finally {
          if (mounted) setState(() { _isPreparingContent = false; });
        }

        if (providerSuccess) {
          // Only proceed to play if our optimistic UI still wants to play
          // (i.e., user hasn't tapped "stop" very quickly after "play")
          if (mounted && _showAsPlayingOptimistic) {
            if (widget.textProvider != null && textToSpeak != null) {
              await _ttsService.speak(textToSpeak);
            } else if (widget.scriptProvider != null && widget.speakScriptFunction != null && scriptData != null) {
              await widget.speakScriptFunction!(_ttsService, scriptData);
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No content to read.")));
            if (_showAsPlayingOptimistic) { // Revert optimistic UI if tried to play but no content
              setState(() { _showAsPlayingOptimistic = false; });
            }
          }
        }
      } else { // desireToPlay is false, so user wants to stop
        await _ttsService.stop();
        // The listener for isSpeakingNotifier will update _showAsPlayingOptimistic.
      }
    } catch (e) {
      print("Error in TtsPlayButton _handleTap (service call): $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error with audio operation: ${e.toString()}")));
        // Revert optimistic UI to actual service state on error
        setState(() { _showAsPlayingOptimistic = _ttsService.isSpeakingNotifier.value; });
      }
    } finally {
      if (mounted) {
        setState(() { _isProcessingAction = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.iconColor ?? Theme.of(context).iconTheme.color;
    final bool isEffectivelyLocked = widget.isPremiumFeature && !widget.hasPremiumAccess;

    IconData currentIconData = _showAsPlayingOptimistic
        ? Icons.pause_circle_filled_outlined
        : Icons.play_circle_fill_outlined;

    String currentTooltip = _showAsPlayingOptimistic ? widget.playingTooltip : widget.playTooltip;
    if (isEffectivelyLocked) {
      currentTooltip = widget.premiumDisabledTooltip;
    }

    return SizedBox( // Constrain the size of the tappable area and Stack
      width: widget.iconSize + 16.0, // IconButton default padding is 8.0 on each side
      height: widget.iconSize + 16.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              currentIconData,
              color: isEffectivelyLocked ? effectiveIconColor?.withOpacity(0.5) : effectiveIconColor,
              size: widget.iconSize,
            ),
            tooltip: currentTooltip,
            onPressed: _handleTap, // Tap handler now checks for premium lock first
            padding: EdgeInsets.zero, // Use SizedBox for sizing control
            splashRadius: widget.iconSize, // Adjust splash radius
          ),
          // Loading spinner overlay (only during initial content prep for a play action)
          if (_isPreparingContent)
            Positioned.fill(
              child: Center(
                child: IgnorePointer( // Spinner doesn't block taps on the underlying IconButton
                  child: SizedBox(
                    width: widget.iconSize + 6,
                    height: widget.iconSize + 6,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5, // Thinner stroke for overlay
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveIconColor?.withOpacity(0.6) ?? Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          // Lock icon overlay if feature is premium and not accessible
          if (isEffectivelyLocked)
            Positioned(
              bottom: 0,
              right: 0,
              child: IgnorePointer(
                child: Icon(
                  Icons.lock_rounded,
                  size: widget.iconSize * 0.5, // Smaller lock icon
                  color: effectiveIconColor?.withOpacity(0.8) ?? Colors.grey.shade700,
                  shadows: [Shadow(color: Theme.of(context).colorScheme.background.withOpacity(0.7), blurRadius: 2.0, offset: Offset(0.5,0.5))],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
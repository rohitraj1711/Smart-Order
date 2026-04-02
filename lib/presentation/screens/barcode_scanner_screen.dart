import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smart_order/core/utils/helpers.dart';
import 'package:smart_order/presentation/providers/order_provider.dart';

/// Full-screen barcode scanner using [mobile_scanner].
/// Validates barcodes (even last digit = valid) and looks up products.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late final MobileScannerController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);

    // Stop the scanner while we process / show dialog
    _controller.stop();

    final provider = context.read<OrderProvider>();
    await provider.processScanResult(rawValue);

    if (!mounted) return;

    final isSuccess = provider.scanSuccess;
    final message = provider.scanMessage ?? '';

    // Show result dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          isSuccess ? Icons.check_circle : Icons.error_outline,
          color: isSuccess ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(isSuccess ? 'Product Found!' : 'Scan Issue'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
              if (isSuccess) Navigator.pop(context); // go back to home
            },
            child: Text(isSuccess ? 'Back to Order' : 'Try Again'),
          ),
          if (!isSuccess)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // close dialog
                Navigator.pop(context); // go back to home
              },
              child: const Text('Cancel'),
            ),
        ],
      ),
    );

    // After dialog closes: if we're still on this screen, restart scanner
    provider.clearScanMessage();
    if (mounted) {
      setState(() => _isProcessing = false);
      _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, state, __) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay
          _ScannerOverlay(theme: theme),

          // Manual entry section at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ManualEntrySection(
              onSubmit: (code) {
                if (code.isNotEmpty) _onDetectManual(code);
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDetectManual(String barcode) async {
    if (_isProcessing) return;
    // Reuse the same processing logic
    setState(() => _isProcessing = true);

    final provider = context.read<OrderProvider>();
    await provider.processScanResult(barcode);

    if (!mounted) return;

    final isSuccess = provider.scanSuccess;
    final message = provider.scanMessage ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );

    if (isSuccess) {
      Navigator.pop(context);
    }

    provider.clearScanMessage();
    setState(() => _isProcessing = false);
  }
}

/// Camera overlay with viewfinder frame.
class _ScannerOverlay extends StatelessWidget {
  final ThemeData theme;

  const _ScannerOverlay({required this.theme});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Instructions
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'Point camera at barcode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Barcode must end with an even digit to be valid',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for manual barcode entry.
class _ManualEntrySection extends StatefulWidget {
  final ValueChanged<String> onSubmit;

  const _ManualEntrySection({required this.onSubmit});

  @override
  State<_ManualEntrySection> createState() => _ManualEntrySectionState();
}

class _ManualEntrySectionState extends State<_ManualEntrySection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Or enter barcode manually',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter barcode number',
                    prefixIcon: Icon(Icons.dialpad),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () {
                  widget.onSubmit(_controller.text.trim());
                  _controller.clear();
                },
                child: const Text('Look Up'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Validation hint
          Builder(
            builder: (context) {
              final text = _controller.text;
              if (text.isEmpty) return const SizedBox.shrink();
              final valid = Helpers.isBarcodeValid(text);
              return Row(
                children: [
                  Icon(
                    valid ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: valid ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    valid ? 'Valid barcode format' : 'Invalid — last digit must be even',
                    style: TextStyle(
                      fontSize: 12,
                      color: valid ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

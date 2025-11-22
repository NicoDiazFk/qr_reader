import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';
import 'package:qr_reader/utils/utils.dart';

class ScanTiles extends StatefulWidget {
  final String tipo;

  const ScanTiles({super.key, required this.tipo});

  @override
  State<ScanTiles> createState() => _ScanTilesState();
}

class _ScanTilesState extends State<ScanTiles> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    setState(() => _isLoading = true);
    await Provider.of<ScanListProvider>(
      context,
      listen: false,
    ).cargarScanPorTipo(widget.tipo);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scanListProvider = Provider.of<ScanListProvider>(context);
    final scansFiltrados = scanListProvider.scans;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scansFiltrados.isEmpty) {
      return const Center(child: Text('No hay elementos para mostrar'));
    }

    return ListView.builder(
      itemCount: scansFiltrados.length,
      itemBuilder: (_, i) => Dismissible(
        key: UniqueKey(),
        background: Container(color: Colors.red),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('¿Seguro que quieres borrar esto?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Borrar'),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) async {
          final scanId = scansFiltrados[i].id;
          if (scanId != null) {
            await Provider.of<ScanListProvider>(
              context,
              listen: false,
            ).borrarScanPorId(scanId);
          }
        },
        child: ListTile(
          leading: Icon(
            chooseIconType(widget.tipo),
            color: Theme.of(context).primaryColor,
          ),
          title: Text(scansFiltrados[i].valor),
          subtitle: Text(scansFiltrados[i].id?.toString() ?? ''),
          trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          onTap: () {
            launchURL(context, scansFiltrados[i]);
          },
        ),
      ),
    );
  }

  IconData chooseIconType(String tipo) {
    switch (tipo) {
      case 'http':
        return Icons.link;
      case 'geo':
        return Icons.map_outlined;
      case 'otro':
        return Icons.more;
      default:
        return Icons.link;
    }
  }
}

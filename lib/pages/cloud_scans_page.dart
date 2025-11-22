import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';
import 'package:qr_reader/providers/user_provider.dart';
import 'package:qr_reader/utils/utils.dart';

class CloudScansPage extends StatefulWidget {
  const CloudScansPage({super.key});

  @override
  State<CloudScansPage> createState() => _CloudScansPageState();
}

class _CloudScansPageState extends State<CloudScansPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCloudScans();
  }

  Future<void> _loadCloudScans() async {
    setState(() => _isLoading = true);
    await Provider.of<ScanListProvider>(
      context,
      listen: false,
    ).loadScansFromCloud();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scanListProvider = Provider.of<ScanListProvider>(context);
    final cloudScans = scanListProvider.cloudScans;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cloudScans.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Scans en la nube',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,

          backgroundColor: Colors.deepPurple,
        ),
        body: Center(child: Text('No hay elementos para mostrar')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Scans en la nube', style: TextStyle(color: Colors.white)),
        centerTitle: true,

        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: cloudScans.length,
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
            final scanId = cloudScans[i].id;
            if (scanId != null) {
              await Provider.of<ScanListProvider>(
                context,
                listen: false,
              ).borrarScanEnNube(scanId);
            }
          },
          child: ListTile(
            leading: Icon(
              chooseIconType(cloudScans[i].tipo),
              color: Theme.of(context).primaryColor,
            ),
            title: Text(cloudScans[i].valor),
            subtitle: Text(cloudScans[i].id?.toString() ?? ''),
            trailing: const Icon(
              Icons.keyboard_arrow_right,
              color: Colors.grey,
            ),
            onTap: () {
              launchURL(context, cloudScans[i]);
            },
          ),
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

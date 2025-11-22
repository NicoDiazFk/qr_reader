//fls
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/pages/cloud_scans_page.dart';
import 'package:qr_reader/pages/login_page.dart';
import 'package:qr_reader/pages/pages_barrel.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';
import 'package:qr_reader/providers/ui_provider.dart';
import 'package:qr_reader/providers/user_provider.dart';
import 'package:qr_reader/widgets/custom_navigatorbar.dart';
import 'package:qr_reader/widgets/scan_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Historial', style: TextStyle(color: Colors.white)),
        centerTitle: true,

        backgroundColor: Colors.deepPurple,

        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () async {
              if (Provider.of<ScanListProvider>(
                context,
                listen: false,
              ).scans.isEmpty) {
                return;
              }

              bool confirmation = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(
                    '¿Seguro que quieres borrar todos los elementos de la lista?',
                  ),
                  content: const Text(
                    'Serán guardados en la nube.',
                    style: TextStyle(fontSize: 14),
                  ),
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
              if (confirmation) {
                if (!context.mounted) return;
                bool ok = await Provider.of<ScanListProvider>(
                  context,
                  listen: false,
                ).borrarTodos();

                if (!context.mounted) return;
                if (ok) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Datos guardados'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Error al guardar'),
                      content: const Text(
                        'No se han podido guardar los datos en la nube.\nNo serán borrados.',
                        style: TextStyle(fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.cloud, color: Colors.white),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CloudScansPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              Provider.of<UserProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),

      body: _HomePageBody(),

      bottomNavigationBar: CustomNavigatorbar(),

      floatingActionButton: ScanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _HomePageBody extends StatelessWidget {
  const _HomePageBody();

  @override
  Widget build(BuildContext context) {
    // Obtener el selected menu opt
    final uiProvider = Provider.of<UiProvider>(context);

    // Cambiar para mostrar la pagina respectiva
    final currentIndex = uiProvider.selectedMenuOpt;

    // Usar el ScanListProvider
    //final scanListProvider = Provider.of<ScanListProvider>(context, listen: false);

    switch (currentIndex) {
      case 0:
        //scanListProvider.cargarScanPorTipo('geo');
        return UbicacionesPage();

      case 1:
        //scanListProvider.cargarScanPorTipo('http');
        return DireccionesPage();

      case 2:
        //scanListProvider.cargarScanPorTipo('http');
        return OtraPage();

      default:
        return UbicacionesPage();
    }
  }
}

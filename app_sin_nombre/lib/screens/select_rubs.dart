import 'package:flutter/material.dart';
import 'package:app_sin_nombre/services/home_service.dart';
import 'package:app_sin_nombre/models/rub.dart';

Future<String?> mostrarSelectorRubro(BuildContext context) async {
  final rubros = await TargetService().getRubros();

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Text(
              'Seleccioná un rubro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: rubros.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final rubro = rubros[index];
                  return ListTile(
                    leading:
                        rubro.icono.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                rubro.icono,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                              ),
                            )
                            : const Icon(Icons.category),
                    title: Text(
                      rubro.nombre,
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () => Navigator.pop(context, rubro.id),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

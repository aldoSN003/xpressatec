import 'package:flutter/material.dart';
import 'teacch_card_widget.dart';

class BoardGrid extends StatelessWidget {
  final List<TeacchCardWidget> cards;

  const BoardGrid({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    // El LayoutBuilder ya no es necesario, el nuevo delegate maneja la responsividad.
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      
      // --- CAMBIO CLAVE: Usamos un delegate similar al de tu ejemplo ---
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        // maxCrossAxisExtent: Define el ancho máximo de cada tarjeta.
        // Flutter creará tantas columnas como quepan en el espacio disponible.
        // Por ejemplo, en un teléfono de 400px de ancho, cabrán 2 columnas (400 / 200 = 2).
        // En una tablet de 900px, cabrán 4 columnas (900 / 200 = 4.5 -> 4).
        maxCrossAxisExtent: 200.0,

        // mainAxisExtent: Fija la altura de cada tarjeta para mantener la consistencia.
        mainAxisExtent: 220.0,

        crossAxisSpacing: 16.0, // Espacio horizontal.
        mainAxisSpacing: 16.0,  // Espacio vertical.
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return cards[index];
      },
    );
  }
}
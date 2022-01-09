import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:great_places/screens/map_screen.dart';
import 'package:great_places/utils/location_util.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPosition;

  const LocationInput({Key? key, required this.onSelectPosition})
      : super(key: key);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  Future<void> _getCurrentUserLocation() async {
    try {
      final locData = await Location().getLocation();
      final LatLng position = new LatLng(locData.latitude!, locData.longitude!);
      _showPreview(position);

      widget.onSelectPosition(position);
    } catch (e) {
      return;
    }
  }

  void _showPreview(LatLng position) {
    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    print(staticMapImageUrl);
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  Future<void> _selectOnMap() async {
    final LatLng? selectedPosition = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(),
      ),
    );

    if (selectedPosition == null) return;

    _showPreview(selectedPosition);

    widget.onSelectPosition(selectedPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: _previewImageUrl == null
              ? Text('Localização não informada')
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextButton.icon(
                icon: Icon(Icons.location_on),
                label: Text('Localização Atual'),
                onPressed: _getCurrentUserLocation,
              ),
            ),
            Expanded(
              child: TextButton.icon(
                icon: Icon(Icons.map),
                label: Text('Selecione no Mapa'),
                onPressed: _selectOnMap,
              ),
            ),
          ],
        )
      ],
    );
  }
}

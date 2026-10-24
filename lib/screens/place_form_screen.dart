import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../models/place_category.dart';
import '../providers/places_provider.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../utils/formatters.dart';
import '../utils/snackbars.dart';
import '../widgets/photo_picker_field.dart';
import '../widgets/rating_stars.dart';

/// Form for adding a new place, or editing [place] when it is given.
/// Pops with the saved [Place].
class PlaceFormScreen extends StatefulWidget {
  const PlaceFormScreen({super.key, this.place});

  final Place? place;

  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final _locationService = LocationService();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late PlaceCategory _category;
  late int _rating;
  DateTime? _visitedAt;

  /// Photo already stored on the server.
  String? _existingPhoto;

  /// Newly picked photo, uploaded on save.
  Uint8List? _newPhotoBytes;
  String? _newPhotoName;

  bool _isLocating = false;
  bool _isSaving = false;

  bool get _isEditing => widget.place != null;

  @override
  void initState() {
    super.initState();
    final place = widget.place;
    _nameController = TextEditingController(text: place?.name);
    _descriptionController = TextEditingController(text: place?.description);
    _latitudeController = TextEditingController(
      text: place?.latitude?.toString(),
    );
    _longitudeController = TextEditingController(
      text: place?.longitude?.toString(),
    );
    _category = place?.category ?? PlaceCategory.nature;
    _rating = place?.rating ?? 3;
    _visitedAt =
        place?.visitedAt ??
        (place == null ? DateUtils.dateOnly(DateTime.now()) : null);
    _existingPhoto = place?.photo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = _visitedAt == null || _visitedAt!.isAfter(today)
        ? today
        : _visitedAt!;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: today,
      helpText: 'Dátum návštevy',
    );
    if (picked != null) setState(() => _visitedAt = picked);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await _locationService.getCurrentPosition();
      _latitudeController.text = position.latitude.toStringAsFixed(6);
      _longitudeController.text = position.longitude.toStringAsFixed(6);
      if (mounted) showMessage(context, 'Poloha bola načítaná.');
    } on LocationException catch (e) {
      if (mounted) showMessage(context, e.message);
    } catch (_) {
      if (mounted) showMessage(context, 'Polohu sa nepodarilo zistiť.');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _newPhotoBytes = bytes;
        _newPhotoName = file.name;
      });
    } catch (_) {
      if (mounted) showMessage(context, 'Fotku sa nepodarilo načítať.');
    }
  }

  void _removePhoto() {
    setState(() {
      _newPhotoBytes = null;
      _newPhotoName = null;
      _existingPhoto = null;
    });
  }

  double? _parseCoordinate(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  String? _validateCoordinate(String? value, String? otherValue, double limit) {
    final text = value?.trim() ?? '';
    final otherText = otherValue?.trim() ?? '';

    if (text.isEmpty) {
      return otherText.isEmpty ? null : 'Zadajte obe súradnice';
    }
    final number = _parseCoordinate(text);
    if (number == null || number.abs() > limit) {
      return 'Číslo od -$limit do $limit';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final place = Place(
      id: widget.place?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      rating: _rating,
      latitude: _parseCoordinate(_latitudeController.text),
      longitude: _parseCoordinate(_longitudeController.text),
      photo: _existingPhoto,
      isFavorite: widget.place?.isFavorite ?? false,
      visitedAt: _visitedAt,
    );

    setState(() => _isSaving = true);
    try {
      final saved = await context.read<PlacesProvider>().savePlace(
        place,
        photoBytes: _newPhotoBytes,
        photoName: _newPhotoName,
      );
      if (mounted) Navigator.pop(context, saved);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showMessage(context, e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Upraviť miesto' : 'Nové miesto'),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PhotoPickerField(
                  category: _category,
                  photoBytes: _newPhotoBytes,
                  photo: _existingPhoto,
                  onPickFromGallery: _pickPhoto,
                  onRemove: _removePhoto,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Názov *',
                    prefixIcon: Icon(Icons.place_outlined),
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Zadajte názov miesta'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Popis',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 2000,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<PlaceCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Kategória',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final category in PlaceCategory.values)
                      DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(category.icon, color: category.color),
                            const SizedBox(width: 12),
                            Text(category.label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 24),
                Text('Hodnotenie', style: textTheme.titleMedium),
                RatingStars(
                  rating: _rating,
                  size: 32,
                  onChanged: (value) => setState(() => _rating = value),
                ),
                const SizedBox(height: 16),
                Text('Dátum návštevy', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event_outlined),
                        label: Text(
                          _visitedAt == null
                              ? 'Vybrať dátum'
                              : formatDate(_visitedAt!),
                        ),
                      ),
                    ),
                    if (_visitedAt != null)
                      IconButton(
                        tooltip: 'Zrušiť dátum',
                        onPressed: () => setState(() => _visitedAt = null),
                        icon: const Icon(Icons.clear),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Poloha', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Zemepisná šírka',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) => _validateCoordinate(
                          value,
                          _longitudeController.text,
                          90,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Zemepisná dĺžka',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) => _validateCoordinate(
                          value,
                          _latitudeController.text,
                          180,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: _isLocating ? null : _useCurrentLocation,
                    icon: _isLocating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('Použiť aktuálnu polohu'),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isEditing ? 'Uložiť zmeny' : 'Pridať miesto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

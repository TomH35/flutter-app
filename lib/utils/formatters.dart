String formatDate(DateTime date) => '${date.day}. ${date.month}. ${date.year}';

String formatCoordinates(double latitude, double longitude) =>
    '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

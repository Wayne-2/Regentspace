String formatTime(String timestamp) {
  final date = DateTime.tryParse(timestamp);
  if (date == null) return timestamp;

  final diff = DateTime.now().difference(date);

  if (diff.inSeconds < 60) return "Just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hrs ago";
  if (diff.inDays < 7) return "${diff.inDays} days ago";

  return "${date.day}/${date.month}/${date.year}";
}

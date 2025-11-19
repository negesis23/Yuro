enum MarkStatus {
  wantToListen('Plan to Listen'),
  listening('Listening'),
  listened('Listened'),
  relistening('Re-listening'),
  onHold('On Hold');
  
  final String label;
  const MarkStatus(this.label);
}

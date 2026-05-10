import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../model/event.dart';
import '../model/registration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ApiService _api = ApiService();
  Event? event;
  List<Registration> registrations = [];
  bool loading = true;
  bool submitting = false;
  bool editing = false;
  String successMessage = '';
  String errorMessage = '';
  String token = '';

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    try {
      final e = await _api.getEvent(widget.eventId);
      final r = await _api.getRegistrations(widget.eventId);
      setState(() {
        event = e;
        registrations = r;
        loading = false;
        _titleCtrl.text = e.title;
        _locationCtrl.text = e.location;
        _capacityCtrl.text = e.capacity.toString();
        _descCtrl.text = e.description ?? '';
      });
    } catch (e) {
      setState(() { loading = false; });
    }
  }

  Future<void> onSubmit() async {
    if (event == null) return;
    setState(() { submitting = true; successMessage = ''; errorMessage = ''; });
    try {
      final reg = await _api.register(event!.id, _firstNameCtrl.text, _lastNameCtrl.text, _emailCtrl.text);
      setState(() {
        registrations.add(reg);
        successMessage = 'Inscription réussie !';
        _firstNameCtrl.clear(); _lastNameCtrl.clear(); _emailCtrl.clear();
        submitting = false;
      });
      await loadData();
    } on Exception catch (e) {
      String msg = 'Une erreur est survenue.';
      if (e.toString().contains('409')) msg = 'Email déjà inscrit.';
      if (e.toString().contains('422')) msg = 'Événement complet.';
      setState(() { errorMessage = msg; submitting = false; });
    }
  }

  Future<void> deleteRegistration(int id) async {
    await _api.deleteRegistration(id);
    await loadData();
  }

  Future<void> deleteEvent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Supprimer cet événement et toutes ses inscriptions ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.deleteEvent(event!.id, token);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { errorMessage = 'Erreur lors de la suppression.'; });
    }
  }

  Future<void> updateEvent() async {
    try {
      await _api.updateEvent(event!.id, {
        'title': _titleCtrl.text,
        'location': _locationCtrl.text,
        'capacity': int.tryParse(_capacityCtrl.text) ?? event!.capacity,
        'description': _descCtrl.text,
      }, token);
      setState(() { editing = false; successMessage = 'Événement mis à jour.'; });
      await loadData();
    } catch (e) {
      setState(() { errorMessage = 'Erreur lors de la mise à jour.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(event?.title ?? 'Détail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: token.isNotEmpty && event != null ? [
          IconButton(icon: Icon(editing ? Icons.close : Icons.edit, color: Colors.indigo), onPressed: () => setState(() { editing = !editing; })),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: deleteEvent),
        ] : [],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (successMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                child: Text(successMessage, style: TextStyle(color: Colors.green[700])),
              ),
            if (errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: Text(errorMessage, style: TextStyle(color: Colors.red[700])),
              ),

            // Infos ou formulaire edit
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: editing ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modifier l\'événement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: _titleCtrl, decoration: _inputDeco('Titre')),
                  const SizedBox(height: 8),
                  TextField(controller: _locationCtrl, decoration: _inputDeco('Lieu')),
                  const SizedBox(height: 8),
                  TextField(controller: _capacityCtrl, decoration: _inputDeco('Capacité'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  TextField(controller: _descCtrl, decoration: _inputDeco('Description'), maxLines: 3),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: updateEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Sauvegarder'),
                    ),
                  ),
                ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('LIEU: ${event!.location}', style: TextStyle(color: Colors.grey[600])),
                  Text('DATE: ${event!.date.substring(0, 10)}', style: TextStyle(color: Colors.grey[600])),
                  if (event!.description != null && event!.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(event!.description!, style: const TextStyle(fontSize: 14)),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: event!.isComplet ? Colors.red[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event!.isComplet ? 'Complet' : '${event!.placesRestantes} / ${event!.capacity} places restantes',
                      style: TextStyle(
                        color: event!.isComplet ? Colors.red[700] : Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Participants
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Participants (${registrations.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (registrations.isEmpty)
                    Text('Aucun participant.', style: TextStyle(color: Colors.grey[500]))
                  else
                    ...registrations.map((reg) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${reg.firstName} ${reg.lastName}'),
                      subtitle: Text(reg.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => deleteRegistration(reg.id),
                      ),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Formulaire inscription
            if (!event!.isComplet)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("S'inscrire", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(controller: _firstNameCtrl, decoration: _inputDeco('Prénom')),
                    const SizedBox(height: 8),
                    TextField(controller: _lastNameCtrl, decoration: _inputDeco('Nom')),
                    const SizedBox(height: 8),
                    TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: _inputDeco('Email')),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitting ? null : onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(submitting ? 'Inscription...' : "S'inscrire"),
                      ),
                    ),
                  ],
                ),
              ),
            if (event!.isComplet)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(16)),
                child: Text('Cet événement est complet.', style: TextStyle(color: Colors.red[700])),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
    );
  }
}
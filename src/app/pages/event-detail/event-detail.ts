import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { DatePipe } from '@angular/common';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { EventService, Event, Registration } from '../../services/event';

@Component({
  selector: 'app-event-detail',
  standalone: true,
  imports: [RouterLink, FormsModule, DatePipe],
  templateUrl: './event-detail.html',
  styleUrl: './event-detail.css'
})
export class EventDetailComponent implements OnInit {
  event: Event | null = null;
  registrations: Registration[] = [];
  loading = true;
  submitting = false;
  editing = false;
  successMessage = '';
  errorMessage = '';
  form = { firstName: '', lastName: '', email: '' };
  editForm = { title: '', description: '', date: '', location: '', capacity: 1 };

  constructor(
    private route: ActivatedRoute,
    private router: Router,
    private eventService: EventService,
    private cdr: ChangeDetectorRef
  ) {}

  get token(): string { return localStorage.getItem('token') ?? ''; }
  get isLoggedIn(): boolean { return !!this.token; }

  ngOnInit() {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    this.eventService.getEvent(id).subscribe({
      next: (data) => {
        this.event = data;
        this.loading = false;
        this.editForm = {
          title: data.title,
          description: data.description ?? '',
          date: data.date,
          location: data.location,
          capacity: data.capacity
        };
        this.loadRegistrations(id);
        this.cdr.detectChanges();
      },
      error: () => { this.loading = false; this.cdr.detectChanges(); }
    });
  }

  loadRegistrations(id: number) {
    this.eventService.getRegistrations(id).subscribe({
      next: (data) => { this.registrations = data; this.cdr.detectChanges(); },
      error: () => {}
    });
  }

  getPlacesRestantes(): number {
    if (!this.event) return 0;
    return this.event.capacity - (this.event.inscriptions_count ?? 0);
  }

  isComplet(): boolean { return this.getPlacesRestantes() <= 0; }

  deleteEvent() {
    if (!this.event) return;
    if (!confirm('Supprimer cet événement et toutes ses inscriptions ?')) return;
    this.eventService.deleteEvent(this.event.id, this.token).subscribe({
      next: () => this.router.navigate(['/']),
      error: (err) => {
        if (err.status === 401) this.router.navigate(['/auth']);
        else this.errorMessage = 'Erreur lors de la suppression.';
        this.cdr.detectChanges();
      }
    });
  }

  updateEvent() {
    if (!this.event) return;
    this.eventService.updateEvent(this.event.id, this.editForm, this.token).subscribe({
      next: (data) => {
        this.event = { ...this.event!, ...data };
        this.editing = false;
        this.successMessage = 'Événement mis à jour.';
        this.cdr.detectChanges();
      },
      error: (err) => {
        if (err.status === 401) this.router.navigate(['/auth']);
        else this.errorMessage = 'Erreur lors de la mise à jour.';
        this.cdr.detectChanges();
      }
    });
  }

  deleteRegistration(regId: number) {
    this.eventService.deleteRegistration(regId).subscribe({
      next: () => {
        this.registrations = this.registrations.filter(r => r.id !== regId);
        if (this.event) this.event.inscriptions_count = Math.max(0, (this.event.inscriptions_count ?? 0) - 1);
        this.cdr.detectChanges();
      },
      error: () => {}
    });
  }

  onSubmit() {
    if (!this.event) return;
    this.submitting = true;
    this.successMessage = '';
    this.errorMessage = '';

    this.eventService.register(this.event.id, this.form).subscribe({
      next: (reg) => {
        this.successMessage = 'Inscription réussie !';
        this.form = { firstName: '', lastName: '', email: '' };
        if (this.event) this.event.inscriptions_count = (this.event.inscriptions_count ?? 0) + 1;
        this.registrations.push(reg);
        this.submitting = false;
        this.cdr.detectChanges();
      },
      error: (err) => {
        const body = err.error;
        if (body?.error === 'DUPLICATE_EMAIL') this.errorMessage = 'Email déjà inscrit.';
        else if (body?.error === 'CAPACITY_REACHED') this.errorMessage = 'Événement complet.';
        else this.errorMessage = 'Une erreur est survenue.';
        this.submitting = false;
        this.cdr.detectChanges();
      }
    });
  }
}

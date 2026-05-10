import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { EventService } from '../../services/event';

@Component({
  selector: 'app-event-create',
  standalone: true,
  imports: [CommonModule, RouterLink, FormsModule],
  templateUrl: './event-create.html',
  styleUrl: './event-create.css'
})
export class EventCreateComponent {
  submitting = false;
  errorMessage = '';
  token = localStorage.getItem('token') ?? '';

  form = {
    title: '',
    description: '',
    date: '',
    location: '',
    capacity: 1
  };

  constructor(private eventService: EventService, private router: Router) {}

  onSubmit() {
    if (!this.token) {
      this.errorMessage = 'Vous devez être connecté pour créer un événement.';
      return;
    }
    this.submitting = true;
    this.errorMessage = '';

    this.eventService.createEvent(this.form, this.token).subscribe({
      next: () => this.router.navigate(['/']),
     error: (err) => {
  if (err.status === 401) {
    this.router.navigate(['/auth']);
  } else {
    this.errorMessage = err.error?.message ?? 'Erreur lors de la création.';
  }
  this.submitting = false;
}
    });


  }
}

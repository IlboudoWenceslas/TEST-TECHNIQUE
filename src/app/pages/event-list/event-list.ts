import { Component, OnInit, ChangeDetectorRef } from '@angular/core';
import { DatePipe } from '@angular/common';
import { RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { EventService, Event } from '../../services/event';

@Component({
  selector: 'app-event-list',
  standalone: true,
  imports: [RouterLink, FormsModule, DatePipe],
  templateUrl: './event-list.html',
  styleUrl: './event-list.css'
})
export class EventListComponent implements OnInit {
  events: Event[] = [];
  loading = true;
  search = '';

  constructor(private eventService: EventService, private cdr: ChangeDetectorRef) {}

  ngOnInit() { this.loadEvents(); }

  loadEvents() {
    this.eventService.getEvents(this.search).subscribe({
      next: (data) => { this.events = data; this.loading = false; this.cdr.detectChanges(); },
      error: () => { this.loading = false; this.cdr.detectChanges(); }
    });
  }

  getPlacesRestantes(event: Event): number {
    return event.capacity - (event.inscriptions_count ?? 0);
  }

  isComplet(event: Event): boolean { return this.getPlacesRestantes(event) <= 0; }

  get token(): string { return localStorage.getItem('token') ?? ''; }
  get isLoggedIn(): boolean { return !!this.token; }
}

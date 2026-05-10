import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface Event {
  id: number;
  title: string;
  description?: string;
  date: string;
  location: string;
  capacity: number;
  createdAt: string;
  inscriptions_count?: number;
}

export interface Registration {
  id: number;
  eventId: number;
  firstName: string;
  lastName: string;
  email: string;
  registeredAt: string;
}

@Injectable({
  providedIn: 'root'
})
export class EventService {
  private apiUrl = 'http://127.0.0.1:8000/api';

  constructor(private http: HttpClient) {}

  getEvents(search?: string, date?: string): Observable<Event[]> {
    let params = new HttpParams();
    if (search) params = params.set('search', search);
    if (date) params = params.set('date', date);
    return this.http.get<Event[]>(`${this.apiUrl}/events`, { params });
  }

  getEvent(id: number): Observable<Event> {
    return this.http.get<Event>(`${this.apiUrl}/events/${id}`);
  }

  createEvent(data: Partial<Event>, token: string): Observable<Event> {
    return this.http.post<Event>(`${this.apiUrl}/events`, data, {
      headers: { Authorization: `Bearer ${token}` }
    });
  }

  getRegistrations(eventId: number): Observable<Registration[]> {
    return this.http.get<Registration[]>(`${this.apiUrl}/events/${eventId}/registrations`);
  }

  register(eventId: number, data: { firstName: string; lastName: string; email: string }): Observable<Registration> {
    return this.http.post<Registration>(`${this.apiUrl}/events/${eventId}/register`, data);
  }

  deleteEvent(id: number, token: string): Observable<any> {
    return this.http.delete(`${this.apiUrl}/events/${id}`, {
      headers: { Authorization: `Bearer ${token}` }
    });
  }
//   getRegistrations(eventId: number): Observable<Registration[]> {
//   return this.http.get<Registration[]>(`${this.apiUrl}/events/${eventId}/registrations`);
// }

deleteRegistration(id: number): Observable<any> {
  return this.http.delete(`${this.apiUrl}/registrations/${id}`);
}
updateEvent(id: number, data: Partial<Event>, token: string): Observable<Event> {
  return this.http.put<Event>(`${this.apiUrl}/events/${id}`, data, {
    headers: { Authorization: `Bearer ${token}` }
  });
}
}

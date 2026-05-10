import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-auth',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './auth.html',
  styleUrl: './auth.css'
})
export class AuthComponent {
  mode: 'login' | 'register' = 'login';
  submitting = false;
  errorMessage = '';

  form = {
    firstName: '',
    lastName: '',
    email: '',
    password: ''
  };

  constructor(private http: HttpClient, private router: Router) {}

  onSubmit() {
    this.submitting = true;
    this.errorMessage = '';

    const url = `http://localhost:8000/api/${this.mode === 'login' ? 'login' : 'register'}`;

    const body = this.mode === 'login'
      ? { email: this.form.email, password: this.form.password }
      : this.form;

   this.http.post<{ access_token: string }>(url, body).subscribe({
  next: (res) => {
    localStorage.setItem('token', res.access_token);
    this.router.navigate(['/']);
  },
      error: (err) => {
        this.errorMessage = err.error?.message ?? 'Identifiants incorrects.';
        this.submitting = false;
      }
    });
  }

  toggleMode() {
    this.mode = this.mode === 'login' ? 'register' : 'login';
    this.errorMessage = '';
  }
}

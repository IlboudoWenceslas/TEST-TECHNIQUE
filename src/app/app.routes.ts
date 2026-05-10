import { Routes } from '@angular/router';
import { EventListComponent } from './pages/event-list/event-list';
import { EventDetailComponent } from './pages/event-detail/event-detail';
import { EventCreateComponent } from './pages/event-create/event-create';
import { AuthComponent } from './pages/auth/auth';



export const routes: Routes = [
  { path: '', component: EventListComponent },
  { path: 'events/:id', component: EventDetailComponent },
  { path: 'create', component: EventCreateComponent },
  // Dans le tableau routes, ajoute :
{ path: 'auth', component: AuthComponent },
];


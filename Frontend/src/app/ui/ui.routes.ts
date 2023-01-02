import { Routes } from '@angular/router';

// Components
import {AccountComponent} from "./account/account.component";
import {ErrorComponent} from "./error/error.component";
import {HomeComponent} from "./home/home.component";
import {TransactionComponent} from "./transaction/transaction.component";
import{ExportComponent} from "./export/export.component";
import{ItemFormComponent} from "./item-form/item-form.component"

export const UiRoute: Routes = [
  { path: '', redirectTo: 'money', pathMatch: 'full'},
  { path: 'exports', component: ExportComponent},
  { path: 'addItem', component: ItemFormComponent},
  { path: 'money', component: TransactionComponent },
  { path: 'home', component: HomeComponent},
  { path: 'account', component: AccountComponent},
  { path: '404', component: ErrorComponent },
  { path: '**', redirectTo: '/404' },
];

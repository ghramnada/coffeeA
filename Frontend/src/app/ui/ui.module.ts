import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';


// Components
import { AccountComponent } from './account/account.component';
import { HomeComponent } from './home/home.component';
import { TopNavComponent } from './top-nav/top-nav.component';
import { TransactionComponent } from './transaction/transaction.component';
import { ErrorComponent } from './error/error.component';
import { AppMaterialModule } from "../app-material.module";

// Routing
import { UiRoute} from "./ui.routes";
import { RouterModule} from "@angular/router";

// Services
import { ContractService } from "../services/contract/contract.service";
import { ThreeBox } from "../services/3box.service";
import { ExportComponent } from './export/export.component'
import { MatTableModule } from '@angular/material/table';
import { ItemFormComponent } from './item-form/item-form.component';

@NgModule({
  declarations: [
    AccountComponent,
    HomeComponent,
    TopNavComponent,
    TransactionComponent,
    ErrorComponent,
    ExportComponent,
    ItemFormComponent
  ],
  imports: [
    CommonModule,
    RouterModule.forChild(UiRoute),
    AppMaterialModule,
    ReactiveFormsModule,
    MatTableModule
  ],
  exports: [
    TopNavComponent,
    HomeComponent
  ],
  providers: [
    ContractService,
    ThreeBox
  ],
})
export class UiModule { }

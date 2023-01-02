import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ContractService } from 'src/app/services/contract/contract.service';

@Component({
  selector: 'app-item-form',
  templateUrl: './item-form.component.html',
  styleUrls: ['./item-form.component.scss']
})

export class ItemFormComponent implements OnInit {
  form : any;
  Item: any ;
  constructor(private contractService:ContractService, private router: Router,private activatedRoute:ActivatedRoute) { }
  ONSUB():void{
    console.log(this.form.value);
    //const ObjectTosubmit = this.form.value;
    const ObjectTosubmit = {...this.Item, ...this.form.value}
    ObjectTosubmit.state = "Shipped";
    this.contractService. save_export(ObjectTosubmit).then(()=>{this.router.navigate(['./exports'])}) //reception du contenu du thread 
                                                 //action post reception du retour du thread 
  }
  ngOnInit(): void {
    this.initForm();
  }

  initForm():void
{ 
  
  this.form=new FormGroup({
    prod_name : new FormControl(null, [Validators.required]),
    quality : new FormControl(null, [Validators.required]),
    quantity : new FormControl(null, [Validators.required]),
    producing_country : new FormControl(null, [Validators.required]),
    goverment_agent : new FormControl(null, [Validators.required]),
    shippement_date : new FormControl(null, [Validators.required]),
    price: new FormControl(null, [Validators.required]),
  });
  //"prod_name"  "quality "quantity"  country" gov_agent ship_date  price
}
}

import {Inject, Injectable} from '@angular/core';
import { WEB3 } from '../../core/web3';
//import contract from 'truffle-contract'; //acceso a libreria deprecada
import { MatSnackBar } from '@angular/material/snack-bar';
import { Subject } from 'rxjs';

import Web3 from 'web3';
import Web3Modal from "web3modal";
import WalletConnectProvider from "@walletconnect/web3-provider";
import { ConditionalExpr } from '@angular/compiler';
import { Console } from 'console';

import {ExpoItem} from "src/models/export_item";
declare let require: any;
const tokenAbi = require('../../../../../Blockchain/build/contracts/SupplyChain.json');
declare let window: any;

@Injectable({
  providedIn: 'root'
})

export class ContractService {
  public accountsObservable = new Subject<string[]>();
  public compatible: boolean;
  web3Modal;
  web3js;
  provider;
  accounts;
  balance;

  public exports:ExpoItem[];
  public C_instance;

  constructor(@Inject(WEB3) private web3: Web3 ,private snackbar: MatSnackBar) {
    const providerOptions = {
      walletconnect: {
        package: WalletConnectProvider, // required
        options: {
          infuraId: "27e484dcd9e3efcfd25a83a78777cdf1" // required
        }
      }
    };

    this.web3Modal = new Web3Modal({
      network: "mainnet", // optional
      cacheProvider: true, // optional
      providerOptions, // required
      theme: {
        background: "rgb(39, 49, 56)",
        main: "rgb(199, 199, 199)",
        secondary: "rgb(136, 136, 136)",
        border: "rgba(195, 195, 195, 0.14)",
        hover: "rgb(16, 26, 32)"
      }
    });
  
  }

  create_account_instance() {
    
      var contract = require("@truffle/contract"); // acceso a nueva version de libreria
      const paymentContract = contract(tokenAbi);
      paymentContract.setProvider(this.provider);
      paymentContract.deployed().then((instance) => {this.C_instance = instance;});
  }  

  async connectAccount() {
    this.provider = await this.web3Modal.connect(); // set provider
    this.web3js = new Web3(this.provider); // create web3 instance
    this.accounts = await this.web3js.eth.getAccounts();
    return this.accounts;
  }

  async accountInfo(accounts){
    const initialvalue = await this.web3js.eth.getBalance(accounts[0]);
    this.balance = this.web3js.utils.fromWei(initialvalue , 'ether');
    return this.balance;
  }

  get_exports():Promise<ExpoItem[]>{
    this.create_account_instance();
    if(this.C_instance.get_exports().length >= 0)
    {
      exports = this.C_instance.get_exports();
      console.log(exports);
      return new Promise(resolve=> resolve(this.exports));
    }
  }

  save_export(item_to_save:ExpoItem):Promise<void>{
    this.C_instance.ship(item_to_save.prod_name ,
      item_to_save.quality, item_to_save.quantity, item_to_save.producing_country ,
      item_to_save.goverment_agent,item_to_save.shippement_date,item_to_save.price);
      this.get_exports();
    return (new Promise (resolve=>resolve()));
  }
  
  trasnferEther(originAccount, destinyAccount, amount) {
    const that = this;

    return new Promise((resolve, reject) => {
      var contract = require("@truffle/contract"); // acceso a nueva version de libreria
      const paymentContract = contract(tokenAbi);
      paymentContract.setProvider(this.provider);
      paymentContract.deployed().then((instance) => {
        let finalAmount =  this.web3.utils.toBN(amount)
        console.log(finalAmount)
        return instance.nuevaTransaccion(
          destinyAccount,
          {
            from: originAccount[0],
            value: this.web3.utils.toWei(finalAmount, 'ether')
          }
          );
      }).then((status) => {
        if (status) {
          return resolve({status: true});
        }
      }).catch((error) => {
        console.log(error);

        return reject('Error transfering Ether');
      });
    });
  }

  failure(message: string) {
    const snackbarRef = this.snackbar.open(message);
    snackbarRef.dismiss()
  }

  success() {
    const snackbarRef = this.snackbar.open('Transaction complete successfully');
    snackbarRef.dismiss()
  }

  
}

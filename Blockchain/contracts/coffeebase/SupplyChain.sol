// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24;
// Update pragma solidity statement to be less restrictive with >= instead of ^

// Define a contract 'Supplychain'


// NOTE: don't need to do "../contracts/.. before b/c already in the contracts master folder so can call these files on command
import "../coffeeaccesscontrol/ConsumerRole.sol";
import "../coffeeaccesscontrol/DistributorRole.sol";
import "../coffeeaccesscontrol/ExporterRole.sol";
import "../coffeeaccesscontrol/RetailerRole.sol";
// You should inherit the Ownable.sol smart contract here and leverage the modifiers defined in that smart contract and use it below as well (line 27)
import "../coffeecore/Ownable.sol";

// leverage modifiers defined in the Ownable smart contract and use it here:
contract SupplyChain is Ownable, ConsumerRole, DistributorRole, ExporterRole, RetailerRole {

  // Define 'owner'
  address contractOwner;
  uint public IdExpo;
  uint public IdSupp;
  uint public  _id_roast;
  uint public  _id_retail;
  mapping (uint => roast_item) roast_items;
  mapping (uint => retail_item) on_retail_items;
  

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, that track its journey through the supply chain -- to be sent from DApp.
  // upc => string[] of the supply chain movement
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Processed,  // 1
    Packed,     // 2
    ForSale,    // 3
    Sold,       // 4
    Shipped,    // 5
    Received,   // 6
    Purchased,   // 7
    OutOfStock
    }
  struct roast_item{
    uint id_roast;
    uint quantity_for_roast;
    uint quantity_ready;
    uint price;
    uint bc;
    address roaster;
  }
  struct retail_item{
    uint quantity;
    uint bc;
    address retailer;
    uint price;
  }
 
  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event Processed(uint upc);
  event Packed(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);
  event Purchased(uint upc);

  




// MODIFIERS SECTION //




  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier OnlyOwner() {
    require(msg.sender == contractOwner, "Only the owner can do this");
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price, "More money is required, this is not enough to handle the transaction!");
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
 /* modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    // this structure (struct) gets this checkValue modifier to execute in the code after the function is called with _make_payable
    address payable consumerAddressPayable = _make_payable(items[_upc].consumerID);
    
    consumerAddressPayable.transfer(amountToReturn);
  }
 
*/


// CONSTRUCTORS //
// public payable 
  constructor() payable {
    contractOwner = msg.sender;
    IdExpo = 0;
    IdSupp = 0;
    _id_roast = 0;
    _id_retail = 0;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == contractOwner) {
      address payable ownerAddressPayable = _make_payable(contractOwner);
      selfdestruct(ownerAddressPayable);
    }
  }

  // _make_payable function to address the above kill function
  function _make_payable(address x) internal pure returns (address payable) {
    //address payable p = address(uint160(x));
    //address payable p = address(uint160(address(x)));
    address payable p = payable(address(x));
    return p;
  }

  // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  /*function buyItem(uint _upc)
    // Call modifier to check if upc has passed previous supply chain stage
    forSale(_upc)
    // Call modifer to check if buyer has paid enough
    paidEnough(items[_upc].productPrice)
    // Call modifer to send any excess ether back to buyer
    checkValue(_upc)
    // Call function to check if purchaser is in fact a Distributor:
    onlyDistributor
    // When it's the first time going through function, distributor is contractOwner that possesses all roles
    public payable 
    {
      // Update the appropriate fields - ownerID, distributorID, itemState
      items[_upc].ownerID = contractOwner;
      items[_upc].distributorID = msg.sender;
      items[_upc].itemState = State.Sold;
      
      // Transfer money to farmer
      address payable originFarmerAddressPayable = _make_payable(items[_upc].originFarmerID);
      
      originFarmerAddressPayable.transfer(msg.value);
      // emit the appropriate event
      emit Sold(_upc);
    }


 // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
 function receiveItem(uint _upc) 
    // Call modifier to check if upc has passed previous supply chain stage
    shipped (_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyRetailer
    // Check on list:
    verifyCaller(items[_upc].retailerID)
    //verify this is the specific retailer for the UPC
    public
    {
    // Update the appropriate fields - ownerID, retailerID, itemState
    items[_upc].ownerID = contractOwner;
    items[_upc].retailerID = msg.sender;
    items[_upc].itemState = State.Received;
    // Emit the appropriate event
    emit Received(_upc);
  }




  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
  // Use the above modifiers to check if the item is received
  function purchaseItem(uint _upc)  
    // Call modifier to check if upc has passed previous supply chain stage
    received(_upc)
    // Access Control List enforced by calling Smart Contract / DApp
    onlyConsumer
    //verify this is the specific retailer for the UPC
    public
    {
    // Update the appropriate fields - ownerID, consumerID, itemState
    items[_upc].ownerID = contractOwner;
    items[_upc].consumerID = msg.sender;
    items[_upc].itemState = State.Purchased;
    // Emit the appropriate event
    emit Purchased(_upc);
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  /*function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originFarmerID,
  // NOTE: Data location must be "memory" for return parameter in function
  string memory originFarmName,
  string memory originFarmInformation,
  string memory originFarmLatitude,
  string memory originFarmLongitude
  ) 
  {
  // Assign values to the 8 parameters
  
  itemSKU = items[_upc].sku;
  
  itemUPC = items[_upc].upc;
  
  ownerID = items[_upc].ownerID;
  
  originFarmerID = items[_upc].originFarmerID;
  
  originFarmName = items[_upc].originFarmName;
  
  originFarmInformation = items[_upc].originFarmInformation;
  
  originFarmLatitude = items[_upc].originFarmLatitude;
  
  originFarmLongitude = items[_upc].originFarmLongitude;
    

  return 
  (
  itemSKU,
  itemUPC,
  ownerID,
  originFarmerID,
  originFarmName,
  originFarmInformation,
  originFarmLatitude,
  originFarmLongitude
  );
  }
*/

  ///
  ///export part 
  struct export_item{
  uint id_expo;
  string prod_name;
  string quality;
  uint quantity;
  uint price; //selling price
  string producing_country;
  string goverment_agent;
  string shippement_date;
  State state;
  address exporter;
  }
  mapping (address => mapping(uint=>export_item)) shipped_items;
  mapping(address => uint[]) shipped_ids;

   modifier shipped(address _add_expo,uint _id_expo) {
    require(shipped_items[_add_expo][_id_expo].state == State.Shipped, "This item hasn't been received yet.");
    _;
  }

  event Shipped(string prodState);
  event Received(string prodState);

  function ship(string memory _prodName ,
  string memory _quality, uint _quantity, string memory _country ,string memory _govermentAgent,
  string memory _shipDate,uint _price) public
  {
    shipped_items[msg.sender][IdExpo] = export_item({
    id_expo:IdExpo,
    prod_name:_prodName,
    quality:_quality,
    quantity:_quantity,
    price:_price,
    producing_country:_country,
    goverment_agent:_govermentAgent,
    shippement_date:_shipDate,
    exporter:msg.sender,
    state:State.Shipped
    });    
    IdExpo +=1;
    emit Shipped("product has been scheduled for shippement successfully");
  }
  
  function impo_received(uint _id) public
  shipped(msg.sender,_id) 
  {
    shipped_items[msg.sender][_id].state = State.Received;
    emit Received( "shippement has arrived to the port");
  }

  function get_exports() public view returns(export_item[] memory){
    uint count = shipped_ids[msg.sender].length;
    export_item[] memory exports = new export_item[](count);
    for (uint i= 0 ; i< count; i++){
        export_item storage item = shipped_items[msg.sender][shipped_ids[msg.sender][i]];
        exports[i] = item;
    }
    return exports;
  }
  ///
  ///supply part 
  struct supply_item{
    uint id_supply;
    uint quantity;
    uint price;
    uint id_expo;
    address ad_expoter;
    address distributor;
  }
  mapping (address => mapping(uint=>supply_item)) on_supply_items;

  modifier received(uint _id_expo,address _add_expo) {
    require(shipped_items[_add_expo][_id_expo].state == State.Received, "This item hasn't been received yet.");
    _;
  }

modifier prod_enough(address _add_expo,uint _id_expo,uint _quantity) {
    require(shipped_items[_add_expo][_id_expo].quantity >= _quantity, "This item isn't packed yet.");
    _;
  }


  function distribute(uint _id_expo,address _add_expo,uint _quantity,uint _price) public payable 
  onlyDistributor
  prod_enough(_add_expo,_id_expo,_quantity)
  ///paidEnough(_quantity*shipped_items[_add_expo][_id_expo].price)
  received(_id_expo,_add_expo)
  {
    address payable exporterAddressPayable = _make_payable(_add_expo);      
    exporterAddressPayable.transfer(msg.value);
    shipped_items[_add_expo][_id_expo].quantity-= _quantity;
    if(shipped_items[_add_expo][_id_expo].quantity == 0)
    {
      shipped_items[_add_expo][_id_expo].state = State.OutOfStock;
    }
    on_supply_items[msg.sender][IdSupp] = supply_item({
      id_supply:IdSupp,
      quantity: _quantity,
      price:_price,
      id_expo:_id_expo,
      ad_expoter:_add_expo,
      distributor:msg.sender
    });
  }
}

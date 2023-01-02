// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'FarmerRole' to manage this role - add, remove, check
contract ExporterRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event ExporterAdded(address indexed account);
  event ExporterRemoved(address indexed account);

  // Define a struct 'farmers' by inheriting from 'Roles' library, struct Role
  Roles.Role private exporters;

  // In the constructor make the address that deploys this contract the 1st farmer
  constructor() {
    _addExporter(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyExporter() {
    // the person doing this MUST be a farmer, so we'll use isDistributor to verify:
    require(isExporter(msg.sender), "Only a Exporter can do this");
    _;
  }

  // Define a function 'isFarmer' to check this role
  function isExporter(address account) public view returns (bool) {
    return exporters.has(account);
  }

  // Define a function 'addFarmer' that adds this role
  function addExporter(address account) public onlyExporter {
    _addExporter(account);
  }

  // Define a function 'renounceFarmer' to renounce this role
  function renounceExporter() public {
    _removeExporter(msg.sender);
  }

  // Define an internal function '_addFarmer' to add this role, called by 'addFarmer'
  function _addExporter(address account) internal {
    exporters.add(account);
    emit ExporterAdded(account);
  }

  // Define an internal function '_removeFarmer' to remove this role, called by 'removeFarmer'
  function _removeExporter(address account) internal {
    exporters.remove(account);
    emit ExporterRemoved(account);
  }
}
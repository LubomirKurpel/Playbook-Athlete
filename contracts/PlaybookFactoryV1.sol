// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PlaybookCollection is ERC1155, AccessControl {
	
	constructor(string memory _uri, address _ownerAddress, uint _numberOfTokens) ERC1155("") {
		_setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
		_setURI(_uri);
		_mint(_ownerAddress, 0, _numberOfTokens, "");
		
		console.log(address(this));
	}
	
	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
	
	function changeUri(string memory _uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
		_setURI(_uri);
	}
	
	function burn(uint _numberOfTokens) external {
		require(balanceOf(_msgSender(), 0) >= _numberOfTokens, "not token ID owner");
		_burn(_msgSender(), 0, _numberOfTokens);
	}
	
}


contract PlaybookFactoryV1 is Ownable {
	
	PlaybookCollection[] public collections;
	
    constructor() Ownable() {}
	
	function createCollection(
		string memory _uri,
		address _ownerAddress,
		uint _numberOfTokens
	) external onlyOwner {
		PlaybookCollection _collection = new PlaybookCollection(_uri, _ownerAddress, _numberOfTokens);
		collections.push(_collection);
    }
	
	// Getters
	function getCollectionsLength() public view returns (uint) {
        return collections.length;
    }
	
	function getCollectionAddressByIndex(uint _index) public view returns (address) {
        return address(collections[_index]);
    }
	
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PlaybookCollectionV1 is ERC1155, AccessControl {
	
	bool public restrictTransfer;
	mapping(address => bool) public allowedContracts;
	
	constructor(string memory _uri, address _ownerAddress, uint _numberOfTokens) ERC1155("") {
		_setupRole(DEFAULT_ADMIN_ROLE, tx.origin);
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
	
	function setRestrictTransfer(bool _value) external onlyRole(DEFAULT_ADMIN_ROLE) {
		restrictTransfer = _value;
	}
	
	function setAllowedContract(address _address, bool _value) external onlyRole(DEFAULT_ADMIN_ROLE) {
		allowedContracts[_address] = _value;
	}
	
	function burn(uint _numberOfTokens) external {
		require(balanceOf(_msgSender(), 0) >= _numberOfTokens, "not token ID owner");
		_burn(_msgSender(), 0, _numberOfTokens);
	}
	
	function isContract(address _addr) private view returns (bool) {
		uint32 size;
		assembly {
			size := extcodesize(_addr)
		}
		return (size > 0);
	}
	
	/**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
	function setApprovalForAll(address operator, bool approved) public override {
		
		if (restrictTransfer && isContract(operator)) {
			require(allowedContracts[operator] == true, "Approve not allowed");
		}
		
        super.setApprovalForAll(operator, approved);
		
    }
	
}


contract PlaybookFactoryV1 is Ownable {
	
    PlaybookCollectionV1[] public collections;
	
    constructor() Ownable() {}
	
    function createCollection(
		string memory _uri,
		address _ownerAddress,
		uint _numberOfTokens
    ) external onlyOwner {
		PlaybookCollectionV1 _collection = new PlaybookCollectionV1(_uri, _ownerAddress, _numberOfTokens);
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
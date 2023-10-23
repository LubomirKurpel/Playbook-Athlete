// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PlaybookCollectionV1 is ERC1155, AccessControl {
	
	bool public restrictTransfer;
	mapping(address => bool) public allowedContracts;
	string public name = "Playbook Athlete's Collection"; // For OpenSea naming of ERC1155 Contract
	
	constructor(string memory _uri, address _ownerAddress, uint _numberOfTokens, string memory _name) ERC1155("") {
		_grantRole(DEFAULT_ADMIN_ROLE, tx.origin);
		_setURI(_uri);
		_mint(_ownerAddress, 0, _numberOfTokens, "");
		name = _name;
		
		console.log(address(this));
	}
	
	function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
	
	/**
     * @dev OpenSea needs contractURI() function to see metadata
     */
	function contractURI() public view returns (string memory) {
        return uri(0);
    }
	
	function changeUri(string memory _uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
		_setURI(_uri);
	}
	
	function changeCollectionName(string memory _name) external onlyRole(DEFAULT_ADMIN_ROLE) {
		name = _name;
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
	
	uint public nonce = 1;
	
    function createCollection(
		string memory _uri,
		address _ownerAddress,
		uint _numberOfTokens,
		string memory _collectionName
    ) external onlyOwner {
		PlaybookCollectionV1 _collection = new PlaybookCollectionV1(_uri, _ownerAddress, _numberOfTokens, _collectionName);
		collections.push(_collection);
		nonce++;
    }
	
	function getFutureCollectionAddress() public view returns (address) {
		bytes memory data;
		if (nonce == 0x00)          data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(this), bytes1(0x80));
		else if (nonce <= 0x7f)     data = abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(this), uint8(nonce));
		else if (nonce <= 0xff)     data = abi.encodePacked(bytes1(0xd7), bytes1(0x94), address(this), bytes1(0x81), uint8(nonce));
		else if (nonce <= 0xffff)   data = abi.encodePacked(bytes1(0xd8), bytes1(0x94), address(this), bytes1(0x82), uint16(nonce));
		else if (nonce <= 0xffffff) data = abi.encodePacked(bytes1(0xd9), bytes1(0x94), address(this), bytes1(0x83), uint24(nonce));
		else                         data = abi.encodePacked(bytes1(0xda), bytes1(0x94), address(this), bytes1(0x84), uint32(nonce));
		return address(uint160(uint256(keccak256(data))));
	}
	
	// Getters
    function getCollectionsLength() public view returns (uint) {
        return collections.length;
    }
	
	function getCollectionAddressByIndex(uint _index) public view returns (address) {
        return address(collections[_index]);
    }
	
}
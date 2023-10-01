// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PlaybookCollectionV1 is ERC1155, AccessControl {
	
	bool public restrictMarketplace;
	address public marketplaceAddress;
	
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
	
	function setRestrictMarketplace(bool _value) external onlyRole(DEFAULT_ADMIN_ROLE) {
		restrictMarketplace = _value;
	}
	
	function setMarketplaceAddress(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
		marketplaceAddress = _address;
	}
	
	function burn(uint _numberOfTokens) external {
		require(balanceOf(_msgSender(), 0) >= _numberOfTokens, "not token ID owner");
		_burn(_msgSender(), 0, _numberOfTokens);
	}
	
	/**
	 * @dev Openzeppelin repositary imports 0.8.0 version instead of newest 0.8.20, both of the versions can be
	 * altered to suit our needs. Version 0.8.0 includes _beforeTokenTransfer hook while version 0.8.20 uses _update method
	 * before each adjustment of balances, including minting, burning and transfers.
	 *
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
	 
	 // TODO: Write tests for marketplace restriction
	function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override {
		
		if (restrictMarketplace && marketplaceAddress != _msgSender()) {
			revert("Not the allowed marketplace");
		}
		
		super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
		
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
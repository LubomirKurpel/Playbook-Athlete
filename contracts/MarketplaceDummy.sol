// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";

/*
	This contract acts as a simple transfer mimicing
	marketplace functionality, where msg.sender is
	not tx.origin. Contract does not contain allowance logic
	at all. Allowance logic is handled in tests.
	This contract is only used to demonstrate
	whether restrictions for marketplace address
	in PlaybookCollection contracts	will be applicable
	and will work.
	
	**In no means use this contract in production.**
*/

contract MarketplaceDummy {
	
    constructor() {}
	
	function dummyTransferNFT(address _transferFrom, address _transferTo, address _collectionContract, uint _numberOfTokens) external {
		
		console.log("Dummy marketplace address: ", address(this));
		console.log("Dummy marketplace - NFT transfer event collection: ", _collectionContract);
		console.log("Dummy marketplace - NFT transfer From: ", _transferFrom);
		console.log("Dummy marketplace - NFT transfer To: ", _transferTo);
		console.log("Dummy marketplace - NFT transfer Number Of Tokens: ", _numberOfTokens);
		
		IERC1155 _IcollectionContract = IERC1155(_collectionContract);
		
		// Require not needed, maybe in production
		// require(_collectionContract.balanceOf(_msgSender(), _tokenID), "Not the token owner");
		
		/**
			@notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
			@dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
			MUST revert if `_to` is the zero address.
			MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
			MUST revert on any other error.
			MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
			After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
			@param _from    Source address
			@param _to      Target address
			@param _id      ID of the token type (Always 0 in PlaybookCollection contracts)
			@param _value   Transfer amount
			@param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
		*/
		_IcollectionContract.safeTransferFrom(_transferFrom, _transferTo, 0, _numberOfTokens, "");
		
		// No revert, print message
		console.log("NFTs transfered successfully!");
		
    }
	
	
}
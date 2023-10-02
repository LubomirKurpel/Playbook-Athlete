const { expect } = require("chai");
const { ethers } = require("hardhat");
const {utils, BigNumber} = require('ethers');


describe("Playbook Athletes Localhost Tests", function () {
	
  let owner,randomPerson,randomPerson_2,randomPerson_3;
  
  let PlaybookFactory_ContractFactory;
  let PlaybookFactory_Contract;
  
  let MarketplaceDummy_ContractFactory;
  let MarketplaceDummy_Contract;
  
  let MarketplaceDummy_2_ContractFactory;
  let MarketplaceDummy_2_Contract;
  
  beforeEach(async function () {
    
	[owner,randomPerson,randomPerson_2,randomPerson_3] = await hre.ethers.getSigners();
	
	
	// 1. Deploy Playbook Factory Contract
    PlaybookFactory_ContractFactory = await hre.ethers.getContractFactory("PlaybookFactoryV1");
    PlaybookFactory_Contract = await PlaybookFactory_ContractFactory.deploy();
    // await PlaybookFactory_Contract.deployed();
    console.log("Playbook Factory contract deployed to:", PlaybookFactory_Contract.target);
	
	// 2. Deploy MarketplaceDummy Contract
    MarketplaceDummy_ContractFactory = await hre.ethers.getContractFactory("MarketplaceDummy");
    MarketplaceDummy_Contract = await MarketplaceDummy_ContractFactory.deploy();
    console.log("MarketplaceDummy contract deployed to:", MarketplaceDummy_Contract.target);
	
	// 3. Deploy MarketplaceDummy Contract 2
    MarketplaceDummy_2_ContractFactory = await hre.ethers.getContractFactory("MarketplaceDummy");
    MarketplaceDummy_2_Contract = await MarketplaceDummy_2_ContractFactory.deploy();
    console.log("MarketplaceDummy 2 contract deployed to:", MarketplaceDummy_2_Contract.target);
	
	
  });
	
  it("Should test deployment of child collection contract", async function () {
	
	// Deploy collection through factory contract
	await PlaybookFactory_Contract.createCollection("", randomPerson.address, 100);
	
	// Get new deployment address
	let collectionAddress = await PlaybookFactory_Contract.getCollectionAddressByIndex(0);
	
	console.log(collectionAddress);
	
  });
	
  it("Should test transfer of NFTs", async function () {
	
	// Deploy collection through factory contract
	await PlaybookFactory_Contract.createCollection("", randomPerson.address, 100);
	
	// Get new deployment address
	let collectionAddress = await PlaybookFactory_Contract.getCollectionAddressByIndex(0);
	
	// Fetch NFT collection by address
	PlaybookCollectionV1Factory = await hre.ethers.getContractFactory("PlaybookCollectionV1");
    PlaybookCollectionV1Contract = await PlaybookCollectionV1Factory.attach(collectionAddress);
    console.log("PlaybookCollectionV1Contract fetched at:", PlaybookCollectionV1Contract.target);
	
	// Test transferring some NFTs to randomPerson_2
	
	/**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
	var contractCall = await PlaybookCollectionV1Contract.connect(randomPerson).safeTransferFrom(
		randomPerson.address, // From
		randomPerson_2.address, // To
		"0", // 0 is our collection index
		"10", // Transfer 10 NFTs
		"0x" // Blank data
	);
	await contractCall.wait();
	
	// Check if NFTs were received
	var balanceOf = await PlaybookCollectionV1Contract.connect(randomPerson_2).balanceOf(randomPerson_2.address, 0); // 0 is our collection index
	
	console.log("randomPerson_2 balance: ", balanceOf);
	
	// Check balance of randomPerson
	var balanceOf = await PlaybookCollectionV1Contract.connect(randomPerson).balanceOf(randomPerson.address, 0); // 0 is our collection index
	
	console.log("randomPerson balance: ", balanceOf);
	
  });
  
  it("Should test transfer through MarketplaceDummy contract", async function () {
	
	// Deploy collection through factory contract
	await PlaybookFactory_Contract.createCollection("", randomPerson.address, 100);
	
	// Get new deployment address
	let collectionAddress = await PlaybookFactory_Contract.getCollectionAddressByIndex(0);
	
	// Fetch NFT collection by address
	PlaybookCollectionV1Factory = await hre.ethers.getContractFactory("PlaybookCollectionV1");
    PlaybookCollectionV1Contract = await PlaybookCollectionV1Factory.attach(collectionAddress);
    console.log("PlaybookCollectionV1Contract fetched at:", PlaybookCollectionV1Contract.target);
	
	
	// Use MarketplaceDummy contract to transfer NFTs
	
	// Approve number of tokens
	/* 
		@dev: function setApprovalForAll Arguments:
		address _operator,
		bool _approved
	*/
	// Grants approval to all NFTs to _operator from msg.sender
	var playbookCollectionApproval = await PlaybookCollectionV1Contract.connect(randomPerson).setApprovalForAll(
		MarketplaceDummy_Contract.target, // address _operator
		true // bool _approved
	);
	await playbookCollectionApproval.wait();
	
	/* 
		@dev: Arguments:
		address _transferFrom,
		address _transferTo,
		address _collectionContract,
		uint _numberOfTokens
	*/
	var marketplaceTransfer = await MarketplaceDummy_Contract.connect(randomPerson).dummyTransferNFT(
		randomPerson.address, // address _transferFrom
		randomPerson_2.address, // address _transferTo
		PlaybookCollectionV1Contract.target, // address _collectionContract
		"10" // 10 tokens
	);
	
	await marketplaceTransfer.wait();
	
  });
  
  it("Should lock transfer only through MarketplaceDummy_1 contract, not MarketplaceDummy_2 contract", async function () {
	
	// Deploy collection through factory contract
	await PlaybookFactory_Contract.createCollection("", randomPerson.address, 100);
	
	// Get new deployment address
	let collectionAddress = await PlaybookFactory_Contract.getCollectionAddressByIndex(0);
	
	// Fetch NFT collection by address
	PlaybookCollectionV1Factory = await hre.ethers.getContractFactory("PlaybookCollectionV1");
    PlaybookCollectionV1Contract = await PlaybookCollectionV1Factory.attach(collectionAddress);
    console.log("PlaybookCollectionV1Contract fetched at:", PlaybookCollectionV1Contract.target);
	
	
	
	
	// Lock transfer of NFTs to MarketplaceDummy_1 contract
	var playbookCollectionRestrictTransfer = await PlaybookCollectionV1Contract.connect(owner).setRestrictTransfer(true);
	await playbookCollectionRestrictTransfer.wait();
	
	var playbookCollectionLock = await PlaybookCollectionV1Contract.connect(owner).setAllowedContract(
		MarketplaceDummy_Contract.target, // address _collectionContract
		true // bool _allowTransfer
	);
	await playbookCollectionLock.wait();
	
	
	
	// Use MarketplaceDummy_1 contract to transfer NFTs
	
	// Approve number of tokens
	/* 
		@dev: function setApprovalForAll Arguments:
		address _operator,
		bool _approved
	*/
	// Grants approval to all NFTs to _operator from msg.sender
	var playbookCollectionApproval = await PlaybookCollectionV1Contract.connect(randomPerson).setApprovalForAll(
		MarketplaceDummy_Contract.target, // address _operator
		true // bool _approved
	);
	await playbookCollectionApproval.wait();
	
	/* 
		@dev: Arguments:
		address _transferFrom,
		address _transferTo,
		address _collectionContract,
		uint _numberOfTokens
	*/
	var marketplaceTransfer = await MarketplaceDummy_Contract.connect(randomPerson).dummyTransferNFT(
		randomPerson.address, // address _transferFrom
		randomPerson_2.address, // address _transferTo
		PlaybookCollectionV1Contract.target, // address _collectionContract
		"10" // 10 tokens
	);
	
	await marketplaceTransfer.wait();
	
	
	// Try to use MarketplaceDummy_2_Contract and expect to fail
	await expect(
		PlaybookCollectionV1Contract.connect(randomPerson).setApprovalForAll(
			MarketplaceDummy_2_Contract.target, // address _operator
			true // bool _approved
		)
	).to.be.reverted;
	
	
	// Test if transfers still work after locking the contract to marketplace
	var contractCall = await PlaybookCollectionV1Contract.connect(randomPerson).safeTransferFrom(
		randomPerson.address, // From
		randomPerson_2.address, // To
		"0", // 0 is our collection index
		"10", // Transfer 10 NFTs
		"0x" // Blank data
	);
	await contractCall.wait();
	
	// Check if NFTs were received
	var balanceOf = await PlaybookCollectionV1Contract.connect(randomPerson_2).balanceOf(randomPerson_2.address, 0); // 0 is our collection index
	
	console.log("randomPerson_2 balance: ", balanceOf);
	
	
  });
  
});

const { expect } = require("chai");
const { ethers } = require("hardhat");
const {utils, BigNumber} = require('ethers');


describe("Playbook Athletes Localhost Tests", function () {
	
  let owner,randomPerson,randomPerson_2,randomPerson_3;
  
  let PlaybookFactory_ContractFactory;
  let PlaybookFactory_Contract;
  
  beforeEach(async function () {
    
	[owner,randomPerson,randomPerson_2,randomPerson_3] = await hre.ethers.getSigners();
	
	
	// 1. Deploy Playbook Factory Contract
    PlaybookFactory_ContractFactory = await hre.ethers.getContractFactory("PlaybookFactoryV1");
    PlaybookFactory_Contract = await PlaybookFactory_ContractFactory.deploy();
    // await USDC_Contract.deployed();
    console.log("Playbook Factory contract deployed to:", PlaybookFactory_Contract.target);
	
	
  });
	
  it.only("Should test deployment of child collection contract", async function () {
	
	await PlaybookFactory_Contract.createCollection("", randomPerson.address, 100);
	
	// Get deployment address
	let collectionAddress = await PlaybookFactory_Contract.getCollectionAddressByIndex(0);
	
	console.log(collectionAddress);
	
	// Get number of tokens for randomPerson
	
	
	return;
	
  });
  
	
	
});

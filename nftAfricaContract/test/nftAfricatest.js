const { assert, expect } = require("chai");
const { getNamedAccounts, deployments, ethers } = require("hardhat");

describe("NFTAFRICA", () => {
  let accounts,
    deployer,
    spender,
    nftAfricaContract,
    BasicNftContract,
    ownedNFT,
    connectNFTcontract;
  let oneEth = ethers.utils.parseEther("0.1");
  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const TOKEN_ID = 0;
    deployer = accounts[0];
    spender = accounts[0];
    await deployments.fixture(["all"]);
    nftAfricaContract = await ethers.getContract("NftAfrica");
    BasicNftContract = await ethers.getContract("BasicNft");

    ownedNFT = BasicNftContract.connect(deployer);
    connectNFTcontract = nftAfricaContract.connect(deployer);
    await ownedNFT._mint();
    await ownedNFT.approve(nftAfricaContract.address, TOKEN_ID);
    console.log(deployer.address);
    console.log(nftAfricaContract.address);
  });

  describe("Listitem NFT", () => {
    it("should emit an event the listing is successful", async () => {
      const tx = await connectNFTcontract.ListItem(ownedNFT.address, 0, oneEth);
      expect(tx).to.emit("ItemListedd");
    });
  });
});

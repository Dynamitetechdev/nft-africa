const { network } = require("hardhat");
const { verify } = require("../utils/verify");
require("dotenv").config();

module.exports = async ({ deployments, getNamedAccounts }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  const args = [];
  const nftAfricaContract = await deploy("NftAfrica", {
    from: deployer,
    args: args,
    log: true,
  });

  const NFTContract = await deploy("BasicNft", {
    from: deployer,
    args: args,
    log: true,
  });

  log("-----------------------------------------------------");
  if (chainId != 31337 && process.env.ETHERSCAN_APIKEY) {
    await verify(nftAfricaContract.address, args);
  }
};

module.exports.tags = ["all", "nftafrica"];

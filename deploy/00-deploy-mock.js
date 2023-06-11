const { network } = require("hardhat");
const {
  developmentChains,
  DECIMALS,
  INITAL_ANSWERS,
} = require("../helper-hardhat-config");

async function deployFunc(hre) {
  const { getNamedAccounts, deployments } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  // when going for localhost or hardhat network we want to use a mock
  if (developmentChains.includes(network.name)) {
    log("Local network detected! Deploying mocks...");
    await deploy("MockV3Aggregator", {
      contract: "MockV3Aggregator",
      from: deployer,
      log: true,
      args: [DECIMALS, INITAL_ANSWERS],
    });
    log("Mocks deployed!");
    log("----------------------------------------------------------");
  }
}

module.exports = deployFunc;
module.exports.tags = ["all", "mocks"];

const path = require("path");
const solc = require("solc");
const fs = require("fs-extra");

// get path to build folder
const buildPath = path.resolve(__dirname, "build");
// delete build folder
fs.removeSync(buildPath);

// get path to Campaigns.sol
const campaignPath = path.resolve(__dirname, "contracts", "Campaign.sol");
// read campaign file
const source = fs.readFileSync(campaignPath, "utf8");
// compile contracts and get contracts
const input = JSON.stringify({
  language: "Solidity",
  sources: {
    "Campaign.sol": {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      "*": {
        "*": ["*"],
      },
    },
  },
});

const abiString = solc.compile(input);
const contracts = JSON.parse(abiString).contracts['Campaign.sol'];

fs.ensureDirSync(buildPath);
for (let contract in contracts) {
    fs.outputJSONSync(
        path.resolve(buildPath, contract + ".json"),
        contracts[contract]
    );
}

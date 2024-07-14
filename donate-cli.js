const { createClient, createWalletClient, getContract, http, parseEther, formatEther } = require('viem');
const { mainnet } = require('viem/chains');
const inquirer = require('inquirer');
require('dotenv').config();

const COFFEE_PRICE_USD = 2.50; // 2.50 USD

const client = createClient({
  transport: http(process.env.RPC_URL),
});

const walletClient = createWalletClient({
  transport: http(process.env.RPC_URL),
  account: process.env.PRIVATE_KEY,
});

const contractAddress = 'YOUR_CONTRACT_ADDRESS'; // Replace with your deployed contract address
const abi = [
  // Replace with your contract ABI
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "coffeeCount",
        "type": "uint256"
      }
    ],
    "name": "donateEther",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  }
];

const contract = getContract({
  address: contractAddress,
  abi,
  publicClient: client,
  walletClient,
});

async function main() {
  console.log('Welcome to Coffee Donation CLI');

  while (true) {
    try {
      const { recipient } = await inquirer.prompt({
        type: 'input',
        name: 'recipient',
        message: 'Enter the address to donate to (BE CAREFUL AND CHECK ADDRESS CLEARLY):',
      });

      const { coffeeCount } = await inquirer.prompt({
        type: 'input',
        name: 'coffeeCount',
        message: 'Enter the number of coffees you\'d like to donate:',
        validate: (value) => {
          const valid = !isNaN(value) && parseInt(value) > 0;
          return valid || 'Please enter a valid number';
        },
      });

      const coffeeCountInt = parseInt(coffeeCount);
      const ethPrice = await getEthPrice();
      const etherRequired = (COFFEE_PRICE_USD * coffeeCountInt) / parseFloat(formatEther(ethPrice));

      console.log(`Processing your donation of ${coffeeCountInt} coffee(s) to ${recipient}...`);

      const tx = await contract.sendTransaction('donateEther', [coffeeCountInt], {
        value: parseEther(etherRequired.toString()),
      });

      console.log('Transaction sent! Waiting for confirmation...');
      const receipt = await tx.wait();

      console.log(`Congrats! You donated ${coffeeCountInt} coffee(s) to ${recipient}`);
      console.log(`Transaction link: https://etherscan.io/tx/${receipt.transactionHash}`);

      const { again } = await inquirer.prompt({
        type: 'confirm',
        name: 'again',
        message: 'Would you like to do another donation?',
      });

      if (!again) break;
    } catch (error) {
      console.error('Transaction failed :(', error);
      break;
    }
  }

  console.log('Exiting the Coffee Donation CLI. Goodbye!');
}

async function getEthPrice() {
    // Chainlink ETH/USD price feed
  const priceFeedAddress = '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419'; // Replace with the Chainlink ETH/USD price feed address
  const priceFeedAbi = [
    {
      "constant": true,
      "inputs": [],
      "name": "latestRoundData",
      "outputs": [
        { "name": "roundId", "type": "uint80" },
        { "name": "answer", "type": "int256" },
        { "name": "startedAt", "type": "uint256" },
        { "name": "updatedAt", "type": "uint256" },
        { "name": "answeredInRound", "type": "uint80" }
      ],
      "payable": false,
      "stateMutability": "view",
      "type": "function"
    }
  ];

  const priceFeed = getContract({
    address: priceFeedAddress,
    abi: priceFeedAbi,
    publicClient: client,
  });

  const { answer } = await priceFeed.read('latestRoundData', []);
  return BigInt(answer) * BigInt(10 ** 10); // Convert to 18 decimals
}

main();

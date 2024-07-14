### README.md

# CoffeeIsHumane

## Overview

CoffeeIsHumane is a smart contract-based project that facilitates donations in the form of coffee equivalents. Users can donate a specified number of coffees (priced at $2.50 each) to a recipient using Ether (ETH), USD Coin (USDC), or Tether (USDT). The project integrates with Chainlink Oracles to fetch the current ETH/USD price, ensuring accurate conversion rates for donations. Additionally, a CLI (Command Line Interface) app is provided for easy interaction with the smart contract.

## Smart Contract

### CoffeeDonation.sol

The `CoffeeDonation` smart contract includes the following functionalities:

- **donateEther**: Allows users to donate ETH equivalent to the number of coffees specified. The ETH/USD price is fetched from Chainlink Oracles.
- **donateUSDC**: Allows users to donate USDC equivalent to the number of coffees specified.
- **donateUSDT**: Allows users to donate USDT equivalent to the number of coffees specified.
- **setRecipient**: Allows the contract owner to set the recipient address for donations.
- **setCoffeePriceUSD**: Allows the contract owner to set the price of a coffee in USD.
- **getEthPrice**: Fetches the current ETH/USD price from Chainlink Oracles.
- **withdrawTokens**: Allows the contract owner to withdraw any ERC20 tokens sent to the contract by mistake.
- **withdrawEther**: Allows the contract owner to withdraw any Ether sent to the contract by mistake.

### Events

- **Donation**: Emitted when a donation is made, including the donor's address, the amount donated, and the number of coffees.

### Fallback Functions

- **receive**: Handles unexpected Ether transfers.
- **fallback**: Handles unexpected calls to the contract.

## CLI Application

The CLI application allows users to interact with the CoffeeDonation smart contract. The CLI flow is as follows:

1. Display a welcome message.
2. Prompt the user to enter the recipient's address (with a caution to verify the address carefully).
3. Prompt the user to enter the number of coffees to donate.
4. Perform the donation transaction.
5. Provide a link to the transaction on Etherscan.
6. Confirm the donation and display a success message.
7. Ask the user if they want to make another donation or exit.

### Prerequisites

- Node.js and npm installed.
- Viem library installed (`npm install viem`).
- Inquirer library installed (`npm install inquirer`).
- A `.env` file containing the RPC URL and private key.

### Running the CLI

1. Create a `.env` file in the root directory with the following content:

```env
RPC_URL=YOUR_INFURA_OR_ALCHEMY_URL
PRIVATE_KEY=YOUR_WALLET_PRIVATE_KEY
```

2. Run the CLI:

```bash
node donate-cli.js
```

## Future Development Goals and Concepts

- **Web Interface**: Develop a user-friendly web interface for the donation system, allowing users to interact with the contract without using the CLI.
- **Support for Additional Tokens**: Integrate support for more ERC20 tokens for donations.
- **Enhanced Security Features**: Implement multi-signature wallets and additional security measures to safeguard donations.
- **Analytics Dashboard**: Create a dashboard to track donations, displaying metrics and statistics for transparency and accountability.
- **Mobile Application**: Develop a mobile application to enable donations on the go, providing a seamless user experience.

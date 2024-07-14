// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


// Use openzeppelin to inherit battle-tested implementations (ERC20, ERC721, etc)
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * A smart contract that allows changing a state variable of the contract and tracking the changes
 * It also allows the owner to withdraw the Ether in the contract
 * @author BuidlGuidl
 */
contract CoffeeDonation is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public recipient;
    IERC20 public usdc;
    IERC20 public usdt;
    AggregatorV3Interface internal priceFeed;

    uint256 public coffeePriceUSD = 2.50 * 10**18; // 2.50 USD in wei

    event Donation(address indexed donor, uint256 amount, uint256 coffeeCount);

    constructor(address _recipient, address _usdc, address _usdt, address _priceFeed) {
        require(_recipient != address(0), "Recipient address cannot be zero");
        recipient = _recipient;
        usdc = IERC20(_usdc);
        usdt = IERC20(_usdt);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function donateEther(uint256 coffeeCount) public payable nonReentrant {
        uint256 etherRequired = (coffeePriceUSD * coffeeCount) / getEthPrice();
        require(msg.value >= etherRequired, "Not enough Ether sent");

        (bool success, ) = recipient.call{value: msg.value}("");
        require(success, "Ether transfer failed");

        emit Donation(msg.sender, msg.value, coffeeCount);
    }

    function donateUSDC(uint256 coffeeCount) public nonReentrant {
        uint256 usdcRequired = (coffeePriceUSD * coffeeCount) / (10**usdc.decimals());
        usdc.safeTransferFrom(msg.sender, recipient, usdcRequired);

        emit Donation(msg.sender, usdcRequired, coffeeCount);
    }

    function donateUSDT(uint256 coffeeCount) public nonReentrant {
        uint256 usdtRequired = (coffeePriceUSD * coffeeCount) / (10**usdt.decimals());
        usdt.safeTransferFrom(msg.sender, recipient, usdtRequired);

        emit Donation(msg.sender, usdtRequired, coffeeCount);
    }

    function setRecipient(address _recipient) public onlyOwner {
        require(_recipient != address(0), "Recipient address cannot be zero");
        recipient = _recipient;
    }

    function setCoffeePriceUSD(uint256 _price) public onlyOwner {
        coffeePriceUSD = _price;
    }

    function getEthPrice() public view returns (uint256) {
        (
            /* uint80 roundID */,
            int256 price,
            /* uint256 startedAt */,
            /* uint256 timeStamp */,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();
        // ETH/USD price is returned with 8 decimals by Chainlink, so we scale it to 18 decimals
        return uint256(price * 10**10); // Convert to 18 decimals
    }

    // Function to withdraw any tokens sent to the contract by mistake
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {
        IERC20(tokenAddress).safeTransfer(owner(), amount);
    }

    // Function to withdraw Ether sent to the contract by mistake
    function withdrawEther(uint256 amount) external onlyOwner {
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Ether transfer failed");
    }

    // Fallback function to handle unexpected Ether transfers
    receive() external payable {
        emit Donation(msg.sender, msg.value, msg.value / coffeePriceUSD);
    }

    fallback() external payable {
        emit Donation(msg.sender, msg.value, msg.value / coffeePriceUSD);
    }
}

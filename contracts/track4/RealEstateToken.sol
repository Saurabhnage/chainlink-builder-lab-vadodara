// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title RealEstateToken
/// @notice A beginner-friendly tokenization example where each token represents a share of a property.
/// @dev The rental income feature is intentionally simple and designed for workshops.
contract RealEstateToken is ERC20, Ownable, ReentrancyGuard {
    string public propertyName;
    string public propertyLocation;

    uint256 public immutable initialSupply;
    uint256 public cumulativeRentPerToken;
    uint256 public totalRentalDeposited;

    mapping(address => uint256) public rentDebt;

    event RentalIncomeDeposited(address indexed from, uint256 amountWei, uint256 cumulativeRentPerToken);
    event RentalIncomeClaimed(address indexed account, uint256 amountWei);

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        address treasury,
        uint256 supply,
        string memory _propertyName,
        string memory _propertyLocation
    ) ERC20(tokenName, tokenSymbol) Ownable(msg.sender) {
        require(treasury != address(0), "treasury required");
        require(supply > 0, "supply required");

        propertyName = _propertyName;
        propertyLocation = _propertyLocation;
        initialSupply = supply;

        _mint(treasury, supply);
    }

    function depositRentalIncome() external payable onlyOwner {
        _deposit(msg.value);
    }

    receive() external payable {
        _deposit(msg.value);
    }

    function _deposit(uint256 amountWei) internal {
        require(amountWei > 0, "send ETH");
        require(totalSupply() > 0, "no token holders");

        totalRentalDeposited += amountWei;
        cumulativeRentPerToken += (amountWei * 1e18) / totalSupply();

        emit RentalIncomeDeposited(msg.sender, amountWei, cumulativeRentPerToken);
    }

    function pendingRent(address account) public view returns (uint256) {
        uint256 earned = (balanceOf(account) * cumulativeRentPerToken) / 1e18;
        if (earned <= rentDebt[account]) {
            return 0;
        }
        return earned - rentDebt[account];
    }

    function claimRentalIncome() external nonReentrant {
        uint256 claimable = pendingRent(msg.sender);
        require(claimable > 0, "nothing to claim");

        rentDebt[msg.sender] += claimable;

        (bool sent, ) = payable(msg.sender).call{value: claimable}("");
        require(sent, "rent transfer failed");

        emit RentalIncomeClaimed(msg.sender, claimable);
    }

    /// @notice Workshop helper: sync the claim debt to the current balance after a token transfer demonstration.
    function syncRentDebt(address account) external onlyOwner {
        rentDebt[account] = (balanceOf(account) * cumulativeRentPerToken) / 1e18;
    }
}

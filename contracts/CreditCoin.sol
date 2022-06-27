// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./abstracts/ETHlessTransfer.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @notice A mintable ERC20
 */
contract CreditCoin is AccessControl, ETHlessTransfer {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() public ERC20("Credit Coin", "CTC") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external {
        require(hasRole(MINTER_ROLE, msg.sender), "Only minter can mint");
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}

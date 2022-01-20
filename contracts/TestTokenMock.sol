// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./abstracts/ETHlessTransfer.sol";
/**
 * @notice A mintable ERC20
 */
contract TestTokenMock is ERC20, AccessControl, ETHlessTransfer {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    constructor() public ERC20("Test Token", "TST") {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external {
        require(hasRole(MINTER_ROLE, msg.sender), "Only minter can mint");
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    function ETHlessTransfer(address sender, address recipient, uint256 amount, uint256 fee, uint256 nonce, bytes memory sig)
    public returns (bool success) {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admin can ethless transfer");
       bool res = _transfer(sender, recipient, amount, fee, nonce, sig);
       return res;
    }
}

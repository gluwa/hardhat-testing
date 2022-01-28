// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/cryptography/ECDSA.sol";
import "../libs/GluwacoinModels.sol";
import "../Validate.sol";
/**
 * @dev Extension of {ERC20} that allows users to send ETHless transfer by hiring a transaction relayer to pay the
 * gas fee for them. The relayer gets paid in this ERC20 token for `fee`.
 */
abstract contract ETHlessTransfer is Context, ERC20 {
    using ECDSA for bytes32;

    mapping (address => mapping (uint256 => bool)) private _usedNonces;

    /**
     * @dev Moves `amount` tokens from the `sender`'s account to `recipient`
     * and moves `fee` tokens from the `sender`'s account to a relayer's address.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits two {Transfer} events.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the `sender` must have a balance of at least the sum of `amount` and `fee`.
     * - the `nonce` is only used once per `sender`.
     */
    function transfer(address sender, address recipient, uint256 amount, uint256 fee, uint256 nonce, bytes memory sig)
    public returns (bool success) {
        _useNonce(sender, nonce);
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        // bytes32 hash = keccak256(abi.encodePacked(address(this), sender, recipient, amount, fee, nonce));
        bytes32 hash = keccak256(abi.encodePacked(GluwacoinModels.SigDomain.Transfer,chainId,address(this), 
        sender, recipient, amount, fee, nonce));

        Validate.validateSignature(hash, sender, sig);

        _collect(sender, fee);
        _transfer(sender, recipient, amount);

        return true;
    }
    function checkSig(address sender, address recipient, uint256 amount, uint256 fee, uint256 nonce, bytes memory sig)public view returns(bytes32, address){
        bytes32 hash = keccak256(abi.encodePacked(GluwacoinModels.SigDomain.Transfer,chainID(),address(this), 
        sender, recipient, amount, fee, nonce));
        // bool res= Validate.validateSignature(hash, sender, sig);
        bytes32 messageHash = hash.toEthSignedMessageHash();

        address signer = messageHash.recover(sig);

        return (hash,signer);
    }
    function chainID()public view returns(uint256){
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
    /* @dev Uses `nonce` for the signer.
    */
    function _useNonce(address signer, uint256 nonce) private {
        require(!_usedNonces[signer][nonce], "ETHless: the nonce has already been used for this address");
        _usedNonces[signer][nonce] = true;
    }

    /** @dev Collects `fee` from the sender.
     *
     * Emits a {Transfer} event.
     */
    function _collect(address sender, uint256 amount) internal {
        _transfer(sender, _msgSender(), amount);
    }
}

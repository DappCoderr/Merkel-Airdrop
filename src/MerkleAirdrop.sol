// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {IERC20, SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712{

    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    address[] public claimers;

    bytes32 private immutable i_merkleProof;
    IERC20 private immutable i_airDropToken;

    mapping (address => bool) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim{
        address account;
        uint256 amount;
    }

    event claimed(address account, uint256 amount);

    constructor(bytes32 merkleProof, IERC20 airDropToken) EIP712("MerkleAirdrop", "1"){
        i_merkleProof = merkleProof;
        i_airDropToken = airDropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s) external {
        if(s_hasClaimed[account]){
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if(!_isValidSignature(account, getMessageHash(account, amount), v,r,s)){
            revert MerkleAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if(MerkleProof.verify(merkleProof, i_merkleProof, leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
        emit claimed(account, amount);
        i_airDropToken.transfer(account, amount);
        s_hasClaimed[account] = true;
    }

    function getMessageHash(address account, uint256 amount) public view returns(bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account:account, amount:amount})))
        );
    }

    function getMerkleProof() external view returns(bytes32){
        return i_merkleProof;
    }

    function getAirdropToken() external view returns(IERC20) {
        return i_airDropToken;
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal pure returns(bool){
        (address actualSigner, ,) = ECDSA.tryRecover(digest, v,r,s);
        return actualSigner == account;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {IERC20, SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop{

    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidProof();

    address[] public claimers;

    bytes32 private immutable i_merkleProof;
    IERC20 private immutable i_airDropToken;

    event claimed(address account, uint256 amount);

    constructor(bytes32 merkleProof, IERC20 airDropToken){
        i_merkleProof = merkleProof;
        i_airDropToken = airDropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if(MerkleProof.verify(merkleProof, i_merkleProof, leaf)){
            revert MerkleAirdrop__InvalidProof();
        }
        emit claimed(account, amount);
        i_airDropToken.transfer(account, amount);
    }

}
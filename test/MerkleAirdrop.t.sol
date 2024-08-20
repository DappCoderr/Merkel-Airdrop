// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {WagmiToken} from "src/WagmiToken.sol";

contract MerkleAirdropTest is Test{
    
    MerkleAirdrop public airdrop;
    WagmiToken public token;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address user;
    uint256 userPrivateKey;

    function setup() public {
        airdrop = new MerkleAirdrop(ROOT ,token);
        token = new WagmiToken();
        (user, userPrivateKey) = makeAddrAndKey("user");
    }

    function testUserCanClaim() public view {
        console.log("user address", user);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {WagmiToken} from "src/WagmiToken.sol";

contract MerkleAirdropTest is Test{
    
    MerkleAirdrop public airdrop;
    WagmiToken public token;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 public proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne,proofTwo];
    address public gasPayer;
    address user;
    uint256 userPrivateKey;

    function setup() public {
        airdrop = new MerkleAirdrop(ROOT ,token);
        token = new WagmiToken();
        token.mint(token.owner(), AMOUNT_TO_SEND);
        token.transfer(address(airdrop), AMOUNT_TO_SEND);
        (user, userPrivateKey) = makeAddrAndKey("Alice");
        gasPayer = makeAddr("gasPayer");

    }

    function testUserCanClaim() public {
        console.log("user address", user);
        uint256 startingBalance = token.balanceOf(user); 
        console.log("Starting Balance", startingBalance);

        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        // vm.prank(user);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v,r,s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending Balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
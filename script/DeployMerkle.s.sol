//SPDX-Licence-Identifier:MIT

pragma solidity ^0.8.13;

import {Script} from "lib/forge-std/src/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {WagmiToken} from "src/WagmiToken.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract DeployMerkle is Script {
    bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToAirdrop = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns(MerkleAirdrop, WagmiToken){
        vm.startBroadcast();
        WagmiToken token = new WagmiToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToAirdrop);
        token.transfer(address(airdrop),s_amountToAirdrop);
        vm.stopBroadcast();
        return(airdrop, token);
    }

    function run() external returns(MerkleAirdrop, WagmiToken){
        return deployMerkleAirdrop();
    }
}
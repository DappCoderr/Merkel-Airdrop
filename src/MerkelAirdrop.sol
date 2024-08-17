// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MerkelAirdrop{

    address[] public claimers;

    bytes32 private immutable i_merkelProof;
    IERC20 private immutable i_airDropToken;

    constructor(bytes32 merkelProof, IERC20 airDropToken){
        i_merkelProof = merkelProof;
        i_airDropToken = airDropToken;
    }

    function claim(bytes32 merkelProof, uint256 amount, bytes32[] calldata ) external{}

}
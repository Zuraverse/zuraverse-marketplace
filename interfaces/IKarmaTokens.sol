//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IKarmaTokens {

    function safeMint(address account, uint256 value) external ;
    function safeBurn(address account, uint256 value) external; 
}
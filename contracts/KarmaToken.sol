//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IKarmaTokens.sol";

contract KarmaToken is ERC20, IKarmaTokens{

    constructor()ERC20("Karma Token", "KP"){}

    function safeMint(address account, uint256 value) external {  // as we can't use internal function in interface so created a cover name safeMint
        _mint(account, value);
    }

    function safeBurn(address account, uint256 value) external {
        _burn(account, value);
    }

    
    function transfer(address to, uint256 value) public override returns (bool) {
        address owner = _msgSender();
        _beforeTokenTransfer(owner, to, value);
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        address spender = _msgSender();
        _beforeTokenTransfer(from, to, value);
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal pure override {
        require(from == address(0));
        require(to == address(0));
        require(amount == 0);
    }

}
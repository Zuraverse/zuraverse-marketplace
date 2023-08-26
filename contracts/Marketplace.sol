// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IKarmaTokens.sol";

import "./interface/IZura.sol";
import "./interface/IHack.sol";

import "hardhat/console.sol";

contract ZuraverseMarketplace is Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 listingPrice = 0.025 ether;

    mapping(uint256 => ZuraNFT) private ZuraNFTMarketList;
    mapping(uint256 => HackNFT) private HackNFTMarketList;

    struct ZuraNFT {
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
    }

    event ZuraNFTCreated (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price,
      bool sold
    );

    struct HackNFT {
      uint256 tokenId;
      address payable seller;
      address payable owner;
      uint256 price;
      bool sold;
    }

    event HackNFTCreated (
      uint256 indexed tokenId,
      address seller,
      address owner,
      uint256 price,
      bool sold
    );

    IZura immutable public Zura;
    IHack immutable public Hack;
    IKarmaTokens immutable public karmaTokens;

    constructor(address _zura, address _hack, address KarmaToken) {    // Updated constructor for karma token
        Zura = IZura(_zura);
        Hack = IHack(_hack);
        karmaTokens = IKarmaTokens(KarmaToken);
    }

    /* Mints a token and lists it in the marketplace */
    function mintZuraNFT(string memory _tokenURI, uint256 price) external payable returns (uint) {
      uint newTokenId = Zura.safeMint(msg.sender, _tokenURI);
      listZura(newTokenId, price);
      return newTokenId;
    }

    function mintHackNFT(string memory _tokenURI, uint256 price) external payable returns (uint) {
      uint newTokenId = Hack.safeMint(msg.sender, _tokenURI);
      listHack(newTokenId, price);
      return newTokenId;
    }

    function listZura(
      uint256 tokenId,
      uint256 price
    ) private {
      require(price > 0, "0 price");
      require(msg.value == listingPrice, "Price != listing price");

      ZuraNFTMarketList[tokenId] =  ZuraNFT(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        price,
        false
      );

      Zura.safeTransferFrom(msg.sender, address(this), tokenId);
      emit ZuraNFTCreated(
        tokenId,
        msg.sender,
        address(this),
        price,
        false
      );
    }

    function listHack(
      uint256 tokenId,
      uint256 price
    ) private {
      require(price > 0, "0 price");
      require(msg.value == listingPrice, "Price != listing price");

      HackNFTMarketList[tokenId] =  HackNFT(
        tokenId,
        payable(msg.sender),
        payable(address(this)),
        price,
        false
      );

      Hack.safeTransferFrom(msg.sender, address(this), tokenId);
      emit HackNFTCreated(
        tokenId,
        msg.sender,
        address(this),
        price,
        false
      );
    }

    // Added functionality for karma token, assuming karmaToken will be minted from UI
    
    function mintKarmaToken(uint256 value) external {
      require(msg.sender.code.length < 0 && msg.sender != address(0), "Only callable by EOAs");
      require(value >= 1000, "Only 1000 karma token can be minted at once");   // We can change as per our need
      karmaToken.safeMint(msg.sender, value);
    }
     
    function redeemTokens(uint256 value) external {
      require(msg.sender.code.length < 0 && msg.sender != address(0), "Only callable by EOAs");
      require(value <= 1000 && value >= 10000);
      karmaToken.safeBurn(msg.sender, value);
    }
}
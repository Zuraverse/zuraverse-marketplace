// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Hack is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, ReentrancyGuard {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter; // Count minted tokens

    uint256 private immutable Hack_Max_Supply;   // Max HACK NFT supply

    uint private immutable Whitelist_Limit; // Max free NFTs

    uint256 private listPrice ;     //List price

    uint256 private specialPrice;

    bool private paidMintAllowed; // param to start/stop paid minting

    bool private whitelistMintAllowed;  // param to start/stop whitelist minting

    bool private specialMintAllowed; 

    uint private mintFrom; // The id from where minting is allowed in that round

    uint private mintUpto; // The id upto which minting is allowed in that round

    bytes32 private merkleRoot ;  // root to be generated from a function            

    mapping(address => bool) public whitelistClaimed; // True once Whitelist claimed

    mapping(address => bool) public specialMintClaimed;

    mapping(uint => bool) public tokenMintStatus; // True once minted

    /// @param maxWhitelistNfts total number of whitelisted nfts
    /// @param _listPrice price in eth for paid NFTs. This can be updated anytime
    /// @param _maxAmount total supply of HACK nfts
    constructor(uint maxWhitelistNfts, uint _listPrice , uint _maxAmount) 
    ERC721("Hippie Alien Cosmic Klub", "HACK") {
        require(_maxAmount>=maxWhitelistNfts, "Hack_Max_Supply<maxWhitelistNfts");
        require(maxWhitelistNfts>0, "maxWhitelistNfts<1");
        require(_listPrice >= 10000000000000000, "listPrice<1gwei");
        Whitelist_Limit = maxWhitelistNfts;
        mintFrom = 1;
        mintUpto = maxWhitelistNfts;
        listPrice = _listPrice;
        Hack_Max_Supply = _maxAmount;
        whitelistMintAllowed = true;
    }

    /** Modifiers */

    modifier whenNotPaused(bool mint_type) {
        _requireNotPaused(mint_type);
        _;
    }

    modifier validateMintId(uint id) {
        require(id>0 && id<= Hack_Max_Supply,"Invalid Token Id");
        require(id >= getMintFromId() && id <= getMintUptoId(), "Token Id Out of Range");
        _;
    }

    /** Getter functions */ 

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeibcm4jp3cdchok6wf2t4jyx3g2qljavnpsjmq3ip3fednayle4yoy/";
    }

    function isPaidMintAllowed() public view returns (bool) {
        return paidMintAllowed;
    }

    function isWhitelistMintAllowed() public view returns (bool) {
        return whitelistMintAllowed;
    }

    function isSpecialMintAllowed() public view returns (bool) {
        return specialMintAllowed;
    }

    function getListPrice() public view returns (uint256) {
        return listPrice;
    }

    function getSpecialPrice() public view returns (uint256) {
        return specialPrice;
    }

    function getMintFromId() view public returns (uint) {
        return mintFrom;
    }

    function getMintUptoId() view public returns (uint) {
        return mintUpto;
    }

    function getMaxWhitelist() public view returns(uint){
        return Whitelist_Limit;
    }

    function getMerkleRoot() public view returns(bytes32){
        return merkleRoot;
    }

    function totalTokensMinted() public view returns (uint) {
        return _tokenIdCounter.current();
    }

    /** Setter functions */

    function allowWhitelistMinting(bool _pause) public onlyOwner {
        whitelistMintAllowed = _pause;
    }

    function allowSpecialMinting(bool _pause) public onlyOwner {
        specialMintAllowed = _pause;
    }

    function allowPaidMinting(bool _pause) public onlyOwner {
        paidMintAllowed = _pause;
    }

    // Function for updating listing price
    function updateListPrice(uint256 _listPrice) external onlyOwner {
        listPrice = _listPrice;
    }

    // specialPrice
    function updateSpecialPrice(uint256 _price) external onlyOwner {
        specialPrice = _price;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setMintIdsPerRound(uint _from, uint _upto) external onlyOwner {
        require(_from>0 && _upto > _from, "Invalid id values");
        require(_upto <=Hack_Max_Supply, "overflow TOTAL_SUPPLY");
        mintFrom = _from;
        mintUpto = _upto;
    }

    function freeMint(uint256 currentTokenId, string memory uri, bytes32[] calldata _merkleProof) public whenNotPaused(whitelistMintAllowed) {
        require(!whitelistClaimed[msg.sender],"Address has already claimed.");
        require(totalTokensMinted() <= getMaxWhitelist(),"Max free mints limit reached.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof , merkleRoot , leaf), "invalid proof.");
  
        whitelistClaimed[msg.sender] = true;

        _mint(msg.sender, currentTokenId, uri);

    }

    function mint(uint256 currentTokenId, string memory uri) external payable whenNotPaused(paidMintAllowed) {
        
        require(msg.value >= listPrice , "Send enough ether to list");
         _mint(msg.sender, currentTokenId, uri);

    }

    function specialMint(uint256 currentTokenId, string memory uri, bytes32[] calldata _merkleProof) external payable whenNotPaused(specialMintAllowed) {
        require(!specialMintClaimed[msg.sender],"Address has already claimed.");
        require(totalTokensMinted() <= getMaxWhitelist(),"Max free mints limit reached.");
        require(msg.value >= specialPrice , "lower than specialPrice");
        require(!whitelistMintAllowed, "Not allowed during whitelist round");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof , merkleRoot , leaf), "invalid proof.");
  
        specialMintClaimed[msg.sender] = true;

        _mint(msg.sender, currentTokenId, uri);
    }

    function _mint(address to, uint256 tokenId, string memory uri) private nonReentrant validateMintId(tokenId) {
        assert(tokenMintStatus[tokenId] == false);
        assert(tokenId>=mintFrom && tokenId<=mintUpto);
        tokenMintStatus[tokenId] = true;
        _safeMint(to,tokenId);
        _setTokenURI(tokenId, uri);
        _tokenIdCounter.increment();
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused(bool mint_type) internal view virtual {
        require((mint_type == paidMintAllowed || mint_type == whitelistMintAllowed) && mint_type, "Pausable: paused");
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
   
}
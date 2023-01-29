// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Hack is ERC721, ERC721URIStorage, ERC721Burnable, Ownable, ReentrancyGuard {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    Counters.Counter private _mintByInstallmentCounter;

    uint256 private MINT_TRACKER;

    uint256 private immutable Max_Token;   // Max supply

    uint256 private listPrice ;     //List price

    bool private allowMint;  

    uint private immutable freeLimit;

    uint private immutable freeLimitPeriod; // Max time period of free minting. Ex - 10 minutes, 3 days etc 

    uint private immutable genesisTime; // time at which contract was deployed

    bytes32 private merkleRoot ;  // root to be generated from a function            

    mapping(address => bool) public whitelistClaimed;

    constructor(uint _freeLimit , uint _listPrice , uint _maxToken , uint _MINT_TRACKER, uint _freeLimitPeriod) ERC721("Hack NFT", "HACK") {
        freeLimit = _freeLimit;
        listPrice = _listPrice;
        Max_Token = _maxToken;
        MINT_TRACKER = _MINT_TRACKER;
        genesisTime = block.timestamp;
        freeLimitPeriod = _freeLimitPeriod;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "infura";
    }

    // Getter function for Listing price 

    function getListprice() public view returns (uint256) {
        return listPrice;
    }

    function mintInstallemntcounter() public view returns(uint){
        return _mintByInstallmentCounter.current();
    }

    function getFreeLimit() public view returns(uint){
        return freeLimit;
    }

    function getMerkleRoot() public view returns(bytes32){
        return merkleRoot;
    }

    // Function for updating listing price

    function updateListPrice(uint256 _listPrice) external onlyOwner payable {
        listPrice = _listPrice;
    }

    // Function for re-allow minting after the installment is over

    function allowMinting(bool _allow) external onlyOwner{
        allowMint = _allow;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function freeMint(address to, string memory uri, bytes32[] calldata _merkleProof) public nonReentrant {
        require(!whitelistClaimed[msg.sender],"Address has already claimed.");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(_merkleProof , merkleRoot , leaf), "invalid proof.");

        uint256 currentTokenId = _tokenIdCounter.current();
        require(currentTokenId <= getFreeLimit(), "No free mints"); 
        
        whitelistClaimed[msg.sender] = true;

        _mint(to, uri);

    }

    function _mint(address to, string memory uri) private {

        require(allowMint == true, "Mint not allowed");
        _mintByInstallmentCounter.increment();
        uint256 currentMintByInstallmentCounter = _mintByInstallmentCounter.current();

         if(currentMintByInstallmentCounter == MINT_TRACKER) {
            _mintByInstallmentCounter.reset();
            allowMint = false;
        }

        _tokenIdCounter.increment();
        uint256 currentTokenId = _tokenIdCounter.current();
        
        require(currentTokenId<= Max_Token,"maximum limit reached");

        _safeMint(to,currentTokenId);
        _setTokenURI(currentTokenId, uri);

    }

    function safeMint(string memory uri) external payable nonReentrant returns(uint) {
        
        uint256 currentTokenId = _tokenIdCounter.current();
        require(block.timestamp < genesisTime + freeLimitPeriod || currentTokenId >= freeLimit, "After free mints"); // This function can be only called after 1k link
        
        require(msg.value >= listPrice , "Send enough ether to list");

         _mint(msg.sender, uri);
   
        return currentTokenId;
    }
    
    function setMaxMintPerRound(uint _maxMints) external onlyOwner {
        require(_maxMints>0, "0 maxMints");
        uint256 currentTokenId = _tokenIdCounter.current();
        require(currentTokenId + _maxMints <= Max_Token, "overflow TOTAL_SUPPLY");
        MINT_TRACKER = _maxMints;
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
}
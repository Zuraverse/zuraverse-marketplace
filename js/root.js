const { MerkleTree } = require('merkletreejs')

const keccak256 = require('keccak256')

const whitelistedAddresses = [
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
    "0x617F2E2fD72FD9D5503197092aC168c91465E7f2"
]

const leafNodes = whitelistedAddresses.map(addr=>keccak256(addr))

console.log("leafNodes:", leafNodes);

const merkleTree = new MerkleTree(leafNodes, keccak256, {sortPairs:true})

//const roothash = merkleTree.getRoot().toString('bytes');

//console.log(roothash);

console.log("---------");
console.log("Merke Tree");
console.log("---------");
console.log(merkleTree.toString());
console.log("---------");
console.log("Merkle Root: " + merkleTree.getHexRoot());

console.log("Proof 1: " + merkleTree.getHexProof(leafNodes[0]));
console.log("Proof 2: " + merkleTree.getHexProof(leafNodes[1]));
console.log("Proof 3: " + merkleTree.getHexProof(leafNodes[2]));
console.log("Proof 4: " + merkleTree.getHexProof(leafNodes[3]));

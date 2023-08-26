const { MerkleTree } = require('merkletreejs')

const keccak256 = require('keccak256')
//const SHA256 = require('crypto-js/sha256')

const whitelistedAddresses = [
   "0x854c57378aeC619fe5507c656A8986a7CFc25f9e",
   "0xb1A610817c1e2649aE5Ce6E29Bd57A0887Df48fF",
   "0x00Dd4cE8a3Ba697a17c079589004446d267435df",
   "0x72e90C673D456FaC8f4D5E65A18c443554d1F434",
   "0x35c4da0D9032e2EfbC0FF43741B4261A38FA6E02",
   "0xe42f43004B3Cd525c414852C0A26f6ba98420759",
   "0x3c3142393C07bb5E91d42DA2DcD6Be299c1Dbc2a",
   "0x949492F1E84a9C7c0CA60AC442c85ED6FfeDF40d",
   "0x512aC4F5b92ce3F8735CedA491360a01f5F9A7d6",
   "0xD401cf6c0aCd13A210D50cdC56FdFAB8607a3A97",
   "0x7Eb4f000253a2EED86223b2a5d2E36582A10b62f",
   "0xb1A610817c1e2649aE5Ce6E29Bd57A0887Df48fF"
]

// const whitelistedAddresses = [
//     //"0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
//     //"0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
//     //"0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
//     "0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678"
// ]

const leafNodes = whitelistedAddresses.map(addr=>keccak256(addr))

//console.log("leafNodes:", leafNodes);

const merkleTree = new MerkleTree(leafNodes, keccak256, {sortPairs:true})

//const roothash = merkleTree.getRoot().toString('bytes');

//console.log(roothash);

console.log("---------");
console.log("Merke Tree");
console.log("---------");
console.log(merkleTree.toString());
console.log("---------");
console.log("Merkle Root: " + merkleTree.getHexRoot());

for (let i = 0; i < whitelistedAddresses.length; i++) {
    console.log("Proof "+i);
    console.log(`${whitelistedAddresses[i]}, "/${i}.json", ${JSON.stringify(merkleTree.getHexProof(leafNodes[i]).toString().split(','))}`);
}



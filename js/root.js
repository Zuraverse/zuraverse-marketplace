const { MerkleTree } = require('merkletreejs')

const keccak256 = require('keccak256')
//const SHA256 = require('crypto-js/sha256')

// const whitelistedAddresses = [
//     "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
//     "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
//     "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
//     // "0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
//     // "0x17F6AD8Ef982297579C203069C1DbfFE4348c372",
//     // "0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678",
//     // "0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7",
//     // "0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C",
//     // "0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC",
//     // "0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c"
//     "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
//     "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"
// ]

const whitelistedAddresses = [
    "0x512aC4F5b92ce3F8735CedA491360a01f5F9A7d6",
    "0x35c4da0D9032e2EfbC0FF43741B4261A38FA6E02",
    //"0x00Dd4cE8a3Ba697a17c079589004446d267435df"
]

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



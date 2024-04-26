// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract CollectionNFT is ERC721URIStorage {
    string private decription;
    string private baseUri;

    constructor(string memory name, string memory symbol, string memory desc, string memory uri) ERC721(name, symbol) {
        decription = desc;
        baseUri = uri;
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";

contract CollectionNFT is ERC721URIStorage, Ownable {
    string private decription;
    string private baseUri;

    constructor(string memory name, string memory symbol, string memory desc, string memory uri, address _owner) ERC721(name, symbol) Ownable(_owner) {
        decription = desc;
        baseUri = uri;
    }

    
}

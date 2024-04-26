// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {IMarkkinatNFT} from "../interfaces/IMarkkinatNFT.sol";
import {ERC721} from "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MarkkinatNFTFactory is ERC721URIStorage {
    address private owner;
    IMarkkinatNFT private iMarkkinatNFT;

    constructor(address _owner, address _collection) ERC721URIStorage() {
        owner = _owner;
        iMarkkinatNFT = IMarkkinatNFT(_collection);
    }

    function createCollection(address _creator, string calldata _name, string calldata symbol, string calldata desc)
        external
    {}
}

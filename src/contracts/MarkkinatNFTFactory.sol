// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import { IMarkkinatNFT } from "../interfaces/IMarkkinatNFT.sol";


contract MarkkinatNFTFactory {

    address private owner;
    IMarkkinatNFT private iMarkkinatNFT;

    constructor(address _owner, address _collection) {
        owner = _owner;
        iMarkkinatNFT = IMarkkinatNFT(_collection);
    }

    function createCollection(address _creator, string calldata _name, string calldata symbol) external {

    }
}
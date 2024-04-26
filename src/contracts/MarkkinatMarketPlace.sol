// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import { IMarkkinatNFTFactory } from "./interfaces/IMarkkinatNFTFactory.sol";

contract MarkkinatMarketPlace {
    
    IMarkkinatNFTFactory private iMarkkinatFactory;

    constructor(address nftFactory) {
        iMarkkinatFactory = IMarkkinatNFTFactory(nftFactory);
    }
}

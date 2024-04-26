// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import {Test} from "lib/forge-std/src/Test.sol";
import {MarkkinatMarketPlace} from "src/contracts/MarkkinatMarketPlace.sol";

contract MarkkinatMarketPlaceTest is Test {
    MarkkinatMarketPlace private marketPlace;
    function setUp() external {
        marketPlace = new MarkkinatMarketPlace();
    }
}

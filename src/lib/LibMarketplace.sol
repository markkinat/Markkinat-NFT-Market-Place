// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library LibMarketPlaceEvents {}

library LibMarketPlaceErrors {
    error RecordExists();
    error NotOwner();
    error NotOwnerOrHighestBidder();
    error RecordDoesNotExist();
    error InvalidCategory();
    error InvalidTime();
    error MustBeContract();
    error MarketPlaceNotApproved();
    error CantUpdateIfStatusNotCreated();
    error CantCancelCompletedListing();
    error ListingAlreadyCompleted();
    error CantUpdate();
    error StatusMustBeCreated();
    error NotReservedTokenId();
    error NotReservedAddress();
    error InvalidCurrency();
    error IncorrectPrice();
    error AuctionEnded();
    error AuctionNotStarted();
    error AuctionStillInProgress();
    error InvalidAddress();
    error NoAuction();
}

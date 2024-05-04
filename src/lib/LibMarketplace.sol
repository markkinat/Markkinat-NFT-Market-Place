// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library LibMarketPlaceEvents {
    event CreateListingSucessful(uint256 indexed, address);
    event ListingUpdatedSuccessfully(uint256 indexed, address, uint);
    event ListingCancelledSuccessfully(uint indexed);
    event ApproveListingCurrency(uint indexed, address, uint);
    event BuyListing(uint indexed, address indexed, uint);
    event CreateAuction(uint, address, uint);
    event AuctionCompleteBuyout(uint indexed, address indexed, uint);
    event BidSuccessfullyPlaced(uint indexed, address indexed, uint);
    event AuctionCancelledSuccessfully(uint indexed);
    event AuctionPayout(uint indexed, address indexed, uint, uint);
}

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

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

// we have two tyoes if listing
// 1. Direct listing & EnglishAuctions
contract MarkkinatMarketPlace {
    struct ListingParameters {
        address assetContract;
        uint256 tokenId;
        uint256 quantity;
        address currency;
        uint256 pricePerToken;
        uint128 startTimestamp;
        uint128 endTimestamp;
        bool reserved;
    }

    enum TokenType {
        ERC721,
        ERC1155
    }

    enum Status {
        UNSET,
        CREATED,
        COMPLETED,
        CANCELLED
    }

    struct Listing {
        uint256 listingId;
        address listingCreator;
        address assetContract;
        uint256 tokenId;
        uint256 quantity;
        address currency;
        uint256 pricePerToken;
        uint128 startTimestamp;
        uint128 endTimestamp;
        bool reserved;
        TokenType tokenType;
        Status status;
    }

    struct AuctionParameters {
        address assetContract;
        uint256 tokenId;
        uint256 quantity;
        address currency;
        uint256 minimumBidAmount;
        uint256 buyoutBidAmount;
        uint64 timeBufferInSeconds;
        uint64 bidBufferBps;
        uint64 startTimestamp;
        uint64 endTimestamp;
    }

    struct Auction {
        uint256 auctionId;
        address auctionCreator;
        address assetContract;
        uint256 tokenId;
        uint256 quantity;
        address currency;
        uint256 minimumBidAmount;
        uint256 buyoutBidAmount;
        uint64 timeBufferInSeconds;
        uint64 bidBufferBps;
        uint64 startTimestamp;
        uint64 endTimestamp;
        TokenType tokenType;
        Status status;
    }

    struct OfferParams {
  address assetContract;
  uint256 tokenId;
  uint256 quantity;
  address currency;
  uint256 totalPrice;
  uint256 expirationTimestamp;
}


    function createAuction(AuctionParameters memory params) external returns (uint256 auctionId);

    constructor() {}

    function createListing(ListingParameters memory params) external returns (uint256 listingId);

    function updateListing(uint256 listingId, ListingParameters memory params) external;

    function cancelListing(uint256 listingId) external;

    function approveCurrencyForListing(uint256 listingId, address currency, uint256 pricePerTokenInCurrency) external;

    function buyFromListing(
        uint256 listingId,
        address buyFor,
        uint256 quantity,
        address currency,
        uint256 expectedTotalPrice
    ) external payable;

    function totalListings() external view returns (uint256);

    function getAllListings(uint256 startId, uint256 endId) external view returns (Listing[] memory listings);

    function getAllValidListings(uint256 startId, uint256 endId) external view returns (Listing[] memory listings); //active listings

    function getListing(uint256 listingId) external view returns (Listing memory listing);

    //Auction
    function createAuction(AuctionParameters memory params) external returns (uint256 auctionId);

    function cancelAuction(uint256 auctionId) external;

    function collectAuctionPayout(uint256 auctionId) external;

    function bidInAuction(uint256 auctionId, uint256 bidAmount) external payable;

    function collectAuctionTokens(uint256 auctionId) external;

    function isNewWinningBid(uint256 auctionId, uint256 bidAmount) external view returns (bool);

    function totalAuctions() external view returns (uint256);

    function getAuction(uint256 auctionId) external view returns (Auction memory auction);

    function getAllAuctions(uint256 startId, uint256 endId) external view returns (Auction[] memory auctions);

    function getAllValidAuctions(uint256 startId, uint256 endId) external view returns (Auction[] memory auctions);

    function getWinningBid(uint256 auctionId)
  external
  view
  returns (
    address bidder,
    address currency,
    uint256 bidAmount
  );

function isAuctionExpired(uint256 auctionId) external view returns (bool);

function makeOffer(OfferParams memory params) external returns (uint256 offerId);

function cancelOffer(uint256 offerId) external;

function acceptOffer(uint256 offerId) external;

function cancelOffer(uint256 offerId) external;

function acceptOffer(uint256 offerId) external;

function totalOffers() external view returns (uint256);

struct Offer {
  uint256 offerId;
  address offeror;
  address assetContract;
  uint256 tokenId;
  uint256 quantity;
  address currency;
  uint256 totalPrice;
  uint256 expirationTimestamp;
  TokenType tokenType;
  Status status;
}

function getOffer(uint256 offerId) external view returns (Offer memory offer);

function getAllOffers(uint256 startId, uint256 endId) external view returns (Offer[] memory offers);

function getAllValidOffer(uint256 startId, uint256 endId) external view returns (Offer[] memory offers);




}

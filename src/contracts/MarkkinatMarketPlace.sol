// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../interfaces/IERC721.sol";

import {LibMarketPlaceErrors} from "../lib/LibMarketplace.sol";

// we have two tyoes if listing
// 1. Direct listing & EnglishAuctions
contract MarkkinatMarketPlace {
    // AUCTION MARKETPLACE
    uint256 auctionIndex;
    address daoAddress;
    address teamAddress;

    Auction[] public allAuctions;
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
        // uint256 quantity;
        address currency;
        uint256 minimumBidAmount;
        uint256 buyoutBidAmount;
        uint64 startTimestamp;
        uint64 endTimestamp;
        TokenType tokenType;
    }

    struct Auction {
        uint256 auctionId;
        address auctionCreator;
        address assetContract;
        uint256 tokenId;
        // uint256 quantity;
        address currency;
        address currentBidOwner;
        uint256 currentBidPrice;
        uint256 minimumBidAmount;
        uint256 buyoutBidAmount;
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

    constructor() {}

    function createAuction(
        AuctionParameters memory params
    ) external returns (uint256 auctionId) {
        // wea re taking only erc 721 for now
        if (params.tokenType != TokenType.ERC721)
            revert LibMarketPlaceErrors.InvalidCategory();

        if (
            params.startTimestamp > block.timestamp ||
            params.startTimestamp >= params.endTimestamp
        ) revert LibMarketPlaceErrors.InvalidTime();

        if (!isContract(params.assetContract))
            revert LibMarketPlaceErrors.MustBeContract();

        IERC721 nftCollection = IERC721(params.assetContract);

        // check onwner of nft
        if (nftCollection.ownerOf(params.tokenId))
            revert LibMarketPlaceErrors.NotOwner();

        // check if owner has approved the marketplace to transfer the NFT
        require(
            nftCollection.getApproved(params.tokenId) == address(this),
            "AuctionMarketPlace: not approved to transfer NFT"
        );

        if (!nftCollection.getApproved(params.tokenId) == address(this))
            revert LibMarketPlaceErrors.MarketPlaceNotApproved();

        nftCollection.transferFrom(msg.sender, address(this), params.tokenId);

        address payable currentBidOwner = payable(address(0));

        Auction memory auction = Auction({
            auctionId: auctionIndex,
            auctionCreator: msg.sender,
            assetContract: params.assetContract,
            tokenId: params.tokenId,
            currency: params.currency,
            currentBidOwner: currentBidOwner,
            currentBidPrice: 0,
            minimumBidAmount: params.minimumBidAmount,
            buyoutBidAmount: params.buyoutBidAmount,
            startTimestamp: params.startTimestamp,
            endTimestamp: params.endTimestamp,
            TokenType: params.tokenType,
            Status: Status.CREATED
        });
    }

    function createListing(
        ListingParameters memory params
    ) external returns (uint256 listingId);

    function updateListing(
        uint256 listingId,
        ListingParameters memory params
    ) external;

    function cancelListing(uint256 listingId) external;

    function approveCurrencyForListing(
        uint256 listingId,
        address currency,
        uint256 pricePerTokenInCurrency
    ) external;

    function buyFromListing(
        uint256 listingId,
        address buyFor,
        uint256 quantity,
        address currency,
        uint256 expectedTotalPrice
    ) external payable;

    function totalListings() external view returns (uint256);

    function getAllListings(
        uint256 startId,
        uint256 endId
    ) external view returns (Listing[] memory listings);

    function getAllValidListings(
        uint256 startId,
        uint256 endId
    ) external view returns (Listing[] memory listings); //active listings

    function getListing(
        uint256 listingId
    ) external view returns (Listing memory listing);

    //Auction
    function createAuction(
        AuctionParameters memory params
    ) external returns (uint256 auctionId);

    function cancelAuction(uint256 auctionId) external;

    function collectAuctionPayout(uint256 auctionId) external;

    function bidInAuction(
        uint256 auctionId,
        uint256 bidAmount
    ) external payable;

    function collectAuctionTokens(uint256 auctionId) external;

    function isNewWinningBid(
        uint256 auctionId,
        uint256 bidAmount
    ) external view returns (bool);

    function totalAuctions() external view returns (uint256);

    function getAuction(
        uint256 auctionId
    ) external view returns (Auction memory auction);

    function getAllAuctions(
        uint256 startId,
        uint256 endId
    ) external view returns (Auction[] memory auctions);

    function getAllValidAuctions(
        uint256 startId,
        uint256 endId
    ) external view returns (Auction[] memory auctions);

    function getWinningBid(
        uint256 auctionId
    )
        external
        view
        returns (address bidder, address currency, uint256 bidAmount);

    function isAuctionExpired(uint256 auctionId) external view returns (bool);

    function makeOffer(
        OfferParams memory params
    ) external returns (uint256 offerId);

    function cancelOffer(uint256 offerId) external;

    function acceptOffer(uint256 offerId) external;

    function cancelOffer(uint256 offerId) external;

    function acceptOffer(uint256 offerId) external;

    function totalOffers() external view returns (uint256);

    function getOffer(
        uint256 offerId
    ) external view returns (Offer memory offer);

    function getAllOffers(
        uint256 startId,
        uint256 endId
    ) external view returns (Offer[] memory offers);

    function getAllValidOffer(
        uint256 startId,
        uint256 endId
    ) external view returns (Offer[] memory offers);

    function isContract(
        address _addr
    ) internal view returns (bool addressCheck) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        addressCheck = (size > 0);
    }
}

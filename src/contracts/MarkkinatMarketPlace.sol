// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../interfaces/IERC721.sol";
import "../interfaces/IERC20.sol";

import {LibMarketPlaceErrors} from "../lib/LibMarketplace.sol";

// we have two tyoes if listing
// 1. Direct listing & EnglishAuctions
contract MarkkinatMarketPlace {
    uint256 auctionIndex;
    uint256 listingIndex;
    address daoAddress;
    address teamAddress;

    Auction[] public allAuctions;
    Listing[] public allListings;

    mapping(uint256 => mapping(address => bool)) private reservedFor;
    mapping(uint256 => mapping(address => uint256)) private reservedForTokenId;

    mapping(uint256 => mapping(address => bool)) private approvedCurrencyForListing;
    mapping(uint256 => mapping(address => uint256)) private approvedCurrencyForAmount;

    // mapping(uint256 => Auction) public auctions;
    // mapping(uint256 => Listing) public listings;

    enum TokenType {
        ERC721,
        ERC1155
    }

    enum Status {
        CREATED,
        COMPLETED,
        CANCELLED
    }

    struct ListingParameters {
        address assetContract;
        uint256 tokenId;
        uint256 quantity;
        address currency;
        uint256 price;
        uint128 startTimestamp;
        uint128 endTimestamp;
        bool reserved;
        TokenType tokenType;
    }

    struct Listing {
        uint256 listingId;
        address listingCreator;
        address assetContract;
        uint256 tokenId;
        // uint256 quantity;
        address currency;
        uint256 price;
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

    modifier isAuctionExpired(uint256 auctionId) {
        if (allAuctions[auctionId].endTimestamp >= block.timestamp) {
            revert LibMarketPlaceErrors.AuctionEnded();
        }
        _;
    }

    function createAuction(AuctionParameters memory params) external returns (uint256 auctionId) {
        // wea re taking only erc 721 for now
        if (params.tokenType != TokenType.ERC721) {
            revert LibMarketPlaceErrors.InvalidCategory();
        }

        if (params.startTimestamp > block.timestamp || params.startTimestamp >= params.endTimestamp) {
            revert LibMarketPlaceErrors.InvalidTime();
        }

        if (!isContract(params.assetContract)) {
            revert LibMarketPlaceErrors.MustBeContract();
        }

        IERC721 nftCollection = IERC721(params.assetContract);

        // check onwner of nft
        if (nftCollection.ownerOf(params.tokenId) != msg.sender) {
            revert LibMarketPlaceErrors.NotOwner();
        }

        if (nftCollection.getApproved(params.tokenId) != address(this)) {
            revert LibMarketPlaceErrors.MarketPlaceNotApproved();
        }

        // nftCollection.transferFrom(msg.sender, address(this), params.tokenId);

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
            tokenType: TokenType.ERC721,
            status: Status.CREATED
        });

        auctionIndex++;

        // push the auction to the array
        allAuctions.push(auction);

        //emit event

        return auction.auctionId;
    }

    function createListing(ListingParameters memory params) external returns (uint256 listingId) {
        if (params.tokenType != TokenType.ERC721) {
            revert LibMarketPlaceErrors.InvalidCategory();
        }

        if (params.startTimestamp > block.timestamp || params.startTimestamp >= params.endTimestamp) {
            revert LibMarketPlaceErrors.InvalidTime();
        }

        if (!isContract(params.assetContract)) {
            revert LibMarketPlaceErrors.MustBeContract();
        }

        IERC721 nftCollection = IERC721(params.assetContract);

        // check onwner of nft
        if (nftCollection.ownerOf(params.tokenId) != msg.sender) {
            revert LibMarketPlaceErrors.NotOwner();
        }

        if (nftCollection.getApproved(params.tokenId) != address(this)) {
            revert LibMarketPlaceErrors.MarketPlaceNotApproved();
        }

        Listing memory listing = Listing({
            listingId: listingIndex,
            listingCreator: msg.sender,
            assetContract: params.assetContract,
            tokenId: params.tokenId,
            currency: params.currency,
            price: params.price,
            startTimestamp: params.startTimestamp,
            endTimestamp: params.endTimestamp,
            reserved: params.reserved,
            tokenType: TokenType.ERC721,
            status: Status.CREATED
        });

        listingIndex++;

        allListings.push(listing);

        // emit event

        return listing.listingId;
    }

    function updateListing(uint256 listingId, ListingParameters memory params) external {
        if (params.startTimestamp > block.timestamp || params.startTimestamp >= params.endTimestamp) {
            revert LibMarketPlaceErrors.InvalidTime();
        }
        // get listing
        Listing storage listing = allListings[listingId];

        if (listing.listingCreator != msg.sender) {
            revert LibMarketPlaceErrors.NotOwner();
        }

        if (listing.status != Status.CREATED) {
            revert LibMarketPlaceErrors.CantUpdateIfStatusNotCreated();
        }

        listing.currency = params.currency;
        listing.price = params.price;

        // update event
    }

    function cancelListing(uint256 listingId) external {
        Listing storage listing = allListings[listingId];

        if (listing.listingCreator != msg.sender) {
            revert LibMarketPlaceErrors.NotOwner();
        }

        if (listing.status == Status.COMPLETED) {
            revert LibMarketPlaceErrors.CantCancelCompletedListing();
        }

        if (listing.status == Status.CANCELLED) {
            revert LibMarketPlaceErrors.ListingAlreadyCompleted();
        }

        listing.status = Status.CANCELLED;

        // emit event
    }

    function approveCurrencyForListing(uint256 listingId, address currency, uint256 priceInCurrency) external {
        Listing storage listing = allListings[listingId];

        if (listing.listingCreator != msg.sender) {
            revert LibMarketPlaceErrors.NotOwner();
        }

        if (listing.status != Status.CREATED) {
            revert LibMarketPlaceErrors.CantUpdateIfStatusNotCreated();
        }

        //if listing is cancelled or completed
        if (listing.status == Status.CANCELLED || listing.status == Status.COMPLETED) {
            revert LibMarketPlaceErrors.CantUpdate();
        }

        approvedCurrencyForListing[listingId][currency] = true;
        approvedCurrencyForAmount[listingId][currency] = priceInCurrency;

        // emit event
    }

    // Get total listings
    function totalListings() external view returns (uint256) {
        return allListings.length;
    }

    function getAllListings() external view returns (Listing[] memory listings) {
        return allListings;
    }

    function getListing(uint256 listingId) external view returns (Listing memory listing) {
        return allListings[listingId];
    }

    function buyFromListing(uint256 listingId, address buyFor, address currency, uint256 expectedTotalPrice)
        external
        payable
    {
        Listing storage listing = allListings[listingId];

        if (listing.status != Status.CREATED) {
            revert LibMarketPlaceErrors.StatusMustBeCreated();
        }

        if (listing.reserved) {
            if (!reservedFor[listing.listingId][buyFor]) {
                revert LibMarketPlaceErrors.NotReservedAddress();
            }
            if (reservedForTokenId[listingId][buyFor] != listing.tokenId) {
                revert LibMarketPlaceErrors.NotReservedTokenId();
            }
        }

        bool isApprovedCurrency = approvedCurrencyForListing[listingId][currency];
        uint256 approvedCurrencyAmount = approvedCurrencyForAmount[listingId][currency];

        if (listing.currency != currency || !isApprovedCurrency) {
            revert LibMarketPlaceErrors.InvalidCurrency();
        }

        if (listing.price != expectedTotalPrice || listing.price != approvedCurrencyAmount) {
            revert LibMarketPlaceErrors.IncorrectPrice();
        }

        address currencyToBeUsed = isApprovedCurrency ? currency : listing.currency;
        uint256 priceToBeUsed = approvedCurrencyAmount > 0 ? expectedTotalPrice : listing.price;

        //TODO calculate percentage and remove it.

        // transfer the currency
        IERC20 ERC20Token = IERC20(currencyToBeUsed);
        ERC20Token.transferFrom(msg.sender, listing.listingCreator, priceToBeUsed);

        // transfer the nft
        IERC721 nftCollection = IERC721(listing.assetContract);
        nftCollection.safeTransferFrom(listing.listingCreator, buyFor, listing.tokenId);

        // update the listing status
        listing.status = Status.COMPLETED;

        // emit event
    }

    function bidInAuction(uint256 auctionId, uint256 bidAmount) external payable isAuctionExpired(auctionId) {
        Auction storage auction = allAuctions[auctionId];

        if (auction.status != Status.CREATED || auction.startTimestamp < block.timestamp) {
            revert LibMarketPlaceErrors.AuctionNotStarted();
        }

        if (auction.endTimestamp <= block.timestamp) {
            revert LibMarketPlaceErrors.AuctionEnded();
        }

        if (bidAmount < auction.minimumBidAmount) {
            revert LibMarketPlaceErrors.IncorrectPrice();
        }

        if (bidAmount >= auction.buyoutBidAmount) {
            // transfer the currency
            IERC20 ERC20Token = IERC20(auction.currency);
            ERC20Token.transferFrom(msg.sender, address(this), bidAmount);

            // transfer the nft
            IERC721 nftCollection = IERC721(auction.assetContract);
            nftCollection.safeTransferFrom(auction.auctionCreator, msg.sender, auction.tokenId);

            // update the auction status
            auction.status = Status.COMPLETED;

            // emit event
        }

        if (bidAmount > auction.currentBidPrice) {
            // transfer the currency
            IERC20 ERC20Token = IERC20(auction.currency);
            ERC20Token.transferFrom(msg.sender, auction.currentBidOwner, bidAmount);

            // update the current bid owner
            auction.currentBidOwner = msg.sender;
            auction.currentBidPrice = bidAmount;

            // emit event
        }
    }

    function cancelAuction(uint256 auctionId) external {
        Auction storage auction = allAuctions[auctionId];

        if (auction.auctionCreator != msg.sender) {
            revert LibMarketPlaceErrors.NotOwner();
        }

        if (auction.status == Status.COMPLETED) {
            revert LibMarketPlaceErrors.CantCancelCompletedListing();
        }

        if (auction.status == Status.CANCELLED) {
            revert LibMarketPlaceErrors.ListingAlreadyCompleted();
        }

        if (auction.currentBidOwner != address(0)) {
            // transfer the currency
            IERC20 ERC20Token = IERC20(auction.currency);
            ERC20Token.transferFrom(address(this), auction.currentBidOwner, auction.currentBidPrice);
        }

        auction.status = Status.CANCELLED;

        // emit event
    }

    function collectAuctionPayout(uint256 auctionId) external {
        Auction storage auction = allAuctions[auctionId];

        if (auction.auctionCreator != auction.currentBidOwner) {
            revert LibMarketPlaceErrors.NotOwner();
        }

        if (auction.status != Status.COMPLETED || auction.endTimestamp < block.timestamp) {
            revert LibMarketPlaceErrors.AuctionNotEnded();
        }

        if (auction.currentBidOwner != address(0)) {
            auction.status = Status.COMPLETED;
            // transfer the nft
            IERC721 nftCollection = IERC721(auction.assetContract);
            nftCollection.safeTransferFrom(auction.listingCreator, auction.currentBidOwner, auction.tokenId);
        }

        // emit event
    }

    function collectAuctionTokens(uint256 auctionId) external {
        Auction storage auction = allAuctions[auctionId];

        if (auction.auctionCreator != auction.auctionCreator) {
            revert LibMarketPlaceErrors.NotOwner();
        }

        if (auction.status != Status.COMPLETED || auction.endTimestamp < block.timestamp) {
            revert LibMarketPlaceErrors.AuctionNotEnded();
        }

        if (auction.currentBidOwner != address(0)) {
            auction.status = Status.COMPLETED;
            // transfer the token
            IERC20 ERC20Token = IERC20(auction.currency);
            ERC20Token.transferFrom(address(this), auction.auctionCreator, auction.currentBidPrice);
        }
    }

    function isNewWinningBid(uint256 auctionId, uint256 bidAmount) external view returns (bool) {
        Auction storage auction = allAuctions[auctionId];
        return bidAmount > auction.currentBidPrice;
    }

    function totalAuctions() external view returns (uint256) {
        return allAuctions.length;
    }

    function getAuction(uint256 auctionId) external view returns (Auction memory auction) {
        return allAuctions[auctionId];
    }

    function getAllAuctions(uint256 startId, uint256 endId) external view returns (Auction[] memory auctions) {
        return allAuctions;
    }

    function getWinningBid(uint256 auctionId)
        external
        view
        returns (address bidder, address currency, uint256 bidAmount)
    {
        Auction storage auction = allAuctions[auctionId];
        return (auction.currentBidOwner, auction.currency, auction.currentBidPrice);
    }

    // function makeOffer(OfferParams memory params) external returns (uint256 offerId);

    // function cancelOffer(uint256 offerId) external;

    // function acceptOffer(uint256 offerId) external;

    // function cancelOffer(uint256 offerId) external;

    // function acceptOffer(uint256 offerId) external;

    // function totalOffers() external view returns (uint256);

    // function getOffer(uint256 offerId) external view returns (Offer memory offer);

    // function getAllOffers(uint256 startId, uint256 endId) external view returns (Offer[] memory offers);

    // function getAllValidOffer(uint256 startId, uint256 endId) external view returns (Offer[] memory offers);

    function isContract(address _addr) internal view returns (bool addressCheck) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        addressCheck = (size > 0);
    }
}

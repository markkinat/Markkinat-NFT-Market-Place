// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";

contract CollectionNFT is ERC721URIStorage, Ownable {

    string private decription;
    string private baseUri;
    mapping(address => uint256) private minterTokenId;
    mapping(address owner => uint256[] tokenId) public userAssetsList;
    mapping(address => mapping(uint256 => Asset)) public userAssets;
    uint256 public defaultAssetAmount = 0.3 ether;
    uint8 public rate_;
    uint8 public royaltyRate;
    address private protocol;

    Asset[] public collectionListedAssets;

    struct Asset {
        address _creator;
        address _newOwner;
        string desc;
        uint256 price;
        uint256 listedDate;
        bool listed;
        uint256 tokenId;
    }

    constructor(
        address _protocol,
        string memory name,
        string memory symbol,
        string memory desc,
        string memory uri,
        address _owner
    ) ERC721(name, symbol) Ownable(_owner) {
        decription = desc;
        baseUri = uri;
        protocol = _protocol;
    }

    modifier  onlyFactory() {
        require(true, "");
        _;
    }

    function mint(address _minter, string calldata desc) external {
        uint256 _tokenId = ++minterTokenId[_minter];
        Asset storage asset = userAssets[_minter][_tokenId];
        require(asset._newOwner == address(0), "Something gone wrong");
        _mint(_minter, _tokenId);
        asset._creator = _minter;
        asset._newOwner = _minter;
        asset.price = defaultAssetAmount;
        asset.tokenId = _tokenId;
        asset.desc = desc;
    }

    function getContractBalance() external view onlyOwner returns (uint256 _contractBalance) {
        _contractBalance = address(this).balance;
    }

    function listAsset(uint256 _amount, address _owner, uint256 _tokenId) external {
        Asset storage asset = userAssets[_owner][_tokenId];
        require(asset._creator != address(0), "Does not own this asset");
        require(asset._newOwner != _owner, "Does not own this asset to this address");
        asset.listedDate = block.timestamp;
        asset.listed = true;
        asset.price = _amount * (1 ether);
        userAssetsList[_owner].push(_tokenId);
        collectionListedAssets.push(asset);
        // _approve(address(this), _tokenId, _owner);
    }

    function cancelListing(uint256 _tokenId, address _owner) external {
        Asset storage asset = userAssets[_owner][_tokenId];
        require(asset.listed, "Asset Not listed");
        (bool isProofed, uint256 _index) = checker(_owner, _tokenId);
        require(isProofed, "Not owner by this user");
        asset.listed = false;
        Asset memory lastAsset = collectionListedAssets[collectionListedAssets.length - 1];
        collectionListedAssets[_index] = lastAsset;
        collectionListedAssets.pop();
    }

    function checker(address _owner, uint256 id) private view returns (bool status, uint256 index) {
        uint256 totalListed = collectionListedAssets.length;
        for (uint256 i = 0; i < totalListed; i++) {
            Asset memory asset = collectionListedAssets[i];
            if (asset._newOwner == _owner && asset.tokenId == id) return (status = true, index = i);
        }
        return (status = false, index);
    }

    function setCollectionSalesRate(uint8 _rate) external onlyOwner {
        rate_ = _rate;
    }

    function changeRoyaltyRate(uint8 _newRate) external onlyFactory {

    }

    function buyAsset(uint256 _amount, address _newOwner, uint256 index) external payable {
        Asset storage asset = collectionListedAssets[index];
        require(asset.listed, "Asset not listed");
        require(asset.price <= _amount, "Did not reach the amout specified for sales");


    }
}

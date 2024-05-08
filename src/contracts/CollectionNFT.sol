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
    address payable private protocol;
    uint8 public protocolRate;

    Asset[] public collectionListedAssets;

    struct Asset {
        address payable _creator;
        address payable _newOwner;
        string desc;
        uint256 price;
        uint256 listedDate;
        bool listed;
        uint256 tokenId;
        uint soldTime;
    }

    constructor(
        address payable _protocol,
        string memory name,
        string memory symbol,
        string memory desc,
        string memory uri,
        address payable _owner
    ) ERC721(name, symbol) Ownable(_owner) {
        decription = desc;
        baseUri = uri;
        protocol = _protocol;
    }


    function mint( address _minter ) external {
        uint256 _tokenId = minterTokenId[_minter];
        _mint(_minter, ++_tokenId);
    }
}

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin-contracts/contracts/access/Ownable.sol";

contract CollectionNFT is ERC721URIStorage, Ownable {
    string private decription;
    string private baseUri;
    mapping (address => uint256) private minterTokenId;
    mapping (address owner => uint256[] tokenId) public userAssetsList; 
    mapping (address => mapping (uint256 => Asset)) public userAssets;
    
    struct ListAsset {
        address _owner;
        address firstCreator;
        uint price;
        uint listedDate;
        uint _tokenId;
    }

    struct Asset{
        address _creator;
        address _newOwner;
        string desc;
    }

    constructor(string memory name, string memory symbol, string memory desc, string memory uri, address _owner) ERC721(name, symbol) Ownable(_owner) {
        decription = desc;
        baseUri = uri;
    }

    function mint( address _minter ) external {
        uint256 _tokenId = minterTokenId[_minter];
        _mint(_minter, ++_tokenId);
        userAssetsList[_minter].push(_tokenId);
        Asset storage asset = userAssets[_minter][_tokenId];
        asset._creator= _minter;
        asset._newOwner = _minter;
        asset.desc = "";
    }

    function getContractBalance() external onlyOwner view returns(uint256 _contractBalance){
        _contractBalance = address(this).balance;
    }

    function listAsset() external payable {

    }


    function buyAsset(uint _tokenId, address _newOwner) external payable {

    }
}

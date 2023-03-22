// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NftAfrica_notListed();
error NftAfrica_NotEnough();
contract NftAfrica {
    struct Listing {
        uint256 price;
        address seller;
    }


    mapping (address => mapping (uint256 => Listing)) private NFTListed;
    mapping(address => uint256) private Proceeds;

    //////////////////////////////////////Events
    event ItemBought(address Seller, address Buyer, uint256 NFTTokenId);

    modifier IsListed(address NFTAddress, uint256 tokenId) {
        Listing memory NFTListedItem = NFTListed[NFTAddress][tokenId];
        if(NFTListedItem.price <= 0) revert NftAfrica_notListed();
        _;
    }
    
    
    function BuyItem(address NFTAddress, uint256 tokenId) payable external IsListed(NFTAddress, tokenId){
        Listing memory NFTListedItem = NFTListed[NFTAddress][tokenId];
        if(msg.value < NFTListedItem.price) revert NftAfrica_NotEnough();
        Proceeds[NFTListedItem.seller] += msg.value;
        IERC721(NFTAddress).safeTransferFrom(NFTListedItem.seller, msg.sender, tokenId);
        delete(NFTListed[NFTAddress][tokenId]);
        emit ItemBought(NFTListedItem.seller, msg.sender, tokenId);
    }
    function ListItem() external {
         
    }
    function UpdateItem() external {

    }
    function CancelListing() external {

    }
}
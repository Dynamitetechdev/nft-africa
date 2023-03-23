// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.11;

/**
 * @title NFT Africa Contract
 * @author 0xdynamite / twitter: techdynamite235
 * @notice This Contract is not ready for production yet, do not use
 */
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


error NftAfrica_notListed();
error NftAfrica_NotEnough();
error NftAfrica_listed();
error NftAfrica_notOwner();
error NftAfrica_PriceCannotBeZero();
error NftAfrica_NarketPlaceNotApproved();
error NftAfrica_noProceeds();
error NftAfrica_withdrawalFailed();

contract NftAfrica {
    /**
     * @dev Listing Structure
     */
    struct Listing {
        uint256 price;
        address seller;
    }
    /**
     * @dev 1. Mapping of the NFT Listed. From the NFT address => tokenId of the NFT => Listing
     * @dev 2. Mapping of the proceeds of the seller of any NFT 
     */
    mapping (address => mapping (uint256 => Listing)) private NFTListed;
    mapping(address => uint256) private Proceeds;

    /**
     * @dev all Events
     */
    event ItemBought(address indexed Seller, address indexed Buyer, uint256 indexed NFTTokenId);
    event ItemListed(address indexed NFTaddress, uint256 indexed tokenId, uint256 indexed NFTprice);
    event ListingUpdate(address indexed NFTAddress, uint256 indexed tokenId, uint256 indexed newPrice);
    event ListingCanceled(address NFTAddress, uint256 tokenId);

    /**
     * @dev all modifiers
     */
    modifier IsOwner(address NFTaddress, uint256 tokenId, address spender) {
        if(IERC721(NFTaddress).ownerOf(tokenId) != spender) revert NftAfrica_notOwner();
        
        _;
    }
    modifier IsListed(address NFTAddress, uint256 tokenId) {
        Listing memory NFTListedItem = NFTListed[NFTAddress][tokenId];
        if(NFTListedItem.price <= 0) revert NftAfrica_notListed();
        _;
    }
    modifier NotLsited(address NFTaddress, uint256 tokenId) {
        Listing memory NFTListedItem = NFTListed[NFTaddress][tokenId];
        if(NFTListedItem.price > 0) revert NftAfrica_listed();
        _;
    }


    /**
     * @dev This Function is to buy already listed Items on the Market
     * @dev Item must be listed
     * @dev Add the msg.value to the sellers proceeds
     * @dev Transfers the NFT address the buyer
     * @dev Delete the bought NFT from the Market Place
     */
    function BuyItem(address NFTAddress, uint256 tokenId) payable external IsListed(NFTAddress, tokenId){
        Listing memory NFTListedItem = NFTListed[NFTAddress][tokenId];
        if(msg.value < NFTListedItem.price) revert NftAfrica_NotEnough();
        Proceeds[NFTListedItem.seller] += msg.value;
        IERC721(NFTAddress).safeTransferFrom(NFTListedItem.seller, msg.sender, tokenId);
        delete(NFTListed[NFTAddress][tokenId]);
        emit ItemBought(NFTListedItem.seller, msg.sender, tokenId);
    }

    /**
     * @dev This Function is to list Item on the Market
     * @dev Item must not be listed
     * @dev Only owner of the Item can List the Item
     * @dev The Market Place Must be Approved to List the Item
     */
    function ListItem(address NFTAddress, uint256 tokenId,uint256 NFTprice) external NotLsited(NFTAddress, tokenId) IsOwner(NFTAddress, tokenId, msg.sender) {
         if(NFTprice <= 0 ) revert NftAfrica_PriceCannotBeZero();
         if(IERC721(NFTAddress).getApproved(tokenId) != address(this)) revert NftAfrica_NarketPlaceNotApproved();
         NFTListed[NFTAddress][tokenId] = Listing(NFTprice, msg.sender);
         emit ItemListed(NFTAddress, tokenId, NFTprice);
    }
    
    /**
     * @dev This Function is to update the price of a listed Item
     * @dev Item must be listed already
     * @dev Only owner of the Item can update the Item price
     */
    function UpdateItem(address NFTAddress, uint256 tokenId,uint256 newPrice)external NotLsited(NFTAddress, tokenId) IsOwner(NFTAddress, tokenId, msg.sender) 
     {
        if(newPrice <= 0) revert NftAfrica_PriceCannotBeZero();
        NFTListed[NFTAddress][tokenId].price = newPrice;
        emit ListingUpdate(NFTAddress,tokenId, newPrice);
    }

    /**
     * @dev This Function is to cancel the listed Item from the market
     * @dev Item must be listed already
     * @dev Only owner of the Item can cancel the Item price
     */
    function CancelListing(address NFTAddress, uint256 tokenId)external NotLsited(NFTAddress, tokenId) IsOwner(NFTAddress, tokenId, msg.sender) {
        delete(NFTListed[NFTAddress][tokenId]);
        emit ListingCanceled(NFTAddress, tokenId);
    }

    /**
     * @dev this function withdraws the proceeds of the Item Sold to the seller
     */
    function WithdrawProceeds() external{
        if(Proceeds[msg.sender] <= 0) revert NftAfrica_noProceeds();
       (bool success, ) = payable(msg.sender).call{value: Proceeds[msg.sender]}("");
       if(!success) revert NftAfrica_withdrawalFailed();
       assert(Proceeds[msg.sender] == 0);
    }
}
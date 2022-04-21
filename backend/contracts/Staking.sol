// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IERC20Mint.sol";
import "hardhat/console.sol";


contract Staking is Ownable, ERC721Holder ,ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsUnstaked;

    address private whitelistedNftContract;
    address private brew;

    uint256 public blocksPerDay = 6647;

    constructor(address _nft ){
        whitelistedNftContract = _nft;
    }



    struct StakeItem {
    uint itemId;
    uint256 tokenId;
    address payable owner;
    uint256 startBlock;
    }

  mapping(uint256 => StakeItem) private idToStakeItem;
  mapping(uint256 => bool) private idExist;

    
    event StakeItemmCreated (
    uint indexed itemId,
    uint256 indexed tokenId,
    address payable owner,
    uint256 startBlock
    );

    function exist(uint256 _id) public view returns(bool){
        return idExist[_id];
    }

    function setTokenAddress(address _brew) public onlyOwner {
         brew = _brew;
    }

    
    function _stakeNft(uint256 tokenId, address _owner) internal returns(bool) {
    _itemIds.increment();
    uint256 itemId = _itemIds.current();
    idExist[tokenId] = true ; 

    idToStakeItem[itemId] =  StakeItem(
      itemId,
      tokenId,
      payable(_owner),
      block.number
    );
    }
    
  
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes memory data
        ) public virtual override returns (bytes4) {
            require(address(whitelistedNftContract) == _msgSender(), "NftStaking: contract not whitelisted");
            _stakeNft(id, from);
            console.log("NFT recieved");
            return ERC721Holder.onERC721Received(operator,from,id,data);
        }

    function calculateRewards(uint256 itemId) view public returns(uint256){
        console.log(block.number);
        uint256 _noOfBlocks = idToStakeItem[itemId].startBlock;

        if(block.number > _noOfBlocks){
            uint256 rev_block = (3 * 10 **18 )/ blocksPerDay;
            uint256 user_blocks = block.number - _noOfBlocks;
            return rev_block * user_blocks;
        }else{
            return 0 ;
        }
    }

    function unStake(
    uint256 itemId
    ) public payable nonReentrant {
    address _owner = idToStakeItem[itemId].owner;

    require(_owner == _msgSender() , " not the owner");

    uint tokenId = idToStakeItem[itemId].tokenId;


    IERC721(whitelistedNftContract).safeTransferFrom(address(this), _msgSender(), tokenId);
    IERC20Mint(brew).mint(_owner,calculateRewards(itemId));

    delete idToStakeItem[itemId];
    
    _itemsUnstaked.increment();
    
    }



        /* Returns all unUnstaked Stake items */
  function fetchStakeItems() public view returns (StakeItem[] memory) {
    uint itemCount = _itemIds.current();
    uint unUnstakedItemCount = _itemIds.current() - _itemsUnstaked.current();
    uint currentIndex = 0;

    StakeItem[] memory items = new StakeItem[](unUnstakedItemCount);
    for (uint i = 0; i < itemCount; i++) {
      if (idToStakeItem[i + 1].owner == address(0)) {
        uint currentId = i + 1;
        StakeItem storage currentItem = idToStakeItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns onlyl items that a user has purchased */
  function fetchMyNFTs() public view returns (StakeItem[] memory) {
    uint totalItemCount = _itemIds.current();
    uint itemCount = 0;
    uint currentIndex = 0;

    for (uint i = 0; i < totalItemCount; i++) {
      if (idToStakeItem[i + 1].owner == _msgSender()) {
        itemCount += 1;
      }
    }

    StakeItem[] memory items = new StakeItem[](itemCount);
    for (uint i = 0; i < totalItemCount; i++) {
      if (idToStakeItem[i + 1].owner == _msgSender()) {
        uint currentId = i + 1;
        StakeItem storage currentItem = idToStakeItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

}
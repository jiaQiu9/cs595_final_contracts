// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RestaurantNFT is ERC721Enumerable, Ownable {
    uint256 public maxSupply;
    uint256 public currentId;
    address public factoryAddress;

    struct TokenMeta {
        string restaurantName;
        string productDescription;
        string location;
    }

    mapping(uint256 => TokenMeta) public tokenMetadata;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        address owner_,
        address factory_
    ) ERC721(name, symbol) {
        maxSupply = _maxSupply;
        factoryAddress = factory_;
        transferOwnership(owner_);
    }

    function mint(
        address to,
        string memory restaurantName,
        string memory description,
        string memory location
    ) external onlyOwner {
        require(currentId < maxSupply, "Max supply reached");
        currentId++;
        _mint(to, currentId);
        tokenMetadata[currentId] = TokenMeta(restaurantName, description, location);
    }
}

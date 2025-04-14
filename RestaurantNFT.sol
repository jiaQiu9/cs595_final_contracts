// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// NFT contract for a restaurant. Only the restaurant owner can mint new tokens.
contract RestaurantNFT is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;       // Tracks how many tokens have been minted
    uint256 public maxSupply;          // Maximum number of tokens allowed to mint
    address public restaurantOwner;    // Address that owns and controls this NFT collection

    // Initializes the NFT with a name, symbol, max supply, and assigns ownership
    constructor(string memory name, string memory symbol, uint256 _maxSupply, address _restaurantOwner)
        ERC721(name, symbol)
    {
        tokenCounter = 0;
        maxSupply = _maxSupply;
        restaurantOwner = _restaurantOwner;

        // Transfer ownership to the restaurant
        transferOwnership(_restaurantOwner);
    }

    // Mint a new token with metadata (URI). Only the owner can mint.
    function mintToken(address to, string memory tokenURI) public onlyOwner returns (uint256) {
        require(tokenCounter < maxSupply, "Max supply reached");

        uint256 newTokenId = tokenCounter;
        _safeMint(to, newTokenId);          // Mint new token safely
        _setTokenURI(newTokenId, tokenURI); // Set metadata URI
        tokenCounter++;                     // Increment counter

        return newTokenId;
    }

    // Burn (destroy) a token. Only the token holder can burn it.
    function burnToken(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Only owner can burn");
        _burn(tokenId);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for interacting with NFT contracts with metadata
interface IERC721WithMetadata {
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// Interface to validate if a collection came from the factory
interface IFactoryValidator {
    function isFactoryChild(address collectionAddr) external view returns (bool);
}

// Swap contract for NFT tokens based on metadata categories (e.g., "seafood")
contract ConditionalNFTSwap {
    address public immutable factory;   // Address of the NFT factory contract
    address public immutable deployer;  // Original deployer of this swap contract

    // Structure representing a swap offer
    struct SwapRequest {
        address requester;              // Who created the swap
        address collection;             // NFT collection address
        uint256 offeredTokenId;         // ID of the token being offered
        string desiredType;             // Desired type/category (e.g., "vegan", "dessert")
        bool deposited;                 // Whether the offered NFT has been deposited
    }

    mapping(uint256 => SwapRequest) public swapRequests; // All swap requests by ID
    uint256 public swapCounter;                          // Tracks number of swap requests

    // Events
    event SwapCreated(uint256 indexed id, address requester, address collection, uint256 tokenId, string desiredType);
    event SwapFulfilled(uint256 indexed id, address fulfiller, uint256 tokenId);
    event SwapCancelled(uint256 indexed id);

    // Initialize swap contract with reference to NFT factory
    constructor(address _factory) {
        factory = _factory;
        deployer = tx.origin; // Address that deployed this contract originally
    }

    // Modifier to ensure only collections created by the factory can interact
    modifier onlyValidCollection(address collection) {
        require(IFactoryValidator(factory).isFactoryChild(collection), "Invalid collection");
        _;
    }

    // Create a swap request specifying the offered token and desired category
    function createSwap(address collection, uint256 tokenId, string memory desiredType)
        external
        onlyValidCollection(collection)
    {
        require(IERC721WithMetadata(collection).ownerOf(tokenId) == msg.sender, "Not the token owner");

        swapRequests[swapCounter] = SwapRequest({
            requester: msg.sender,
            collection: collection,
            offeredTokenId: tokenId,
            desiredType: desiredType,
            deposited: false // Future: could be toggled once NFT is transferred
        });

        emit SwapCreated(swapCounter, msg.sender, collection, tokenId, desiredType);
        swapCounter++;
    }

    // Cancel an open swap request
    function cancelSwap(uint256 id) external {
        SwapRequest storage req = swapRequests[id];
        require(req.requester == msg.sender, "Not your swap");
        delete swapRequests[id];
        emit SwapCancelled(id);
    }

    // (Optional) Future function: acceptSwap(), deposit(), validateMatchByType(), etc.
}

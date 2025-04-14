// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721WithMetadata {
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ConditionalNFTSwap {
    address public immutable allowedContract; // Only this contract can be used
    address public immutable deployer;        // Must be deployed by this address

    struct SwapRequest {
        address requester;
        uint256 offeredTokenId;
        string desiredType; // E.g., "seafood"
        bool deposited;
    }

    mapping(uint256 => SwapRequest) public swapRequests;
    uint256 public swapCounter;

    constructor(address _allowedContract) {
        allowedContract = _allowedContract;
        deployer = tx.origin; // Marcus as the original deployer
    }

    function createSwap(uint256 _offeredTokenId, string memory _desiredType) external returns (uint256) {
        IERC721WithMetadata nft = IERC721WithMetadata(allowedContract);
        require(nft.ownerOf(_offeredTokenId) == msg.sender, "You don't own this NFT");

        nftTransfer(msg.sender, address(this), _offeredTokenId);

        swapRequests[swapCounter] = SwapRequest({
            requester: msg.sender,
            offeredTokenId: _offeredTokenId,
            desiredType: _desiredType,
            deposited: true
        });

        return swapCounter++;
    }

    function fulfillSwap(uint256 _swapId, uint256 _incomingTokenId) external {
        SwapRequest storage request = swapRequests[_swapId];
        require(request.deposited, "Invalid swap or already fulfilled");

        // Validate metadata and owner
        IERC721WithMetadata nft = IERC721WithMetadata(allowedContract);
        require(nft.ownerOf(_incomingTokenId) == msg.sender, "You don't own this NFT");

        // Fetch and compare type from metadata
        string memory uri = nft.tokenURI(_incomingTokenId);
        require(matchesDesiredType(uri, request.desiredType), "NFT does not match the desired type");

        // Transfer NFTs
        nftTransfer(msg.sender, request.requester, _incomingTokenId);
        nftTransfer(address(this), msg.sender, request.offeredTokenId);

        delete swapRequests[_swapId];
    }

    function nftTransfer(address from, address to, uint256 tokenId) internal {
        (bool success, bytes memory data) = allowedContract.call(
            abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", from, to, tokenId)
        );
        require(success, "Transfer failed");
    }

    // VERY simplified example — assumes type is a substring in URI like ".../seafood/..."
    function matchesDesiredType(string memory uri, string memory desired) internal pure returns (bool) {
        return bytesContains(uri, desired);
    }

    function bytesContains(string memory a, string memory b) internal pure returns (bool) {
        return (bytes(a).length >= bytes(b).length && bytes(b).length > 0 && indexOf(a, b) != -1);
    }

    function indexOf(string memory a, string memory b) internal pure returns (int) {
        bytes memory aBytes = bytes(a);
        bytes memory bBytes = bytes(b);
        for (uint i = 0; i <= aBytes.length - bBytes.length; i++) {
            bool matchFound = true;
            for (uint j = 0; j < bBytes.length; j++) {
                if (aBytes[i + j] != bBytes[j]) {
                    matchFound = false;
                    break;
                }
            }
            if (matchFound) return int(i);
        }
        return -1;
    }
}



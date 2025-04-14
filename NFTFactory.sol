// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./RestaurantNFT.sol";

contract NFTFactory {
    struct CollectionInfo {
        address contractAddress;
        address owner;
        string name;
        uint256 maxSupply;
    }

    CollectionInfo[] public collections;
    mapping(address => address[]) public userCollections;

    event CollectionCreated(
        address indexed owner,
        address indexed contractAddress,
        string name,
        uint256 maxSupply
    );

    function createRestaurantNFT(
        string memory name,
        uint256 maxSupply,
        address owner
    ) external {
        RestaurantNFT newCollection = new RestaurantNFT(
            name,
            name,
            maxSupply,
            owner,
            address(this)
        );

        collections.push(CollectionInfo({
            contractAddress: address(newCollection),
            owner: owner,
            name: name,
            maxSupply: maxSupply
        }));

        userCollections[owner].push(address(newCollection));

        emit CollectionCreated(owner, address(newCollection), name, maxSupply);
    }

    function getUserCollections(address user) external view returns (address[] memory) {
        return userCollections[user];
    }

    function getAllCollections() external view returns (CollectionInfo[] memory) {
        return collections;
    }

    function isFactoryDeployed(address contractAddr) public view returns (bool) {
        for (uint i = 0; i < collections.length; i++) {
            if (collections[i].contractAddress == contractAddr) {
                return true;
            }
        }
        return false;
    }
}

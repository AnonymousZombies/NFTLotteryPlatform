// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface ITokenPool {
    function transferTokenToTokenPool(address contractAddr, uint256 tokenId)
        external;
}

contract ERC721Lottery is ERC721 {
    uint256 private _tokenId;

     mapping(bytes4 => bool) internal supportedInterfaces;

    constructor(string memory name_, string memory symbol_, address approve_)
        ERC721(name_, symbol_)
    {
        mint(approve_);
        supportedInterfaces[this.supportsInterface.selector] = true;
        supportedInterfaces[bytes4(keccak256("function getApproved(uint256)"))] = true;
        supportedInterfaces[bytes4(keccak256("function transferFrom(address,address,uint256)"))] = true;
    }

    function mint(address approve_) public {
        for (uint256 i = 0; i < 100; i++) {
            _mint(msg.sender, _tokenId);
            approve(approve_, _tokenId);
            _tokenId++;
        }
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return supportedInterfaces[interfaceId];
    }
}

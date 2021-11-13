// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ContextB.sol";
import "./utils/structs/TokenInfoStruct.sol";

interface IERC721 {
    function getApproved(uint256 tokenId) external view returns (address);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract TokenPool is Ownable, ContextB {
    // using ERC165Checker for ERC165Checker;

    event StoreToken(uint256 tokenId, address contractAddr);
    event StoreTokens(uint256[] tokenIds, address contractAddr);

    mapping(address => TokenInfoStruct.TokenInfo[]) private _tokens;

    TokenInfoStruct.TokenInfo[] private _allTokenInfo;

    constructor(address externalStorageAccessAddr_)
        ContextB(externalStorageAccessAddr_)
    {
        _IESA().setContractPermission(address(this), _msgSender());
        _IESA().setContractAddr("TokenPool", address(this));
    }

    modifier checkSupportsInterface(address account) {
        require(ERC165Checker.supportsERC165(account), "Contract not support ERC165");
        require(
            ERC165Checker.supportsInterface(
                account,
                bytes4(keccak256("function getApproved(uint256)"))
            ),
            "Contract not support getApproved interface"
        );
        require(
            ERC165Checker.supportsInterface(
                account,
                bytes4(
                    keccak256("function transferFrom(address,address,uint256)")
                )
            ),
            "Contract not support transferFrom interface"
        );
        _;
    }

    function storeLotteryTokens(
        uint256[] memory tokenIds_,
        address contractAddr_
    ) public checkSupportsInterface(contractAddr_) {
        TokenInfoStruct.TokenInfo[] storage tokensInfo = _tokens[contractAddr_];

        for (uint256 i = 0; i < tokenIds_.length; i++) {
            uint256 tokenId = tokenIds_[i];
            address approvedAddr = IERC721(contractAddr_).getApproved(tokenId);

            if (approvedAddr != _IESA().getContractAddr("Treasury")) continue;

            TokenInfoStruct.TokenInfo memory tokenInfo = TokenInfoStruct.TokenInfo({
                contractAddr: contractAddr_,
                tokenId: tokenId
            });

            tokensInfo.push(tokenInfo);
            _allTokenInfo.push(tokenInfo);
        }

        emit StoreTokens(tokenIds_, contractAddr_);
    }

    function storeLotteryToken(uint256 tokenId_, address contractAddr_)
        public
        checkSupportsInterface(contractAddr_)
    {
        TokenInfoStruct.TokenInfo[] storage tokensInfo = _tokens[contractAddr_];
        address approveAddr = IERC721(contractAddr_).getApproved(tokenId_);
        require(
            approveAddr == _IESA().getContractAddr("Treasury"),
            "Please approve this contract address"
        );

        TokenInfoStruct.TokenInfo memory tokenInfo = TokenInfoStruct.TokenInfo({
            contractAddr: contractAddr_,
            tokenId: tokenId_
        });
        tokensInfo.push(tokenInfo);
        _allTokenInfo.push(tokenInfo);

        emit StoreToken(tokenId_, contractAddr_);
    }

    function getTokenInfoById(uint256 tokenInfoId)
        public
        view
        returns (TokenInfoStruct.TokenInfo memory)
    {
        return _allTokenInfo[tokenInfoId];
    }
}

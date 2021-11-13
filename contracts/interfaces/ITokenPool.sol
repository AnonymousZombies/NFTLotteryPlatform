// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../utils/structs/TokenInfoStruct.sol";

interface ITokenPool {
    function getTokenInfoById(uint256 tokenInfoId)
        external
        view
        returns (TokenInfoStruct.TokenInfo memory);
}
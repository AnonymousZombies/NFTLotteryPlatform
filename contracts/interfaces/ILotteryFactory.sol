// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ILotteryFactory {
    function getLotteryAddrById(uint256 lotteryId)
        external
        view
        returns (address);
}

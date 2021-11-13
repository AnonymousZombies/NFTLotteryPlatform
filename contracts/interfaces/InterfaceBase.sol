// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./ILotteryFactory.sol";
import "./ILottery.sol";
import "./ITokenPool.sol";
import "../ContextB.sol";

import "hardhat/console.sol";

abstract contract InterfaceBase is ContextB {

    function _ILF() internal view returns (ILotteryFactory) {
        return ILotteryFactory(_IESA().getContractAddr("LotteryFactory"));
    }

    function _IL(uint256 lotteryId) internal view returns (ILottery) {
        return ILottery(_ILF().getLotteryAddrById(lotteryId));
    }

    function _ITP() internal view returns (ITokenPool) {
        return ITokenPool(_IESA().getContractAddr("TokenPool"));
    }
}

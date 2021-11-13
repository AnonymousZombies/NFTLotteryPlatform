// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../Lottery.sol";
import "../ContextB.sol";

contract LotteryFactory is Ownable, ContextB {
    event GetTokenList(uint256 numOfToken);

    uint256 private _lotteryCounter;

    bool private _hasLotteryActive;

    address private _externalStorageAccessAddr;

    constructor(address externalStorageAccessAddr_)
        ContextB(externalStorageAccessAddr_)
    {
        _lotteryCounter++;
        _IESA().setContractPermission(address(this), _msgSender());
        _IESA().setContractAddr("LotteryFactory", address(this));

        _externalStorageAccessAddr = externalStorageAccessAddr_;
    }

    modifier lockCreateLottery() {
        require(!_IESA().getHasLotteryActive(), "A lottery is activating");
        _;
        _IESA().setHasLotteryActive(true);
    }

    function createLottery(
        uint256 numOfTicket,
        uint256 numOfDiamondPrizeWinners,
        uint256 numOfGoldPrizeWinners,
        uint256 numOfSilverPrizeWinners,
        uint256 numOfBronzePrizeWinners,
        uint256[] memory tokenInfoIds
    ) public onlyOwner lockCreateLottery {
        uint256 totalWinner = numOfDiamondPrizeWinners +
            numOfGoldPrizeWinners +
            numOfSilverPrizeWinners +
            numOfBronzePrizeWinners;

        require(
            totalWinner <= numOfTicket,
            "Total winner can not greater than the number of Ticket"
        );

        Lottery lottery = new Lottery(
            numOfTicket,
            numOfDiamondPrizeWinners,
            numOfGoldPrizeWinners,
            numOfSilverPrizeWinners,
            numOfBronzePrizeWinners,
            _msgSender(),
            tokenInfoIds,
            _externalStorageAccessAddr
        );

        _IESA().setLotteryAddr(_lotteryCounter, address(lottery));
        _IESA().setLotteryId(_lotteryCounter, address(lottery));

        _lotteryCounter++;
    }

    function setHasLotteryActive(bool hasLotteryActive) public onlyOwner {
        _IESA().setHasLotteryActive(hasLotteryActive);
    }

    function getLotteryAddrById(uint256 lotteryId)
        public
        view
        returns (address)
    {
        return _IESA().getLotteryAddrById(lotteryId);
    }

    function getTokenListFromTokenPool(uint256 numOfToken) public onlyOwner {
        emit GetTokenList(numOfToken);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/InterfaceBase.sol";
import "./utils/structs/TokenInfoStruct.sol";
import "./ContextB.sol";
import "hardhat/console.sol";

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract Treasury is Ownable, ContextB, InterfaceBase {

    uint256 public constant diamondPrizeAmount = 400 ether;
    uint256 public constant goldPrizeAmount = 100 ether;
    uint256 public constant silverPrizeAmount = 10 ether;
    uint256 public constant bronzePrizeAmount = 1 ether;

    constructor(address externalStorageAccessAddr_) ContextB(externalStorageAccessAddr_) {
        _IESA().setContractPermission(address(this), _msgSender());
        _IESA().setContractAddr("Treasury", address(this));
    }

    function redeemAward(
        uint256 lotteryId,
        uint256 ticketId,
        uint256 prizeType
    ) public {
        require(!_IL(lotteryId).isActive(), "Lottery not ended");
        address lotteryFactoryAddr = _IESA().getContractAddr("LotteryFactory");
        require(
            lotteryFactoryAddr != address(0x0),
            "_lotteryFactoryAddr not zero address"
        );
        
        uint256 ticketStatus = _IL(lotteryId).getTicketPrizeStatus(ticketId);
        require(ticketStatus == 1, "Ticket can not redeem award");
        address ticketOwner = _IL(lotteryId).getTicketOwner(ticketId);
        require(_msgSender() == ticketOwner, "Not yours ticket");
        bool success;

        if (prizeType == 0) {
            require(_IL(lotteryId).isPrizeId(ticketId, 0), "Ticket not diamond prize");
            require(address(this).balance >= diamondPrizeAmount, "Contract balance not enough");

            (success, ) = ticketOwner.call{value: diamondPrizeAmount}("");
        } else if (prizeType == 1) {
            require(_IL(lotteryId).isPrizeId(ticketId, 1), "Ticket not gold prize");
            require(address(this).balance >= goldPrizeAmount, "Contract balance not enough");

            (success, ) = ticketOwner.call{value: goldPrizeAmount}("");
        } else if (prizeType == 2) {
            require(_IL(lotteryId).isPrizeId(ticketId, 2), "Ticket not silver prize");
            require(address(this).balance >= silverPrizeAmount, "Contract balance not enough");

            (success, ) = ticketOwner.call{value: silverPrizeAmount}("");
        } else if (prizeType == 3) {
            require(_IL(lotteryId).isPrizeId(ticketId, 3), "Ticket not bronze prize");
            require(address(this).balance >= bronzePrizeAmount, "Contract balance not enough");
            
            (success, ) = ticketOwner.call{value: bronzePrizeAmount}("");
        }

        require(success, "redeem award failed");
        _IL(lotteryId).setTicketPrizeStatus(ticketId, 2);
        // Transfer token to ticket owner
        uint256 tokenId = _IL(lotteryId).getTokenByTicketId(ticketId);
        console.log("redeemAward", ticketId, tokenId);
        TokenInfoStruct.TokenInfo memory tokenInfo = _ITP().getTokenInfoById(tokenId);
        address tokenOwner = IERC721(tokenInfo.contractAddr).ownerOf(tokenId);
        IERC721(tokenInfo.contractAddr).transferFrom(tokenOwner, ticketOwner, tokenId);
    }

    receive() external payable {}
}

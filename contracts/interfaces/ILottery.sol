// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ILottery {
    function getTicketPrizeStatus(uint256 ticketId)
        external
        view
        returns (uint256);
    function setTicketPrizeStatus(uint256 ticketId, uint256 status) external;
    function getTicketOwner(uint256 ticketId) external view returns (address);
    function isPrizeId(uint256 ticketId, uint256 prizeType) external view returns (bool);
    function isActive() external view returns (bool);
    function getTokenByTicketId(uint256 ticketId) external view returns (uint256);
}
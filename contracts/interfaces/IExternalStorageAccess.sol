// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

interface IExternalStorageAccess {
    /**
     * @dev Emits when the contract `contractName` is set with an address
     * `contractAddr`.
     */
    event SetContractAddr(string indexed contractName, address contractAddr);

    function getOwner() external view returns (address);

    function setContractAddr(string memory contractName, address contractAddr) external;
    function getContractAddr(string memory contractName) external view returns (address);
    function delContractAddr(string memory contractName) external;

    function setContractPermission(address contractAddr, address caller) external;

    function setLotteryAddr(uint256 lotteryId, address lotteryAddr) external;
    function getLotteryAddrById(uint256 lotteryId) external view returns (address);
    function setLotteryId(uint256 lotteryId, address lotteryAddr) external;
    function getLotteryIdByAddr(address lotteryAddr) external view returns (uint256);
    function setHasLotteryActive(bool hasLotteryActive) external;
    function getHasLotteryActive() external view returns (bool);

    /* System-level parameters */
}

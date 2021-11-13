// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ExternalStorageAccessBase.sol";
import "../interfaces/IExternalStorageAccess.sol";

import "hardhat/console.sol";

/// @author Simon Tian
/// @title A contract for accessing storage
contract ExternalStorageAccess is IExternalStorageAccess, Ownable, ExternalStorageAccessBase {
    /**
     * @dev Sets `externalStorageAccessAddr_`.
     */
    constructor(address externalStorageAddr_)
        ExternalStorageAccessBase(externalStorageAddr_) {}

    function getOwner() public view override returns (address) {
        return owner();
    }

    function setContractAddr(string memory contractName, address contractAddr)
        public
        override
        onlyByContractSetter
    {
        bytes32 key = _getStringKey("constants.contractName.", contractName);
        setAddress(key, contractAddr);

        emit SetContractAddr(contractName, contractAddr);
    }

    function getContractAddr(string memory contractName)
        public
        view
        override
        returns (address)
    {
        return _getContractAddr(contractName);
    }

    function delContractAddr(string memory contractName)
        public
        override
        onlyByContractSetter
    {
        bytes32 key = _getStringKey("constants.contractName.", contractName);
        delAddress(key);
    }

    // A new contract would set up the permission to itself first. And replace
    // the existing contract by contract name.
    function setContractPermission(address contractAddr, address caller)
        public
        override
    {
        require(caller == owner());
        _setupRole(CONTRACT_ADDR_SETTER, contractAddr);
    }

    function setLotteryAddr(uint256 lotteryId, address lotteryAddr)
        public
        override
        onlyByContract("LotteryFactory")
    {
        _setLotteryAddr(lotteryId, lotteryAddr);
    }

    function setLotteryId(uint256 lotteryId, address lotteryAddr)
        public
        override
        onlyByContract("LotteryFactory")
    {
        _setLotteryId(lotteryId, lotteryAddr);
    }

    function getLotteryAddrById(uint256 lotteryId)
        public
        view
        override
        returns (address)
    {
        return _getLotteryAddr(lotteryId);
    }

    function getLotteryIdByAddr(address lotteryAddr)
        public
        view
        override
        returns (uint256)
    {
        return _getLotteryId(lotteryAddr);
    }

    function setHasLotteryActive(bool hasLotteryActive)
        public
        override
        onlyByContract("LotteryFactory")
    {
        _setHasLotteryActive(hasLotteryActive);
    }

    function getHasLotteryActive()
        public
        view
        override
        returns (bool)
    {
        return _getHasLotteryActive();
    }

    /* System-level parameters */
}

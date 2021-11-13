// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "hardhat/console.sol";
import "./ContextB.sol";

// lottery contract
contract Lottery is Ownable, ContextB {
    using EnumerableSet for EnumerableSet.UintSet;

    event PurchaseTicket(address account, uint256 ticketId);

    uint256 public startTime;
    uint256 public endTime;

    // the number of prize winner
    uint256 public numOfRemainingDiamondPrizeWinners;
    uint256 public numOfRemainingGoldPrizeWinners;
    uint256 public numOfRemainingSilverPrizeWinners;
    uint256 public numOfRemainingBronzePrizeWinners;

    // the id of prize winner
    EnumerableSet.UintSet diamondPrizeTicketIds;
    EnumerableSet.UintSet goldPrizeTicketIds;
    EnumerableSet.UintSet silverPrizeTicketIds;
    EnumerableSet.UintSet bronzePrizeTicketIds;
    EnumerableSet.UintSet totalPrizeTicketIds;

    // winner address array
    address[] public diamondPrizeWinners;
    address[] public goldPrizeWinners;
    address[] public silverPrizeWinners;
    address[] public bronzePrizeWinners;

    bool private _isActive;

    uint256[] private tickets;
    mapping(uint256 => address) private _ticketOwner;
    mapping(address => uint256) private _balance;

    // status: 0: no prize 1: have prize 2: already withdraw
    mapping(uint256 => uint256) private _ticketPrizeStatus;

    uint256 private _ticketCounter;
    uint256 private _numOfTicket;

    uint256[] private _tokenInfoIds;

    uint256 public constant lotteryPeriod = 7 days; // 7 days
    uint256 public ticketPrice = 0.001 ether;
    uint256 public startingIndex;
    uint256 public startingBlockIndex;

    uint256 public redeemDeadLine = 8 weeks;

    constructor(
        uint256 numOfTicket_,
        uint256 numOfDiamondPrizeWinners_,
        uint256 numOfGoldPrizeWinners_,
        uint256 numOfSilverPrizeWinners_,
        uint256 numOfBronzePrizeWinners_,
        address lotteryOwner_,
        uint256[] memory tokenInfoIds_,
        address externalStorageAccessAddr_
    ) ContextB(externalStorageAccessAddr_) {
        numOfRemainingBronzePrizeWinners = numOfBronzePrizeWinners_;
        numOfRemainingSilverPrizeWinners = numOfSilverPrizeWinners_;
        numOfRemainingGoldPrizeWinners = numOfGoldPrizeWinners_;
        numOfRemainingDiamondPrizeWinners = numOfDiamondPrizeWinners_;
        _numOfTicket = numOfTicket_;

        startTime = block.timestamp;
        endTime = startTime + lotteryPeriod;

        _isActive = true;
        _ticketCounter++;

        _tokenInfoIds = tokenInfoIds_;

        transferOwnership(lotteryOwner_);
    }

    modifier onlyOwnerOrContract(string memory contractName) {
        require(
            _msgSender() == owner() ||
            _msgSender() == _IESA().getContractAddr(contractName),
            "Not allowed"
        );
        _;
    }

    function purchaseTicket() public payable {
        require(isActive(), "Current lottery is ended");
        require(_ticketCounter <= _numOfTicket, "Ticket was sold out");
        require(msg.value >= ticketPrice, "Value not enough");

        _ticketOwner[_ticketCounter] = _msgSender();
        _balance[_msgSender()]++;
        tickets.push(_ticketCounter);

        emit PurchaseTicket(_msgSender(), _ticketCounter);
        _ticketCounter++;
    }

    function revealPrizeTicketId(uint8 prizeType, uint256 randomNumber_) public onlyOwner {
        require(!isActive(), "Lottery not ended");

        if (prizeType == 0) {
            require(goldPrizeTicketIds.length() > 0, "Please reveal gold prize tickets");
            _revealPrizeTicketId(diamondPrizeTicketIds, diamondPrizeWinners, numOfRemainingDiamondPrizeWinners, randomNumber_);
        } else if (prizeType == 1) {
            require(silverPrizeTicketIds.length() > 0, "Please reveal silver prize tickets");
            _revealPrizeTicketId(goldPrizeTicketIds, goldPrizeWinners, numOfRemainingGoldPrizeWinners, randomNumber_);
        } else if (prizeType == 2) {
            require(bronzePrizeTicketIds.length() > 0, "Please reveal bronze prize tickets");
            _revealPrizeTicketId(silverPrizeTicketIds, silverPrizeWinners, numOfRemainingSilverPrizeWinners, randomNumber_);
        } else if (prizeType == 3) {
            _revealPrizeTicketId(bronzePrizeTicketIds, bronzePrizeWinners, numOfRemainingBronzePrizeWinners, randomNumber_);
        }
    }

    function endLottery() public onlyOwner {
        require(diamondPrizeTicketIds.length() > 0, "Not reveal all prize");
        require(!isActive(), "Lottery not ended");
        _mappingTicketIdToToken();
    }

    function _mappingTicketIdToToken() private {
        startingBlockIndex = block.number;
        startingIndex = uint256(blockhash(startingBlockIndex - 1)) % _numOfTicket;

        if (startingIndex == 0) startingIndex++;
    }

    function getTokenByTicketId(uint256 ticketId) public view returns (uint256) {
        require(startingIndex != 0, "Not set startingIndex");
        uint256 tokenIndex = (startingIndex + ticketId) % _numOfTicket;
        return _tokenInfoIds[tokenIndex];
    }

    function getTicketOwner(uint256 ticketId) public view returns (address) {
        return _ticketOwner[ticketId];
    }

    function setLotteryDeactive() public onlyOwner {
        _isActive = false;
    }

    function getBalance(address account) public view returns (uint256) {
        return _balance[account];
    }

    function getTicketPrizeStatus(uint256 ticketId) public view returns (uint256) {
        return _ticketPrizeStatus[ticketId];
    }

    function setTicketPrizeStatus(uint256 ticketId, uint256 status)
        public
        onlyOwnerOrContract("Treasury")
    {
        _ticketPrizeStatus[ticketId] = status;
    }

    function getPrizeTicketIds(uint256 prizeType) public view returns (uint256[] memory) {
       if (prizeType == 0) {
           return diamondPrizeTicketIds.values();
       } else if (prizeType == 1) {
           return goldPrizeTicketIds.values();
       } else if (prizeType == 2) {
           return silverPrizeTicketIds.values();
       } else if (prizeType == 3) {
           return bronzePrizeTicketIds.values();
       }
    }

    function getPrizeWinners(uint256 prizeType) public view returns (address[] memory) {
        if (prizeType == 0) {
           return diamondPrizeWinners;
        } else if (prizeType == 1) {
           return goldPrizeWinners;
        } else if (prizeType == 2) {
           return silverPrizeWinners;
        } else if (prizeType == 3) {
           return bronzePrizeWinners;
        }
    }

    function isPrizeId(uint256 ticketId, uint256 prizeType) public view returns (bool) {
        if (prizeType == 0) {
           return diamondPrizeTicketIds.contains(ticketId);
        } else if (prizeType == 1) {
           return goldPrizeTicketIds.contains(ticketId);
        } else if (prizeType == 2) {
           return silverPrizeTicketIds.contains(ticketId);
        } else if (prizeType == 3) {
           return bronzePrizeTicketIds.contains(ticketId);
        }
    }

    function isActive() public view returns (bool) {
        return endTime > block.timestamp && _isActive;
    }

    function _isRevealed(uint256 ticketId_) private view returns (bool) {
        return totalPrizeTicketIds.contains(ticketId_);
    }

    function _revealPrizeTicketId(
        EnumerableSet.UintSet storage prizeTicketIds_,
        address[] storage prizeWinners,
        uint256 numOfPrizeWinners,
        uint256 randomNumber_
    ) private onlyOwner {
        uint256 randomNumber = randomNumber_;
        uint256 numOfRevealed;
        uint256 loopCounter;
        while (true) {
            loopCounter++;
            uint256 ticketId = (randomNumber % _numOfTicket) + 1;
            if (_isRevealed(ticketId)) {
                randomNumber = uint256(
                    keccak256(abi.encode(randomNumber, loopCounter))
                );
                continue;
            }

            prizeTicketIds_.add(ticketId);
            address owner = _ticketOwner[ticketId];
            prizeWinners.push(owner);
            totalPrizeTicketIds.add(ticketId);
            _ticketPrizeStatus[ticketId] = 1;
            numOfRevealed++;

            if (numOfRevealed >= numOfPrizeWinners) break;
        }
    }
}

pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "hardhat/console.sol";

contract RandomNumberGenerator is VRFConsumerBase {
    event GenerateRandomNumber(bytes32 requestId, uint256 randomness);
    
    bytes32 internal keyHash =
        0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
    uint256 internal fee = 0.1 * 10**18; // 0.1 LINK

    uint256[] public resultArray;

    address private constant _VRFCoordinator =
        0xa555fC018435bef5A13C6c6870a9d4C11DEC329C;
    address private constant _link = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;

    constructor()
        VRFConsumerBase(
            _VRFCoordinator, // VRF Coordinator
            _link // LINK Token
        )
    {}

    function getRandomness(uint256 requestCounter)
        public
        view
        returns (uint256)
    {
        return resultArray[requestCounter];
    }

    function getRandomnessLength() public view returns (uint256) {
        return resultArray.length;
    }

    function _getRandomNumber() internal returns (bytes32 requestId) {
        console.log("_getRandomNumber", address(this));
        require(
            LINK.balanceOf(address(this)) > fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        resultArray.push(randomness);
        emit GenerateRandomNumber(requestId, randomness);
    }
}

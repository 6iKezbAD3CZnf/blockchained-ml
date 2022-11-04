// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract BlockchainedLearning {
    uint64 private constant SIZE = 2287;

    uint blockNumber;
    event Update(uint blockNumber);

    constructor() {
        blockNumber = 0;
    }

    function update(int32[SIZE] calldata weights) public {
        blockNumber = block.number;
        emit Update(blockNumber);
    }

    function get() public view returns (uint) {
        return blockNumber;
    }
}

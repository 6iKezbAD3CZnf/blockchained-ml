// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract BlockchainedLearning {
    uint private constant SIZE = 4;
    uint64[SIZE] public weights;

    event Update(uint64[SIZE][] grad);

    constructor() {
        for (uint i = 0; i < SIZE; i++) {
            weights[i] = 0;
        }
    }

    function update(uint64[SIZE][] calldata grad) public {
        for (uint i = 0; i < grad.length; i++) {
            for (uint j = 0; j < SIZE; j++) {
                weights[j] += grad[i][j];
            }
        }
    }

    function get() public view returns (uint64[SIZE] memory) {
        return weights;
    }
}

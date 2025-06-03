// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 private storedData;

    function store(uint256 num) public {
        storedData = num;
    }

    function retrieve() public view returns (uint256) {
        return storedData;
    }
}

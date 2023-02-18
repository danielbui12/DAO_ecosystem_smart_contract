// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library DateTime {
        function getHour(uint256 timestamp) public pure returns (uint256) {
                return uint256((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint256 timestamp) public pure returns (uint256) {
                return uint256((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint256) {
                return uint256(timestamp % 60);
        }
}
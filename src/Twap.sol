// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";

contract Twap {
    IUniswapV2Pair pool;

    // 1HourTWAP storage slots
    uint256 public first1HourSnapShot_Price0Cumulative;
    uint32 public first1HourSnapShot_TimeStamp;

    // 1DayTWAP storage slots
    uint256 public first1DaySnapShot_Price0Cumulative;
    uint32 public first1DaySnapShot_TimeStamp;

    constructor(address _pool) {
        pool = IUniswapV2Pair(_pool);
    }

    //** ONE HOUR TWAP START      **//
    function first1HourSnapShot() public {
        first1HourSnapShot_Price0Cumulative = pool.price0CumulativeLast();
        (,, first1HourSnapShot_TimeStamp) = pool.getReserves();
    }

    function second1HourSnapShot() public returns (uint224 oneHourTwap) {
        uint256 currentPrice0Cumulative = pool.price0CumulativeLast();
        (,, uint32 currentTimeStamp) = pool.getReserves();

        uint32 timeElapsed = currentTimeStamp - first1HourSnapShot_TimeStamp;

        // TWAP = (PriceCumulative2 - PriceCumulative1) / (T2 - T1)
        unchecked {
            oneHourTwap = uint224((currentPrice0Cumulative - first1HourSnapShot_Price0Cumulative) / timeElapsed);
        }
        return oneHourTwap;
    }

    //** ONE DAY TWAP START      **//
    function first1DaySnapShot() public {
        first1DaySnapShot_Price0Cumulative = pool.price0CumulativeLast();
        (,, first1DaySnapShot_TimeStamp) = pool.getReserves();
    }

    function second1DaySnapShot() public returns (uint224 oneDayTwap) {
        uint256 currentPrice0Cumulative = pool.price0CumulativeLast();
        (,, uint32 currentTimeStamp) = pool.getReserves();

        uint32 timeElapsed = currentTimeStamp - first1DaySnapShot_TimeStamp;

        unchecked {
            // Ensure we use Cumulative Price difference divided by timeElapsed
            oneDayTwap = uint224((currentPrice0Cumulative - first1DaySnapShot_Price0Cumulative) / timeElapsed);
        }
        return oneDayTwap;
    }
}

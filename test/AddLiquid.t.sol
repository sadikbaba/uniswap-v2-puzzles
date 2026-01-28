// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {AddLiquid} from "../src/AddLiquid.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import "../src/interfaces/IERC20.sol";
import "./mock/mockERC20.sol";
import {mockUniswapV2Pair} from "./mock/mokcUniswapV2Pair.sol";




contract AddLiquidTest is Test {
    AddLiquid public addLiquid;

    MockERC20  public weth;
    MockERC20 public usdc;

mockUniswapV2Pair public pool ;

    function setUp() public {

        vm.createSelectFork("https://eth.llamarpc.com");

        usdc = new MockERC20();
        weth = new MockERC20();
        pool = new mockUniswapV2Pair();
 
        addLiquid = new AddLiquid();

        // transfers 1 WETH to addLiquid contract
        deal(address(weth), address(addLiquid), 1 ether);

        // transfers 1000 USDC to addLiquid contract
        deal(address(usdc), address(addLiquid), 1000e6);
    }

    function test_AddLiquidity() public {
        (uint256 reserve0, uint256 reserve1,) = pool.getReserves();
        uint256 _totalSupply = mockUniswapV2Pair(pool).totalSupply();

        vm.prank(address(0xb0b));
        addLiquid.addLiquidity(address(usdc), address(weth), address(pool), reserve0, reserve1);

        uint256 foo = (1000e6) - (mockUniswapV2Pair(address(usdc)).balanceOf(address(addLiquid)));

        uint256 puzzleBal = mockUniswapV2Pair(pool).balanceOf(address(0xb0b));

        uint256 bar = (foo * reserve1) / reserve0;

        uint256 expectBal = min((foo * _totalSupply) / (reserve0), (bar * _totalSupply) / (reserve1));

        require(puzzleBal > 0, "No LP tokens minted");
        assertEq(puzzleBal, expectBal, "Incorrect LP tokens received");
    }

    // Internal function
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
}

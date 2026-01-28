// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BurnLiquidWithRouter} from "../src/BurnLiquidWithRouter.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import "src/interfaces/IERC20.sol";
import {AddLiquidWithRouter} from "src/AddLiquidWithRouter.sol";
import {AddLiquid} from "src/AddLiquid.sol";

contract BurnLiquidWithRouterTest is Test {
    AddLiquidWithRouter public addlpwithrouter;
    AddLiquid public addlp;
    BurnLiquidWithRouter public burnLiquidWithRouterAddress;

    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public pool = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    address public router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/r1VHZ886XuNYndhbw_FF6");

        addlpwithrouter = new AddLiquidWithRouter(router);
        addlp = new AddLiquid();
        vm.rollFork(20055371);

        burnLiquidWithRouterAddress = new BurnLiquidWithRouter(router);

        // transfers 0.01 UNI-V2-LP to BurnLiquidWithRouterAddress
        deal(pool, address(burnLiquidWithRouterAddress), 0.01 ether);
    }

    function test_BurnLiquidityWithRouter() public {
        uint256 deadline = block.timestamp + 1 minutes;
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(pool).getReserves();

        vm.startPrank(address(0xb0b));
        addlpwithrouter.addLiquidityWithRouter(usdc, block.timestamp);
        addlp.addLiquidity(weth, usdc, pool, reserve0, reserve1);
        burnLiquidWithRouterAddress.burnLiquidityWithRouter(pool, usdc, weth, deadline);
        uint256 usdcBal = IERC20(usdc).balanceOf(address(burnLiquidWithRouterAddress));
        uint256 wethBal = IERC20(weth).balanceOf(address(burnLiquidWithRouterAddress));

        assertEq(usdcBal, 1432558576085, "Incorrect USDC tokens received");
        assertEq(wethBal, 388231892770818155977, "Incorrect WETH tokens received");
    }
}

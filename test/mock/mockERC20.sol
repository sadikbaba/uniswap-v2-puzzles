// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;


import {IERC20} from "src/interfaces/IERC20.sol";


contract MockERC20  {


     mapping ( address => uint) balances;

    function transfer(address to, uint256 amount) external returns(bool) {
        balances[msg.sender]-= amount;
        balances[to] += amount;
        return true;
    }
}
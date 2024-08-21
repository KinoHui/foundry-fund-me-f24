// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    // 测试第一步，setup()
    function setUp() external {
        // us -> FundMeTest -> FundMe
        // msg.sender = address(us)
        fundMe = new FundMe();
    }

    function testMinUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        assertEq(fundMe.i_owner(), address(this));
    }

    function testPricedFeedVersionIsAccurate() public view {
        uint version = fundMe.getVersion();
        assertEq(version, 4);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // SOlidity中无法使用
    uint256 constant DEFAULT_BALANCE = 10 ether;

    // 测试第一步，setup()
    function setUp() external {
        // us -> FundMeTest -> FundMe
        // msg.sender = address(us)
        // 重构fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, DEFAULT_BALANCE);
    }

    function testMinUsdIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPricedFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // next line should fail/revert (Foundry's cheat code)
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdateDateStructure() public funded {
        uint256 ammountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(ammountFunded, SEND_VALUE);
    }

    function testGetFunders() public funded {
        address funderAddress = fundMe.getFunders(0);
        console.log(funderAddress);
        assertEq(funderAddress, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // vm.txGasPrice该cheatcode将会使之后代码中的操作带上gas，gasleft()是solidity中内置的函数，返回该交易中的剩余gas
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawCheaperWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        // vm.txGasPrice该cheatcode将会使之后代码中的操作带上gas，gasleft()是solidity中内置的函数，返回该交易中的剩余gas
        vm.prank(fundMe.getOwner());
        fundMe.withdrawCheaper();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunder() public funded {
        uint160 numberOfUsers = 10; // SOlidity ^0.8后 不能直接在uint256和address之间转换，需要通过uint256(uint160(address))来转换，160位数匹配
        uint160 userAddress = 1;
        for (userAddress; userAddress < numberOfUsers; userAddress++) {
            hoax(address(userAddress), SEND_VALUE); // hoax（cheatcode）作用类似prank，下一笔交易使用给的地址，并带有给定的balance
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testPrintStorageData() public {
        for (uint256 i = 0; i < 3; i++) {
            bytes32 value = vm.load(address(fundMe), bytes32(i));
            console.log("Vaule at location", i, ":");
            console.logBytes32(value);
        }
        console.log("PriceFeed address:", address(fundMe.getPriceFeed()));
    }
}

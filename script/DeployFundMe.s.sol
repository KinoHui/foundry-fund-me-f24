// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelpConfig} from "./HelpConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // vm之外不会部署到链上，不消耗gas
        HelpConfig helpConfig = new HelpConfig();
        address usdEthPriceFeed = helpConfig.acctiveNetWorkConfig();

        vm.startBroadcast();
        FundMe fundMe = new FundMe(usdEthPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}

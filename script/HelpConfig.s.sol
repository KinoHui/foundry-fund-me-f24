// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelpConfig is Script {
    NetWorkConfig public acctiveNetWorkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetWorkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            acctiveNetWorkConfig = getSepoliaEthConfig();
        } else {
            acctiveNetWorkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetWorkConfig memory) {
        NetWorkConfig memory sepoliaConfig = NetWorkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetWorkConfig memory) {
        // price feed contract
        // 1.deploy the mocks
        // 2.return the mock address

        if (acctiveNetWorkConfig.priceFeed != address(0)) {
            return acctiveNetWorkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetWorkConfig memory anvilHelpConfig = NetWorkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilHelpConfig;
    }
}

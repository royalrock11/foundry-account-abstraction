// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {EntryPoint} from "lib/account-abstraction/contracts/core/EntryPoint.sol";

import {console2} from "lib/openzeppelin-contracts/lib/forge-std/src/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract HelperConfig is Script {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

   struct NetworkConfig {
        address entryPoint;
        // address usdc;
        address account;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 constant LOCAL_CHAIN_ID = 31337;
    address constant BURNER_WALLET = 0xc83965e46AF878D78aEb901fA1f359A178989de0;

    address constant FOUNDRY_DEFAULT_WALLET = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    NetworkConfig public localNetworkConfig;

    mapping(uint256 => NetworkConfig) public networkConfigs;

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getEthSepoliaConfig();
    }

   function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else if (networkConfigs[chainId].account != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    /*//////////////////////////////////////////////////////////////
                                CONFIGS
    //////////////////////////////////////////////////////////////*/
    function getEthSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789, account: BURNER_WALLET});
    }

    function getZksyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({entryPoint: address(0), account: BURNER_WALLET});
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.account != address(0)) {
            return localNetworkConfig;
        }

        // console2.log("Deploying Mocks...");
        vm.startBroadcast(FOUNDRY_DEFAULT_WALLET);

        EntryPoint entryPoint = new EntryPoint();

        vm.stopBroadcast();

        return NetworkConfig({entryPoint: address(entryPoint), account: FOUNDRY_DEFAULT_WALLET});
    }
}

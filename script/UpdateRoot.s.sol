// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

interface IRootUpdater {
    function updateRoot(bytes32 newRoot) external;

    function currentMerkleRoot() external view returns (bytes32);
}

contract UpdateRootScript is Script {
    address internal constant ZK_CLEAR_CREW =
        0x5E1DaD01d2A0f0b7e07ef6cBa61c972E30D7CCb5;
    bytes32 internal constant CURRENT_ROOT =
        0x215ba3788a3635e5b0d73c65b773cd531671144edab9a417edae352136d3b71a;

    function run() public {
        vm.startBroadcast();

        IRootUpdater(ZK_CLEAR_CREW).updateRoot(CURRENT_ROOT);

        vm.stopBroadcast();

        bytes32 updatedRoot = IRootUpdater(ZK_CLEAR_CREW).currentMerkleRoot();
        console.logBytes32(updatedRoot);
        require(updatedRoot == CURRENT_ROOT, "root update failed");
    }
}

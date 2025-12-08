// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {zkClearCrew} from "../src/zkClearCrew.sol";
import {HonkVerifier} from "../src/verifier.sol";

contract ClearCrewDeploy is Script {
    zkClearCrew public zkClearCrewInstance;
    HonkVerifier public verifier;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // 1. Deploy HonkVerifier first
        console.log("Deploying HonkVerifier...");
        verifier = new HonkVerifier();
        console.log("HonkVerifier deployed at:", address(verifier));

        // 2. Deploy zkWhistleblowing with verifier address
        console.log("Deploying zkWhistleblowing...");
        zkClearCrewInstance = new zkClearCrew(
            address(verifier),
            address(0xA420ee2e00D20D99a9c9c957C69E6EcE94379E3d)
        );
        console.log("zkClearCrew deployed at:", address(zkClearCrewInstance));

        // 3. Verify deployment
        console.log("Verifying deployment...");
        address deployedVerifier = zkClearCrewInstance.verifier();
        require(
            deployedVerifier == address(verifier),
            "Verifier address mismatch"
        );
        console.log("Deployment verification successful");

        console.log("=== Deployment Summary ===");
        console.log("HonkVerifier:     ", address(verifier));
        console.log("zkClearCrew: ", address(zkClearCrewInstance));
        console.log("Network:          ", block.chainid);
        console.log("Block number:     ", block.number);

        vm.stopBroadcast();
    }
}

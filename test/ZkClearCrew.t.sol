// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {zkClearCrew} from "../src/zkClearCrew.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract ZkClearCrewProofTest is Test {
    event WhistleblowSubmitted(
        address indexed whistleblower,
        string ipfsCid,
        bytes32 submittedRoot
    );

    address internal constant TEST_USER =
        address(0xA420ee2e00D20D99a9c9c957C69E6EcE94379E3d);

    HonkVerifier internal verifier;
    zkClearCrew internal app;

    function setUp() public {
        verifier = new HonkVerifier();
        app = new zkClearCrew(address(verifier), address(this));
    }

    function testVerifierDirect_WithProvidedProofAndRoot() public view {
        bytes memory proof = _proofFromEnv();
        bytes32 submittedRoot = _rootFromEnv();

        bytes32[] memory publicInputs = new bytes32[](1);
        publicInputs[0] = submittedRoot;

        bool ok = verifier.verify(proof, publicInputs);
        assertTrue(ok, "verifier.verify returned false");
    }

    function testSubmitWhistleblow_WithProvidedProofAndRoot() public {
        bytes memory proof = _proofFromEnv();
        bytes32 submittedRoot = _rootFromEnv();
        string memory ipfsCid = _cidFromEnv();

        app.updateRoot(submittedRoot);

        vm.expectEmit(true, true, true, true);
        emit WhistleblowSubmitted(TEST_USER, ipfsCid, submittedRoot);

        vm.prank(TEST_USER);
        app.submitWhistleblow(proof, ipfsCid, submittedRoot);
    }

    function _proofFromEnv() internal view returns (bytes memory) {
        return vm.envBytes("ZK_PROOF_BYTES");
    }

    function _rootFromEnv() internal view returns (bytes32) {
        return vm.envBytes32("ZK_SUBMITTED_ROOT");
    }

    function _cidFromEnv() internal view returns (string memory) {
        return vm.envString("ZK_IPFS_CID");
    }
}

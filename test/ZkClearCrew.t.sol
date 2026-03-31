// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {zkClearCrew} from "../src/zkClearCrew.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract ZkClearCrewProofTest is Test {
    uint256 internal constant EXPECTED_PROOF_BYTES = 456 * 32;

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
        bytes32 nullifierHash = _nullifierHashFromEnv();

        bytes32[] memory publicInputs = new bytes32[](2);
        publicInputs[0] = submittedRoot;
        publicInputs[1] = nullifierHash;

        bool ok = verifier.verify(proof, publicInputs);
        assertTrue(ok, "verifier.verify returned false");
    }

    function testSubmitWhistleblow_WithProvidedProofAndRoot() public {
        bytes memory proof = _proofFromEnv();
        bytes32 submittedRoot = _rootFromEnv();
        bytes32 nullifierHash = _nullifierHashFromEnv();
        string memory ipfsCid = _cidFromEnv();

        app.updateRoot(submittedRoot);

        vm.expectEmit(true, true, true, true);
        emit WhistleblowSubmitted(TEST_USER, ipfsCid, submittedRoot);

        vm.prank(TEST_USER);
        app.submitWhistleblow(proof, ipfsCid, submittedRoot, nullifierHash);
    }

    function _proofFromEnv() internal view returns (bytes memory) {
        bytes memory raw = vm.envBytes("ZK_PROOF_BYTES");
        emit log_named_uint("raw_proof_length", raw.length);

        if (raw.length == EXPECTED_PROOF_BYTES) {
            return raw;
        }

        require(
            raw.length > EXPECTED_PROOF_BYTES,
            "proof shorter than verifier expectation"
        );

        return _slice(raw, raw.length - EXPECTED_PROOF_BYTES, EXPECTED_PROOF_BYTES);
    }

    function _rootFromEnv() internal view returns (bytes32) {
        return vm.envBytes32("ZK_SUBMITTED_ROOT");
    }

    function _cidFromEnv() internal view returns (string memory) {
        return vm.envString("ZK_IPFS_CID");
    }

    function _nullifierHashFromEnv() internal view returns (bytes32) {
        return vm.envBytes32("ZK_NULLIFIER_HASH");
    }

    function _slice(
        bytes memory data,
        uint256 start,
        uint256 len
    ) internal pure returns (bytes memory out) {
        require(start + len <= data.length, "slice out of bounds");

        out = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            out[i] = data[start + i];
        }
    }
}

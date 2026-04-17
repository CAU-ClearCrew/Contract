// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {Test} from "forge-std/Test.sol";
import {zkClearCrew} from "../src/zkClearCrew.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract ZkClearCrewProofTest is Test {
    uint256 internal constant EXPECTED_PROOF_BYTES = 508 * 32;
    uint256 internal constant PUBLIC_INPUT_BYTES = 2 * 32;
    string internal constant PROOF_PATH = "testdata/proof";
    string internal constant PUBLIC_INPUTS_PATH = "testdata/public_inputs";
    string internal constant TEST_IPFS_CID = "QmTestCid";

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

    function testVerifierDirect_WithProvidedProofAndRoot() public {
        bytes memory proof = _proofFromFile();
        (bytes32 submittedRoot, bytes32 nullifierHash) = _publicInputsFromFile();

        bytes32[] memory publicInputs = new bytes32[](2);
        publicInputs[0] = submittedRoot;
        publicInputs[1] = nullifierHash;

        bool ok = verifier.verify(proof, publicInputs);
        assertTrue(ok, "verifier.verify returned false");
    }

    function testSubmitWhistleblow_WithProvidedProofAndRoot() public {
        bytes memory proof = _proofFromFile();
        (bytes32 submittedRoot, bytes32 nullifierHash) = _publicInputsFromFile();
        string memory ipfsCid = TEST_IPFS_CID;

        app.updateRoot(submittedRoot);

        vm.expectEmit(true, true, true, true);
        emit WhistleblowSubmitted(TEST_USER, ipfsCid, submittedRoot);

        vm.prank(TEST_USER);
        app.submitWhistleblow(proof, ipfsCid, submittedRoot, nullifierHash);
    }

    function _proofFromFile() internal returns (bytes memory) {
        bytes memory raw = vm.readFileBinary(PROOF_PATH);
        emit log_named_uint("raw_proof_length", raw.length);

        require(raw.length == EXPECTED_PROOF_BYTES, "unexpected proof length");
        return raw;
    }

    function _publicInputsFromFile()
        internal
        view
        returns (bytes32 submittedRoot, bytes32 nullifierHash)
    {
        bytes memory publicInputs = vm.readFileBinary(PUBLIC_INPUTS_PATH);
        require(
            publicInputs.length == PUBLIC_INPUT_BYTES,
            "unexpected public input length"
        );

        assembly {
            submittedRoot := mload(add(publicInputs, 0x20))
            nullifierHash := mload(add(publicInputs, 0x40))
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/*
### **. 제보 제출 (온체인)**

- 고발자는 Arbitrum 컨트랙트에:
    - **STARK 증명 + 제보내용(ipfs cid) + submittedRoot**를 제출.
- 컨트랙트는:
    - **STARK Verifier**로 증명을 검증 → 제보자가 실제 사원임을 확인.
    - **submittedRoot** 현재 root와 비교 → 현재 회사 소속임을 증명.
    - 유효한 제보만 Event로 기록 → 기업이 안전하게 수신.
*/

interface IVerifier {
    function verify(
        bytes calldata _proof,
        bytes32[] calldata _publicInputs
    ) external view returns (bool);
}

contract zkClearCrew {
    // groupId를 이벤트로 띄워야하지않나?
    event WhistleblowSubmitted(
        address indexed whistleblower,
        string ipfsCid,
        bytes32 submittedRoot
    );

    // STARK Verifier contract address
    address public verifier;
    address public owner;
    bytes32 public currentMerkleRoot;

    constructor(address _verifier, address _owner) {
        verifier = _verifier;
        owner = _owner;
    }

    function updateRoot(bytes32 newRoot) external {
        require(msg.sender == owner, "Only owner can update Merkle root");
        currentMerkleRoot = newRoot;
    }

    function submitWhistleblow(
        bytes calldata proof,
        string calldata ipfsCid,
        bytes32 submittedRoot
    ) external {
        require(isValidMerkleRoot(submittedRoot), "Invalid root");
        require(verifyProof(proof, submittedRoot), "Invalid proof");

        emit WhistleblowSubmitted(msg.sender, ipfsCid, submittedRoot);
    }

    // STARK 증명을 통해 실제 Merkle 트리의 사원인지 검증
    function verifyProof(
        bytes calldata proof,
        bytes32 submittedRoot
    ) internal view returns (bool) {
        // submittedRoot를 public input으로 사용
        bytes32[] memory publicInputs = new bytes32[](1);
        publicInputs[0] = submittedRoot;
        return IVerifier(verifier).verify(proof, publicInputs);
    }

    function isValidMerkleRoot(bytes32 root) internal view returns (bool) {
        return root == currentMerkleRoot;
    }
}

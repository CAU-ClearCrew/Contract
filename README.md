## zkClearCrew Contracts

온체인 익명 제보를 위한 zk-SNARK/STARK 기반 검증 컨트랙트 패키지입니다. Arbitrum에서 제보자가 Merkle 트리에 포함된 실존 구성원임을 증명하고, IPFS CID 형태의 제보 내용을 제출합니다.

### 폴더 구조

- `src/zkClearCrew.sol`: 메인 제보 컨트랙트. 루트 관리와 제보 이벤트 발생.
- `src/Verifier.sol`: Honk STARK/zkProof 검증기 (Aztec 제공 HonkVerifier).
- `script/deployer.s.sol`: Foundry 배포 스크립트. Verifier → zkClearCrew 순서로 배포.
- `broadcast/`: 배포 결과 아티팩트.

### 핵심 컨트랙트 (`zkClearCrew.sol`)

- 상태 변수: `verifier`(HonkVerifier 주소), `owner`, `currentMerkleRoot`.
- `updateRoot(bytes32 newRoot)`: 오너만 Merkle root 갱신.
- `submitWhistleblow(bytes proof, string ipfsCid, bytes32 submittedRoot)`: 증명 검증 후 제보 이벤트 발생. `submittedRoot`가 `currentMerkleRoot`와 일치해야 하며, STARK 검증에 실패하면 revert.
- 이벤트 `WhistleblowSubmitted(address whistleblower, string ipfsCid, bytes32 submittedRoot)` 발행으로 오프체인 수신 가능.

### 배포 (예시)

```bash
forge script script/deployer.s.sol:ClearCrewDeploy \
	--rpc-url $RPC_URL \
	--private-key $PRIVATE_KEY \
	--broadcast
```

배포 스크립트는 HonkVerifier를 먼저 배포한 뒤, 해당 주소와 오너 지갑 주소를 생성자 인자로 넣어 `zkClearCrew`를 배포합니다.

### 루트 업데이트 & 제보 흐름

1. 오너가 `updateRoot(newRoot)`로 최신 Merkle root 반영.
2. 제보자는 off-chain에서 STARK 증명을 만들고 `submitWhistleblow(proof, ipfsCid, submittedRoot)` 호출.
3. 컨트랙트는 `Verifier.verify`로 증명 확인 → `submittedRoot`가 `currentMerkleRoot`와 같으면 `WhistleblowSubmitted` 이벤트 발생.

### 로컬 개발

- 빌드: `forge build`
- 테스트: `forge test`
- 포맷: `forge fmt`

### 필요 환경 변수

- `RPC_URL`: 대상 네트워크 RPC 엔드포인트
- `PRIVATE_KEY`: 배포/트랜잭션에 사용할 개인키 (안전하게 관리)

### 참고

- Foundry 문서: https://book.getfoundry.sh/

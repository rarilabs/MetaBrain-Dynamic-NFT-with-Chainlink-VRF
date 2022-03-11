// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract MetaBrainVRFNFT is ERC721, VRFConsumerBase {
    using SafeMath for uint256;
    using Strings for uint256;

    // Deployed on Opensea: https://testnets.opensea.io/collection/metabrain-vrf-nft
    // Contract on Rinkeby: https://rinkeby.etherscan.io/address/

    //https://docs.chain.link/docs/vrf-contracts/
    address private VRFCoordinator = 0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B; // Kovan: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
    address private linkToken = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709; // Kovan: 0xa36085F69e2889c224210F603D836748e7dC0088
    bytes32 private keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311; // Kovan: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
    uint256 private fee = 0.1 * 10 ** 18; //0.1 LINK

    string public baseUri = "ipfs://QmVA4mwKVZ7kqKVnfhRRkg4mBVHaFkMcERdPpsJnVcnLVo/";

    mapping(bytes32 => address) public requestToSender; // requestId => sender's address
    mapping(bytes32 => uint256) public requestToTokenId; // requestId => tokenId

    uint256[] public tokenPool = [1,2,3,4,5,6,7,8,9];
    

    // VRFConsumerBase(VRFCoordinator, linkToken)
    constructor() ERC721("MetaBrain", "BRAIN") VRFConsumerBase(0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, 0x01BE23585060835E02B77ef475b0Cc51aA1e0709) {
    }

    function mintRandomBrain() public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestToSender[requestId] = _msgSender();

        return requestId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
        uint256 size = tokenPool.length;
        uint256 index = randomNumber % size;

         // token id
        requestToTokenId[requestId] = tokenPool[index];

        // swap & remove token from pool
        tokenPool[index] = tokenPool[tokenPool.length - 1];
        tokenPool.pop();

        _safeMint(requestToSender[requestId], requestToTokenId[requestId]);
    }
    
    function tokenURI(uint256 _tokenId) override public view returns (string memory) {
        return string(abi.encodePacked(baseUri, _tokenId.toString(), ".json"));
    }

}

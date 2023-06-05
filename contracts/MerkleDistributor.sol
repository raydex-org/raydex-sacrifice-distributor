// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleDistributor {
    address public immutable token;
    bytes32 public immutable merkleRoot;

    mapping(address => uint) private addressesClaimed;

    event Claimed(address indexed _from, uint256 amount);

    constructor(address token_, bytes32 merkleRoot_) {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    function claim(bytes32[] calldata merkleProof, uint256 amount) external {
        require(
            addressesClaimed[msg.sender] == 0,
            "MerkleDistributor: Drop already claimed."
        );

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(msg.sender));

        require(
            MerkleProof.verify(merkleProof, merkleRoot, node),
            "MerkleDistributor: Invalid proof."
        );

        // Mark it claimed and send the token.
        addressesClaimed[msg.sender] = 1;

        require(
            IERC20(token).transfer(msg.sender, amount),
            "MerkleDistributor: Transfer failed."
        );

        emit Claimed(msg.sender, amount);
    }
}

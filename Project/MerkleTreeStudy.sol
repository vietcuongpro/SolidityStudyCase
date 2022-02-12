/*
    Imagine an array of 2^n element,
    We compute hash of 2 consecutive element
        (1, 2) (3, 4) ... (2^n-1, 2^n)
            \   |     ...      /
            h1 h2            h_k
        => Then continue to compute until only 1 hash left => merkle tree root
            (if number of hash is odds, we can duplicate the last hash to get 1)

    => Usage example: Eve want to check a transaction 3 is included in a block or not
    => we only need tx_hash of block (3, 4) & some upper block (total logn blocks) to 
        compute the single hash => if it match merkle tree root -> the transaction is included
    => This way we don't need to reveal entire set

    Write a contract using Merkle Tree that verify if a transaction is included in the block or not
*/

pragma solidity ^0.8.0;

contract MerkleTreeUsage {
    // Verify if leaf_hash is included in the merkle tree
    function verify(
        bytes32[] memory hash_nodes,    // array of hashes to compute merkle root
        bytes32 root,   // merkle root
        bytes32 leaf,   // the leaf_hash of the transaction we want to verify
        uint index  // index of that transaction
    ) public pure returns (bool) {
        bytes32 hash = leaf;

        for (uint i = 0; i < hash_nodes.length; i++) {
            if (index % 2 == 0) 
                hash = keccak256(abi.encodePacked(hash, hash_nodes[i]));
            else 
                hash = keccak256(abi.encodePacked(hash_nodes[i], hash));
            
            index /= 2;
        }

        return hash == root;
    }
}

contract TestMerkleTreeUsage {
    bytes32[] hashes;

    constructor() {
        string[4] memory transactions = [
            "a -> b",
            "b -> c",
            "c -> d",
            "d -> a"
        ];

        for (uint i = 0; i < transactions.length; i++)
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        
        uint offset = 0;
        uint n = hashes.length;
        while (n > 0) {
            for (uint i = 0; i < n-1; i+=2) 
                hashes.push(
                    keccak256(abi.encodePacked(hashes[offset+i], hashes[offset+i+1]))
                );
            
            offset += n;
            n /= 2;
        }
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length-1];
    }

    function getHashes() public view returns (bytes32[] memory) {
        return hashes;
    }
}

/*
    root:  0x1211004d09ab92da15e52e7d10fe420ff792f9cbee5057a507f946a1a50a4353
    hashes: 0xa687396aad571ea3dfb2dc934cc9c261be6616a1dbd6d7bf634a3e0e5fe21662, (index 0)
        0x65e3c684c8f8c3a77fd88a223c590cfb91c6b972c8cfe3da828d83cefab8d7e8, (index 1)
        0xe7a78f79e0481d9db78f589325cc95ef56779e32006f294464b9b31bcf552ecb, (index 2)
        0x22427e60d281a4089a2e709c67a603226fd452e8d6dc690cd3a9fafbe0837f74, (index 3)
        0xbad11186aee9d6ff105df77c8d9f7a3f196de7d79751a76bd02d478098fa51c9, (index 0-1)
        0x43849265939bd81c3c7181c4d4aa286df29c9534f107d88388d0623cbbf938a5, (index 2-3)
        0x1211004d09ab92da15e52e7d10fe420ff792f9cbee5057a507f946a1a50a4353 (root)

    Test verify if (index 3) is included in the block
        leaf: 0x22427e60d281a4089a2e709c67a603226fd452e8d6dc690cd3a9fafbe0837f74
        root: 0x1211004d09ab92da15e52e7d10fe420ff792f9cbee5057a507f946a1a50a4353
        index: 3
        hash_nodes:
            0xe7a78f79e0481d9db78f589325cc95ef56779e32006f294464b9b31bcf552ecb (index 2)
            0xbad11186aee9d6ff105df77c8d9f7a3f196de7d79751a76bd02d478098fa51c9 (index 0-1)
        => ["0xe7a78f79e0481d9db78f589325cc95ef56779e32006f294464b9b31bcf552ecb", "0xbad11186aee9d6ff105df77c8d9f7a3f196de7d79751a76bd02d478098fa51c9"]
*/
# Purpose

This contract can be used to show private data can still access

# Explain

Storage has 2^256 slot, each slot 32 bytes
- Data is stored sequentially in declaration order
- Storage is designed to be optimal. If neighboring data fit in a single 32 bytes, it is 
    packed in same slot, starting from the right

# Important

Look at test/sample-test.js how to get data of each slot
The contract is deployed at 0x7508E391F8fD72B0f3024c6c49A0f3398385797D on Ropsten
Run 'npx hardhat compile' then 'npx hardhat test' to see

# Prevent Technique

Don't put important information on the blockchain

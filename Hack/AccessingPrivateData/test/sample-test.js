const { expect } = require("chai");
const { ethers } = require("hardhat");

var Web3 = require("web3")
var web3js = new Web3("https://eth-ropsten.alchemyapi.io/v2/UoFovRMiC1EFEFkPusipx64GsulFSwJ1")

describe("Testing", function () {
  it("Get content of each slot in storage", async function () {
    let contract_addr = "0x7508E391F8fD72B0f3024c6c49A0f3398385797D"
    let web3_getStorageAt = web3js.eth.getStorageAt

    console.log("-- Slot 0: --")
    /* Get content of slot-0 in contract storage
        Result = '0x7b' -> 123 -> the 'count' variable
     */
    await web3_getStorageAt(contract_addr, 0, console.log)

    console.log("-- Slot 1: --")
    /*
        Result = '0x000000000000000000001f01265989e604334a68b9dbf1ae453c35c9d7b0b7a6'
        Leftmost 20 bytes -> owner = 0x265989e604334a68b9dbf1ae453c35c9d7b0b7a6
        next 1 bytes -> isTrue = 0x01 -> true
        next 1 bytes -> u16 = 0x1f -> 31
    * */
    await web3_getStorageAt(contract_addr, 1, console.log)

    console.log("-- Slot 2: --")
    /* Result = '0x7465737400000000000000000000000000000000000000000000000000000000'
    *   => this is pass word, convert to ascii using web3.utils.toAscii
    *   => password = 'test'
    * */
    await web3_getStorageAt(contract_addr, 2, console.log)
    console.log("Password: ", Web3.utils.toAscii("0x746573740000000000000000000000000000000000000000000000000000000"))

    console.log("-- Slot 3/4/5: --")
    await web3_getStorageAt(contract_addr, 3, console.log)
    await web3_getStorageAt(contract_addr, 4, console.log)
    await web3_getStorageAt(contract_addr, 5, console.log)

    console.log("-- Slot 6: --")
    /*
      Result 0x2 -> Length of array = 2
     */
    await web3_getStorageAt(contract_addr, 6).then(console.log)

    let hash = Web3.utils.soliditySha3({type: "uint", value: 6})
    // this is keccak256(6), 'string' type
    let hash_value = BigInt(hash)
    let big_one = BigInt(1)

    console.log("-- Slot keccak256(6) -- ")
    console.log('User 0 ID: ')
    await web3_getStorageAt(contract_addr, hash).then(console.log)
    let pos_pw = '0x' + (hash_value+ big_one).toString(16)
    console.log("User 0's Password (bytes32): ")
    await web3_getStorageAt(contract_addr, pos_pw).then(console.log)
    // Result: 0x6162633132330000000000000000000000000000000000000000000000000000
    console.log("User 0's password (ascii):", Web3.utils.toAscii("0x6162633132330000000000000000000000000000000000000000000000000000"))

    let index1 = '0x'+ (hash_value + BigInt(2) * big_one).toString(16)
    console.log('User 1 ID: ')
    await web3_getStorageAt(contract_addr, index1).then(console.log)
    let index1_pw = '0x'+ (BigInt(index1)+ big_one).toString(16)
    console.log("User 1's Password (bytes32): ")
    await web3_getStorageAt(contract_addr, index1_pw).then(console.log)
    // Result: 0x3132336162630000000000000000000000000000000000000000000000000000
    console.log("User 1's password (ascii):", Web3.utils.toAscii("0x3132336162630000000000000000000000000000000000000000000000000000"))

    console.log('-- Key 1 in mapping --: ')
    let map_key1slot = Web3.utils.soliditySha3({type: 'uint', value: 1}, {type: 'uint', value: 7})
    console.log('User id: ')
    await web3_getStorageAt(contract_addr, map_key1slot).then(console.log)
    let tmp = '0x'+(BigInt(map_key1slot)+big_one).toString(16)
    console.log('User password: ')
    await web3_getStorageAt(contract_addr, tmp).then(console.log)
  })
});

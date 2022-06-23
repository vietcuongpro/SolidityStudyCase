const { ethers, upgrades } = require("hardhat")

const PROXY = "0x567f0e9F937184d34b0e2fdc6ccEfB5cfD1d76e1"

async function main() {
    const SampleV2 = await ethers.getContractFactory("SampleV2")
    await upgrades.upgradeProxy(PROXY, SampleV2)
    console.log("Sample upgraded")
}

main()
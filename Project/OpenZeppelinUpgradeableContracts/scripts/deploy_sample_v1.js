const { ethers, upgrades } = require("hardhat")

async function main() {
    console.log("limbo")
    const Sample = await ethers.getContractFactory("Sample")

    const sample = await upgrades.deployProxy(Sample, [666], {
        initializer: "init"
    })
    await sample.deployed()

    console.log("Sample deployed to: ", sample.address)
}

main()
const main = async () => {
    const domainContractFactory = await hre.ethers.getContractFactory("Domains");
    const domainContract = await domainContractFactory.deploy("khushi");
    await domainContract.deployed();

    console.log("Contract deployed to:", domainContract.address);

    let txn = await domainContract.register("awesome", { value: hre.ethers.utils.parseEther("0.1") });
    await txn.wait();
    console.log("Minted domain awesome.khushi");

    txn = await domainContract.setRecord("awesome", "Isn't Khushi awesome ??");
    await txn.wait();
    console.log("Set record for awesome.khushi");

    const address = await domainContract.getAddress("awesome");
    console.log("Owner of domain awesome:", address);

    const balance = await hre.ethers.provider.getBalance(domainContract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();
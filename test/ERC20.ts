/* eslint-disable @typescript-eslint/no-unused-expressions */

// import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
// import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { ERC20 } from "../typechain-types/ERC20";
import { ENS } from "../typechain-types";
// import { sign } from "crypto";

let fakeUsdt: ERC20;
let ens: ENS;

describe("ENS Testing", function () {
	it("deploy fake usdt", async function () {
		const [signer] = await ethers.getSigners();
		const FakeUSDT = await ethers.getContractFactory("ERC20");
		fakeUsdt = await FakeUSDT.deploy("Fake USDT", "USDT", 18, signer.address, 1e4) as ERC20;
		await fakeUsdt.deployed();
		expect(fakeUsdt.address).to.exist;
	});

	it("deploy ENS", async function () {
		const ENS = await ethers.getContractFactory("ENS");
		ens = await ENS.deploy(fakeUsdt.address) as ENS;
		await ens.deployed();
		expect(ens.address).to.exist;
		
	});

	it("approve USDT for ENS purchase", async () => {
		const [signer] = await ethers.getSigners();
		const amount = ethers.utils.parseEther("0.1");
		const tx = await fakeUsdt.approve(ens.address, amount);
		await tx.wait();
		const allowance = await fakeUsdt.allowance(signer.address, ens.address);
		expect(allowance.toHexString()).to.equal(amount.toHexString());
	})

	/* it("add name into ENS registry", async () => {
		const myEns = "maria.ens";
		const tx = await ens.addName(myEns, fakeUsdt.address);
		await tx.wait();
		const nameaddress = await ens.resolve(myEns);
		expect(nameaddress).to.equal(fakeUsdt.address);
	}) */
});

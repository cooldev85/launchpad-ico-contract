import hre from 'hardhat';
import { Contract } from 'ethers';
import 'colors';
const {ethers, deployments} = hre;

const deployContract = async (name: string, args: Array<any>) => {
	const _Contract = await ethers.getContractFactory(name)
	const _contract = await _Contract.deploy(...args)
	await _contract.deployed()
	console.log('\t', `${name}`, _contract.address.green)
	return _contract
}

const sendTx = async (contract: Contract, method: string, args: Array<string|number|boolean>, log: string) => {
	const tx = await contract[method](...args)
	console.log('\t', log.replace('{tx}', String(tx.hash).yellow))
	await tx.wait()
}


const deploy = async (owner: string) => {
	console.log('deployer ', owner);
	console.log('deploying contracts...'.yellow);
	const deamNameWrapper = await deployContract('DeamNameWrapper', []);
	await sendTx(registry, 'setOwner', [ZERO_HASH, root.address], `Setting owner of root node to root contract ({tx})`)
	
	// fs.writeFileSync(path.join(ENSLibPath, `contracts.json`), JSON.stringify({
	// 	registry: registry.address,
	// 	dnsSECImpl: dnsSECImpl.address,
	// 	tldPublicSuffixList: tldPublicSuffixList.address,
	// 	dnsRegistrar: dnsRegistrar.address,
	// 	reverseRegistrar: reverseRegistrar.address,
	// 	root: root.address,
	// 	registrar: registrar.address,
	// 	staticMeta: staticMeta.address,
	// 	nameWrapper: nameWrapper.address,
	// 	dummyOracle: dummyOracle.address,
	// 	priceOracle: priceOracle.address,
	// 	ethRegistrarController: ethRegistrarController.address,
	// 	publicResolver: publicResolver.address,
	// 	deamNameWrapper: deamNameWrapper.address,
	// }, null, '\t'));

	// const contractList = [
	// 	'ENSRegistry', 
	// 	'DNSSECImpl', 
	// 	'TLDPublicSuffixList',
	// 	'DNSRegistrar',
	// 	'ReverseRegistrar',
	// 	'Root',
	// 	'BaseRegistrarImplementation',
	// 	'StaticMetadataService',
	// 	'NameWrapper',
	// 	'DummyOracle',
	// 	'ExponentialPremiumPriceOracle',
	// 	'ETHRegistrarController',
	// 	'PublicResolver',
	// 	'DeamNameWrapper'
	// ];

	// for (let i of contractList) {
	// 	fs.writeFileSync(path.join(ENSLibPath, 'abis', `${i}.json`), JSON.stringify((await deployments.getArtifact(i)).abi, null, '\t'))
	// }
}

async function main() {
	const [owner] = await ethers.getSigners();

	const {
		// registry,
		// dnsSECImpl,
		// tldPublicSuffixList,
		// dnsRegistrar,
		reverseRegistrar,
	} = await deploy(owner.address);

	// start test
	console.log('start testing...'.yellow)
	
	
	await test_set_text("koinu.irina.galaxy.neon", publicResolver, deamNameWrapper)
};

main().then(() => process.exit(0)).catch((error) => {
	console.error(error);
	process.exit(1);
});
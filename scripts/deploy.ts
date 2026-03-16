import { ethers } from "hardhat";

/**
 * Deploy scripti — DIDRegistry ve RevocationRegistry'yi local node'a yükler.
 * Çalıştırma: npx hardhat run scripts/deploy.ts --network localhost
 */
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deployer adresi  :", deployer.address);
  console.log("---");

  // DIDRegistry deploy
  const DIDRegistryFactory = await ethers.getContractFactory("DIDRegistry");
  const DIDRegistry = await DIDRegistryFactory.deploy();
  await DIDRegistry.waitForDeployment();
  const didAddr = await DIDRegistry.getAddress();
  console.log("DIDRegistry      :", didAddr);

  // RevocationRegistry deploy
  const RevRegistryFactory = await ethers.getContractFactory(
    "RevocationRegistry",
  );
  const RevRegistry = await RevRegistryFactory.deploy();
  await RevRegistry.waitForDeployment();
  const revAddr = await RevRegistry.getAddress();
  console.log("RevocationRegistry:", revAddr);

  // .env için hazır çıktı
  console.log("\n.env dosyasına kopyalayın:");
  console.log(`DID_REGISTRY_ADDRESS=${didAddr}`);
  console.log(`REVOCATION_ADDRESS=${revAddr}`);
  console.log(
    `PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`,
  );
  console.log(`ADMIN_API_KEY=mvp-demo-secret-key`);
  console.log(`PORT=3001`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

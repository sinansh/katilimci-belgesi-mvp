import { expect } from "chai";
import { ethers } from "hardhat";

describe("DIDRegistry", function () {
  async function deployFixture() {
    const [admin, other] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("DIDRegistry");
    const registry = await Factory.deploy();
    await registry.waitForDeployment();
    return { registry, admin, other };
  }

  it("Admin varsayilan olarak yetkili issuer olmali", async function () {
    const { registry, admin } = await deployFixture();
    expect(await registry.isAuthorized(admin.address)).to.equal(true);
  });

  it("Admin yeni issuer ekleyebilmeli", async function () {
    const { registry, other } = await deployFixture();
    await registry.registerIssuer(other.address, "did:ethr:" + other.address);
    expect(await registry.isAuthorized(other.address)).to.equal(true);
  });

  it("Sadece admin issuer ekleyebilmeli", async function () {
    const { registry, other } = await deployFixture();
    await expect(
      registry.connect(other).registerIssuer(other.address, "did:ethr:test"),
    ).to.be.revertedWith("Only admin");
  });

  it("Kayitli DID string dogru donmeli", async function () {
    const { registry, other } = await deployFixture();
    const did = "did:ethr:" + other.address;
    await registry.registerIssuer(other.address, did);
    expect(await registry.getIssuerDID(other.address)).to.equal(did);
  });
});

describe("RevocationRegistry", function () {
  async function deployFixture() {
    const [admin, other] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("RevocationRegistry");
    const registry = await Factory.deploy();
    await registry.waitForDeployment();
    return { registry, admin, other };
  }

  it("Iptal edilmeyen belge gecerli olmali", async function () {
    const hash = ethers.keccak256(ethers.toUtf8Bytes("test-credential"));
    const { registry } = await deployFixture();
    expect(await registry.isRevoked(hash)).to.equal(false);
  });

  it("Iptal edilen belge gecersiz olmali", async function () {
    const { registry } = await deployFixture();
    const hash = ethers.keccak256(ethers.toUtf8Bytes("test-credential"));
    await registry.revoke(hash);
    expect(await registry.isRevoked(hash)).to.equal(true);
  });

  it("Ayni belge iki kez iptal edilememeli", async function () {
    const { registry } = await deployFixture();
    const hash = ethers.keccak256(ethers.toUtf8Bytes("test-credential"));
    await registry.revoke(hash);
    await expect(registry.revoke(hash)).to.be.revertedWith(
      "Zaten iptal edilmis",
    );
  });

  it("Sadece admin iptal edebilmeli", async function () {
    const { registry, other } = await deployFixture();
    const hash = ethers.keccak256(ethers.toUtf8Bytes("test-credential"));
    await expect(registry.connect(other).revoke(hash)).to.be.revertedWith(
      "Only admin",
    );
  });
});

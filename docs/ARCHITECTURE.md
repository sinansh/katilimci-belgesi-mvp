# Mimari Özet

## Katmanlar
- **Blockchain**: Hardhat local node (localhost:8545)
- **Akıllı Sözleşmeler**: DIDRegistry.sol + RevocationRegistry.sol
- **API**: Node.js + Express (localhost:3001)
- **Frontend**: React (localhost:3000)

## Veri Akışı
Kişisel veri zincire yazılmaz.
Zincir sadece: issuer adresi + DID + iptal hash listesi tutar.

## Endpointler
- POST /api/issue   → VC üret
- POST /api/verify  → M2M doğrula
- POST /api/revoke  → İptal et

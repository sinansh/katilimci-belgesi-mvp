// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title DIDRegistry
 * @notice Yetkili belge ihraççı kurumların adreslerini ve DID'lerini tutar.
 * @dev Kişisel veri içermez. Sadece kurumların açık anahtarı (adres) ve
 *      did:ethr: formatındaki merkeziyetsiz kimlik dizesi saklanır.
 *      Bu sözleşme blokzinciri "veritabanı" değil "güven çapası" olarak kullanır.
 */
contract DIDRegistry {
    address public admin;

    // Kurum adresi → yetkili mi?
    mapping(address => bool) public authorizedIssuers;

    // Kurum adresi → DID string (örn: "did:ethr:0x123...")
    mapping(address => string) public issuerDID;

    // ── Constructor ────────────────────────────────────────────────────────
    constructor() {
        admin = msg.sender;
        // Admin aynı zamanda varsayılan issuer'dır
        authorizedIssuers[msg.sender] = true;
        issuerDID[msg.sender] = string(
            abi.encodePacked("did:ethr:", _addressToString(msg.sender))
        );
    }

    // ── Modifier ───────────────────────────────────────────────────────────
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    // ── Yazma Fonksiyonları ────────────────────────────────────────────────

    /**
     * @notice Yeni bir yetkili kurum kaydeder.
     * @param issuer Kurumun Ethereum adresi
     * @param did    Kurumun DID string'i (örn: "did:ethr:0x...")
     */
    function registerIssuer(address issuer, string calldata did) external onlyAdmin {
        require(issuer != address(0), "Gecersiz adres");
        require(bytes(did).length > 0, "DID bos olamaz");
        authorizedIssuers[issuer] = true;
        issuerDID[issuer] = did;
    }

    // ── Okuma Fonksiyonları ────────────────────────────────────────────────

    /**
     * @notice Verilen adresin yetkili issuer olup olmadığını döner.
     */
    function isAuthorized(address issuer) external view returns (bool) {
        return authorizedIssuers[issuer];
    }

    /**
     * @notice Verilen adresin kayıtlı DID string'ini döner.
     */
    function getIssuerDID(address issuer) external view returns (string memory) {
        return issuerDID[issuer];
    }

    // ── Yardımcı ──────────────────────────────────────────────────────────

    /**
     * @dev Adres tipini hex string'e çevirir (did:ethr: prefix için).
     */
    function _addressToString(address addr) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory data = abi.encodePacked(addr);
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(data[i] >> 4)];
            str[3 + i * 2] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title RevocationRegistry
 * @notice İptal edilmiş credential'ların hash'lerini tutar.
 * @dev Kişisel veri içermez. Sadece iptal edilmiş belgelerin
 *      keccak256 hash değerleri saklanır.
 *      Bir hash bu listeye eklenince ilgili belge kalıcı olarak geçersiz sayılır.
 */
contract RevocationRegistry {
    address public admin;

    // credential hash → iptal edildi mi?
    mapping(bytes32 => bool) public isRevoked;

    // ── Constructor ────────────────────────────────────────────────────────
    constructor() {
        admin = msg.sender;
    }

    // ── Modifier ───────────────────────────────────────────────────────────
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    // ── Yazma Fonksiyonları ────────────────────────────────────────────────

    /**
     * @notice Bir credential'ı iptal listesine ekler.
     * @param credentialHash İptal edilecek belgenin keccak256 hash'i
     * @dev Hash zincire yazıldıktan sonra geri alınamaz.
     *      Yeni belge üretmek için yeni bir hash ile /api/issue çağrılır.
     */
    function revoke(bytes32 credentialHash) external onlyAdmin {
        require(!isRevoked[credentialHash], "Zaten iptal edilmis");
        isRevoked[credentialHash] = true;
    }

    // ── Okuma Fonksiyonları ────────────────────────────────────────────────

    /**
     * @notice Verilen hash'in iptal listesinde olup olmadığını döner.
     * @param credentialHash Sorgulanacak belgenin keccak256 hash'i
     * @return true → iptal edilmiş, false → geçerli
     */
    function checkRevocation(bytes32 credentialHash) external view returns (bool) {
        return isRevoked[credentialHash];
    }
}
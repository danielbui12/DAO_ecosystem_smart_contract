// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";


contract ScepterNFT is ERC1155Burnable {
    uint256 constant SCEPTER = 0;
    address _owner;

    constructor()
        ERC1155(
            "https://gateway.pinata.cloud/ipfs/QmS7w292w7znk6yTK9bBRwLNQuWvWGfjQij9iVBYQM8QoR/{id}.json"
        )
    {
        _owner = msg.sender;
    }

    mapping(address => bool) private _validTarget;

    /**
        @dev Setup marketplace for locking period 
     */
    function setValidTarget(address target, bool permission)
        external
        onlyOwner
    {
        _validTarget[target] = permission;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        _owner = newOwner;
    }

    /**
     * @dev Only mint for the valid target
     * @param amount - amount
     */
    function mintValidTarget(uint256 amount) external {
        require(_validTarget[msg.sender], "SCEPTERNFT: Not valid target");
        _mint(msg.sender, SCEPTER, amount, "");
    }

    modifier onlyOwner() {
        require(_owner == msg.sender);
        _;
    }
}

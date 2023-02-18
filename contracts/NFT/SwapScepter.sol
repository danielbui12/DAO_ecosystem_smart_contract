// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./ICrownNFT.sol";
import "./IScepterNFT.sol";

contract SwapScepter is ERC165, IERC721Receiver, IERC1155Receiver {
    uint256 public constant PRICE = 200000;
    uint256 public constant MAX_SUPPLY = 10;
    address private _CrownNFT;
    address private _ScepterNFT;
    uint256 public currentSupply;

    constructor(address CrownNFT_, address ScepterNFT_) {
        _CrownNFT = CrownNFT_;
        _ScepterNFT = ScepterNFT_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function swapCrown() external {
        IScepterNFT sceptor = IScepterNFT(_ScepterNFT);
        ICrownNFT crown = ICrownNFT(_CrownNFT);
        uint256 userBalance = sceptor.balanceOf(msg.sender, 0);
        require(userBalance >= PRICE, "SwapSceptor:Insufficent balance");
        currentSupply += 1;
        require(
            currentSupply <= MAX_SUPPLY,
            "SwapSceptor: Run out of CrownNFT"
        );
        uint256 nftId = crown.mintValidTarget(1);
        sceptor.safeTransferFrom(msg.sender, address(this), 0, PRICE, "");
        crown.safeTransferFrom(address(this), msg.sender, nftId);
    }

    function burnScepter() external {
        IScepterNFT sceptor = IScepterNFT(_ScepterNFT);
        sceptor.burn(address(this), 0, sceptor.balanceOf(address(this), 0));
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }
}

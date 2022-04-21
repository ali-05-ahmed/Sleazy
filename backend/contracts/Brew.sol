// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IERC20Mint.sol";


contract Brew is ERC20 ,IERC20Mint,Ownable, AccessControlEnumerable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address _minter) ERC20("BREW", "$BR") {
        _setupRole(MINTER_ROLE, _minter);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function mint(address account, uint256 amount) external override onlyRole(MINTER_ROLE) virtual {
         _mint(account, amount);
    }
}
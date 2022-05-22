// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract YourCollectible is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Ownable
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("YourCollectible", "YCB") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function mintItem(address to, string memory uri) public returns (uint256) {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // TODO надо бы добавить пагинацию
    function getAllTokens() external view returns(string memory) {
        uint totalSupply = this.totalSupply();
        if (totalSupply == 0) {
            return '{"tokens":[]}';
        }

        bytes memory b;

        for (uint i = 1; i <= totalSupply; i++) {
            string memory closeTag = i == totalSupply ? '"]' : '"],';
            b = abi.encodePacked(b, '[', uint2str(i), ',"', this.tokenURI(i), closeTag);
        }

        b = abi.encodePacked('{"tokens":[', b, ']}');

        return string(b);
    }

    function getTokensOf(address holder) external view returns(string memory) {
        uint holderBalance = balanceOf(holder);
        if (holderBalance == 0) {
            return '{"tokens":[]}';
        }

        uint counted;
        bytes memory b;

        for (uint i = 1; i <= this.totalSupply(); i++) {
            if (ownerOf(i) == holder) {
                counted++;
                string memory closeTag = counted == holderBalance ? '"]' : '"],';
                b = abi.encodePacked(b, '[', uint2str(i), ',"', this.tokenURI(i), closeTag);
                if (counted == holderBalance) {
                    break;
                }
            }
        }

        b = abi.encodePacked('{"tokens":[', b, ']}');

        return string(b);
    }

    // https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity
    function uint2str(uint256 _i) internal pure returns(string memory str) {
        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);
        uint256 k = length;

        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }

        str = string(bstr);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable {
    string _baseTokenURI;

    uint256 public _price = 0.01 ether;

    bool public _paused;

    uint256 public maxTokenIds = 20;

    uint256 public tokenIds;

    IWhitelist whitelist;

    bool public presaleStarted;

    uint256 public presaleEnded;

    modifier onlyWhenNotPaused() {
        require(!_paused, "contract is paused");
        _;
    }

    constructor(
        string memory baseURI,
        address whitelistContract
    ) ERC721("Crypto Devs", "CD") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && presaleEnded > block.timestamp,
            "presale not running"
        );
        require(
            whitelist.whitelistedAddresses(msg.sender),
            "not a white list address"
        );
        require(tokenIds < maxTokenIds, "max tokens are minted");
        require(msg.value >= _price, "not enough money");
        tokenIds = tokenIds + 1;
        _safeMint(msg.sender, tokenIds);
    }

    function mint() public payable onlyWhenNotPaused {
        require(
            presaleStarted && presaleEnded >= block.timestamp,
            "preasale not ended yet"
        );
        require(tokenIds < maxTokenIds, "max tokens are minted");
        require(msg.value >= _price, "not enough money");

        tokenIds = tokenIds + 1;
        _safeMint(msg.sender, tokenIds);
    }

    function _baseURI()
        internal
        view
        virtual
        override
        returns (string memory)
    {return _baseTokenURI;}

    function setPaused(bool val) public onlyOwner {
        _paused=val;
    }

    function withdraw() public onlyOwner {
        address _owner=owner();
        uint256 amount=address(this).balance;
        (bool sent,)=_owner.call{value:amount}("");
        require(sent,"amount noe sent");
    }

    receive() external payable {}

    //  if msg.data is not empty
    fallback() external payable {}
}

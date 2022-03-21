// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title SocialFiERC721 Contract
contract SocialFiERC721 is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, EIP712, ERC721Votes {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor(string memory name_, string memory symbol_, uint256 maxSupply_, uint256 price_, uint256 priceWhitelist_, address splitter_) ERC721(name_, symbol_) {
        maxSupply = maxSupply_;
        price = price_;
        priceWhitelist = priceWhitelist_;
        splitter = splitter_;

        //start in paused state
        _pause();
    }




contract FlatEnumerableERC721 is Ownable, Pausable, ERC721Enumerable {

    uint256 public maxSupply;
    uint256 public price;
    uint256 public priceWhitlist; //price for whitelisted accounts
    uint256 public mintCount;
    string public baseURI;
    address public splitter; //splitter contract where mint and royalty revenue will be sent
    mapping(uint256 => string) public labels; //token id => label
    mapping(uint256 => string) public messages; //token id => message 
    mapping(uint256 => string) public punkNames; //token id => punkName
    mapping(uint256 => string) public storys; //token id => story

    /// @dev reverts if any tokens have been minted
    modifier onlyPreMint() {
        require(mintCount == 0, "must be before first mint");
        _;
    }

    ///@dev reverts if not token owner
    modifier onlyTokenOwner(uint256 tokenId) {
        require(msg.sender == ownerOf(tokenId), "only token owner can call");
        _;
    }






    /// @dev toggles paused state on/off
    function togglePaused() public onlyOwner {
        paused() ? _unpause() : _pause();
    }

    /// @dev sets a new basePrice value
    /// @param newPrice value of new basePrice
    function setPrice(uint256 newPrice) public onlyOwner onlyPreMint {
        price = newPrice;
    }
    
        /// @dev sets a new whitelabelPrice value
    /// @param newPrice value of new basePrice
    function setPrice(uint256 newPriceWhitelist) public onlyOwner onlyPreMint {
        priceWhitelist = newPriceWhitelist;
    }

    /// @dev overridden ERC721Metadata function to return baseURI
    /// @return baseURI string
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /// @dev sets a new baseURI for contract
    /// @param newBaseURI new baseURI to set
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    /// @dev mints the next tokenId if mint value is paid
    function mint(address to) public payable whenNotPaused { // TODO - Add when not whitelistOnly logic
        //validate
        require(to != address(0x0), "cannot mint to zero address");
        require(mintCount < maxSupply, "max supply reached");
        require(msg.value == price, "must send exact value to mint");
        // TODO - require(,);  ADDRESS MUST BE ON THE WHITELIST

        //update state
        mintCount += 1;

        //send native to owner address
        (bool sent, bytes memory data) = owner().call{value: msg.value}("");
        require(sent, "failed to send to owner address");

        //safely mint to recipient address
        _safeMint(to, mintCount);
    }
    
        /// @dev mints the next tokenId if whitelist mint value is paid and if address is on the whitelist 
    function mintWhitelist(address to) public payable whenNotPaused {
        //validate
        require(to != address(0x0), "cannot mint to zero address");
        require(msg.value == price, "must send exact value to mint");

        //update state
        mintCount += 1;

        //send native to owner address
        (bool sent, bytes memory data) = owner().call{value: msg.value}("");
        require(sent, "failed to send to owner address");

        //safely mint to recipient address
        _safeMint(to, mintCount);
    }
    
        /// @dev sets a new label for token id
    function setLabel(uint256 tokenId, string memory newLabel) public onlyTokenOwner(tokenId) {
        labels[tokenId] = newLabel;
    }

    /// @dev sets a new message for token id
    function setMessage(uint256 tokenId, string memory newMessage) public onlyTokenOwner(tokenId) {
        messages[tokenId] = newMessage;
    }
    
        /// @dev sets a new punkName for token id - First naming is free. Count name updates. Each new name = number of times renamed times nameCost
    function setPunkName(uint256 tokenId, string memory newLabel) public onlyTokenOwner(tokenId) {
        // TODO - check for payment to be included nameCount[tokenId] * nameCost
        punkNames[tokenId] = newPunkName; 
        // TODO - update nameCount[tokenID];
    }

    /// @dev updates the story for token id - User can only add to current story not erase or start over. Add a blank space between previous story and newStory.
    function setStory(uint256 tokenId, string memory newMessage) public onlyTokenOwner(tokenId) {
        storys[tokenId] = newStory; // TODO - Revise so that Story gets appended: (current story + " " + newStory
    }
    
// TODO - Review these functions from an alternative approach from OZ Wizart - should any of these be added or replace the above?   
//    function safeMint(address to, string memory uri) public onlyOwner {
//        uint256 tokenId = _tokenIdCounter.current();
//        _tokenIdCounter.increment();
//        _safeMint(to, tokenId);
//        _setTokenURI(tokenId, uri);
//    }
//
//    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
//        internal
//        whenNotPaused
//        override(ERC721, ERC721Enumerable)
//    {
//        super._beforeTokenTransfer(from, to, tokenId);
//    }
//
//
//    // The following functions are overrides required by Solidity.
//
//    function _afterTokenTransfer(address from, address to, uint256 tokenId)
//        internal
//        override(ERC721, ERC721Votes)
//    {
//        super._afterTokenTransfer(from, to, tokenId);
//    }
//
//    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
//        super._burn(tokenId);
//    }
//
//    function tokenURI(uint256 tokenId)
//        public
//        view
//        override(ERC721, ERC721URIStorage)
//        returns (string memory)
//    {
//        return super.tokenURI(tokenId);
//    }
//
//    function supportsInterface(bytes4 interfaceId)
//        public
//        view
//        override(ERC721, ERC721Enumerable)
//        returns (bool)
//    {
//        return super.supportsInterface(interfaceId);
//    }
//}
//
//

    // TODO - Need to add whitelist functions.
        // addWhitelistAddress (onlyOwner, require valid address, etc.)
        // removeWhitelistAddress (onlyOwner,)
        // clearWhitelist onlyOwner - removes all addresses from whitelist
        // isWhitelist - checks that a provided address is listed on the whitelist ... use this to check whitelist accounts
    
    // TODO - Add way to reward another TelosPunk. Can only do it from an owned TelosPunk NFT.  I'm still figuring this one out.

}

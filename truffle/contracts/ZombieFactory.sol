// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./KittyInterface.sol";

contract ZombieFactory is Ownable, ERC721 {
    event NewZombie(uint256 zombieId, string name, uint256 dna);
    using Counters for Counters.Counter;
    Counters.Counter internal _zombieIds;

    uint256 dnaDigits = 16;
    uint256 dnaModulus = 10**dnaDigits;
    uint256 cooldownTime = 1 days;

    struct Zombie {
        string name;
        uint256 dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // Zombie[] public zombies;
    mapping(uint256 => Zombie) public zombieIdToZombie;
    mapping(uint256 => address) public zombieIdToOwner;
    mapping(address => uint256) ownerZombieCount;
    mapping(uint256 => address) zombieApprovals;

    modifier onlyOwnerOf(uint256 _zombieId) {
        require(
            msg.sender == zombieIdToOwner[_zombieId],
            "Should be owner of the zombie"
        );
        _;
    }

    constructor() ERC721("CryptoZombies", "CRZMB") {}

    function _createZombie(string memory _name, uint256 _dna) internal {
        _zombieIds.increment();
        uint256 id = _zombieIds.current();
        zombieIdToZombie[id] = Zombie(
            _name,
            _dna,
            1,
            uint32(block.timestamp + cooldownTime),
            0,
            0
        );

        zombieIdToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender] + 1;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str)
        private
        view
        returns (uint256)
    {
        uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        require(
            ownerZombieCount[msg.sender] == 0,
            "Only one zombie can be created for an Account."
        );
        uint256 randDna = _generateRandomDna(_name);
        randDna = randDna - (randDna % 100);
        _createZombie(_name, randDna);
    }

    // implement function for ERC721
    function balanceOf(address _owner) public view override returns (uint256) {
        return ownerZombieCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view override returns (address) {
        return zombieIdToOwner[_tokenId];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal override {
        ownerZombieCount[_to] += 1;
        ownerZombieCount[msg.sender] -= 1;
        zombieIdToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {
        require(
            zombieIdToOwner[_tokenId] == msg.sender ||
                zombieApprovals[_tokenId] == msg.sender,
            "Should be owner or owner approved."
        );
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId)
        public
        override
        onlyOwnerOf(_tokenId)
    {
        zombieApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    // ZombieFeeding
    KittyInterface kittyContract;

    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= block.timestamp);
    }

    function feedAndMultiply(
        uint256 _zombieId,
        uint256 _targetDna,
        string memory _species
    ) internal onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombieIdToZombie[_zombieId];
        require(_isReady(myZombie), "Zombie is not ready yet.");
        uint256 targetDna = _targetDna % dnaModulus;
        uint256 newDna = (myZombie.dna + targetDna) / 2;
        if (
            keccak256(abi.encodePacked(_species)) ==
            keccak256(abi.encodePacked("kitty"))
        ) {
            newDna = newDna - (newDna % 100) + 99;
        }
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
        uint256 kittyDna;
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}

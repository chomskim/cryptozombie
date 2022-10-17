// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ZombieFactory.sol";

contract ZombieHelper is ZombieFactory {
    using Counters for Counters.Counter;
    uint256 levelUpFee = 0.001 ether;

    modifier aboveLevel(uint256 _level, uint256 _zombieId) {
        require(zombieIdToZombie[_zombieId].level >= _level);
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setLevelUpFee(uint256 _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    function levelUp(uint256 _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombieIdToZombie[_zombieId].level += 1;
    }

    function changeName(uint256 _zombieId, string calldata _newName)
        external
        aboveLevel(2, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        zombieIdToZombie[_zombieId].name = _newName;
    }

    function changeDna(uint256 _zombieId, uint256 _newDna)
        external
        aboveLevel(20, _zombieId)
        onlyOwnerOf(_zombieId)
    {
        zombieIdToZombie[_zombieId].dna = _newDna;
    }

    function getZombiesByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](ownerZombieCount[_owner]);
        uint256 zombieCount = _zombieIds.current();
        uint256 counter = 0;
        for (uint256 i = 0; i < zombieCount; i++) {
            if (zombieIdToOwner[i + 1] == address(this)) {
                result[counter] = i + 1;
                counter++;
            }
        }

        return result;
    }
}

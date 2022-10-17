// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ZombieHelper.sol";

contract CryptoZombies is ZombieHelper {
    uint256 randNonce = 0;
    uint256 attackVictoryProbability = 70;

    function randMod(uint256 _modulus) internal returns (uint256) {
        randNonce += 1;
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    function attack(uint256 _zombieId, uint256 _targetId)
        external
        onlyOwnerOf(_zombieId)
    {
        Zombie storage myZombie = zombieIdToZombie[_zombieId];
        Zombie storage enemyZombie = zombieIdToZombie[_targetId];
        uint256 rand = randMod(100);
        if (rand <= attackVictoryProbability) {
            myZombie.winCount += 1;
            myZombie.level += 1;
            enemyZombie.lossCount += 1;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount += 1;
            enemyZombie.winCount += 1;
            _triggerCooldown(myZombie);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib\openzeppelin-contracts\contracts\proxy"; //@openzeppelin-contracts/contracts/proxy/Proxy.sol

contract SmallProxy is Proxy {
    //this is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 private constant _IMPLEMENTATION_SOLT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function setImplementation(address newImplementation) public {
        assembly {
            sstore(_IMPLEMENTATION_SOLT, newImplementation)
        }
    }

    function _implementation()
        view
        override
        imternal
        returns (address implementationAddress)
    {
        assembly {
            implementationAddress := sload(_IMPLEMENTATION_SOLT)
        }
    }

    function getDataToTransact(
        uint256 numberToUpdate
    ) public pure returns (bytes memory) {
        return abi.encodeWithSignature("setValue(uint256)", numberToUpdate);
    }

    function readStorage()
        public
        view
        returns (uint256 valueAtStorageSlotZero)
    {
        assembly {
            valueAtStorageSlotZero := sload(0)
        }
    }
}

// smallProxy --(delegateCall)-> ImplementationA
contract ImplementationA {
    uint256 public value;

    function setValue(uint256 newValue) public {
        value = newValue;
    }
}

// Upgraded Contract
contract ImplementationB {
    uint256 public value;

    function setValue(uint256 newValue) public {
        value = newValue + 2;
    }
}

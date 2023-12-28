//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {MyContract} from "../src/MyContract.sol";
import {Test} from "forge-std/Test.sol";
//import {StdInvarient} from "forge-std/StdInvariant.sol";

contract MyContractTest{
    MyContract exampleContract;
    function testAlwaysGetZero()public{
        uint256 data =0;
        exampleContract.doStuff(data);
        assert(exampleContract.shouldAlwaysBeZero()==0);
    }
    //StateLess Fuzzing test
    function testAlwaysGetZeroFuzz(uint256 data)public{
        //uint256 data =0;
        exampleContract.doStuff(data);
        assert(exampleContract.shouldAlwaysBeZero()==0);
    }
//StateFull Fuzzing
    function testAlwaysGetZeroStateFull()public{
    uint256 data =7;
    exampleContract.doStuff(data);
    assert(exampleContract.shouldAlwaysBeZero()==0);

    data =0;
    exampleContract.doStuff(data);
    assert(exampleContract.shouldAlwaysBeZero()==0);


}
}
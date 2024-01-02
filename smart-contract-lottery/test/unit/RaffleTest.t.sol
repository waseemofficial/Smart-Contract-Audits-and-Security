// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

//import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig helperConfig;

    //helperConfig state variables
    uint256 enteranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player"); //@dev: Standerd cheats from Forge
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();
        (
            enteranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        ) = helperConfig.activeNetworkConfig();
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN); //RaffleState.Open
    }
}
// import "forge-std/Test.sol";
// import {Raffle} from "../src/Raffle.sol";
// import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

// contract RaffleTest is Test {
//     Raffle raffle;
//     VRFCoordinatorV2Mock vrfCoordinator;

//     function setUp() public {
//         raffle = new Raffle(
//             0.1 ether,
//             30 seconds,
//             vrfCoordinator,
//             0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef,
//             0,
//             500000
//         );

//         vrfCoordinator = new VRFCoordinatorV2Mock();
//     }

//     function testFulfillRandomWords() public {
//         uint256[] memory randomWords = new uint256[](1);
//         randomWords[0] = 123456789;

//         Raffle.fulfillRandomWords(0, randomWords);

//         assertEq(Raffle.RaffleState.OPEN, Raffle.s_raffleState());
//         assertEq(0, Raffle.s_players.length);
//         assertGt(Raffle.s_lastTimeStamp(), block.timestamp);
//     }
// }

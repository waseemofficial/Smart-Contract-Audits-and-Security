// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract RaffleTest is Test {
    /*Events */
    event EnteredRaffle(address indexed player); // @dev: Event emitted when a player enter the raffle

    /*inetilisation globale variables */
    Raffle raffle;
    HelperConfig helperConfig;

    //helperConfig state variables
    uint256 enteranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;
    uint256 deployerKey;
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
            callbackGasLimit,
            link,

        ) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_USER_BALANCE); //@dev: Give player some ether to play with
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN); //RaffleState.Open
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        //Arrange
        vm.prank(PLAYER);

        //Act  //Assert
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayersWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enteranceFee}();
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEmitsEventOnEnterance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: enteranceFee}();
    }

    function testCantEnterWhenRaffleIsCalculating() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1); //@dev: Advance time to enterance
        vm.roll(block.number + 1); //@dev: Advance block by one
        raffle.performUpkeep("");
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enteranceFee}();
    }

    /////////////////////////
    /// checkUpkeep      ///
    ///////////////////////
    function testCheckUpKeepReturnsFalseIfNoBalance() public {
        //Arrange
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        //Act
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        //Assert
        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRaffleNotOpen() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");
        //Act
        (bool upKeepNeeded, ) = raffle.checkUpkeep("");
        //Assert
        assert(upKeepNeeded == false);
    }

    ///////////////////////////
    /// performUpkeep test ///
    /////////////////////////
    function testPerformUpkeepCanOnlyRunIfCheckIsTrue() public {
        //Arrange
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        //Act
        //Assert
        raffle.performUpkeep("");
    }

    function testperformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        //Arrange
        uint256 currentBalance = 0;
        uint256 numOfPlayers = 0;
        uint256 raffleState = 0;

        //custom Error Check with Message
        //Act //Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector,
                currentBalance,
                numOfPlayers,
                raffleState
            )
        );
        raffle.performUpkeep("");
    }

    ///////////////////////////
    ///test Events/emits   ///
    /////////////////////////
    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: enteranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        _;
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId()
        public
        raffleEnteredAndTimePassed
    {
        //@note "recordLogs tells the VM to Start recording all emitted events to access them use "//!getRecordedLogs()
        //Act
        vm.recordLogs();
        raffle.performUpkeep(""); //emit RequestId
        //special case for the event Vm.log Array data Type
        Vm.Log[] memory entries = vm.getRecordedLogs();
        //@note all logs are Recorded in //!bytes32 in foundry

        bytes32 requestId = entries[1].topics[1];
        Raffle.RaffleState rState = raffle.getRaffleState();

        //Assert
        assert(uint256(requestId) > 0);
        assert(uint256(rState) == 1);
    }

    //!/////////////////////////
    //!/ fullfillRandomWords///
    //!///////////////////////
    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    //!------------------------------
    function testFulfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 randomRequestId
    ) public raffleEnteredAndTimePassed skipFork {
        //Arrange
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            randomRequestId,
            address(raffle)
        );
        //Act
        //Assert
    }

    function testFulfillRandomWordsPicsAWinnerResetsAndSendsMoneyToWinner()
        public
        raffleEnteredAndTimePassed
        skipFork
    {
        //Arrange
        uint256 additionalEnterats = 5;
        uint256 startingIndex = 1;
        for (
            uint256 i = startingIndex;
            i < startingIndex + additionalEnterats;
            i++
        ) {
            address player = address(uint160(i)); //Address(1) //!makeAddr()
            hoax(player, STARTING_USER_BALANCE); //! this is equal to prank(player)+deal(player,1 ether)
            raffle.enterRaffle{value: enteranceFee}();
        }
        uint256 prize = enteranceFee * (additionalEnterats + 1);
        vm.recordLogs();
        raffle.performUpkeep(""); //emit RequestId
        //special case for the event Vm.log Array data Type
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        uint256 previousTimeStamp = raffle.getLastTimeStamp();
        //Act
        //pretend to be VRF Coordinator to get random number and set winner

        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );

        //Assert
        assert(uint256(raffle.getRaffleState()) == 0);
        assert(raffle.getRecentWinner() != address(0));
        assert(raffle.getLengthOfPlayers() == 0);
        assert(previousTimeStamp < raffle.getLastTimeStamp());
        // console.log(raffle.getRecentWinner().balance);
        // console.log(prize + STARTING_USER_BALANCE - enteranceFee);
        assert(
            prize + STARTING_USER_BALANCE - enteranceFee ==
                raffle.getRecentWinner().balance
        );
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

## Foundry

testRaffleInitializesInOpenState
This test checks that the Raffle contract is initialized in the open state when deployed.

### Summary

The Raffle contract has two possible states - open and calculating. This test ensures that when the contract is first deployed, it starts in the open state.

### Details

The test does the following:

- Deploys a new Raffle contract
- Checks that the contract's raffleState is 0, which corresponds to the OPEN state
- Checks that the contract's players mapping is empty, since no tickets have been bought yet

### Significance

This test provides confidence that the Raffle contract is initialized properly on deployment. Starting in the open state allows players to start buying tickets for the raffle. The contract transitioning to the correct initial state is critical for its proper functioning.

### Related Tests
testRaffleTransitionsFromOpenToCalculating
testRaffleTransitionsFromCalculatingToOpen
These tests check the state transition logic when the raffle moves from open to calculating, and back to open again after a winner is picked.

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
 forge --help
 anvil --help
 cast --help
```
codes for debugging and coverage
```shell
forge --test --mt <"test_name" or "test_path"> -vvvvv
forge coverage
forge coverage  --report debug > coverage.txt 
forge test --debug <"test_name" or "test_path">

```
### IMPORTENT WEBSITES
- openchain.xyz
- 
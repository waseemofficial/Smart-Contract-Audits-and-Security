-include .env
#PHONY is used so not to confuse with folders
.PHONY:

# to build
build:; forge build

#to compile
compile:; forge compile

# to deploy on sepolia network using meta-mask 
deploy-sepolia: 
	forge script script/deployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-key $(ETHERSCAN_API_KEY) -vvvv

#to run test's
test:; forge test

# to get .gas-snapshot
snapshot:; forge snapshot

# to format the code manually
format:; forge fmt

# to get coverage report
coverage:; forge coverage

# to record gif using tape
vhs-record:; vhs < test_coverage.tape && vhs < gas_report.tape

ifeq ($(findstring --network sepolia,$(ARGS)), --network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/deployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

fund:
	@forge script script/Interacrions.s.sol:FundFundMe $(NETWORK_ARGS)

withdraw:
	@forge script script/Interacrions.s.sol:WithdrawFundMe $(NETWORK_ARGS)
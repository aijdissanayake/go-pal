# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: geth android ios geth-cross swarm evm all test clean
.PHONY: geth-linux geth-linux-386 geth-linux-amd64 geth-linux-mips64 geth-linux-mips64le
.PHONY: geth-linux-arm geth-linux-arm-5 geth-linux-arm-6 geth-linux-arm-7 geth-linux-arm64
.PHONY: geth-darwin geth-darwin-386 geth-darwin-amd64
.PHONY: geth-windows geth-windows-386 geth-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

geth:
	build/env.sh go run build/ci.go install ./cmd/geth
	@echo "Done building."
	@echo "Run \"$(GOBIN)/geth\" to launch geth."

swarm:
	build/env.sh go run build/ci.go install ./cmd/swarm
	@echo "Done building."
	@echo "Run \"$(GOBIN)/swarm\" to launch swarm."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/geth.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Geth.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

geth-cross: geth-linux geth-darwin geth-windows geth-android geth-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/geth-*

geth-linux: geth-linux-386 geth-linux-amd64 geth-linux-arm geth-linux-mips64 geth-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-*

geth-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/geth
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep 386

geth-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/geth
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep amd64

geth-linux-arm: geth-linux-arm-5 geth-linux-arm-6 geth-linux-arm-7 geth-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep arm

geth-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/geth
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep arm-5

geth-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/geth
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep arm-6

geth-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/geth
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep arm-7

geth-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/geth
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep arm64

geth-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/geth
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep mips

geth-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/geth
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep mipsle

geth-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/geth
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep mips64

geth-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/geth
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/geth-linux-* | grep mips64le

geth-darwin: geth-darwin-386 geth-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/geth-darwin-*

geth-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/geth
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/geth-darwin-* | grep 386

geth-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/geth
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/geth-darwin-* | grep amd64

geth-windows: geth-windows-386 geth-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/geth-windows-*

geth-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/geth
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/geth-windows-* | grep 386

geth-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/geth
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/geth-windows-* | grep amd64

# PAL Custom Commands
.PHONY: node bootnode accounts pal
-include .env

DATADIR=datadir

# Colors
NC=\033[0m
GREEN=\033[0;32m
CYAN=\033[0;36m

# bootnode command generates bootnode.txt if bootnode.txt is not found
# and runs bootnode, else run bootnode.
#
# e.g.
#	`make bootnode`
bn_port=30301
bootnode:
	@mkdir -p datadir
ifeq (,$(wildcard ./datadir/bootnode.txt))
	@echo "Generating bootnode..."
	@go run cmd/bootnode/main.go -genkey datadir/bootnode.txt
	@echo "Running bootnode..."
	@go run cmd/bootnode/main.go -nodekey datadir/bootnode.txt -verbosity 9 -addr :$(bn_port)
else
	@echo "Running bootnode..."
	@go run cmd/bootnode/main.go -nodekey datadir/bootnode.txt -verbosity 9 -addr :$(bn_port)
endif

# accounts command generates `n` number of accounts specified (default n=3) and
# add addresses of accounts created to .env file.
#
# e.g.
#	`make accounts n=11`
n = 3
accounts:
	@$(eval NUMBERS := $(shell seq 1 $(n)))
	@$(foreach index,$(NUMBERS), \
		mkdir -p $(DATADIR)/pal-node-$(index); \
		echo PAL_NODE_$(index) := $(DATADIR)/pal-node-$(index) >> .env; \
		OUTPUT="$(shell build/bin/geth account new --datadir datadir/pal-node-$(index) --password $(PAL_PWD_DIR))"; \
		echo PAL_N$(index)_ETHERBASE := \"0x$${OUTPUT:10:40}\" >> .env; \
	)

docker:
	@docker build -t pal/testnet .

# node command runs node.
#	args:
#		index -
#			node number to run (default: 1)
#		rpcport -
#			rpc port number (default: 8545)
#		port -
#			port number (default: 30303)
# 	e.g.
#		`make node` -> make default node 1 with default rpcport 8545 and port 30303
#		`make node index=2 rpcport=8565 port=30304` -> make node 2 with rpcport 8565 and port 30304
index=1
rpcport=8545
port=30303
node:
	@mkdir -p $(PAL_NODE_$(index))
	@build/bin/geth --datadir $(PAL_NODE_$(index)) init datadir/pal.json
	@build/bin/geth \
	--extradata 'pal-1.0.0' \
	--datadir $(PAL_NODE_$(index)) \
	--networkid $(PAL_NETWORK_ID) \
	--bootnodes $(PAL_BOOTNODE_ADDR) \
	--unlock $(PAL_N$(index)_ETHERBASE) \
	--etherbase $(PAL_N$(index)_ETHERBASE) \
	--password $(PAL_PWD_DIR) \
	--port $(port) \
	--minerthreads 1 \
	--rpcaddr 127.0.0.1 \
	--rpcapi "admin,db,eth,debug,miner,net,shh,txpool,personal,web3,clique,gateway" \
	--rpccorsdomain "*" \
	--rpcport $(rpcport) \
	--mine \
	--rpc

genesis:
	@echo 'paltestnet\n2\n3\nEOF' | puppeth || true
	@touch inputs.txt ; \
	NETWORK_NAME="paltestnet" ; \
	NEW_GENESIS=2 ; \
	ENGINE=2 ; \
	BLOCK_TIME=5 ; \
	LINE=$$(grep -an PAL_N1_ETHERBASE .env) ; \
	ADDR=$$(echo $$LINE | awk 'BEGIN { FS="0x" } ; {print $$2}') ; \
	ADDR_1=$$(echo $${ADDR%?}) ; \
	LINE=$$(grep -an PAL_N2_ETHERBASE .env) ; \
	ADDR=$$(echo $$LINE | awk 'BEGIN { FS="0x" } ; {print $$2}') ; \
	ADDR_2=$$(echo $${ADDR%?}) ; \
	LINE=$$(grep -an PAL_N3_ETHERBASE .env) ; \
	ADDR=$$(echo $$LINE | awk 'BEGIN { FS="0x" } ; {print $$2}') ; \
	ADDR_3=$$(echo $${ADDR%?}) ; \
	NETWORK_ID=2020 ; \
	MANAGE_GENESIS=2 ; \
	EXPORT_GENESIS=2 ; \
	GENESIS_FILE=datadir/pal.json ; \
	echo $$NETWORK_NAME >> inputs.txt ; \
	echo $$NEW_GENESIS >> inputs.txt ; \
	echo $$ENGINE >> inputs.txt ; \
	echo $$BLOCK_TIME >> inputs.txt ; \
	echo $$ADDR_1 >> inputs.txt ; \
	echo $$ADDR_2 >> inputs.txt ; \
	echo $$ADDR_3'\n' >> inputs.txt ; \
	echo $$ADDR_1 >> inputs.txt ; \
	echo $$ADDR_2 >> inputs.txt ; \
	echo $$ADDR_3'\n' >> inputs.txt ; \
	echo $$NETWORK_ID >> inputs.txt ; \
	echo $$MANAGE_GENESIS >> inputs.txt ; \
	echo $$EXPORT_GENESIS >> inputs.txt ; \
	echo $$GENESIS_FILE >> inputs.txt ; \
	cat inputs.txt | puppeth || true ; \
	rm inputs.txt ; \
	echo PAL_NETWORK_ID := 2020 >> .env

# pal commands builds the network with default settings.
pal:
	@rm -rf datadir
	@cp .env-sample .env

	@echo "\n${CYAN}[1] Building geth${NC}"
	@$(MAKE) geth

	@echo "\n${CYAN}[2] Setting up bootnode${NC}"
	@echo PAL_BOOTNODE_IP := 127.0.0.1 >> .env
	@echo Checking for running bootnode...
	@if [ "`lsof -t -i:30301`" ]; then \
		echo - Kill running bootnode...; \
		kill $$(lsof -t -i:30301); \
	else \
		echo - No process running on port 30301...; \
	fi
	@echo Running bootnode...
	@$(MAKE) bootnode &> output.txt 2>&1 &
	@sleep 10
	@echo Extracting bootnode address...
	@OUTPUT="$$(grep -an enode: output.txt)" ; \
	OUTPUT=$$(echo $$OUTPUT | awk 'BEGIN { FS="self=" } ; { print $$2 }') ; \
	PREFIX=$$(echo $$OUTPUT | awk 'BEGIN { FS="@" } ; { print $$1 }') ; \
	SUFFIX=$$(echo $$OUTPUT | awk 'BEGIN { FS="\]" } ; { print $$2 }') ; \
	echo PAL_BOOTNODE_ADDR := \"$$PREFIX'@$${PAL_BOOTNODE_IP}'$$SUFFIX\" >> .env
	@kill $$(lsof -t -i:30301) || true
	@rm output.txt

	@echo "\n${CYAN}[3] Creating password file${NC}"
	@echo password > datadir/password.txt

	@echo "\n${CYAN}[4] Creating accounts${NC}"
	@$(MAKE) accounts

	@echo "\n${CYAN}[5] Run puppeth${NC}"
	@$(MAKE) genesis

clean-pal:
	rm -rf datadir/pal-*/geth

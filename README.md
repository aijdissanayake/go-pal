# Go-PPN

Official implementation of PolicyPal Network's Protocol in Go.

## Get all Dependency packages

To get all dependency packages, run

```bash
go get ./...
```

## Default Setup

To setup a test network with default configuration with 3 nodes, run

```bash
make setup-pal
```

This default setup is configured as followed:

- bootnode
    - ip: `127.0.0.1`
    - port: `:30301`
- node 1
    - rpcport `:8545`
    - port `:30303`
- node 2
    - rpcport `:8546`
    - port `:30304`
- node 3
    - rpcport `:8547`
    - port `:30305`

To run your test network, run

```bash
make bootnode
make node
make node index=2 rpcport=8546 port=30304
make node index=3 rpcport=8547 port=30305
```

## Custom Setup

Follow the steps below to setup a custom setup for your network.

1. To build pal, run

    ```bash
    make pal
    ```

2. To generate and run a bootnode,

    ```bash
    make bootnode
    ```

    If bootnode is not already generated, `bootnode.txt` will be created in the directory, `datadir`. Else, this command will just run the previously generated bootnode.

    By default, bootnode will run at port `30301`. To run bootnode with a port of your choice, run the following,

    ```bash
    make bootnode bn_port=<CHOICE_OF_PORT>
    ```

3. Get enode address from the output of `make bootnode` and run the following with the `IP` and `PORT` of your choice,

    ```bash
    echo PAL_BOOTNODE_IP := <BOOTNODE_IP> >> .env
    echo PAL_BOOTNODE_ADDR := \"<ENODE_ADDRESS>@\${PAL_BOOTNODE_IP}:<PORT>\" >> .env
    ```

    Example:
    ```bash
    echo PAL_BOOTNODE_IP := 127.0.0.1 >> .env
    echo PAL_BOOTNODE_ADDR := \"enode://123...@\${PAL_BOOTNODE_IP}:53535\" >> .env
    ```

    The command above will append the bootnode ip and address to the `.env` file. For a local test network, set `PAL_BOOTNODE_IP` to `127.0.0.1`.

4. **For setting up a local test network**, create a `password.txt` in `datadir` which will contain the password for the accounts. This password will be set during accounts creation and will be used to unlock accounts.

    To do so, run

    ```bash
    echo password > datadir/password.txt
    ```

5. To create accounts, run

    ```bash
    make accounts
    ```

    By default, 3 accounts will be created with the password of each account set to the password in the `password.txt` file.

    To create the number of accounts desired, run

    ```bash
    make accounts n=<number of accounts to create>
    ```

    At account creation, directory of accounts' nodes and addresses will also be extracted and then added to `.env`.

6. To create our genesis JSON file, run `puppeth`.

    In `puppeth`,

    - Set your network name
    - Select `2` to `Configure new genesis`
    - Select `2` to select `Clique - proof-of-authority` as the consensus engine
    - Set the block time to `5` seconds
    - Select accounts created in **step 5** to be signers (Allowed to seal blocks)
    - Select accounts created in **step 5** to be pre-funded
    - Select your chain/network ID (or leave it as default for a random chain/network ID)
    - Select `2` to `Manage existing genesis`
    - Select `2` to `Export genesis configuration`
    - Set the file to save genesis as `datadir/pal.json`
    - Exit `puppeth`

    Add network ID to `.env`,

    ```bash
    echo PAL_NETWORK_ID := <NETWORK_ID> >> .env
    ```

## Run The Network

To run the network,

```bash
make bootnode
make node
make node index=2 rpcport=8546 port=30304
make node index=3 rpcport=8547 port=30305
```

Feel free to set your own preferred `rpcport` for each node, as long as no two same nodes are using the same `rpcport`.

## List of Make commands

| Command         | Description                      |
|:---------------:|----------------------------------|
| **`make setup-pal`** | Setup a network with default configuration|
| **`make pal`** | To build local pal|
| **`make setup-pal`** | To setup local testnet|
| **`./build/bin/pal`** | To run your local pal|
| **`make bootnode`** | To create a bootnode|
| **`make node`** | To create a node with ppn-node-*|
| **`make clean-ppn`** | Clean all datadir|
| **`make accounts`** | Creates all datadir accounts|

## How to Run Tests

| Command         | Description                      |
|:---------------:|----------------------------------|
| **`go test ./eth`** | Go into your eth folder and run all test files|
| **`go test -v -cpu 4 ./eth`** | Running all the test cases in eth folder. Using options -cpu (number of cores allowed) and -v (logging even if no error) is recommended.|

## How to Run Pal Console

| Command         | Description                      |
|:---------------:|----------------------------------|
| **`go attach <path-to-ppn-folder>/go-ppn/datadir/ppn-node/pal.ipc`** | Connect to run PAL console (JS console)|

## Reference

| Links         | Description                            |
|:--------------------:|----------------------------------|
| **<https://web3js.readthedocs.io/en/1.0/web3-eth.html>** |  Call blockchain using web3 |

## License

```text
Copyright (C) 2018  PolicyPal Network

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

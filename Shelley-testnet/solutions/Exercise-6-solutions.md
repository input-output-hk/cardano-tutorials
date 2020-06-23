# Example Solution for Shelley Stakepool Exercise Sheet 6

## Stake Pool Parameters and Protocol Parameters

### Prerequisites

1. 	Complete [Exercise Sheet 5](pioneers-exercise-5.md).
2. 	Read the
    [Cardano Tutorial Documentation](https://github.com/input-output-hk/cardano-tutorials)
    and [General Documentation on Stake Pool Parameters,
    Pool De-Registration and Protocol Parameters](https://testnets.cardano.org).
3. 	Checkout and build the sources which have been tagged with `1.13.0`.

        cabal update
        cd cardano-node
        git fetch --all --tags -f
        git checkout tags/1.13.0
        cabal install cardano-node cardano-cli
        cd ..

    __Remark:__ `cabal install` will symlink the binaries to `~/.cabal/bin`, so
    make sure that folder is in your `PATH` and takes precedence over
    other locations where old binaries might be lying around.

4. 	Start a relay node and the node running your stake pool from
    [Exercise Sheet 5](pioneers-exercise-5.md).

    Let us assume that we have configuration files

    -   `ff-config.json`
    -   `ff-genesis.json`
    -   `ff-topology.json`

    We can download the latest versions of these files at
    [https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html), but we might want to tweak the config-file and the topology (to add more peers).

    We will eventually run three nodes (one relay, two stake pools),
    and we will run them on the same computer in this example,
    although we would in reality run them on different machines.

    We can (and should) use the same genesis configuration for all three nodes,
    but we need separate versions of the other two types of files.

    Let us assume that we are aiming for the following configuration:

    | Node                          | Relay                 | Pool 1                | Pool 2                |
    | ----------------------------- | --------------------- | --------------------- | --------------------- |
    | port                          | 3000                  | 3001                  | 3002                  |
    | topology file                 | `relay-topology.json` | `node1-topology.json` | `node2-topology.json` |
    | config file                   | `relay-config.json`   | `node1-config.json`   | `node2-config.json`   |
    | database folder               | `relay-db`            | `node1-db`            | `node2-db`            |
    | logging file                  | `logs/relay.log`      | `logs/node1.log`      | `logs/node2.log`      |
    | cold key verification file    |                       | `node1.vkey`          | `node2.vkey`          |
    | cold key signing file         |                       | `node1.skey`          | `node2.skey`          |
    | KES key verification file     |                       | `kes1-001.vkey`       | `kes2-001.vkey`       |
    | KES key signing file          |                       | `kes1-001.skey`       | `kes2-001.skey`       |
    | VRF key verification file     |                       | `vrf1.vkey`           | `vrf2.vkey`           |
    | VRF key signing file          |                       | `vrf1.skey`           | `vrf2.skey`           |
    | stake key verification file   |                       | `stake1.vkey`         | `stake2.vkey`         |
    | stake key signing file        |                       | `stake1.skey`         | `stake2.skey`         |
    | payment key verification file | `pay.vkey`            |                       |                       |
    | payment key signing file      | `pay.skey`            |                       |                       |
    | stake address                 |                       | `stake1`              | `stake2`              |
    | payment address               |                       | `pay1`                | `pay2`                |
    | issue counter                 |                       | `node1.counter`       | `node2.counter`       |
    | operational certificate       |                       | `node1-001.cert`      | `node2-001.cert`      |
    | stake certificate             |                       | `stake1.cert`         | `stake2.cert`         |
    | delegation certificate        |                       | `stake1.deleg`        | `stake2.deleg`        |
    | pool certificate              |                       | `pool1.cert`          | `pool2.cert`          |

    __Note__: In this example solution, we use only one _payment key pair_ `pay.vkey`/`pay.skey`, but it is of course possible to use several different ones.

    We assume that we have already renamed the relevant files from previous exercises and therefore already have:
    `node1.vkey`, `node1.skey`, `kes1-001.vkey`, `kes1-001.skey`, `vrf1.vkey`, `vrf1.skey`, `stake1.vkey`, `stake1.skey`, `pay.vkey`, `pay.skey`, `stake1`,
    `pay1`, `node1.counter`, `node1-001.cert`, `stake1.deleg`, `pool1.cert`.

    We can start by creating the three config-files by making three copies of our template and configuring logging correctly in each of the copies
    by editing the part

        "setupScribes": [
            {
              "scFormat": "ScText",
              "scKind": "StdoutSK",
              "scName": "stdout",
              "scRotation": null
            },
            {
              "scFormat": "ScText",
              "scKind": "FileSK",
              "scName": "logs/mainnet.log"
            }
        ]

    and replacing `logs/mainnet.log` by the correct log-file name.

    Next we create the three topology files. We aim for the following topology:
    ![Topology](topology.png)

    This is achieved as follows:

    - `relay-topology.json`:

            {
                "Producers": [
                    {
                        "addr": "127.0.0.1",
                        "port": 3001,
                        "valency": 1
                    },
                    {
                        "addr": "127.0.0.1",
                        "port": 3002,
                        "valency": 1
                    },
                    {
                        "addr": "relays-new.ff.dev.cardano.org",
                        "port": 3001,
                        "valency": 2
                    }
                ]
            }

    - `node1-topology.json` and `node2-topology.json`:

            {
                "Producers": [
                    {
                        "addr": "127.0.0.1",
                        "port": 3000,
                        "valency": 1
                    }
                ]
            }

    Now we can start the relay...

        cardano-node run \
            --topology relay-topology.json \
            --database-path relay-db \
            --socket-path relay-db/node-socket \
            --port 3000 \
            --config relay-config.json

    ...and the first pool

        cardano-node run \
            --topology node1-topology.json \
            --database-path node1-db \
            --socket-path node1-db/node-socket \
            --port 3001 \
            --config node1-config.json \
            --shelley-kes-key kes1-001.skey \
            --shelley-vrf-key vrf1.skey \
            --shelley-operational-certificate node1-001.cert

### Objectives

In the sixth exercise, we will make sure that you can:

1. 	Run multiple stake pools;
2. 	Vary the stake pool parameters;
3. 	Retire Stake Pools.

As before, if you have any questions or encounter any problems,
please feel free to use the dedicated Telegram channel.

IOHK staff will be monitoring the channel, and other Pioneers may also be able to help you.

Please report any bugs or improvements through the
[cardano-node](https://github.com/input-output-hk/cardano-node)
and [cardano-tutorials](https://github.com/input-output-hk/cardano-tutorials)
GitHub repositories.

### Exercises

1. 	Create a new set of hot keys for your stake pool and restart it with those keys.

    We start by creating the KES key pair:

        cardano-cli shelley node key-gen-KES \
            --verification-key-file kes1-002.vkey \
            --signing-key-file kes1-002.skey

    Before we can create a new operational certificate, we need to figure out start of the KES validity period.
    We need to know how long a period is from the genesis file:

        cat ff-genesis.json | grep KESPeriod
        > "slotsPerKESPeriod": 3600,

    So one period lasts 3600 slots. What slot are we currently in?

        export CARDANO_NODE_SOCKET_PATH=node1-db/node-socket
        cardano-cli shelley query tip --testnet-magic 42
        > Tip (SlotNo {unSlotNo = 432571}) ...

    So we get for the current period:

        expr 432571 / 3600
        > 120

    With this we are able to generate a new operational certificate for our first pool:

        cardano-cli shelley node issue-op-cert \
            --hot-kes-verification-key-file kes1-002.vkey \
            --cold-signing-key-file node1.skey \
            --operational-certificate-issue-counter node1.counter \
            --kes-period 120 \
            --out-file node1-002.cert

    And we can stop our node, then restart it with the new certificate:

        cardano-node run \
            --topology node1-topology.json \
            --database-path node1-db \
            --socket-path node1-db/node-socket \
            --port 3001 \
            --config node1-config.json \
            --shelley-kes-key kes1-002.skey \
            --shelley-vrf-key vrf1.skey \
            --shelley-operational-certificate node1-002.cert

2. 	Register and start a second stake pool, as you did in [Exercise 5](pioneers-exercise-4.md).

    Let's start by creating the cold keys and VRF keys for our second pool:

        cardano-cli shelley node key-gen \
            --cold-verification-key-file node2.vkey \
            --cold-signing-key-file node2.skey \
            --operational-certificate-issue-counter-file node2.counter

        cardano-cli shelley node key-gen-VRF \
            --verification-key-file vrf2.vkey \
            --signing-key-file vrf2.skey

    Generating hot keys, an operational certificate and starting the node
    works exactly as above, where we did this for our first pool:

        cardano-cli shelley node key-gen-KES \
            --verification-key-file kes2-001.vkey \
            --signing-key-file kes2-001.skey

        cardano-cli shelley node issue-op-cert \
            --hot-kes-verification-key-file kes2-001.vkey \
            --cold-signing-key-file node2.skey \
            --operational-certificate-issue-counter node2.counter \
            --kes-period 120 \
            --out-file node2-001.cert

        cardano-node run \
            --topology node2-topology.json \
            --database-path node2-db \
            --socket-path node2-db/node-socket \
            --port 3002 \
            --config node2-config.json \
            --shelley-kes-key kes2-001.skey \
            --shelley-vrf-key vrf2.skey \
            --shelley-operational-certificate node2-001.cert

    Next we create stake keys, the corresponding stake address and a payment address for the new pool:

        cardano-cli shelley stake-address key-gen \
            --verification-key-file stake2.vkey \
            --signing-key-file stake2.skey

        cardano-cli shelley stake-address build \
            --stake-verification-key-file stake2.vkey \
            --out-file stake2
            --tesntet-magic 42

        cardano-cli shelley address build \
            --payment-verification-key-file pay.vkey \
            --stake-verification-key-file stake2.vkey \
            --out-file pay2
            --testnet-magic 42

    Now we can create the three certificates we need, the _registration certificate_ for the new pool,
    the _registration certificate_ for the new stake address and the _delegation certificate_ from
    the new stake address to the new pool:

        cardano-cli shelley stake-pool registration-certificate \
            --cold-verification-key-file node2.vkey \
            --vrf-verification-key-file vrf2.vkey \
            --pool-pledge 50000000000 \
            --pool-cost 100000000 \
            --pool-margin 0.03 \
            --pool-reward-account-verification-key-file stake2.vkey \
            --pool-owner-stake-verification-key-file stake2.vkey \
            --out-file pool2.cert

        cardano-cli shelley stake-address registration-certificate \
            --stake-verification-key-file stake2.vkey \
            --out-file stake2.cert

        cardano-cli shelley stake-address delegation-certificate \
            --stake-verification-key-file stake2.vkey \
            --cold-verification-key-file node2.vkey \
            --out-file stake2.deleg

    In this example we have set the pledge to 50,000 ada, the cost to 100 ada and the margin to 3%.

    We are left with publishing those three certificates on the blockchain
    by attaching them to one or more transactions - we will do it in a single transaction here.
    Additionally, we must make sure that our pledge is met by sending at least 50,000 ada to `pay2`.
    We can interact which each of our three nodes to do this, but we choose the relay node for this example.

    We start by checking funds available in UTxO's belonging to `pay1`:

        export CARDANO_NODE_SOCKET_PATH=relay-db/node-socket
        cardano-cli shelley query utxo \
            --address $(cat pay1) \
            --testnet-magic 42

                    TxHash                  TxIx        Lovelace
        ----------------------------------------------------------
        20cb52...                              0      999499413951

    We need the protocol parameters:

        cardano-cli shelley query protocol-parameters \
            --testnet-magic 42 \
            --out-file params.json

    Now we can calculate transaction fees:

        cardano-cli shelley transaction calculate-min-fee \
            --tx-in-count 1 \
            --tx-out-count 2 \
            --ttl 460000 \
            --testnet-magic 42 \
            --signing-key-file pay.skey \
            --signing-key-file node2.skey \
            --signing-key-file stake2.skey \
            --certificate pool2.cert \
            --certificate stake2.cert \
            --certificate stake2.deleg \
            --protocol-params-file params.json

        > runTxCalculateMinFee: 188909

    We look up deposits for pool- and key-registration:

        cat ff-genesis.json | grep Deposit
            "poolDeposit": 500000000,
            "keyDeposit": 400000,

    And calculate our change (assuming we only want to transfer 50,000 ada from `pay1` to `pay2`):

        expr 999499413951 - 188909 - 50000000000 - 500000000 - 400000
        > 948998825042

    We build the raw transaction, sign it and submit it:

        cardano-cli shelley transaction build-raw \
            --tx-in 20cb52...#0 \
            --tx-out $(cat pay2)+50000000000 \
            --tx-out $(cat pay1)+948998825042 \
            --ttl 460000 \
            --fee 188909 \
            --out-file tx.raw \
            --certificate-file stake2.cert \
            --certificate-file pool2.cert \
            --certificate-file stake2.deleg

        cardano-cli shelley transaction sign \
            --tx-body-file tx.raw \
            --signing-key-file pay.skey \
            --signing-key-file node2.skey \
            --signing-key-file stake2.skey \
            --testnet-magic 42 \
            --out-file tx.signed

        cardano-cli shelley transaction submit \
            --tx-file tx.signed \
            --testnet-magic 42

3. 	Record your “pool id” in the Shelley Testnet spreadsheet, to advertise that it is running,
    and advertise the new pool cost and margin settings in the spreadsheet,
    as well as those for your original pool.

    __Note:__ At the time of writing, proper pool id's have not been implemented yet.
    Please use the CBOR-hex from the cold key verification file instead.

    We look up our "pool id":

        cat node2.vkey

        > type: Node operator verification key
        > title: Stake pool operator key
        > cbor-hex:
        >  582033...

    So we can enter `582033...`, 100 ada and 3%
    into the spreadsheet.

4. 	Change the parameters for your original pool.
    Increase the cost by 10,000 ada and set the margin to 20%.
    Choose a suitable pledge value.
    Advertise these new settings in the spreadsheet.

    If we want to change our original pool
    and set cost to 15,000 ada, margin to 20% and pledge to 900,000 ada,
    we create a new pool registration certificate accordingly:

        cardano-cli shelley stake-pool registration-certificate \
            --cold-verification-key-file node1.vkey \
            --vrf-verification-key-file vrf1.vkey \
            --pool-pledge 900000000000 \
            --pool-cost 15000000000 \
            --pool-margin 0.20 \
            --pool-reward-account-verification-key-file stake2.vkey \
            --pool-owner-stake-verification-key-file stake1.vkey \
            --out-file pool1.cert
            --testnet-magic 42

    Here we have additionally (although this was not required) changed the reward account to `stake2.vkey`,
    so the rewards from both our pools will go to the same stake key `stake2.vkey` from now on.

    We have to submit the new certificate to the blockchain:

        cardano-cli shelley query utxo \
            --address $(cat pay1) \
            --testnet-magic 42

                    TxHash                  TxIx        Lovelace
        ----------------------------------------------------------
        0fe697...                              1      948998825042

        cardano-cli shelley transaction calculate-min-fee \
            --tx-in-count 1 \
            --tx-out-count 1 \
            --ttl 460000 \
            --testnet-magic 42 \
            --signing-key-file pay.skey \
            --signing-key-file node1.skey \
            --signing-key-file stake1.skey \
            --certificate pool1.cert \
            --protocol-params-file params.json

        > 181385

        expr 948998825042 - 181385
        > 948998643657

        cardano-cli shelley transaction build-raw \
            --tx-in 0fe697...#1 \
            --tx-out $(cat pay1)+948998643657 \
            --ttl 460000 \
            --fee 181385 \
            --out-file tx.raw \
            --certificate-file pool1.cert

        cardano-cli shelley transaction sign \
            --tx-body-file tx.raw \
            --signing-key-file pay.skey \
            --signing-key-file node1.skey \
            --signing-key-file stake1.skey \
            --testnet-magic 42 \
            --out-file tx.signed

        cardano-cli shelley transaction submit \
            --tx-file tx.signed \
            --testnet-magic 42

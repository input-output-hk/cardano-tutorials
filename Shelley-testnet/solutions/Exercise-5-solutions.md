# Example Solution for Shelley Stakepool Pioneers Exercise Sheet 5

LATEST NODE TAG: 1.13.0

## Running a Stake Pool

### Prerequisites

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

4. 	Make sure you have access to:

    a. 	One or more funded addresses.

    b. 	The keys and operational certificate for the stake pool
        that you set up in Exercise 3.

    c. 	The stake keys from Exercise 4.

    Let's assume for this solution that we have

    | File           | Content                           |
    | -------------- | --------------------------------  |
    | `pay.vkey`     | payment verification key          |
    | `pay.skey`     | payment signing key               |
    | `stake.vkey`   | staking verification key          |
    | `stake.skey`   | staking signing key               |
    | `stake`        | registered stake address          |
    | `pay`          | fundedn address linked to `stake` |
    | `node.vkey`    | cold verification key             |
    | `node.skey`    | cold signing key                  |
    | `node.counter` | issue counter                     |
    | `node.cert`    | operational certificate           |
    | `kes.vkey`     | KES verification key              |
    | `kes.skey`     | KES signing key                   |
    | `vrf.vkey`     | VRF verification key              |
    | `vrf.skey`     | VRF signing key                   |

5. 	Start a relay node.

        wget https://hydra.iohk.io/build/2715059/download/1/ff-config.json
        wget https://hydra.iohk.io/build/2715059/download/1/ff-genesis.json
        wget https://hydra.iohk.io/build/2715059/download/1/ff-topology.json

        rm -rf db logs

        cardano-node run \
            --topology ff-topology.json \
            --database-path db \
            --socket-path db/node-socket \
            --port 8080 \
            --config ff-config.json

        export CARDANO_NODE_SOCKET_PATH=db/node-socket
        cardano-cli shelley query protocol-parameters \
            --testnet-magic 42 \
            --out-file params.json

### Exercises

1. 	Generate a registration certificate for your stake pool:

        cardano-cli shelley stake-pool registration-certificate \
	        --stake-pool-verification-key-file node.vkey \
            --vrf-verification-key-file vrf.vkey \
            --pool-pledge 1000000000 \
            --pool-cost 256000000 \
            --pool-margin 0.07 \
            --reward-account-verification-key-file stake.vkey \
            --pool-owner-staking-verification-key stake.vkey \
            --out-file pool.cert

2. 	Pledge some stake to your stake pool.  

        cardano-cli shelley stake-address delegation-certificate \
            --staking-verification-key-file stake.vkey \
            --stake-pool-verification-key-file node.vkey \
            --out-file deleg.cert

3. 	Register the pool online.  

        cardano-cli shelley transaction calculate-min-fee \
            --tx-in-count 1 \
            --tx-out-count 1 \
            --ttl 430000 \
            --testnet-magic 42 \
            --signing-key-file pay.skey \
            --signing-key-file node.skey \
            --signing-key-file stake.skey \
            --certificate pool.cert \
            --certificate deleg.cert \
            --protocol-params-file params.json

        > runTxCalculateMinFee: 184377

        cat ff-genesis.json | grep poolDeposit
        > "poolDeposit": 500000000,

        cardano-cli shelley query utxo \
            --testnet-magic 42 \
            --address

        cardano-cli shelley query utxo \
            --address $(cat pay) \
            --testnet-magic 42

                         TxHash                       TxIx        Lovelace
        --------------------------------------------------------------------
        8aba76...                                        0       99999255886
        92d4ff...                                        0      899498750011

        expr 99999255886 - 500000000 - 184377
        > 99499071509

        cardano-cli shelley transaction build-raw \
            --tx-in 8aba76...#0 \
            --tx-out $(cat pay)+99499071509 \
            --ttl 430000 \
            --fee 184377 \
            --tx-body-file tx.raw \
            --certificate pool.cert \
            --certificate deleg.cert

        cardano-cli shelley transaction sign \
            --tx-body-file tx.raw \
            --signing-key-file pay.skey \
            --signing-key-file node.skey \
            --signing-key-file stake.skey \
            --testnet-magic 42 \
            --tx-file tx.signed

        cardano-cli shelley transaction submit \
            --tx-file tx.signed \
            --testnet-magic 42

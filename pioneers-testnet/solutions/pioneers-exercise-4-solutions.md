# Example Solution for Shelley Stakepool Pioneers Exercise Sheet 4

## Delegation

### Prerequisites

3. 	Checkout and build the sources which have been tagged with `1.12.0`.

        cabal update
        cd cardano-node
        git fetch --all --tags -f
        git checkout tags/1.12.0
        cabal build all
        cp dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-node-1.12.0/x/cardano-node/build/cardano-node/cardano-node ~/.local/bin/
        cp dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-cli-1.12.0/x/cardano-cli/build/cardano-cli/cardano-cli ~/.local/bin/
        cd ..

4.	Start a node and obtain the protocol parameters.  
    Make sure you know what each of these is (especially the fees).

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
 
1. 	Create a new payment key pair `pay.skey`/`pay.vkey`.

        cardano-cli shelley address key-gen \
            --verification-key-file pay.vkey \
            --signing-key-file pay.skey

    Create a new stake address key pair, `stake.skey`/`stake.vkey`.

        cardano-cli shelley stake-address key-gen \
            --verification-key-file stake.vkey \
            --signing-key-file stake.skey

2.  Use the stake address verification key from Step 1 to build your stake address.
    Save the address in file `stake`.

        cardano-cli shelley stake-address build \
            --staking-verification-key-file stake.vkey > stake

3.  Build a payment address `pay` for the payment key `pay.vkey` which delegates to the
    new stake address from Step 2 and transfer some funds to your new address.

        cardano-cli shelley address build \
            --payment-verification-key-file pay.vkey \
            --staking-verification-key-file stake.vkey > pay

    How to transfer funds to the new address of course depends on your current
    UTxO's. Assuming you have an address saved to file `addr`
    and that the signing payment key for that address is in file `addr.skey`, 
    you can look for UTxO's at that address with

        cardano-cli shelley query filtered-utxo \
            --address $(cat addr) \
            --testnet-magic 42

                         TxHash                       TxIx        Lovelace
        --------------------------------------------------------------------
        e4962d...                                        0      999499083081

    We need to know the current _tip_ of the blockchain in order to set the 
    `ttl`-parameter of the transaction correctly.

        cardano-cli shelley query tip --testnet-magic 42

        > Tip (SlotNo {unSlotNo = 350160}) 

    So in this example the tip is at slot 350160, so we can choose something like
    355000 as `ttl`.

    Let's assume we want to transfer 100,000 ada to the new stake address, then
    we will have a transaction with one input (the UTxO we found in the last step)
    and two outputs: 100,000 ada to the new address and change to the old address.

    We can calculate fees with

        cardano-cli shelley transaction calculate-min-fee \
            --tx-in-count 1 \
            --tx-out-count 2 \
            --ttl 355000 \
            --testnet-magic 42 \
            --signing-key-file addr.skey \
            --protocol-params-file params.json

        > runTxCalculateMinFee: 167965

    We calculate our change:

        expr 999499083081 - 100000000000 - 167965
        > 899498915116

    Build the raw transaction:

        cardano-cli shelley transaction build-raw \
            --tx-in e4962d...#0 \
            --tx-out $(cat pay)+100000000000 \
            --tx-out $(cat addr)+899498915116 \
            --ttl 355000 \ 
            --fee 167965 \
            --tx-body-file tx.raw   

    Sign it:

        cardano-cli shelley transaction sign \ 
            --tx-body-file tx.raw \
            --signing-key-file addr.skey \
            --testnet-magic 42 \
            --tx-file tx.signed

    Submit it:

        cardano-cli shelley transaction submit \
            --tx-file tx.signed \
            --testnet-magic 42

4.  First create a certificate, `stake.cert`, 
    using the `stake.vkey` from Step 1.

        cardano-cli shelley stake-address registration-certificate \
            --staking-verification-key-file stake.vkey \
            --out-file stake.cert
        
    We can pay an arbitrary fee for the transaction as we did before, 
    but it is more cost efficient to pay the correct amount.  
    You can use a CLI command to calculate the fee.

        cardano-cli shelley transaction calculate-min-fee \ 
            --tx-in-count 1 \
            --tx-out-count 1 \
            --ttl 355000 \
            --testnet-magic 42 \
            --signing-key-file pay.skey \
            --signing-key-file stake.skey \
            --certificate stake.cert \
            --protocol-params-file params.json

    Now build the transaction to register your stake address.

        cardano-cli shelley query utxo \
            --address $(cat pay) \
            --testnet-magic 42

                         TxHash                         Ix        Lovelace
        --------------------------------------------------------------------
        53b02e...                                        0      100000000000

        expr 100000000000 - 400000 - 171309
        > 99999428691

        cardano-cli shelley transaction build-raw \
            --tx-in 53b02e...#0 \
            --tx-out $(cat pay)+99999428691 \
            --ttl 355000 \
            --fee 171309 \
            --tx-body-file tx.raw \
            --certificate stake.cert

    Sign the transaction with both the payment- and stake- signing keys:

        cardano-cli shelley transaction sign \
            --tx-body-file tx.raw \
            --signing-key-file pay.skey \
            --signing-key-file stake.skey \
            --testnet-magic 42 \
            --tx-file tx.signed

    And, finally, submit the signed transaction: 

        cardano-cli shelley transaction submit \
            --tx-file tx.signed \
            --testnet-magic 42

5.  First create a delegation certificate, `deleg.cert`. 

    Assuming we have a stake pool verification key file `IOHK.vkey` with the
    following content:

        type: Node operator verification key
        title: Stake pool operator key
        cbor-hex:
         58200a9a89fe46bbc3b58998ab0d58da862194b51f1ce48ae319076bc1cf725e6108

    Generate the certificate:

        cli stake-address delegation-certificate \
            --staking-verification-key-file stake.vkey \
            --stake-pool-verification-key-file IOHK.vkey \
            --out-file deleg.cert


    Then build, sign and submit a transaction as before.

        cardano-cli shelley transaction calculate-min-fee \
            --tx-in-count 1 \
            --tx-out-count 1 \
            --ttl 360000 \
            --testnet-magic 42 \
            --signing-key-file pay.skey \
            --signing-key-file stake.skey \
            --certificate deleg.cert \
            --protocol-params-file params.json 

        > runTxCalculateMinFee: 172805

        cardano-cli shelley query utxo \
            --address $(cat pay) \
            --testnet-magic 42

                         TxHash                       TxIx        Lovelace
        --------------------------------------------------------------------
        0cba01...                                        0       99999428691

        expr 99999428691 - 172805
        > 99999255886

        cardano-cli shelley transaction build-raw \
            --tx-in 0cba01...#0 \
            --tx-out $(cat pay)+99999255886 \
            --ttl 360000 \
            --fee 172805 \
            --tx-body-file tx.raw \
            --certificate deleg.cert 

        shelley transaction sign \
            --tx-body-file tx.raw \
            --signing-key-file pay.skey \
            --signing-key-file stake.skey \
            --testnet-magic 42 \
            --tx-file tx.signed

        cardano-cli shelley transaction submit \
            --tx-file tx.signed \
            --testnet-magic 42

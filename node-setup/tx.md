# Creating a Simple Transaction

In this tutorial we want to create and submit a simple transaction.
We assume that you have created an _address key pair_ and the corresponding _address_
(as explained [here](address.md)) and that you have some utxo at that address.

Let us assume that you want to send 100 ada from an address saved in file `addr1`
to an address saved in file `addr2`. Let us assume that the signing key for `addr1`
is in file `addr1.skey`.

1. We first want to calculate the necessary fees for this transaction.
   In order to do this, we need the _protocol parameters_, which we can save to file `protocol.json`
   with:

        cardano-cli shelley query protocol-parameters \
            --testnet-magic 42 > protocol.json

   Out simple transaction will have one input (from `addr1`) and two outputs,
   100 ada to `addr2` and the change back to `addr1`. We can calculate the fees with:

        cardano-cli shelley transaction calculate-min-fee \
            --tx-in-count 1 \
            --tx-out-count 2 \
            --ttl 100000 \
            --testnet-magic 42 \
            --signing-key-file addr1.skey \
            --protocol-params-file protocol.json

        > 168141

   (The `--testnet-magic 42` identifies the FF-testnet.
   Other testnets will use other numbers, and mainnet uses `--mainnet` instead.)

   So we need to pay 168141 lovelace fee.

   Assuming we want to spend an original utxo containing 1,000,000 ada (1,000,000,000,000 lovelace),
   we therefore will have: 

        expr 1000000000000 - 100000000 - 168141

        > 999899831859

   change.

2. We need the transaction hash and index of the utxo we want to spend, which we can find out
   as follows:

        cardano-cli shelley query utxo \
            --address $(cat addr1) \
            --testnet-magic 42

        >                            TxHash                                 TxIx        Lovelace
        > ----------------------------------------------------------------------------------------
        > 4e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99     4     1000000000000

3. Now we have all the information we need to create the transaction (using a "time to live" of slot 100000,
   after which the transaction will become invalid) and writing the transaction
   to file `tx001.raw`).
   
   __Note:__ The TTL is an absolute slot number (not relative), which means that the `--ttl` value 
   should be greater than the current slot number.

        cardano-cli shelley transaction build-raw \
            --tx-in 4e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99#4 \
            --tx-out $(cat addr2)+100000000 \
            --tx-out $(cat addr1)+999899831859 \
            --ttl 100000 \
            --fee 168141 \
            --tx-body-file tx001.raw

4. We need to sign the transaction with the signing key for `addr1`:

        cardano-cli shelley transaction sign \
            --tx-body-file tx001.raw \
            --signing-key-file addr1.skey \
            --testnet-magic 42 \
            --tx-file tx001.signed

   This writes the signed transaction to file `tx001.signed`.

5. Now we can submit the transaction with:

        export CARDANO_NODE_SOCKET_PATH=db/node.socket
        cardano-cli shelley transaction submit \
            --tx-file tx001.signed \
            --testnet-magic 42

6. We must give it some time to get incorporated into the blockchain, but eventually, we will see the effect:

        cardano-cli shelley query utxo \
            --address $(cat addr1) \
            --testnet-magic 42

        >                            TxHash                                 TxIx        Lovelace
        > ----------------------------------------------------------------------------------------
        > b64ae44e1195b04663ab863b62337e626c65b0c9855a9fbb9ef4458f81a6f5ee     1      999899831859

        cardano-cli shelley query utxo \
            --address $(cat addr2) \
            --testnet-magic 42

        >                            TxHash                                 TxIx        Lovelace
        > ----------------------------------------------------------------------------------------
        > b64ae44e1195b04663ab863b62337e626c65b0c9855a9fbb9ef4458f81a6f5ee     0         100000000

# Retiring a Stake Pool

After having seen how to [_register_](pool.md) a stake pool,
we want to _deregister_ one in this tutorial.

We assume that we have a registered stake pool with cold keys
`node.vkey` and `node.skey`, a payment address with sufficient funds
(for the transaction fees) `pay` and an associated payment signing key `pay.skey`.
We furthermore assume the our node socket path is `relay-db/node-socket` and
that our genesis file is `ff-genesis.json`.

In order to retire our pool, we need to create a _deregistration certificate_
and attach it to a transaction that we submit to the blockchain.

1.  The deregistration certificate contains the _epoch_ in which we want to retire the pool.
    This epoch must be _after_ the current epoch and _not later than_ `eMax` epochs in the
    future, where `eMax` is a protocol parameter.

    So we first need to figure out the current epoch. The number of _slots per epoch_
    is recorded in the genesis file, and we can get it with

        cat ff-genesis.json | grep epoch
        > "epochLength": 21600,

    So one epoch lasts for 21600 slots. We get the current slot by querying the tip:

        export CARDANO_NODE_SOCKET_PATH=relay-db/node-socket
        cardano-cli shelley query tip --testnet-magic 42
        > Tip (SlotNo {unSlotNo = 856232}) ...

    This gives us

        expr 856232 / 21600
        > 39

    So we are currently in epoch 39.

    We can look up `eMax` by querying the current protocol parameters:

        cardano-cli shelley query protocol-parameters \
            --testnet-magic 42 \
            --out-file params.json
        cat params.json | grep eMax
        > "eMax": 100,

    This means the earlist epoch for retirement is 40 (one in the future), and the latest is 139
    (current epoch plus `eMax`).  So for example, we can decide to retire in epoch 41.

2.  Now we can create the deregistration certificate and save it as `pool.dereg`:

        cardano-cli shelley stake-pool deregistration-certificate \
            --cold-verification-key-file node.vkey \
            --epoch 41 \
            --out-file pool.dereg

3.  Finally, we need to create a transaction containing the certificate and submit it.
    We calculate fees:

        cardano-cli shelley transaction calculate-min-fee \
            --tx-in-count 1 \
            --tx-out-count 1 \
            --ttl 860000 \
            --testnet-magic 42 \
            --signing-key-file pay.skey \
            --signing-key-file node.skey \
            --certificate pool.dereg \
            --protocol-params-file params.json
        > 171309

    We query our address for a suitable UTxO to use as input:

        cardano-cli shelley query utxo \
            --address $(cat pay) \
            --testnet-magic 42



               TxHash             TxIx        Lovelace
        ------------------------------------------------
        9db6cf...                    0      999999267766

    We calculate our change:

        expr 999999267766 - 171309
        > 999999096457

    Build the raw transaction:

        cardano-cli shelley transaction build-raw \
            --tx-in 9db6cf...#0 \
            --tx-out $(cat pay)+999999096457 \
            --ttl 860000 \
            --fee 171309 \
            --out-file tx.raw \
            --certificate-file pool.dereg

    Sign it with both the payment signing key and the cold signing key
    (the first signature is necessary because we are spending funds from `pay`,
    the second because the certificate needs to be signed by the pool owner):

        cardano-cli shelley transaction sign \
            --tx-body-file tx.raw \
            --signing-key-file pay.skey \
            --signing-key-file node.skey \
            --testnet-magic 42 \
            --out-file tx.signed

    And submit to the blockchain:

        cardano-cli shelley transaction submit \
            --tx-file tx.signed \
            --testnet-magic 42

    And we are done. The pool will retire at the end of epoch 40.
    If we change our mind, we can create and submit a new registration certificate before epoch 41,
    which will then overrule the deregistration certificate.


# Register stake address in the blockchain

Before, we created our payment keys and address, which allow us to control our funds; we also created our stake keys and stake address, which allow us to participate in the protocol by delegating our stake or by creating a stake pool.  

We need to _register_ our __stake key__ in the blockchain. To achieve this, we:

* Create a registration certificate
* Determine the Time-to-Live (TTL)
* Calculate the fees and deposit   
* Submit the certificate to the blockchain with a transaction


### Create a _registration certificate_:

    cardano-cli shelley stake-address registration-certificate \
    --stake-verification-key-file stake.vkey \
    --out-file stake.cert

Once the certificate has been created, we must include it in a transaction to post it to the blockchain.

### Determine the TTL
As before, to create the transaction you need to determine the TTL.

### Calculate fees and deposit

This transaction has only 1 input (the UTXO used to pay the transaction fee) and 1 output (our payment.addr to which we are sending the change). This transaction has to be signed by both the payment signing key `payment.skey` and the stake signing key `stake.skey`; and includes the certificate `stake.cert`:

    cardano-cli shelley transaction calculate-min-fee \
    --tx-in-count 1 \
    --tx-out-count 1 \
    --ttl 200000 \
    --testnet-magic 42 \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --certificate-file stake.cert \
    --protocol-params-file protocol.json

    > 171485

In this transaction we have to not only pay transaction fees, but also include a _deposit_ (which we will get back when we deregister the key) as stated in the protocol parameters:

The deposit amount can be found in the `protocol.json` under `keyDeposit`:

        ...
        "keyDeposit": 400000,
        ...

Assuming we have a UTXO containing 1000 ada, we get:

    expr 1000000000 - 171485 - 400000

    > 999428515

### Submit the certificate with a transaction:

Build the transaction:

    cardano-cli shelley transaction build-raw \
    --tx-in <the utxo used for paying fees and deposit>#<TxIX> \
    --tx-out $(cat payment.addr)+999428515 \
    --ttl 200000 \
    --fee 171485 \
    --out-file tx.raw \
    --certificate-file stake.cert

Sign it:

    cardano-cli shelley transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --testnet-magic 42 \
    --out-file tx.signed

And submit it:

    cardano-cli shelley transaction submit \
    --tx-file tx.signed \
    --testnet-magic 42

Your stake key is now registered in the blockchain.

# Register stake address in the blockchain

Before, we created our payment keys and address that allow us to control our funds; we also created our stake keys and stake address that allow us to partipate in the protocol.  


1. For us to later be able to delegate our stake to one or more pools, we need to _register_ our stake key in the blockchain.

   First, we need to create an _address registration certificate_:

        cardano-cli shelley stake-address registration-certificate \
            --staking-verification-key-file stake.vkey \
            --out-file stake.cert

5. Once the certificate has been created, we must include it in a transaction to post it to the blockchain.

   We first calculate the fees needed for this transaction. As always, we would have to replace the `--testnet-magic 42`
   if we were to target a different network. We also have to choose `--ttl` high enough, depending on where the tip of our blockchain currently is at.
   The transaction will have to be signed by both the payment signing key corresponding to the utxo used to pay the fees
   and by the stake signing key.

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

   We will have to not only pay fees for this transaction, but also include a _deposit_ (which we will get back when we deregister the key).
   The deposit amount can be found in the `protocol.json` under key `keyDeposit`:

        ...
        "keyDeposit": 400000,
        ...
        
   Assuming we have an utxo containing 1000 ada, we would get a change output of value

        expr 1000000000 - 171485 - 400000
        > 999428515

   Now we can create the raw transaction:

        cardano-cli shelley transaction build-raw \
            --tx-in <the utxo used for paying fees and deposit> \
            --tx-out $(cat payment.addr)+999428515 \
            --ttl 200000 \
            --fee 171485 \
            --out-file tx.raw \
            --certificate-file stake.cert

   We sign it:

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

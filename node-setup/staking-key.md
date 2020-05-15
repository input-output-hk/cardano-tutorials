# Stake Keys and Stake Addresses

In previous tutorials on [adresses](address.md) and [transactions](tx.md),
we used "enterprise" addresses for simplicity. Such an address can receive payments,
but it can not participate in staking.

Let us remedy this now and create staking keys and a staking address!

1. We assume that you have a running [node](build.md) and access to the [command line interface](cli.md).
   To create a staking key pair and save the verification key to `staking.vkey` and the signing key to `staking.skey`,
   we type

        cardano-cli shelley node key-gen-staking \
            --verification-key-file staking.vkey \
            --signing-key-file staking.skey

2. Once we have such a staking key pair, we can create _staking addresses_, addresses that can receive payments
   _and_ participate in staking. To create such an address, we need our newly created staking key pair _and_
   a usual _payment key pair_, which we can create as explained [here](address.md).

   Assuming that we have the payment verification key in file `payment.vkey` and that we want to save our new staking address
   to file `addr.staking`, we can invoke `cardano-cli` as follows:

        cardano-cli shelley address build-staking \
            --payment-verification-key-file payment.vkey \
            --staking-verification-key-file staking.vkey \
            > addr.staking

   We can use this address in the same way as [before](tx.md) to receive and make payments: Others can send ada to this address,
   and we can spent from this address using the _payment_ signing key (which in our example would be the signing key belonging to
   the verification key `payment.vkey`).

3. While we are at it, let us also create a _reward address_ associated with our staking keys, a special address for the purpose
   of receiving staking rewards:

        cardano-cli shelley address build-reward \
            --staking-verification-key-file staking.vkey \
            > rewards

   This will create a reward address for our staking key pair and save it to file `rewards`.

4. For us to later be able to delegate our stake to one or more pools, we need to _register_ our stake key.
   We first need to create an _address registration certificate_:

        cardano-cli shelley stake-address registration-certificate \
            --staking-verification-key-file staking.vkey \
            --out-file staking.cert

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
            --signing-key-file staking.skey \
            --certificate staking.cert \
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
            --tx-out $(cat addr.staking)+999428515 \
            --ttl 200000 \
            --fee 171485 \
            --tx-body-file tx.raw \
            --certificate staking.cert

   We sign it:

        cardano-cli shelley transaction sign \
            --tx-body-file tx.raw \
            --signing-key-file payment.skey \
            --signing-key-file staking.skey \
            --testnet-magic 42 \
            --tx-file tx.signed

   And submit it:

        cardano-cli shelley transaction submit \
            --tx-filepath tx.signed \
            --testnet-magic 42

# Staking Keys and Staking Addresses

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
and we can spend from this address using the _payment_ signing key (which in our example would be the signing key belonging to
the verification key `payment.vkey`).

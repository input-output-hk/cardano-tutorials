# Registering a Stake Pool

(__Note__: This won't work with tag `pioneer-3` and has only been tested with the latest version on `master`!)

Let us register our own stake pool!

For this tutorial we assume that you have set up a [block-producing node with one or more relays](topology.md),
created the [necessary keys and operational certificate](node-op-cert.md) for your block-producing node,
registered a [stake address](staking-key.md) and have some funds at your stake address.

1. We need to create a _stake pool registration certificate_:

        cardano-cli shelley stake-pool registration-certificate \
            --stake-pool-verification-key-file node.vkey \ 
            --vrf-verification-key-file vrf.vkey \
            --pool-pledge 100000000000 \
            --pool-cost 10000000000 \
            --pool-margin 0.01 \
            --reward-account-verification-key-file staking.vkey \
            --pool-owner-staking-verification-key staking.vkey \
            --out-file pool.cert

   | Parameter                            | Explanation                                       |
   |--------------------------------------|---------------------------------------------------|
   | stake-pool-verification-key-file     | verification _cold_ key                           |
   | vrf-verification-key-file            | verification _VRS_ key                            |
   | pool-pledge                          | pledge (lovelace)                                 |
   | pool-cost                            | operational costs per epoch (lovelace)            |
   | pool-margin                          | operator margin                                   |
   | reward-account-verification-key-file | verification staking key for the rewards          |
   | pool-owner-staking-verification-key  | verification staking key(s) for the pool owner(s) |
   | out-file                             | output file to write the certificate to           |

   So in the example aboce, we use the cold- and VRF-keys that we created [here](node-op-cert.md),
   promise to pledge 100,000 ada to our pool,
   declare operational costs of 10,000 ada per epoch,
   set the operational margin (i.e. the ratio of rewards we take after taking our costs and before the rest is distributed amongst owners and delegators
   according to their delegated stake) to 1%,
   use the staking key we created [here](staking-key.md) to receive our rewards
   and use the same key as pool owner key for the pledge.

   We could use a different key for the rewards, and we could provide more than one owner key if there were multiple owners who share the pledge.

2. We have to honor our pledge by delegating at least the pledged amount to our pool,
   so we have to create a _delegation certificate_ to achieve this:

        cardano-cli shelley stake-address delegation-certificate \
            --staking-verification-key-file staking.vkey \
            --stake-pool-verification-key-file node.vkey \
            --out-file delegation.cert 

   This creates a delegation certificate which delegates funds from all stake addresses associated with key `staking.vkey` to 
   the pool belonging to cold key `node.vkey`. If we had used different staking keys for the pool owners in the first step,
   we would need to create delegation certificates for all of them instead.

3. Finally we need to submit the pool registration certificate and the delegation certificate(s) to the blockchain
   by including them in one or more transactions. We can use one transaction for multiple certificates, the certificates will be applied in order.
   We start by calculating the fees (as explained [here](tx.md)):

        cardano-cli shelley transaction calculate-min-fee \ 
            --tx-in-count 1 \
            --tx-out-count 1 \ 
            --ttl 200000 \ 
            --testnet-magic 42 \
            --signing-key-file addr1.skey \
            --signing-key-file staking.skey \
            --signing-key-file node.skey \
            --certificate pool.cert \
            --certificate delegation.cert \ 
            --protocol-params-file protocol.json 

        > 184685

   Note how we included the two certificates in the call to `calculate-min-fee` and that the transaction will have to be signed by the payment key corresponding to the
   address we use to pay for the transaction, 
   the staking key(s) of the owner(s) and the cold key of the node.
   We will also have to pay a deposit for the stake pool registration. 
   The deposit amount is specified in the genesis file:

        "poolDeposit": 500000000

   In order to calculate the correct amounts, we first query our stake address as explained [here](tx.md). 
   We might get somethin like

                                   TxHash                                 TxIx        Lovelace
        ----------------------------------------------------------------------------------------
        9db6cf...                                                            0      999999267766

   Note that the available funds are higher than the pledge, which is fine. They just must not be _lower_.

   In this example, we can now calculate our change:

        expr 999999267766 - 500000000 - 184685
        > 999499083081

   Now we can build our transaction:

        cardano-cli shelley transaction build-raw \
            --tx-in 9db6cf...#0 \ 
            --tx-out $(cat addr1.staking)+999499083081 \
            --ttl 200000 \
            --fee 184685 \
            --tx-body-file tx003.raw \
            --certificate pool.cert \
            --certificate delegation.cert 

   We sign:

        cardano-cli shelley transaction sign \ 
            --tx-body-file tx003.raw \
            --signing-key-file addr1.skey \ 
            --signing-key-file staking.skey \
            --signing-key-file node.skey \
            --testnet-magic 42 \
            --tx-file tx003.signed

   And submit:

        cardano-cli shelley transaction submit \
            --tx-file tx003.signed \
            --testnet-magic 42

  That's it! Our stake pool has been registered.

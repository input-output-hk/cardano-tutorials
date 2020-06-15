# Registering a Stake Pool

Let us register our own stake pool!

For this tutorial we assume that you have set up a [block-producing node with one or more relays](topology.md),
created the [necessary keys and operational certificate](node-op-cert.md) for your block-producing node,
registered a [stake address](staking-key.md) and have some funds at your stake address.

1. We need to create a _stake pool registration certificate_:

        cardano-cli shelley stake-pool registration-certificate \
            --cold-verification-key-file node.vkey \
            --vrf-verification-key-file vrf.vkey \
            --pool-pledge 100000000000 \
            --pool-cost 10000000000 \
            --pool-margin 0.01 \
            --pool-reward-account-verification-key-file stake.vkey \
            --pool-owner-stake-verification-key-file stake.vkey \
            --testnet-magic 42 \
            --out-file pool.cert

   | Parameter                                 | Explanation                                       |
   |-------------------------------------------|---------------------------------------------------|
   | stake-pool-verification-key-file          | verification _cold_ key                           |
   | vrf-verification-key-file                 | verification _VRS_ key                            |
   | pool-pledge                               | pledge (lovelace)                                 |
   | pool-cost                                 | operational costs per epoch (lovelace)            |
   | pool-margin                               | operator margin                                   |
   | pool-reward-account-verification-key-file | verification staking key for the rewards          |
   | pool-owner-stake-verification-key-file    | verification staking key(s) for the pool owner(s) |
   | testnet-magic                             | testnet identifier number                         |
   | out-file                                  | output file to write the certificate to           |

   So in the example above, we use the cold- and VRF-keys that we created [here](node-op-cert.md),
   promise to pledge 100,000 ada to our pool,
   declare operational costs of 10,000 ada per epoch,
   set the operational margin (i.e. the ratio of rewards we take after taking our costs and before the rest is distributed amongst owners and delegators
   according to their delegated stake) to 1%,
   use the staking key we created [here](staking-key.md) to receive our rewards
   and use the same key as pool owner key for the pledge.

   We could use a different key for the rewards, and we could provide more than one owner key if there were multiple owners who share the pledge.
   
The __pool.cert__ file should look like this: 

	type: StakePoolCertificateShelley
	title: Free form text
	cbor-hex:
	 18b58a03582062d632e7ee8a83769bc108e3e42a674d8cb242d7375fc2d97db9b4dd6eded6fd5820
	 48aa7b2c8deb8f6d2318e3bf3df885e22d5d63788153e7f4040c33ecae15d3e61b0000005d21dba0
	 001b000000012a05f200d81e820001820058203a4e813b6340dc790f772b3d433ce1c371d5c5f5de
	 46f1a68bdf8113f50e779d8158203a4e813b6340dc790f772b3d433ce1c371d5c5f5de46f1a68bdf
	 8113f50e779d80f6   

2. We have to honor our pledge by delegating at least the pledged amount to our pool,
   so we have to create a _delegation certificate_ to achieve this:

        cardano-cli shelley stake-address delegation-certificate \
            --staking-verification-key-file stake.vkey \
            --stake-pool-verification-key-file node.vkey \
            --out-file delegation.cert 

   This creates a delegation certificate which delegates funds from all stake addresses associated with key `stake.vkey` to 
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
            --signing-key-file payment.skey \
            --signing-key-file stake.skey \
            --signing-key-file node.skey \
            --certificate-file pool.cert \
            --certificate-file delegation.cert \ 
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
            --tx-out $(cat payment.addr)+999499083081 \
            --ttl 200000 \
            --fee 184685 \
            --out-file tx003.raw \
            --certificate-file pool.cert \
            --certificate-file delegation.cert 

   We sign:

        cardano-cli shelley transaction sign \ 
            --tx-body-file tx003.raw \
            --signing-key-file payment.skey \ 
            --signing-key-file stake.skey \
            --signing-key-file node.skey \
            --testnet-magic 42 \
            --out-file tx003.signed

   And submit:

        cardano-cli shelley transaction submit \
            --tx-file tx003.signed \
            --testnet-magic 42

  That's it! Our stake pool has been registered.
  
  To verify that your stake pool registration was indeed successful, you can perform the following steps:
  
  	cardano-cli shelley stake-pool id --verification-key-file <path to your node.vkey>
  
  will output your poolID. You can then check for the presence of your poolID in the network ledger state, with the following command:
  
  	cardano-cli shelley query ledger-state --testnet-magic 42 | grep poolPubKey | grep <poolId>

which should return a non-empty string if your poolID is located in the ledger. You can then then head over to a pool listing website such as https://ff.pooltool.io/ and (providing it is up and running and showing a list of registered stake pools) you should hopefully be able to find your pool in there by searching using your poolID, and subsequently claiming it (might require registration on the website) and giving it a customized name.
  
  

# Shelley Stakepool Exercise Sheet 2

LATEST TAG: 1.13.0

## Basic Transactions on the Cardano Blockchain

In the first exercise, we set up a Cardano node and ran it.  In this exercise, we will build transactions that are submitted to the Blockchain.  Transactions are the basic mechanism that is used to transfer Ada between stakeholders, register staking pools, stake Ada, and many other things.

### Prerequisites

1. Complete Exercise Sheet 1, and confirm that you have successfully built and run a node.  Also make sure that you have requested some test Ada through the [spreadsheet](https://docs.google.com/spreadsheets/d/1o62S2_24bcZNIpT3FASKHVGHG-dQ4J0vDaVCEsxbVKU/edit?usp=sharing).

2. Read the Cardano Tutorials and General Documentation on Basic Transactions, Metadata, Addresses, Blocks and Slots at:
    a) [Cardano Tutorials](https://github.com/input-output-hk/cardano-tutorials/)
    b) [Shelley Testnet Documentation](https://testnets.cardano.org/)

3. Checkout the latest version of the Shelley node and CLI from source, and rebuild and reinstall them if they have changed:

```bash
        git checkout tags/1.13.0
        …
        cabal install cardano-node cardano-cli
        …
```

Before building, you might want to confirm that you are on the correct tagged version:

```bash
        git branch
	> (HEAD detached at 1.13.0)
	>  master
        cardano-node
  > cardano-node 1.13.0 - linux-x86_64 - ghc-8.6
```

### Objectives

In the second exercise, we will make sure that you can:

1. Build simple transactions using the basic transaction mechanism;
2. Sign transactions and confirm that the transaction is complete;
3. Submit transactions to the Shelley Testnet Blockchain;
4. Verify that the transactions have been processed by inspecting the addresses that they have been sent to.

This unlocks many of the things that we will want to do with the Cardano Blockchain in future, including transferring Ada, stake pool registration, and staking.

As before, if you have any questions or encounter any problems, please feel free to use the dedicated Cardano Forum channel.  IOHK staff will be monitoring the channel, and other pool operators may also be able to help you.


### Exercises

In this excercise we will be following steps from [Creating a Simple Transaction tutorial](https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/tx.md)

1. If you are not on the correct version of the node, then some of these commands may not work.
   It may be frustrating to stop and restart a working system, but it is better than discovering that
   you do not have the correct version! Before starting the rest of the exercises, you may want
   to make sure that you do not have an old instance of the node running:

```bash
        killall cardano-node
```

Then start a new instance of the node, as you did in Exercise 1:

```bash
        cardano-node run --config …
```

and verify that your new node instance is running:

```bash
        ps x | grep cardano-node
	>10765 pts/4 R + 1:20  cardano-node …
```


   Your node should be connected to the Shelley Testnet and verifying the blocks that it receives.

2. Verify that you have received some test Ada at the address that you created in Exercise 1, *payment.addr*.

```bash
        cardano-cli shelley query utxo \
            --address … \
            --testnet-magic …
```

Create a new address *payment2.addr*:

```bash
        cardano-cli shelley address key-gen …
        cardano-cli shelley address build …
```

3. Build a transaction to transfer Ada from *payment.addr* to *payment2.addr*.  You will need to use the Shelley transaction processing operations:

```bash
        cardano-cli shelley transaction build-raw \
            --tx-in …
```

   This is the most basic form of transaction construction.  We will use more sophisticated ones later.  The transaction will be created in the file txbody. You will need to provide explicit transaction inputs and outputs. Keep in mind that the output for the change needs to be specified as well, so the sum of your inputs needs to match the sum of your outputs + fee.

```bash
   | Format       | Explanation                                                                                  |
   | ------------ | -------------------------------------------------------------------------------------------- |
   | Id#Index     | This identifies the UTxO that is the source of the Ada – you should get this from query utxo  |
   | Out+lovelace | Hex encoded address that will receive the Ada and the amount to send in Lovelace.            |
```

You will also need to give it a time to live in slots (ttl) and a fee (in lovelace). Use the following settings:

```bash
   | Parameter | Value   |
   | --------- | ------- |
   | ttl       | 500000  |
   | fee       | 1000000 |
```

   The settings that are used here indicate that the transaction should be processed before slot 500,000 and  that it will cost no more than 1 Ada to submit (a safe value for a simple transaction on the Testnet).  You must pay this (small) fee every time you successfully process a transaction on the Cardano Blockchain.  It will be distributed as part of the pool rewards.  The source of this fee is encoded in the transaction as a UTxO.

Here's an **example** of a transaction that instructs the transfer of 100,000,000 lovelace from one account (account A) to another account (account B).

```bash
	cardano-cli shelley transaction build-raw \
		--tx-in 91999ea21177b33ebe6b8690724a0c026d410a11ad7521caa350abdafa5394c3#0 \
		--tx-out 82065820acc8de978a8c484a6797a014c28f6746c98ebe93d7f4498d66ea639ec953933f+100000000 \
		--tx-out a72ec98117def0939cc310b17de10d218f41ef5c84d94a89fe6097318d3de983+99899000000 \
		--fee 1000000 \
		--ttl 500000 \
		--out-file txbody
```

Note that there are two outputs. First is the amount sent to account B, second is the change being returned to account A, where the change is equal to the input from account A, minus the value being transferred to account B, minus the fee.

We are now ready to sign the transaction and submit it to the chain.

4. Sign your transaction in *txbody* using the signing key for *payment.addr* (created in Excercise 1) :

```bash
        cardano-cli shelley transaction sign \
            --tx-body-file txbody \
            --signing-key-file txsign \
            --testnet-magic … \
            --out-file txout
```

You will need to give the correct Network Magic Id for the Testnet, as supplied in the Genesis file (e.g. 42).

5. Submit your transaction to the Blockchain:

```bash
        cardano-cli shelley transaction submit \
            --testnet-magic … \
            --tx-file txout
```

   If you made a mistake or if the node is not running or it cannot be contacted, you will see an error.  Just correct the error or kill/restart the node in this case and try again.

6. After 2 minutes (possibly earlier), your Ada should be transferred to your new address.

```bash
        cardano-cli shelley query utxo \
            --address … \
            --testnet-magic …
```

7. Finally, build a transaction that sends a total of 1,000 Ada from *payment.addr* to two different addresses (a multi-address transaction).

```bash
        cardano-cli shelley address key-gen …
        cardano-cli shelley address build …
        cardano-cli shelley address key-gen …
        cardano-cli shelley address build …
        cardano-cli shelley transaction build-raw …
```

   The required fee will be higher than before, since part of the cost is based on the number of addresses that the output is sent to.  You can check that the fee will be sufficient before you build the transaction using:

```bash
        cardano-cli shelley query protocol-parameters --testnet-magic 42 > protocol-parameters.json
        cardano-cli shelley transaction calculate-min-fee --protocol-params-file protocol-parameters.json …
```

Sign, submit and wait for the transaction to be processed as before.

```bash
        cardano-cli shelley transaction sign …
        cardano-cli shelley transaction submit …
```

   Once the transaction has completed, you will be able to verify that each of the addresses has received the correct amount of Ada.  Note that you now own four different addresses, each of which holds some Ada.  As you continue to process transactions and send/receive Ada to more addresses, your Ada will gradually become split among many different addresses, creating fragmentation.  This is not normally a big problem for the typical user who only owns a small amount of Ada, but can become a large problem for exchanges (as well as for whales, like you on the Testnet).

8. Optional Exercise (Easy).

   Exchange some Ada with another Testnet user.

9. Optional Exercise (Easy).

   Defragment your Ada so that it is all held in one place.


In the next exercise, we will set up a node so that it can run as a staking pool.

### Feedback

Please provide any feedback or suggested changes to the tutorials or exercises by either raising an issue on the [cardano-tutorials repository](https://github.com/input-output-hk/cardano-tutorials) or by forking the repository and submitting a PR.

Please provide any feedback or suggested changes on the node itself by raising an issue at the [cardano-node repository](https://github.com/input-output-hk/cardano-node).

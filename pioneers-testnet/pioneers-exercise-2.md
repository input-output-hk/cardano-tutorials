# Shelley Stakepool Pioneers Exercise Sheet 2

## Basic Transactions on the Cardano Blockchain

In the first exercise, we set up a Cardano node and ran it.  In this exercise, we will build transactions that are submitted to the Blockchain.  Transactions are the basic mechanism that is used to transfer Ada between stakeholders, register staking pools, stake Ada, and many other things.

### Prerequisites

1. Complete Exercise Sheet 1, and confirm that you have successfully built and run a node.  Also make sure that you have requested some test Ada through the spreadsheet.

2. Read the IOHK Tutorial Documentation and General Documentation on Basic Transactions, Metadata, Addresses, Blocks and Slots at:
a. https://github.com/input-output-hk/cardano-tutorials/
b. https://testnet.cardano.org/

3. Checkout the latest version of the Shelley node and CLI from source, and rebuild and reinstall them if they have changed:

```bash
$ git checkout pioneer
$ cabal build all
$ …
```

### Objectives

In the second exercise, we will make sure that you can:

1. Build simple transactions using the basic transaction mechanism;
2. Sign transactions and confirm that the transaction is complete;
3. Submit transactions to the Pioneer Blockchain;
4. Verify that the transactions have been processed by inspecting the addresses that they have been sent to.

This unlocks many of the things that we will want to do with the Cardano Blockchain in future, including transferring Ada, stake pool registration, and staking.

If you have any questions or encounter any problems, please feel free to use the dedicated Friend & Family Telegram channel.  IOHK staff will be monitoring the channel, and other Pioneers may also be able to help you.

### Exercises

1. Make sure that you do not have an old instance of the node running:

```bash
$ killall cardano-node
```

Start a new instance of the node, as you did in Exercise 1:

```bash
$ cardano-node run --config …
```

Verify that your new node instance is running:

```bash
$ ps x | grep cardano-node
10765 pts/4 R + 1:20  cardano-node …
$
```

Your node should be connected to the Pioneer Testnet and verifying the blocks that it receives.

2. 	Verify that you have received some test Ada at the address that you provided to IOHK in Exercise 1, *myaddr*.

```
$ cardano-cli shelley query filtered-utxo \
 	--address ... \
 	--network-magic …
```

Create a new address *myaddr2*:

```bash
$ cardano-cli shelley address key-gen …
```

3. Build a transaction to transfer Ada from *myaddr* to *myaddr2*.  You will need to use the Shelley transaction processing operations:

```bash
$ cardano-cli shelley transaction build-raw \
  --tx-body-file txbody …
```

This is the most basic form of transaction construction.  We will use more sophisticated ones later.  The transaction will be created in the file txbody. You will need to provide explicit transaction inputs and outputs.

| Id#Index     | This identifies the UTxO that is the source of the Ada – you should get this from  *myaddr*. |
|--------------|--------------------------------------------------------------------------------------------|
| Out+lovelace | Hex encoded address that will receive the Ada and the amount to send in Lovelace.          |

You will also need to give it a time to live, in slots (ttl) and a fee (in lovelace).  Use the following settings:

| ttl 	| 1000    	|
|-----	|---------	|
| fee 	| 1000000 	|

The settings that are used here indicate that the transaction should be processed within 1,000 slots and  that it will cost no more than 1 Ada to submit (a safe value for a simple transaction on the Testnet).  You must pay this (small) fee every time you successfully process a transaction on the Cardano Blockchain.  It will be distributed as part of the pool rewards.  The source of this fee is encoded in the transaction as a UTxO.  We are now ready to sign the transaction and submit it to the chain.

4. Generate a signing key, txsign.

```bash
$ cardano-cli keygen …
```

Sign your transaction in txbody using the signing key for *myaddr*:

```bash
$ cardano-cli shelley transaction sign \
 	--tx-body-file txbody \
 	--signing-key-file txsign \
 	--network-magic … \
 	--tx-body-file txbody
```

You will need to give the correct Network Magic Id for the Testnet, as supplied by IOHK in the Genesis file (e.g. 42).

5. Submit your transaction to the Blockchain:

```bash
$ cardano-cli shelley transaction submit \
 	--network-magic … \
 	--tx-body-file txbody
```

If you made a mistake or if the node is not running or it cannot be contacted, you will see an error.  Just correct the error or kill/restart the node in this case and try again.

6. After 2 minutes (possibly earlier), your Ada should be transferred to your new address.

```bash
 	$ cardano-cli shelley query filtered-utxo \
 	 	--address … \
 	 	--network-magic …
```

7. Finally, build a transaction that sends a total of 1,000 Ada from *myaddr* to two different addresses (a multi-address transaction).

```bash
$ cardano-cli shelley address key-gen …
$ cardano-cli shelley address key-gen …
$ cardano-node shelley transaction build-raw …
```

The required fee will be higher than before, since part of the cost is based on the number of addresses that the output is sent to.  You can check that the fee will be sufficient before you build the transaction using:

```bash
$ cardano-node shelley transaction calculate-min-fee …
```

Sign, submit and wait for the transaction to be processed as before.

```bash
$ cardano-cli shelley transaction sign …
$ cardano-node shelley transaction submit …
```

Once the transaction has completed, you will be able to verify that each of the addresses has received the correct amount of Ada.  Note that you now own four different addresses, each of which holds some Ada.  As you continue to process transactions and send/receive Ada to more addresses, your Ada will gradually become split among many different addresses, creating fragmentation.  This is not normally a big problem for the typical user who only owns a small amount of Ada, but can become a large problem for exchanges (as well as for whales, like you on the Testnet).

8. Optional Exercise (Easy).

Exchange some Ada with another Pioneer

9. Optional Exercise (Easy).

Defragment your Ada so that it is all held in one place.

10. Optional Exercise (Medium).

Read about certificates and build and submit a transaction that requires a certificate.

In the next exercise, we will set up a node so that it can run as a staking pool.

### Feedback

Please provide any feedback or suggested changes by either raising an issue on the [cardano-tutorials repository](https://github.com/input-output-hk/cardano-tutorials) or by forking the repository and submitting a PR.

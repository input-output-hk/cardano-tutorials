## Objectives
In the second exercise, we will make sure that you can:

* Build simple transactions using the basic transaction mechanism;
* Sign transactions and confirm that the transaction is complete;
* Submit transactions to the Pioneer Blockchain;
* Verify that the transactions have been processed by inspecting the addresses that they have been sent to.


### PREREQUISITES

1. Have a node running

		cardano-node run \
		--topology relay/ff-topology.json \
		--database-path relay/db \
		--socket-path relay/db/node.socket \
		--host-addr x.x.x.x \
		--port 3001 \
		--config relay/ff-config.json
2. Have funds in you payment.addr . If you don't, please register your address on the spreadsheet.


### LET'S GO FOR IT !!

We are using the node socket to submit transactions, so let's set environment variable `CARDANO_NODE_SOCKET_PATH` to the socket-path specified in your node configuration, let's our relay node for that.


   	export CARDANO_NODE_SOCKET_PATH=relay/db/node.socket

Let's create a second __payment key pair__ and __address__ (You should have created one in Exercise 1). We need to create also a __stake key pair__ and a 	__stake address__. The payment set, gives you control of your funds, the stake set, allows you to participate in the 	protocol, by delegating tour stake or creating your own stake pool.

**Generate Payment Key Pair**

	$ cardano-cli shelley address key-gen \
	    --verification-key-file payment2.vkey \
	    --signing-key-file payment2.skey

This has created two files containging our signing key and our verification key, let's take a look.

	$ cat payment.skey

	> type: SigningKeyShelley
	> title: Free form text
	> cbor-hex:
	>  18ad58202bd444b77c3149a31a59729c91691ff14dccf0a0891d6c6630668007f27e5806

	$ cat payment.vkey

	> type: PaymentVerificationKeyShelley
	> title: Free form text
	> cbor-hex:
	>  18af582024caa975f44df72753c3cc4b1bd7ca46fce12d4503d6a0bc003473dc4fd6e780


**Generate Stake Key Pair**

	cardano-cli shelley stake-address key-gen \
	--verification-key-file stake2.vkey \
	--signing-key-file stake2.skey

This has created another set of keys, these ones will later allow us to delegate and/or create a stake pool. Let's see how they look

	$ cat stake2.skey

	> type: SigningKeyShelley
	> title: Free form text
	> cbor-hex:
	>  18ad58205feed52eff8860d3041b523f89d41075376bbe05aebb716a1c7a3f1310c3cbb7

	$ cat stake2.vkey

	> type: StakingVerificationKeyShelley
	> title: Free form text
	> cbor-hex:
	> 18b9582021ddc6229bc5e4eb00bc723492d89d1f899aad5e48cfbca57da5605c1e9b3e34

**Generate Payment Address**

Now we will use both `payment2.vkey` and `stake2.vkey`to build a **payment address**. This will link our payment address to our **stake keys** and **stake address**.

	$ cardano-cli shelley address build \
	--payment-verification-key-file payment.vkey \
	--staking-verification-key-file stake.vkey > payment2.addr


**Generate Stake Address**

And, now generate you stake address. This will collect your rewards from delegation.

	cardano-cli shelley stake-address build \
	--staking-verification-key-file stake2.vkey \
	--out-file stake2.addr


**Yei!! Now we have two payment addresses, we can send a transaction.**

## TRANSACTIONS

To create our transaction we will need the protocl parameters, so let's query the parameters and save them in `protocol.json`

	$ cardano-cli shelley query protocol-parameters \
	    --testnet-magic 42 \
	    --out-file protocol.json

We also need the UTXO details of the payment address that will send the funds.

	$ cardano-cli shelley query utxo \
	    --address $(cat payment.addr) \
	    --testnet-magic 42

		                             TxHash                                 TxIx        Lovelace
	----------------------------------------------------------------------------------------
	65bc31936bae87240236e42a73b84d03dc7fd1cee5ac73caff051eeec7a34da0     1                 0
	e757f08b856c5f12d5784f749c4fc2b1fda8b48299b520f29f6055ce94a5d8cf     0      499498404313


Sending funds to our new `payment2.addr`requires five (5) simple steps.

   1. Determine the appropiate TTL (Time to live)
   2. Calculate the fee
   3. Build the transaction
   4. Sign the transaction
   5. Submit the transaction

But you can't just copy-paste things from here. There are some tweaks you need to do to the examples provided to make the transaction work. It is a good idea to open a text editor and make changes there, and then go to the CLI.

**DETERMINE TTL**

Let's find the current slot number, and increase it in ~1000 to give us some time to submit the transaction.

	$ cardano-cli shelley query tip --testnet-magic 42

	> Tip (SlotNo {unSlotNo = 266201}) (ShelleyHash {unShelleyHash = HashHeader {unHashHeader = 	26f76f2345f1ef4c39df82c89c6585bced4a0e484a3087bbd4afa06cfe2bb0c9}}) (BlockNo {unBlockNo = 9818})

So we are currently on slot 266201, __Let's make our transaction TTL 267500__. We will use this to calculate the fee and to build the transaction.

**CALCULATE FEE**

Our transaction will have 1 input (tx-in-count), the UTXO from our sending address `e757f0...5d8cf` from above,  and 2 outputs (tx-in-count), the receiveing address (payment2.addr) and a second ouput to send the change (payment.addr)

	$ cardano-cli shelley transaction calculate-min-fee \
	    --tx-in-count 1 \
	    --tx-out-count 2 \
	    --ttl 267500 \
	    --testnet-magic 42 \
	    --signing-key-file payment.skey \
	    --protocol-params-file protocol.json

	> runTxCalculateMinFee: 167965

So this transaction costs 167965 lovelaces.

Now we need to make some quick math, lets say we want to send 100 tADA to `payment2.addr` from our UTXO containing 499498404313 lovelaces.

	$ expr 499498404313 - 100000000 - 167965
	499398236348

 The result is the ammount we need to send back to our own `payment.addr`

**BUILD TRANSACTION**

Again, you may want to open a text editor to work on building the transaction, and then when it is ready yo con go to the CLI

	$ cardano-cli shelley transaction build-raw \
		--tx-in e757f08b856c5f12d5784f749c4fc2b1fda8b48299b520f29f6055ce94a5d8cf#0 \
		--tx-out $(cat payment2.addr)+100000000 \
		--tx-out $(cat payment.addr)+499398236348 \
		--ttl 267500 \
		--fee 167965 \
		--out-file tx008.raw


* tx-in  --> the UTXO from where you are sending funds__#TxIx__ from above (0 in this case).
* tx-out --> receiving address (payment2.addr)
* tx-out --> sending the change back
* ttl    --> absolute slot number
* fee    --> the result from calculate-min-fee
* out-file --> the output raw file


**SIGN TRANSACTION**

We use the __payment.skey__ to sign the transaction

	$ cardano-cli shelley transaction sign \
	    --tx-body-file tx008.raw \
	    --signing-key-file payment.skey \
	    --testnet-magic 42 \
	    --out-file tx008.signed


**SUBMIT TRANSACTION**

	$ cardano-cli shelley transaction submit \
	    --tx-file tx008.signed \
	    --testnet-magic 42


**QUERY THE UTXOS OF BOTH ADDRESSES**

	$ cardano-cli shelley query utxo --address $(cat payment.addr) --testnet-magic 42

	                          TxHash                                 TxIx        Lovelace
	----------------------------------------------------------------------------------------
	65bc31936bae87240236e42a73b84d03dc7fd1cee5ac73caff051eeec7a34da0     1                 0
	e36927fe54b4170b60a131cb6195f4c73a2952ea7f88507777f8ee91b682e61d     1      499398236348

	$ cardano-cli shelley query utxo --address $(cat payment2.addr) --testnet-magic 42

	                           TxHash                                 TxIx        Lovelace
	----------------------------------------------------------------------------------------

	e36927fe54b4170b60a131cb6195f4c73a2952ea7f88507777f8ee91b682e61d     0         100000000



Hey, we have moved some funds !! Congratulations. You have finished exercise 2.

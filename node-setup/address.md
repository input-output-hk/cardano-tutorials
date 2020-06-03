# Creating keys and addresses

We need to create two sets of keys and addresses: One set to control our funds (make and receive payments) and one set to control our stake (to participate in the protocol delegating our stake) 

Let's produce our cryptographic keys first, as we will need them to later create our addresses:

### Payment key pair
1. First we need to generate our _payment key pair_:

        cardano-cli shelley address key-gen \
            --verification-key-file payment.vkey \
            --signing-key-file payment.skey

   This will create two files (here named `payment.vkey` and `payment.skey`),
   one containing the _public verification key_, one the _private signing key_.

   The files are in plain-text format and human readable:

        cat payment.vkey

        > type: VerificationKeyShelley
        > title: Free form text
        > cbor-hex:
        >  18af58...

   The first line describes the file type and should not be changed.
   The second line is a free form text that we could change if we so wished.
   The key itself is the cbor-encoded byte-string in the fourth line.
   
### Stake key pair
2. Now let us create our _stake key pair_ : 

		cardano-cli shelley stake-address key-gen \
		--verification-key-file stake.vkey \
		--signing-key-file stake.skey

### Payment address
3. We then use `payment.vkey` and `stake.vkey` to create our `payment address`: 

		cardano-cli shelley address build \
		--payment-verification-key-file payment.vkey \
		--stake-verification-key-file stake.vkey \
		--out-file payment.addr  
     
This created the file payment.addr, let's check its content: 

		cat payment.addr 
		
		> 01ed8...


4. In order to query your address (see the utxo's at that address),
   you first need to set environment variable `CARDANO_NODE_SOCKET_PATH`
   to the socket-path specified in your node configuration. In this example we will use
   the block-producing node created in the previous steps:

        export CARDANO_NODE_SOCKET_PATH=~/cardano-node/block-producing/db/node.socket

   and make sure that your node is running.  Then use

        cardano-cli shelley query utxo \
            --address 01df79ad8d... \
            --testnet-magic 42
	    
	    >                           TxHash                                 TxIx        Lovelace
	    ---------------------------------------------------------------------------------------

__Note__ At this moment there is no balance displayed since we just created this address. Once you get funds you will find the UTXO hash under TxHash, its Index under TxIx and the balance in lovelaces under Lovelace. 

   
(The `--testnet-magic 42` is specific to the FF-testnet, for mainnet we would use `--mainnet` instead.)
   
   
### Stake address
5. Finnaly, we can create our stake address. This address __CAN'T__ receive payments but will receive the rewards from participating in the protocol. We will save this address in the file `stake.addr`

		cardano-cli shelley stake-address build \
		--staking-verification-key-file stake.vkey \
		--out-file stake.addr 

This created the file stake.addr, let's check its content: 

		cat stake.addr 
		
		> 820058... 
		
Our stake address needs to be registered in the blockchain for it to be useful. We deal with that in another tutorial ["Registering stake address to the blockchain"](staking-key.md) 


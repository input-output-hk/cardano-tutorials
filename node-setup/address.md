# Creating an address

We can use the [command line interface](cli.md)
to create an address,
which will enable us to receive and send ada.

1. First we need to generate an _address key pair_:

        cardano-cli shelley address key-gen \
            --verification-key-file addr.vkey \
            --signing-key-file addr.skey

   This will create two files (here named `addr.vkey` and `addr.skey`),
   one containing the _public verification key_, one the _private signing key_.

   The files are in plain-text format and human readable:

        cat addr.vkey

        > type: VerificationKeyShelley
        > title: Free form text
        > cbor-hex:
        >  18af58...

   The first line describes the file type and should not be changed.
   The second line is a free form text that we could change if we so wished.
   The key itself is the cbor-encoded byte-string in the fourth line.

2. Now we can use the verification key we just created to make an address:

        cardano-cli shelley address build \
            --payment-verification-key-file addr.vkey

        > 820658...

   The "enterprise" address type can just receive payments and does not participate in staking.
   This is fine for the purpose of this tutorial, we will cover staking in other tutorials.
   Note that in recent versions of the command, you should just use `build` rather than `build-enterprise`.

   It is probably a good idea to store this address in a file:

        cardano-cli shelley address build \
            --payment-verification-key-file addr.vkey > addr

   Instead of writing the generated address to the console, 
   this command will store it in file `addr`. 

3. In order to query your address (see the utxo's at that address),
   you first need to set environment variable `CARDANO_NODE_SOCKET_PATH`
   to the socket-path specified in your node configuration. In this example we will use
   the block-producing node created in the previous steps:

        export CARDANO_NODE_SOCKET_PATH=~/cardano-node/block-producing/db/node.socket

   and make sure that your node is running.  Then use

        cardano-cli shelley query filtered-utxo \
            --address 820658... \
            --testnet-magic 42

   (The `--testnet-magic 42` is specific to the FF-testnet, for mainnet we would use `--mainnet` instead.)

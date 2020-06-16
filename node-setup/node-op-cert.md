# Creating an Operational Node Certificate

With the setup described in previous tutorials,
our node was able to synchronize with the blockchain and process [transactions](tx.md),
but it was not able to _produce blocks_.
A block producing node needs a _cold key pair_, a _KES key pair_, a _VRF key pair_ and an _operational node certificate_.
In this tutorial we will see how to generate those keys and the certificate and how to start a node that is configured to use them.

1. We assume that you have access to the [command line interface](cli.md).
   First of all, we want to create a _cold key pair_ for our node.

   __This key pair is called "cold", because ideally, it will be created and stored offline, not on a computer that is connected to the internet,
   let alone on the computer running the node.__

   The reason for this is security: Under no circumstances must these keys fall into the wrong hands!

   To create such a key pair (on our offline computer), we type

        cardano-cli shelley node key-gen \
            --cold-verification-key-file node.vkey \
            --cold-signing-key-file node.skey \
            --operational-certificate-issue-counter issue-counter.cert

   This will create three files (which we named `node.vkey`, `node.skey` and `issue-counter.cert` here, but you can choose those names freely),
   one for the (public) verification key, one for the (private) signing key and one for the "operational certificate counter".
   The counter will keep track of the number of certificates you have issued, so that each certificate can get the correct "serial number".

2. We continue by creating a _VRF key pair_ (where "VRF" stands for _Verifiable Random Function_).
   This key will be used by our node to participate in the "lotteries" which determine
   which node has the right to create a block in each slot:

        cardano-cli shelley node key-gen-VRF \
            --verification-key-file vrf.vkey \
            --signing-key-file vrf.skey

   The verification key will be saved to `vrf.vkey`, the signing key to `vrf.skey`. You can choose different names if you like.

3. Let us create our first _KES key pair_ next! KES stands for _Key Evolving Signature_, which means that the key "evolves" (changes)
   automatically after each "period". The length of a period (in slots) is specified in the genesis file:

        "slotsPerKESPeriod": 3600

   So with this configuration, the key would change every 3600 slots, and the old key would be "thrown away". This happens for security reasons,
   because it means that even if the key gets compromised, it can't be used to retroactively sign blocks from previous periods.

   We create a fresh KES key pair as follows:

        cardano-cli shelley node key-gen-KES \
            --verification-key-file kes.vkey \
            --signing-key-file kes.skey

   This will save the verification key to `kes.vkey` and the signing key to `kes.skey`.
   You can of course choose different names for those files if you like.

4. Now we can create an operational node certificate:

We have learned that  `"slotsPerKESPeriod": 3600`

So one period lasts 3600 slots. What is the current tip of the blockchain?,
We can use our node to query the tip:

    export CARDANO_NODE_SOCKET_PATH=path/to/node-socket
    cardano-cli shelley query tip --testnet-magic 42
    > Tip (SlotNo {unSlotNo = 432571}) ...

Look for Tip `unSlotNo` value. In this example we are on slot 432571. so now we can calculate KES period:

    expr 432571 / 3600
    > 120

With this information we can generate our opertional certificate:

    cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter issue-counter.cert \
    --kes-period 120 \
    --out-file shelley-op.cert


   This will create a certificate and save it to file `shelley-op.cert`.
   It will update the "serial number" saved in the previously generated `issue-counter.cert`,
   and it will link our secure "cold" key to the operational "hot" KES key.

5. After all this work, we can move the KES- and VRF- keys and the certificate to the computer running our node and start the node as follows:

        cardano-node run \
            --topology ... \
            --database-path ... \
            --socket-path ... \
            --port ...
            --config ... \
            --shelley-kes-key kes.skey \
            --shelley-vrf-key vrf.skey \
            --shelley-operational-certificate shelley-op.cert

   The first parameters are all as [before](ekg.md), only the last three are new: We pass the VRF- and KES-signing keys and the certificate to the node.

   Our node will include this certificate in the header of each block it creates,
   and it will sign each such block with the KES key.

   The KES key will evolve for 120 periods, which is also specified in our genesis file:

        "maxKESEvolutions": 120

   So after `120 * 3600` slots (5 days), the KES key will become invalid.
   (These are the parameters for the FF-testnet. KES keys on the mainnet will be valid for 90 days.)

   Before the end of that period, we will have to repeat steps 3.-5. to generate a new KES key pair, create a certificate for it and run our node with the new key and new certificate.

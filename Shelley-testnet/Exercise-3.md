# Shelley Stakepool Exercise Sheet 3

LATEST TAG: 1.14.2

## Starting a Stake Pool: First Steps

In the second exercise, we submitted transactions to the Testnet blockchain.  In this exercise, we will set up our own stake pool and relay, so that we can delegate stake later.

### Prerequisites

1. Complete Exercise Sheet Two. You should be able to:

    a. Start a node;

    b. Generate keys;

    c. Build, sign and submit basic transactions.

2. Read the Cardano Tutorials and General Documentation on Stake Pools,  Key generation, Operational Certificates and Key Evolving Signatures at:

    a. https://github.com/input-output-hk/cardano-tutorials/

    b. https://testnets.cardano.org/

4. Checkout the latest version of the Shelley node and CLI from source, and rebuild and reinstall them if they have changed:

```
git checkout tags/1.14.2
git branch
> * (HEAD detached at 1.14.2)
…
cabal install cardano-node cardano-cli
cardano-node --version
> cardano-node 1.14.2 - linux-x86_64 - ghc-8.6
```

4. Create two new directories pool and relay, and copy the configuration files to them:
```
mkdir pool
mkdir relay
cp -a ff-{topology,genesis,config}.json pool
cp -a ff-{topology,genesis,config}.json relay
```
These can be anywhere in your filesystem that you have write access to.  The tutorial suggests that you create them within your local git repository, but you may not want to do that, since if you ever  re-clone the sources from github,  you will overwrite them.


### Objectives

In the third exercise, we will make sure that you can:

1.  Set up the keys for a relay and a stake pool;
2.  Handle the Key Evolving Signature Scheme;
3.  Start the relay and the stake pool.

As before, if you have any questions or encounter any problems, please feel free to use the dedicated Cardano Forum channel.  IOHK staff will be monitoring the channel, and other pool operators may also be able to help you.


Please report any bugs or issues through the relevant github repository.


### Exercises

1. To provide extra security on the Shelley network, we will use a key evolving signature (KES) scheme. This helps protect the network against an attacker being able to reuse compromised keys from one or more stake pools to sign new blocks, and so potentially take control of the Cardano Blockchain.  To make this work, you will need two sets of keys to run your stakepool: a set of master (cold) keys and a set of current block signing (hot) keys.  The KES mechanism is used to create new hot keys on a periodic basis from the cold keys.  The necessary keys can all be produced from the command line.

First produce the KES key pair:
```
cardano-cli shelley node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey
```
On the mainnet, block signing keys will be forced to evolve every 90 days (that is, you will need to generate a new set of hot keys roughly every 3 months).  On the testnet, they will evolve more frequently (roughly every 5 days, as defined in the genesis block).  As a stakepool operator you will need to update your block signing keys whenever they expire.


2. Create a new directory to hold your cold keys
```
mkdir ~/cold-keys
pushd ~/cold-keys
```
Then generate a pair of cold keys and a cold counter file:
```
cardano-cli shelley node key-gen \
    --cold-verification-key-file cold.vkey \
    --cold-signing-key-file cold.skey \
    --operational-certificate-issue-counter cold.counter
```
The cold counter file should look like:
```
type: Node operational certificate issue counter
title: Next certificate issue number: 0
cbor-hex:
 00
```

3. We now have all the components that we need to create the operational certificate for your pool.  You will need to pass in the hot KES verification key file that you generated in Step 1, the cold signing key from step 2, and you will also need to specify the period for which the KES key will be valid.  Here we choose 10,000, but you should choose a valid period.
```
pushd +1
export KES_PERIOD=10000
cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file ~/cold-keys/cold.skey \
    --operational-certificate-issue-counter ~/cold-keys/coldcounter \
    --kes-period ${KES_PERIOD} \
    --out-file node.cert
```
You will need to regenerate the hot keys and issue a new operational certificate (rotate the KES keys) whenever the hot keys expire.  Otherwise you will no longer be able to sign blocks.

4. Having created the hot keys, we will now make sure that no-one can access our cold keys.
```
 chmod a-rwx ~/cold-keys
```

This ensures that noone (including yourself) can read/modify your cold keys.  Whenever you need to create a new set of hot keys, you will need to:
```
 chmod u+rwx ~/cold-keys
 cardano-cli shelley node issue-op-cert ...
 chmod a-rwx ~/cold-keys
```

5. Generate a VRF key pair for your new stake pool, in the same way as we did before.
```
cardano-cli shelley node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
```

6. We can now set up our stake pool using the operational certificate and stake pool KES and VRF signing keys that you have generated.  Your stake pool should be connected to the relay node but not to any external node.  This will isolate your stake pool from general network traffic and improve its ability to create blocks.  You will need to alter the standard topology file for the pool to do this.  Copy the standard topology file and add in the following:

```
    ...
    "Producers": [
      {
        "addr": "127.0.0.1",
        "port": 4242,
        "valency": 1
      }
    ]
```
The port can be anything you like, provided that the relay and pool agree on what is needed, and provided that it is not a system port (port 1024 and below are usually reserved for specific services, for example).  For the relay, you will want to add:
```
    ...
    "Producers": [
      {
        "addr": "127.0.0.1",
        "port": 4240,
        "valency": 1
      },
      {
        "addr": "relays-new.ff.dev.cardano.org",
        "port": 3001,
        "valency": 1
      }
    ]
    ...
```

Choose any port that you like.


7. Now start the relay, exactly as you have done for a node before.
```
# relay
cardano-node run \
    --config ... \
    ... \
    --port 4242
```

8. Note that the pool needs additional KES and VRF signing keys and the operational certificate that you created above.  You will probably want to open a second Linux terminal window.
```
# pool
cardano-node run \
    --config ... \
    ... \
    --shelley-kes-key ... \
    --shelley-vrf-key ... \
    --shelley-operational-certificate ... \
    --port 4240
```

9. Check that your two nodes are properly connected to each other, that the relay node is responding to external requests, and that both the relay and the pool are syncing to the blockchain.  Congratulations, you now have a functioning system that can be used to base your pool operations on!


10. Optional Exercise (Medium).

The whole point of the KES mechanism is to place the pool’s master keys in cold storage, so that they cannot be compromised. While we are just testing the system, we do not need to be quite so cautious, since we can easily regenerate new cold keys and start a new pool.  In this exercise we will simulate the hot key/cold key process.

Create a new user account on a second physical or virtual machine, and install the cardano-cli and cardano-node binaries (if your system is sufficiently similar to the first one, you may be able to simply copy the binaries that you have previously built, rather than building them from scratch, but remember to keep these up to date).   Generate cold keys and the operational certificate on the second machine, and copy these over to your first system.  Repeat this every time the hot keys expire.  This gives separation between the system that is running the live stake pool and the one that is holding the cold keys.  To ensure maximum security, you should generate cold keys and operational certificates on a system that is not connected to the internet, and use e.g. a secure USB key to transfer the required certificates to your online stake pool system.


11. Optional Exercise (Easy).

Extend your topology file so that you are connecting to a few other peers, and not just to the IOHK Testnet relays.  Confirm that you are receiving blocks.  If you are feeling brave, create a different configuration that doesn’t include the IOHK Testnet relays.


12. Optional Exercise (Easy).

Run your relay and pool independently.  This can either be on different physical/virtual machines, or in separate user accounts on the same machine.  You will probably find it is easiest to maintain a single build, and copy binaries as you update them, but take care to ensure that you always have consistent versions for your pool and relay.


13.  Optional Exercise (Easy).

Inspect the Genesis JSON file.  This contains the key settings for the Testnet Blockchain. Do you know what each of the parameters does?  If not, ask one of your peers.


14.  Optional Exercise (Easy).

Similarly, inspect the Configuration JSON file.  This contains the settings for your node. As with the Genesis file, make sure you know what each of the parameters does, and if not, ask one of your peers.


You now have a setup that will let you run a pool and have gained experienced with the node and CLI, but we have not set up a proper staking key and we have not yet registered the pool on-chain, so it is not possible to delegate to it, or to produce any blocks.  We have made good progress, but there will certainly be more Bears that we will encounter!

In the next exercise, we will set up staking keys and use the official staking commands to delegate funds to different pools.


### Feedback

Please provide any feedback or suggested changes to the tutorials or exercises by either raising an issue on the [cardano-tutorials repository](https://github.com/input-output-hk/cardano-tutorials) or by forking the repository and submitting a PR.

Please provide any feedback or suggested changes on the node itself by raising an issue at the [cardano-node repository](https://github.com/input-output-hk/cardano-node).

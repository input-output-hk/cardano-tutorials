# Shelley Stakepool Exercise Sheet 1

LATEST TAG: 1.13.0

## Getting Started

Welcome to the Shelley Testnet!  We are excited that you have joined us on this adventure. In this testnet phase, we will been running through a series of structured tests on the new Haskell Shelley node with you so that we can improve the experience for all stakepool operators and other Cardano users. At this stage, the software and documentation are both very new, so please help us fill any gaps and make improvements. Your feedback is essential and you can play a key role in helping us to identify these gaps and make improvements.

### Prerequisites

1. Make sure you can access:
    - [The Cardano Tutorial Documentation](https://github.com/input-output-hk/cardano-tutorials/tree/master/node-setup)
    - [Shelley Testnet Documentation](https://testnets.cardano.org/en/shelley-haskell/overview/)
    - [Cardano Node Github repository](https://github.com/input-output-hk/cardano-node) where you can find:
    - [Shelley Genesis Documentation](https://github.com/input-output-hk/cardano-node/blob/master/doc/shelley-genesis.md)

2. Subscribe to:
    - [The Staking/Delegation Area on the Cardano Forum](https://forum.cardano.org/c/stakingdelegation/116)

  You should be comfortable with using Linux shell commands and have a basic understanding of cryptography and the Cardano ecosystem.

5. Set up your platform:
  - You will need an x86 host (AMD or Intel), Virtual Machine or AWS instance with at least 2 cores, 4GB of RAM and at least 10GB of free disk space (more may be helpful - 30GB is recommended);
  - You will need to install a recent version of Linux (We have tested it in Ubuntu 18.04 and 20.04, Fedora 30 and CentOS 8) We are not supporting Windows or MacOS at this moment – this will help us isolate any issues that arise;
  - You will need to install: git, ghc, cabal.  Please make sure you install the correct versions (currently GHC 8.6.5 and Cabal 3.0).

6. Make sure you are on a network that is not firewalled. In particular, we will be using TCP/IP port 3001 by default to establish connections with other nodes, so this will need to be open.

### Objectives

In the first exercise, we will ensure that you can:

1. set up and run a Cardano node
2. connect to the Testnet Shelley blockchain in OBFT mode
3. request some test ada to use in the testnet.

This should be everything that you need to get you up and running.

### Exercises

1. Download, Build and Install the Cardano Node Software using the instructions in the [Cardano Tutorial](../node-setup/000_install.md).  You may need to do this repeatedly, so you may want to bookmark the instructions.  You will need to use the correctly tagged version at each stage. The most recent tag at the time of writing is 1.13.0.

2. Download the genesis, topology, and configuration files, as described in the tutorial.


 wget …

3. Start the node using the configuration files, the testnet magic, and the other configuration settings, as shown in the tutorial.


    cardano-node run --config …


4. Check that your instance of the node is properly connected to the Testnet and is verifying the blocks that are produced, as described in the tutorial.

  Congratulations!  You now have a working node that is connected to the first-ever public Shelley Cardano network! In our later exercises, we will first use this to submit transactions, and then set up a working stake pool, so that you can produce blocks yourself.

5. Use the node CLI commands to generate an address key, utxo.txt, that will be used to provide you with funds.

   - [Tutorial on making an address](../node-setup/020_keys_and_addresses.md)

6. Request funds from the faucet with


    curl -v -XPOST “https://faucet.ff.dev.cardano.org/send-money/$(cat payment.addr)"


You can also hit it once a day without the API key to get 1K.

Extra funds can be returned to

    00677291d73b71471afa49fe2d20b96f7227b05f863dafe802598964533e0dc3bc0cf7eb8153441db271a2288560378b209014350792f273bdc307f06ca34f0c6f

### Optional exercise (moderately hard).

- Generate two sets of operational certificates and VRF keys, and set up the Key Evolving Signature Scheme (KES), as defined in the tutorial, start up two nodes (one with each set of certificate/keys), and connect your nodes so that they form a small self-network.
  https://github.com/input-output-hk/cardano-node/blob/master/doc/shelley-genesis.md

The next Shelley Testnet exercise will involve building, signing, and submitting simple transactions using your own node.

### Feedback

Please provide any feedback or suggested changes to the tutorials or exercises by either raising an issue on the [cardano-tutorials repository](https://github.com/input-output-hk/cardano-tutorials) or by forking the repository and submitting a PR.

Please provide any feedback or suggested changes on the node itself by raising an issue at the [cardano-node repository](https://github.com/input-output-hk/cardano-node).

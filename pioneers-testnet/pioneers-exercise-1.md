# Shelley Stakepool Pioneers Exercise Sheet 1

## Getting Started

Welcome to the IOHK Pioneers Group!  We are excited that you have joined us on this adventure.  In the coming days, we will be running through a series of structured tests on the new Haskell Shelley node with you so that we can improve the experience for all stakepool operators and other Cardano users. At this stage, the software and documentation are both very new, so please help us fill any gaps and make improvements. Your feedback is essential and you can play a key role in helping us to identify these gaps and make improvements.

### Prerequisites

1. Attend the Pioneer briefing meeting or read the Pioneer briefing notes

2. Read the Code of Conduct.  This governs your behaviour and responsibilities on the Pioneer testnet.

3. Register on Telegram and provide IOHK with your Telegram handle.  We will use a dedicated Telegram channel as our main point of contact.

4. Make sure you can access:
    - [The IOHK Tutorial Documentation](https://github.com/input-output-hk/cardano-tutorials/tree/master/node-setup)
    - [Shelley Testnet Documentation](https://testnets.cardano.org/en/shelley-haskell/overview/)
    - [Cardano Node Github repository](https://github.com/input-output-hk/cardano-node) where you can find:
      - [Shelley Genesis Documentation](https://github.com/input-output-hk/cardano-node/blob/master/doc/shelley-genesis.md)

  You should be comfortable with using Linux shell commands and have a basic understanding of cryptography and the Cardano ecosystem.

5. Set up your platform:
  - You will need an x86 host (AMD or Intel), Virtual Machine or AWS instance with at least 2 cores, 4GB of RAM and at least 10GB of free disk space;
  - You will need to install a recent version of Linux, not Windows or MacOS – this will help us isolate any issues that arise;
  - You will need to install: git, ghc, cabal.  Please make sure you install the correct versions (currently GHC 8.6.5 and Cabal 3.0).

6. Make sure you are on a network that is not firewalled. In particular, we will be using TCP/IP port 3001 by default to establish connections with other nodes, so this will need to be open.

### Objectives

In the first exercise, we will ensure that you can:

1. set up and run a Cardano node
2. connect to the Pioneer Testnet Shelley blockchain in OBFT mode
3. request some test ada to use in the testnet.

This should be everything that you need to get you up and running.

### Exercises

1. Download, build, and install the Cardano node software using the instructions provided in the [IOHK Tutorial](https://github.com/input-output-hk/cardano-tutorials/tree/master/node-setup).  You will need to do this repeatedly as the Pioneer testnet progresses, so you may want to bookmark the instructions. We will be updating the software regularly.  You will need to use the correctly tagged version at each stage. Generally, you will be able to use the version that is tagged “latest” in the GitHub repository.

2. Start the node using the genesis, topology, network, and other configuration settings that will be given to you by IOHK. Follow the instructions in the IOHK tutorial. 
  
```bash
 cardano-node run --config …
```

1. Check that your instance of the node is properly connected to the Pioneer testnet and is verifying the blocks that are produced, as described in the IOHK tutorial.

  Congratulations!  You now have a working node that is connected to the first-ever public Shelley Cardano network! In our later exercises, we will first use this to submit transactions, and then set up a working stake pool, so that you can produce blocks yourself.

4. Use the node CLI commands to generate an address key, utxo.txt, that will be used to provide you with funds.  Extract the address from your address key key as described in the IOHK tutorial (linked above), and record it in this [Google Doc](https://docs.google.com/spreadsheets/d/1o62S2_24bcZNIpT3FASKHVGHG-dQ4J0vDaVCEsxbVKU/edit?usp=sharing).

   - [Tutorial on making an address](https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/address.md)

5. Confirm on [SurveyMonkey](https://www.surveymonkey.co.uk/r/S9N5M5H) that you have successfully completed this exercise, and provide your feedback on any problems that you have encountered.  Once we are happy that all the Pioneers have installed the node and perfomed a test run of the node, and that we have ironed out any issues that you experience, we will progress to the next step: building and submitting transactions.

### Optional exercise (moderately hard).

- Generate two sets of operational certificates and VRF keys, and set up the Key Evolving Signature Scheme (KES), as defined in the tutorial, start up two nodes (one with each set of certificate/keys), and connect your nodes so that they form a small self-network.
  https://github.com/input-output-hk/cardano-node/blob/master/doc/shelley-genesis.md

The next Pioneer testnet exercise will involve building, signing, and submitting simple transactions using your own node.

### Feedback

Please provide any feedback or suggested changes by either raising an issue on the [cardano-tutorials repository](https://github.com/input-output-hk/cardano-tutorials) or by forking the repository and submitting a PR.

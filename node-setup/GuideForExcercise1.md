# Installing and Running a Node: A quick guide


## REQUISITES

Set up your platform:

You will need:

* An x86 host (AMD or Intel), Virtual Machine or AWS instance with at least __2 cores, 4GB of RAM and at least 10GB of free disk space;__
* A recent version of Linux, __not Windows or MacOS__ – this will help us isolate any issues that arise;
* Make sure you are on a network that is not firewalled. In particular, we will be using TCP/IP port 3000 and 3001 by default to establish connections with other nodes, so this will need to be open.

If you are not sure on how to configure your server, please read the [Getting access to Linux at AWS](https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/AWS.md) tutorial. 

## Install dependencies

We need the following packages and tools on our Linux system to download the source code and build it:
    - the version control system ``git``,
    - the ``gcc`` C-compiler,
    - C++ support for ``gcc``,
    - developer libraries for the the arbitrary precision library ``gmp``,
    - developer libraries for the compression library ``zlib``,
    - developer libraries for ``systemd``,
    - developer libraries for ``ncurses``,
    - ``ncurses`` compatibility libraries,
    - the Haskell build tool ``cabal``,
    - the GHC Haskell compiler.

If we are using an AWS instance running Amazon Linux AMI 2 (see the [AWS walk-through](AWS.md) for how to get such an instance up and running)or another CentOS/RHEL based system, we can install these dependencies as follows:

    sudo yum update -y
    sudo yum install git gcc gcc-c++ tmux gmp-devel make tar wget zlib-devel -y
    sudo yum install systemd-devel ncurses-devel ncurses-compat-libs -y

For Debian/Ubuntu use the following instead:
   
        
    sudo apt-get update -y
    sudo apt-get -y install build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 -y
   
If you are using a different flavor of Linux, you will need to use the package manager suitable for your platform instead of `yum` or `apt-get`, and the names of the packages you need to install might differ.

Download, unpack, install and update Cabal:

    wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
    tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
    rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig
    mkdir -p ~/.local/bin
    mv cabal ~/.local/bin/
    cabal update

This will work on a fresh [AWS instance](AWS.md) and assumes that folder `~/.local/bin` is in your `PATH`.
On other systems, you must either move the executable to a folder that is in your `PATH` or modify your `PATH` by adding the line

    export PATH="~/.local/bin:$PATH"

to your `.bashrc`-file.

Above instructions install Cabal version `3.2.0.0`. You can check the version by typing

   cabal --version

Finally, we download and install GHC:

    wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz
    tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz
    rm ghc-8.6.5-x86_64-deb9-linux.tar.xz
    cd ghc-8.6.5
    ./configure
    sudo make install
    cd ..

## Download the source code for cardano-node

To download the source code, we use git:
    
    git clone https://github.com/input-output-hk/cardano-node.git
    

This should create a folder ``cardano-node``, then download the latest source code from git into it.
After the download has finished, we can check its content by
  
    ls cardano-node

__Note__ that the content of your `cardano-node`-folder can slightly differ from this!

We change our working directory to the downloaded source code folder:

    cd cardano-node

For reproducible builds, we should check out a specific release, a specific "tag". 
For the FF-testnet, we will use tag `pioneer`, which we can check out as follows:

    git fetch --all --tags
    git checkout tags/pioneer


## Build and install the node

Now we build and install the node with ``cabal``, 
which will take a couple of minutes the first time you do a build. Later builds will be much faster, because everything that does not change will be cached.

    cabal install cardano-node cardano-cli

__Note__: At the time of writing, there is a bug in the latest version of the software that prevents ``cabal install`` from working correctly. As a workaround, you can use ``cabal build`` instead:

    cabal build all
    cp -p dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-node-1.11.0/x/cardano-node/build/cardano-node/cardano-node ~/.local/bin/
    cp -p dist-newstyle/build/x86_64-linux/ghc-8.6.5/cardano-cli-1.11.0/x/cardano-cli/build/cardano-cli/cardano-cli ~/.local/bin/

The remark about your `PATH` from above applies here as well: Make sure folder `~/.local/bin` is in your path or copy the executables to a folder that is.

If you have old versions of `cardano-node` installed on your system, make sure that the new one will be picked! You can check by typing

    which cardano-node

    > ~/.local/bin/cardano-node

If you ever want to update the code to a newer version, go to the ``cardano-node`` directory, pull the latest code with ``git`` and rebuild. 
This will be much faster than the initial build:

    cd cardano-node
    git fetch --all --tags
    git tag
    git checkout tags/<the-tag-you-want>
    cabal install cardano-node cardano-cli

Note that it might be necessary to delete the `db`-folder (the database-folder) before running an updated version of the node.


## Get genesis, configutarion, topology files, and start the node

To start your node and connect it to F&F testnet you will need three important files: `ff-config.json` `ff-genesis.json` and `ff-topology.json`. We will download them from <https://hydra.iohk.io/build/2622346/download/1/index.html>
		
    wget https://hydra.iohk.io/build/2622346/download/1/ff-config.json 
    wget https://hydra.iohk.io/build/2622346/download/1/ff-genesis.json
    wget https://hydra.iohk.io/build/2622346/download/1/ff-topology.json
    
Now you can start the node, double check that port 3001 is open. In the `cardano-node` directory run:

    cardano-node run \
       --topology ff-topology.json \
       --database-path db \
       --socket-path db/node.socket \
       --port 3001 \
       --config ff-config.json

![](https://github.com/CarlosLopezDeLara/cardano-tutorials/blob/CarlosLopezDeLara-QuickGuide-Excercise1/node-setup/images/starting-single-node.png)

**Cool, you have just connected your node to the F&F Testnet.** 

## Configure block-producing and relay nodes

Let's stop that single node now and do something more interesting.

As stake pool operator, you will have two types of nodes, **block producing nodes** and **relay nodes**. Each block producing node must be accompagnied by several relay nodes.

To be clear: Both types of nodes run exactly the same program, **cardano-node**. The difference between the two types lies in how they are configured and how they are connected to each other:
	
* A **block producing** node will be configured with various key-pairs needed for block generation (cold keys, KES hot keys and VRF hot keys). It will only be connected to its relay nodes.

* A **relay node** will not be in possession of any keys and will therefore be unable to produce blocks. It will be connected to its block producing node, other relays and external nodes.

Each node should run on a dedicated server, and the block producing node's server's firewall should be configured to only allow incoming connections from its relays.

In this tutorial, we will simplify matters by having a block producing node (It won't produce blocks yet), and by using a single relay. For now, we will run both nodes on the same server. 

We have explained how to run a single node, and now you have suitable configuration files `ff-config.json`,`ff-topology.json` and `ff-genesis.json` available.

Both our nodes must use the same `ff-genesis.json`, they can use the same `ff-config.json` (but don't have to), and they need different `ff-topology.json` files.

Let us create separate folders for the two nodes and copy the configuration files to both directories.

    cd cardano-node
    mkdir block-producing
    mkdir relay
    cp ff-config.json ff-genesis.json ff-topology.json block-producing/
    cp ff-config.json ff-genesis.json ff-topology.json relay/


We will run our block-producing node on port 3000 (make sure it is opened) and our relay on port 3001 
(you can of course use different ports if you like)

We must modify the block-producer's `ff-topology.json` to only "talk" to the relay:

Navigate to `/block-producing` and open `ff-topology.json` with your favorite text editor:
 
    {
      "Producers": [
        {
          "addr": "x.x.x.x", # Replace with your public IP
          "port": 3001,
          "valency": 1
        }
      ]
    }
  
In the  `relay/ff-topology.json` we instruct the node to "talk" to the block-producer *and* an external node as before:


	{
	   "Producers": [
	     {
	       "addr": x.x.x.x", # Replace with your public IP
	       "port": 3000,
	       "valency": 1
	     },
	     {
	       "addr": "relays-new.ff.dev.cardano.org",
	       "port": 3001,
	       "valency": 1
	     }
	   ]
	 }
    
To start your nodes on our AWS instance, a terminal multiplexer like [`tmux`](https://github.com/tmux/tmux/wiki) is useful, because it allows us to open different panes in a single terminal window. 

We have already installed `tmux` when we installed dependencies.

You can find a short overview of available commands [here](https://tmuxcheatsheet.com/). 

You start `tmux` with

    tmux new

Then you can split the screen with `Ctrl`-`b`-`%` and navigate between the two panes with `Ctrl`-`b`-`→` and `Ctrl`-`b`-`←`.

![tmux with two panels](https://github.com/CarlosLopezDeLara/cardano-tutorials/blob/CarlosLopezDeLara-QuickGuide-Excercise1/node-setup/images/tmux-view.png)


From one `tmux`-panel we start the block-producing node with the following command. Under `host-addr` replace the x.x.x.x with your public ip

    cardano-node run \
    --topology block-producing/ff-topology.json \
    --database-path block-producing/db \
    --socket-path block-producing/db/node.socket \
    --host-addr x.x.x.x --port 3000 \
    --config block-producing/ff-config.json

The node will start, but it won't receive any data, because we have configured it to only "talk" to the relay node, and we haven't yet started the relay.

We switch to the other `tmux`-panel with `Ctrl`-`b`-`→` and start the relay node with a similar command. Under `host-addr` replace the x.x.x.x with your public ip

    cardano-node run \
     --topology relay/ff-topology.json \
     --database-path relay/db \
     --socket-path relay/db/node.socket \
     --host-addr x.x.x.x \
     --port 3001 \
     --config relay/ff-config.json
                  
After a few seconds, both nodes should receive data.
   
   
   ![tmux with two nodes](https://github.com/CarlosLopezDeLara/cardano-tutorials/blob/CarlosLopezDeLara-QuickGuide-Excercise1/node-setup/images/tmux-2-nodes.png)


Cool, we have put a couple of nodes to work! But this nodes can't do anything more than read from the blockchain. To setup a stake pool and being able to produce blocks we will need a set of keys, addresses, and other things. Let's create some keys first.

## Create key pair and an address

Create a new SSH connection with your server. 
Go to `cardano-node` directory with 
   
    cd cardano-node

We will be using the command line interface`cardano-cli`now. To learn about the usage of this tool type: 
   
    cardano-cli --help

     
We need to generate a __payment key pair__:

    cardano-cli shelley address key-gen \
      --verification-key-file payment.vkey \
      --signing-key-file payment.skey

This will create two files (here named `payment.vkey` and `payment.skey`), one containing the __public verification key__, one the __private signing key__.

The files are in plain-text format and human readable:

        cat payment.vkey

        > type: VerificationKeyShelley
        > title: Free form text
        > cbor-hex:
        >  18af58...

* The first line describes the file type and should not be changed.
* The second line is a free form text that we could change if we so wished.
* The key itself is the cbor-encoded byte-string in the fourth line.
   

Now we can use the verification key we just created to make an address. For now, we will use an address type that can receive and send transactions, but cannot do staking: `enterprise` type. 

    cardano-cli shelley address build-enterprise \
        --payment-verification-key-file payment.vkey

        > 820658...

Let's store this address in a file:

    cardano-cli shelley address build-enterprise \
        --payment-verification-key-file payment.vkey > address

Instead of writing the generated address to the console, this command will store it in file `address`. 
   

To query your address (see the utxo's at that address),you first need to set environment variable `CARDANO_NODE_SOCKET_PATH` to the socket-path specified in your node configuration, we will use our relay node for that.

    export CARDANO_NODE_SOCKET_PATH=relay/db/node.socket      
   
Then use
   
    cardano-cli shelley query filtered-utxo \
        --address 8206582..... \
        --testnet-magic 42
  
 The output should look like this, note that we do not have any funds yet. 
   
   ```
                              TxHash                                 TxIx        Lovelace
----------------------------------------------------------------------------------------
   ```
   
   


Congratulations, you have finished excercise 1 !!

## Node monitoring 

Please read [Monitoring a node with EKG](https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/ekg.md) and [Monitoring a node with Prometheus](https://github.com/input-output-hk/cardano-tutorials/blob/master/node-setup/prometheus.md) tutorials. 



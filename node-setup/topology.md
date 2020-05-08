# Block producers and Relays

There are two types of nodes, _block producing nodes_ and _relay nodes_. 
Each block producing node must be accompagnied by several relay nodes.

To be clear: Both types of nodes run exactly the same program, _cardano-node_.
The difference between the two types lies in how they are configured and how they are connected to each other:

- A block producing nodes will be configured with various key-pairs needed for block generation (cold keys,
  KES hot keys and VRF hot keys). It will only be connected to its relay nodes.

- A relay node will not be in possession of any keys and will therefore be unable to produce blocks.
  It will be connected to its block producing node, other relays and external nodes.

Each node should run on a dedicated server, 
and the block producing node's server's firewall should be configured to only allow incoming connections from its relays.

In this tutorial, we will simplify matters by having a block producing node that can't produce blocks,
by using a single relay
and by running both nodes on the same server.

_This is insecure and only serves demonstration purposes!_

1. We have explained how to run a single node [here](build.md) and [here](ekg.md),
   so we assume that you have suitable configuration files `config.yaml`,
   `topology.json` and `genesis.json` available.

   Both our nodes must use the same `genesis.json`, 
   they can use the same `config.yaml` (but don't have to),
   and they need different `topology.json`-files.

   We can start by creating separate folders for the two nodes and simply copying the configuration files we have:

        cd cardano-node
        mkdir block-producing
        mkdir relay
        cp config.yaml genesis.json topology.json block-producing/
        cp config.yaml genesis.json topology.json relay/

2. We will run our block-producing node on port 8080 and our relay on port 8081
   (you can of course use different ports if you like).

   We must modify the block-producer's topology-file to only "talk" to the relay:

   `block-producing/topology.json`:

        {
           "Producers": [
             {
               "addr": "127.0.0.1",
               "port": 8081,
               "valency": 1
             }
           ]
         }

   In the relay's topology-file we instruct the node to "talk" to the block-producer _and_ an external node as before:

   `relay/topology.json`:

        {
           "Producers": [
             {
               "addr": "127.0.0.1",
               "port": 8080,
               "valency": 1
             },
             {
               "addr": "relays-new.cardano-mainnet.iohk.io",
               "port": 3001,
               "valency": 1
             }
           ]
         }

   In our case we can use `127.0.0.1:8080` for the producer and `127.0.0.1:8081` for the relay. 
   In a real scenario, you would use the public IP-addresses of your servers instead.

3. In order to start our nodes on our AWS instance, a terminal multiplexer like [`tmux`](https://github.com/tmux/tmux/wiki)
   is useful, because it allows us to open different panes in a single terminal window.
   You can install `tmux` using

        sudo yum install tmux -y

   You can find a short overview of available commands [here](https://tmuxcheatsheet.com/). You start `tmux` with

        tmux new

   Then you can split the screen with `Ctrl`-`b`-`%` and navigate between the two panes with `Ctrl`-`b`-`→` and `Ctrl`-`b`-`←`.

   ![tmux with two panels](images/tmux.png)

4. From one `tmux`-panel we start the block-producing node with

        cardano-node run \
            --topology block-producing/topology.json \
            --database-path block-producing/db \
            --socket-path block-producing/db/node.socket \
            --host-addr 127.0.0.1 \
            --port 8080 \
            --config block-producing/config.yaml

   The node will start, but it won't receive any data, because we have configured it to only "talk" to the relay,
   and we haven't yet started the relay.

5. We switch to the other `tmux`-panel and start the relay node with

        cardano-node run \
            --topology relay/topology.json \
            --database-path relay/db \
            --socket-path relay/db/node.socket \
            --host-addr 127.0.0.1 \
            --port 8081 \
            --config relay/config.yaml

   After a few seconds, both nodes should receive data.

   ![Block-producing node and relay node running in parallel](images/producer-relay.png)



# Shelley Stakepool Exercise 3

## Objectives

* Set up the keys for a relay and a stake pool;
* Handle the Key Evolving Signature Scheme;
* Start the relay and the stake pool.


A good setup for a stake pool is to have (at least) one block-producing node connected __(only)__ to at least one realay node under the control of the stake pool operator, and each relay node connected to other realy nodes in the network. Each node should run on a separate server.

![network diagram](producer-relay-diagram.png)

First, we need to setup our __block-producing node__. You can build the node from source or maintain a single build on your relay and copy the binaries to your block-producing node. Just make sure you have consistent versions across them.

### Basic block-producing node firewall configuration:

* Make sure you can only login with SSH Keys, not password.
* Make sure to setup SSH connections in a port different than the the default 22
* Make sure to configure the firewall to only allow connections from your relay nodes by setting up their ip addresses.

### Basic relay node firewall configuration:

 * Make sure you can only login with SSH Keys, not password.
 * Make sure to setup SSH connections in a port different than the default 22.
 * Make sure you only have the strictly necessary ports opened.

## Crating keys for our block-producing node

(This assumes you already have the binaries on your server.)

Our __block-producing node__ or __pool node__ needs a __VRF__ Key pair, a __KES__ Key pair, a __Cold__ key pair and an __Operational Certificate__

Let's establish an SSH connection with our server

    ssh -i ~/.ssh/id_rsa <USER>@<PUBLIC IP> -p <SSH PORT>

We are in, now, let's create a directory to store the keys that we will generate:

    mkdir keys
    cd keys

Now, generate the KES Key pair

    cardano-cli shelley node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey

and our VRF Key pair

    cardano-cli shelley node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey

It is time to generate our __Cold__ Keys and a __Cold_counter__ file:

    cardano-cli shelley node key-gen \
    --cold-verification-key-file cold.vkey \
    --cold-signing-key-file cold.skey \
    --operational-certificate-issue-counter coldcounter

Finnaly, we can generate our __Operational Certificate__

To tho that, first We need to know the slots per KES period, we get it from the genesis file:

    cat ff-genesis.json | grep KESPeriod
    > "slotsPerKESPeriod": 3600,

So one period lasts 3600 slots. What is the current tip of the blockchain?,
We can use your relay node (from Exercise 2) to query the tip:

    export CARDANO_NODE_SOCKET_PATH=path/to/node-socket
    cardano-cli shelley query tip --testnet-magic 42
    > Tip (SlotNo {unSlotNo = 432571}) ...

Look for Tip `unSlotNo` value. In this example we are on slot 432571. So in this example we have KES period is 120:

    expr 432571 / 3600
    > 120

With this information we can generate our opertional certificate:

    cardano-cli shelley node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file cold.skey \
    --operational-certificate-issue-counter coldcounter \
    --kes-period 120 \
    --out-file opcert

## Copy the keys to a secure storage.

Lets copy our keys to our local machine and from there to cold storage.From another terminal in your __local machine__ do:

    scp -rv -P<SSH PORT> -i ~/.ssh/id_rsa <USER>@<PUBLIC IP>:~/keys ~/pool-keys

    > Transferred: sent 3220, received 6012 bytes, in 1.2 seconds
    Bytes per second: sent 2606.6, received 4866.8
    debug1: Exit status 0

And verify that the files are there:

    ls pool-keys/keys

    > coldcounter  cold.skey  cold.vkey  kes.skey  kes.vkey  vrf.skey  vrf.vkey


__NOTE__ The best place for your cold keys is a SECURE USB or other SECURE EXTERNAL DEVICE, not a computer with internet access. So, move your cold keys to cold storage and delete the files from your local machine.       

### Delete the Cold Keys from the server.

Back to our __server__, now we can delete the __Cold Keys__ from here:

    rm cold*

And verify that they are gone:

    ls

    > kes.skey  kes.vkey  vrf.skey  vrf.vkey opcert

### Configure topology files for block-producing and relay nodes.

Get the configuration files for your block-producing node if you dont have them already:

    mkdir config-files
    cd config-files     

    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-config.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-genesis.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-topology.json


Lets make our __block-producing__ node to "talk" only to our relay node

	nano ff-topology.json

	{
	  "Producers": [
	    {
	      "addr": "<RELAY NODE PUBLIC IP",
	      "port": 3001,
	      "valency": 1
	    }
	  ]
	}

No we open an SSH connection to our __Relay node__ (if you haven't already) and add our __Block-producing node__ to the topology file.
This is a good moment to add also other relay nodes in the network.

    nano ff-topology.j	son


	{
		"Producers": [
			{
			   "addr": "<BLOCK-PRODUCING NODE IP",
		      "port": 3001,
		      "valency": 1
			},
			{
				"addr": "<IP ADDRESS>",
				"port": <PORT>,
				"valency": 1
			},
			{
				"addr": "<IP ADDRESS>",
				"port": <PORT>,
				"valency": 1
			}
		]
	}

### Start your system

First we restart our __relay node__ with:

	~$ cardano-node run \
	 --topology path/to/ff-topology.json \
	 --database-path path/to/db \
	 --socket-path path/to/db/node.socket \
	 --host-addr <PUBLIC IP> \
	 --port 3001 \
	 --config path/to/ff-config.json

then, we start our __block producing__ node with:

	~$ cardano-node run \
	--topology keys/ff-topology.json \
	--database-path /db \
	--socket-path /db/node.socket \
	--host-addr <PUBLIC IP> \
	--port 3001 \
	--config config-files/config.json
	--shelley-kes-key keys/kes.skey
	--shelley-vrf-key keys/vrf.skey
	--shelley-operational-certificate keys/opcert


And we are done !

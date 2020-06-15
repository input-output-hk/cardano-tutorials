# Configure topology files for block-producing and relay nodes.

Before we register our stake pool, let's configure our __block-producing__ and __relay__ nodes:

__NOTE:__ Here you can find peers to connect to, and submit your own stake pool data:  https://github.com/input-output-hk/cardano-ops/blob/master/topologies/ff-peers.nix#L5-L10

### Configure the block-producing node

Get the configuration files for your block-producing node if you don't have them already, for example

    mkdir config-files
    cd config-files     

    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-config.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-genesis.json
    wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/ff-topology.json

Make the __block-producing__ node to "talk" only to __YOUR__ relay node. Do not forget to configure your firewall also:

    nano ff-topology.json

  	{
  	  "Producers": [
  	    {
  	      "addr": "<RELAY NODE PUBLIC IP",
  	      "port": <PORT>,
  	      "valency": 1
  	    }
  	  ]
  	}

### Configure the relay node:

Make your __relay node__ `talk` to your __block-producing node__ and `other relays` in the network by editing the `ff-topology.json` file.

This is a good moment to add other relay nodes in the network.  

    nano ff-topology.json

  	{
  		"Producers": [
  			{
  			   "addr": "<BLOCK-PRODUCING NODE IP",
  		      "port": <PORT>,
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

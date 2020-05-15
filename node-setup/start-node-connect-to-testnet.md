# How to start the node and connect it to the testnet.

Starting the node and connecting to the network requires 3 important files: 

* topology,json
* genesis.json
* config.json

You can download them [here](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html).

Or from the command line with: 

    wget https://hydra.iohk.io/build/2628541/download/1/ff-topology.json
    wget https://hydra.iohk.io/build/2628541/download/1/ff-genesis.json
    wget https://hydra.iohk.io/build/2628541/download/1/ff-config.json
    
## The topology.json file

Tells your node to which nodes in the network it should talk to. A minimal version of this file looks like this: 


	{
	  "Producers": [
	    {
	      "addr": "relays-new.ff.dev.cardano.org",
	      "port": 3001,
	      "valency": 1
	    }
	  ]
	}

* This means that your node will contact `relays-new.ff.dev.cardano.org` on `port 3001`. 

* `valency` tells the node how many connections your node should have. It only has an effect for dns addresses. If a dns asdress is given, valency governs to how many resolved ip addresses should we maintain acctive (hot) connection; for ip addresses, valency is used as a boolean value, where `0` means to ignore the address.


## The genesis.json file

The genesis file is generated with the `cardano-cli` by reading a `genesis.spec.json` file, which is out of scope for this document. 
But it is important because it is used to set:

* `genDelegs`, a mapping from genesis keys to genesis delegates.
* `initialFunds`, a mapping from the initial addresses to the initial values at those address. 
* `MaxLovelaceSupply`, the total amount of lovelaces in the blockchain.  
* `startTime`, the time of slot zero.

The `genesis.json` file looks like the one below.

	{
	  "activeSlotsCoeff": 0.05,
	  "protocolParams": {
	    "poolDecayRate": 0,               
	    "poolDeposit": 500000000,         
	    "protocolVersion": {
	      "minor": 0,
	      "major": 0
	    },
	    "decentralisationParam": 0.5,
	    "maxTxSize": 16384,               
	    "minFeeA": 44,                                  
	    "maxBlockBodySize": 65536,        
	    "keyMinRefund": 0,                
	    "minFeeB": 155381,                 
	    "eMax": 1,                         
	    "extraEntropy": {
	      "tag": "NeutralNonce"
	    },
	    "maxBlockHeaderSize": 1400,
	    "keyDeposit": 400000,              
	    "keyDecayRate": 0,                 
	    "nOpt": 50,                        
	    "rho": 0.00178650067,              
	    "poolMinRefund": 0,                
	    "tau": 0.1,                        
	    "a0": 0.1                          
	  },
	  "protocolMagicId": 42,
	  "startTime": "2020-05-12T20:15:00.000000000Z", # Time of slot 0                                   
	  "genDelegs": {                       
	    "c1f35a67ff923bf2637a3ce75413bec24e97b4fdacb7f654ec248c3a23a2b1a3": "067696862f671a83fb64490938826466e530b8bc340e937d4931b4051020f58e",
	    "18c6ff0bd626e4728c3c1d2b171d8610109e74404e857f5cffc112784d74642c": "1d847f1e3d6ed31430435597802cd79e6566b64a29c857e42a3c3b8717986a22",
	    "1e5a4f62ccbad10b0a004717cb3f099ef43e8ca3a7554a9b71afa839606bdf20": "1f5f0e1aea3a320cd443d82959531fa7a8b1f4c6fe966018154e129dbbd57ff1"
	  },
	  "updateQuorum": 3,                                              
	  "maxMajorPV": 0,                    
	  "initialFunds": {                    
	    "8206582025b36d57e010f92c3d6f806c790a56026e89c51ed1e6fa5e0c3e5ba353b1e0f1": 1e+16,
	    "82065820a91a7b8edb303c02fd89a47b7e8260d068e5a7bc2ca03df0cfe7a3d3fa33d32b": 1000000000000,
	    "82065820a7ee278cb040adc655a5cc2e5602ffcb8fd1ad2c59451766edb266a36e66b7e2": 1000000000000,
	    "820658206b0612190830f2b459f5fbf736ac3710bdb7541d6ac1ce2974ad2f8229392647": 1000000000000,
	    "82065820368fc64ab809471aa90ccfc3f69529e1474244d10ff18659d6bca444af3cbcca": 1000000000000,
	    "82065820408410a98b1de8f4b2194c82421f3fa7465de38193d5c09e45dad5c3644a013b": 1000000000000,
	    "8206582061747e62b224446cf83b8718fa40b33e3721e5a3c0a4c3d33bccf0fe776decf9": 1000000000000,
	    "82065820e31324d3244e2830f23bb5d99246fe4cb2c7f5bc790e0cde9c61ce4237ed10a4": 1000000000000,
	    "820658208ead96e6f7e185834775dc8698ab6dde642d72b1c992ccb2406fb773e1bc9e42": 1000000000000,
	    "82065820586c4440e8e1dc7cd20f5521c093b573df079cb902ff2b43d166202343d8b259": 1000000000000,
	    "8206582052446d0019ccc997ea383a5f4c68d47efc8698694957abf53f55cb25277c8ea5": 1000000000000,
	    "82065820156241e0e3458e0374dc291352d028330e677c3cc5f7985dfeec6e6f3a2296c2": 1000000000000,
	    "820658206d30a984c860f31ed9cc15b553bb93888b520de2e2ef9016fe5086c73a284bf0": 1000000000000,
	    "82065820ab5b1bc14e5daeb78d6c89bb470ec689572d987c6ec6d27459fdd0245de8dc73": 1000000000000,
	    "8206582003f7e759327693587a3edcbd3baff6bc62b66dc04faf79043845262c47c74efc": 1000000000000,
	    "8206582008c04935dd9f6f95abee9e2e3c22a0a5bf490b1113b363e202d2e561815f1651": 1000000000000,
	    "82065820d2373b5a8174f81c5f9755d9bd66ff3b19f9222f30c7e97687f11ef38eaa14bf": 1000000000000,
	    "820658204d0ed308db69341157c0ce7711e0a7fa058bac50404e91f64b986f1a31405415": 1000000000000,
	    "82065820dd15d9d311e7391ba20e24b019b81953e586f699ef6af467883c868aff3ed00b": 1000000000000,
	    "82065820407c5b89430231733be29ea114608648329c9c8450cc28f20f818a4ef8c578dc": 1000000000000,
	    "82065820cbbcdec2c18a9e8dbe37f6e2763226e60b0c094a02e9ba9896ff64ef3988de39": 1000000000000,
	    "8206582005c42f2412ab658e4b81d18254f19cdcc3d4a54b2dfd740b8612a9da9e502c48": 1000000000000
	  },
	  "maxLovelaceSupply": 45000000000000000, 	                                        
	  "networkMagic": 42,
	  "epochLength": 21600,             
	  "staking": null,
	  "slotsPerKESPeriod": 86400,       
	  "slotLength": 1,
	  "maxKESEvolutions": 14,                                              
	  "securityParam": 108
    }

Here is a brief description of each parameter. You can learn more in the [spec](https://github.com/input-output-hk/cardano-ledger-specs/tree/master/shelley/chain-and-ledger/executable-spec)


| PARAMETER | MEANING | 
|----------| --------- |
| activeSlotsCoeff | The proportion of slots in which blocks should be issued. | 
| poolDecayRate | Decay rate for pool deposits |
| poolDeposit | The amount of a pool registration deposit |
| protocolVersion| Accepted protocol versions |
| decentralisationParam | Percentage of blocks produced by stake pools |
| maxTxSize | Maximal transaction size | 
| minFeeA | The linear factor for the minimum fee calculation | 
| maxBlockBodySize | Maximal block body size |
| keyMinRefund | The minimum percent refund guarantee |
| minFeeB | The constant factor for the minimum fee calculation |
| maxBlockBodySize | Maximal block body size | 
| keyMinRefund | The minimum percent refund guarantee |
| minFeeB | The constant factor for the minimum fee calculation | 
| eMax | Epoch bound on pool retirement | 
| extraEntropy | Well, extra entropy =) |
| maxBlockHeaderSize | | 
| keyDeposit | The amount of a key registration deposit |
| keyDecayRate | The deposit decay rate | 
| nOpt | Desired number of pools | 
| rho | Treasury expansion | 
|	poolMinRefund | The minimum percent pool refund | 
|	tau | Monetary expansion | 
|	a0 | Pool influence | 
| protocolMagicId | | 
| startTime | Time of slot 0 |
| genDelegs | Mapping from genesis keys to genesis delegate |                
| updateQuorum | Determines the quorum needed for votes on the protocol parameter updates |
| maxMajorPV | Provides a mechanism for halting outdated nodes |
| initialFunds | Mapping address to values | 
| maxLovelaceSupply | The total number of lovelace in the system, used in the reward calculation. |
| networkMagic | | 
| epochLength | Number of slots in an epoch. |
| staking | | 
| slotsPerKESPeriod | Number of slots in an KES period |
| slotLength | | 
| maxKESEvolutions | The maximum number of time a KES key can be evolved before a pool operator must create a new operational certificate |
| securityParam | Security parameter k |




## The config.json file | To do
________________

## Starting the node

Starting the the node uses the command `cardano-node run` and a set of options that define the node configuration and to which network the node will connect among other parameters.  
	
You can get the complete list of options with `cardano-node -run --help`  

	--topology FILEPATH             The path to a file describing the topology.
  	--database-path FILEPATH        Directory where the state is stored.
  	--socket-path FILEPATH          Path to a cardano-node socket
  	--host-addr HOST-NAME           Optionally limit node to one ipv6 or ipv4 address
  	--port PORT                     The port number
  	--config NODE-CONFIGURATION     Configuration file for the cardano-node
  	--validate-db                   Validate all on-disk database files
  	--shutdown-ipc FD               Shut down the process when this inherited FD reaches EOF
  	--shutdown-on-slot-synced SLOT  Shut down the process after ChainDB is synced up to the
  	                                specified slot
   -h,--help                       Show this help text
   
Finally, to start a passive node, do:

	cardano-node run --topology path/to/ff-topology.json \
						--database-path path/to/db \
						--socket-path path/to/db/node.socket \
						--host-addr 192.0.2.0 \ 
						--port 3001 \
						--config path/to/ff-config.json


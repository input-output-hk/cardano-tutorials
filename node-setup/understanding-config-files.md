# Understanding your configuration files and how to use them:




## The topology.json file

Tells your node to which nodes in the network it should talk to. A minimal version of this file looks like this:


	{
	  "Producers": [
	    {
	      "addr": "x.x.x.x",
	      "port": 3001,
	      "valency": 1
	    }
	  ]
	}

* This means that your node will contact node at ip `x.x.x.x` on `port 3001`.

* `valency` tells the node how many connections your node should have. It only has an effect for dns addresses. If a dns asdress is given, valency governs to how many resolved ip addresses should we maintain acctive (hot) connection; for ip addresses, valency is used as a boolean value, where `0` means to ignore the address.

Your __block-producing__ node must __ONLY__ talk to your __relay nodes__, and the relay node should talk to other relay nodes in the network. Go to our telegram channel to find out IP addresses and ports of peers.


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
    "minUTxOValue": 0,
    "decentralisationParam": 1,
    "maxTxSize": 16384,
    "minFeeA": 44,
    "maxBlockBodySize": 65536,
    "keyMinRefund": 0,
    "minFeeB": 155381,
    "eMax": 100,
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
  "genDelegs": {
    "68c3462163394860dbea2153d9969c7493c3aedcafa951cce80d54f009179c6e": {
      "delegate": "1b63914346d3e21616cac6d9b8ed31817b946b352ff139beb3fd93d5befbb4ec",
      "vrf": "f953e5e3daf47891592579ec3a6b2dd7f12a3984a5bc2d57f8181b5664da29cd"
    },
    "68791cb64465ad87af62485c84a8c7c784879c52a3a10166371a02d3f8b4fcee": {
      "delegate": "fb6867d5f5cab90c1f394cd5d09323989e6ec7a429aa02d17f09bba3341c83a0",
      "vrf": "90bb9758eae5f945c9a57ca776289c0dddcb81bf2683dad6903bc80fe6747e3f"
    },
    "57991844610f49632e2b4055f5ae2f8678c6fbfb4062466cd56a6a6a3711e3e1": {
      "delegate": "1f93c26b4b6a5663cf366e00f8d8fcb623bd3e1a1e8bd1ac2cfe0e6a60978ef1",
      "vrf": "6f668ce3fd93011e11576986ef778f6a1c8e8773ae43720509725f57697e9b45"
    }
  },
  "updateQuorum": 3,
  "networkId": "Testnet",
  "maxMajorPV": 0,
  "initialFunds": {
    "605b9f3715742489a4c5a138e4a47984a41a6623aab620037ee67baed820521ba5": 1e+16,
    "604f01b17ab652e625f8e274c3c1a142097ba828e7e8afe7f2c73aab4544261aa7": 1000000000000000
  },
  "maxLovelaceSupply": 45000000000000000,
  "networkMagic": 42,
  "epochLength": 21600,
  "staking": null,
  "systemStart": "2020-06-05T01:00:00.000000000Z",
  "slotsPerKESPeriod": 3600,
  "slotLength": 1,
  "maxKESEvolutions": 120,
  "securityParam": 108
}


Here is a brief description of each parameter. You can learn more in the [spec](https://github.com/input-output-hk/cardano-ledger-specs/tree/master/shelley/chain-and-ledger/executable-spec)


| PARAMETER | MEANING |
|----------| --------- |
| activeSlotsCoeff | The proportion of slots in which blocks should be issued. |
| poolDecayRate | Decay rate for pool deposits |
| poolDeposit | The amount of a pool registration deposit |
| protocolVersion| Accepted protocol versions |
| decentralisationParam | Percentage of blocks produced by federated nodes |
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
| rho | Monetary expansion  |
|	poolMinRefund | The minimum percent pool refund |
|	tau | Treasury expansion |
|	a0 | Pledge influence |
| protocolMagicId | Testnet identifier |
| systemStart | Time of slot 0 |
| genDelegs | Mapping from genesis keys to genesis delegate |                
| updateQuorum | Determines the quorum needed for votes on the protocol parameter updates |
| maxMajorPV | Provides a mechanism for halting outdated nodes |
| initialFunds | Mapping address to values |
| maxLovelaceSupply | The total number of lovelace in the system, used in the reward calculation. |
| networkMagic | Used to distinguish between mainnet |
| epochLength | Number of slots in an epoch. |
| staking | Initial stake delegation |
| slotsPerKESPeriod | Number of slots in an KES period |
| slotLength | The length of each slot in seconds|
| maxKESEvolutions | The maximum number of time a KES key can be evolved before a pool operator must create a new operational certificate |
| securityParam | Security parameter k |


## The config.json file

The default `config.json` file that we downloaded is shown below.

This file has __4__ sections that allow you to have full control on what your node does and how the informtion is presented.

__NOTE Due to how the config.json file is generated, fields on the real file are shown in a different (less coherent) order. Here we present them in a more structured way__

### 1 Basic Node Configuration.

First section relates the basic node configuration parameters. Make sure you have to `TPraos`as the protocol, the correct path to the `ff-genesis.json` file, `RequiresMagic`for its use in a testnet.
Note that in this example we are using the SimpleView. This will send the output to `stdout`. Other option is `LiveView` which uses a terminal multiplexer to generate a fancy view. We will cover this topic later.

	{
	  "Protocol": "TPraos",
	  "GenesisFile": "ff-genesis.json",
	  "RequiresNetworkMagic": "RequiresMagic",

### 2 Update parameteres

This protocol version number gets used by block producing nodes as part of the system for agreeing on and synchronising protocol updates.You just need to be aware of the latest version supported by the network. You dont need to change anything here.

	  "ApplicationName": "cardano-sl",
	  "ApplicationVersion": 0,
	  "LastKnownBlockVersion-Alt": 0,
	  "LastKnownBlockVersion-Major": 0,
	  "LastKnownBlockVersion-Minor": 0,


### 3 Tracing

`Tracers` tell your node what information you are interested in when logging. Like switches that you can turn ON or OFF according the type and quantity of information that you are interesetd in. This provides fairly coarse grained control, but it is relatively efficient at filtering out unwanted trace output.

The node can run in either the `SimpleView` or `LiveView`. The `SimpleView` just uses standard output, optionally with log output. The `LiveView` is a text console with a live view of various node metrics.

`TurnOnLogging`: Enbles or disables logging overall.

`TurnOnLogMetrics`: Enable the collection of various OS metrics such as memory and CPU use. These metrics can be directed to the logs or monitoring backends.

`setupBackends`, `defaultBackends`, `hasEKG`and `hasPrometheus`: The system supports a number of backends for logging and monitoring. This settings list the the backends available to use in the configuration. The logging backend is called `Katip`.
Also enable the EKG backend if you want to use the EKG or Prometheus monitoring interfaces.

`setupScribes` and `defaultScribes`: For the Katip logging backend we must set up outputs (called scribes) The available types of scribe are:

* FileSK: for files
* StdoutSK/StderrSK: for stdout/stderr
* JournalSK: for systemd's journal system
* DevNullSK
* The scribe output format can be ScText or ScJson.

`rotation` The default file rotation settings for katip scribes, unless overridden in the setupScribes above for specific scribes.


	  "TurnOnLogging": true,
	  "TurnOnLogMetrics": true,
	  "ViewMode": "SimpleView",
	  "TracingVerbosity": "NormalVerbosity",
	  "minSeverity": "Debug",
	  "TraceBlockFetchClient": false,
	  "TraceBlockFetchDecisions": false,
	  "TraceBlockFetchProtocol": false,
	  "TraceBlockFetchProtocolSerialised": false,
	  "TraceBlockFetchServer": false,
	  "TraceChainDb": true,
	  "TraceChainSyncBlockServer": false,
	  "TraceChainSyncClient": false,
	  "TraceChainSyncHeaderServer": false,
	  "TraceChainSyncProtocol": false,
	  "TraceDNSResolver": true,
	  "TraceDNSSubscription": true,
	  "TraceErrorPolicy": true,
	  "TraceForge": true,
	  "TraceHandshake": false,
	  "TraceIpSubscription": true,
	  "TraceLocalChainSyncProtocol": false,
	  "TraceLocalErrorPolicy": true,
	  "TraceLocalHandshake": false,
	  "TraceLocalTxSubmissionProtocol": false,
	  "TraceLocalTxSubmissionServer": false,
	  "TraceMempool": true,
	  "TraceMux": false,
	  "TraceTxInbound": false,
	  "TraceTxOutbound": false,
	  "TraceTxSubmissionProtocol": false,
	  "setupBackends": [
	    "KatipBK"
	  ],
	  "defaultBackends": [
	    "KatipBK"
	  ],
	  "hasEKG": 12788,
	  "hasPrometheus": [
	    "127.0.0.1",
	    12798
	  ],
	  "setupScribes": [
	    {
	      "scFormat": "ScText",
	      "scKind": "StdoutSK",
	      "scName": "stdout",
	      "scRotation": null
	    }
	  ],
	  "defaultScribes": [
	    [
	      "StdoutSK",
	      "stdout"
	    ]
	  ],
	  "rotation": {
	    "rpKeepFilesNum": 10,
	    "rpLogLimitBytes": 5000000,
	    "rpMaxAgeHours": 24
	    },	  

### 4 Fine grained logging control

It is also possible to have more fine grained control over filtering of trace output, and to match and route trace output to particular backends. This is less efficient than the coarse trace filters above but provides much more precise control. `options`:

`mapBackends`This routes metrics matching specific names to particular backends. This overrides the defaultBackends listed above. And note that it is an **override** and not an extension so anything matched here will not go to the default backend, only to the explicitly listed backends.

`mapSubtrace` This section is more expressive, we are working on its documentation.


	  "options": {
	    "mapBackends": {
	      "cardano.node-metrics": [
	        "EKGViewBK",
	        {
	          "kind": "UserDefinedBK",
	          "name": "LiveViewBackend"
	        }
	      ],
	      "cardano.node.BlockFetchDecision.peers": [
	        "EKGViewBK",
	        {
	          "kind": "UserDefinedBK",
	          "name": "LiveViewBackend"
	        }
	      ],
	      "cardano.node.ChainDB.metrics": [
	        "EKGViewBK",
	        {
	          "kind": "UserDefinedBK",
	          "name": "LiveViewBackend"
	        }
	      ],
	      "cardano.node.metrics": [
	        "EKGViewBK",
	        {
	          "kind": "UserDefinedBK",
	          "name": "LiveViewBackend"
	        }
	      ]
	    },
	    "mapSubtrace": {
	      "benchmark": {
	        "contents": [
	          "GhcRtsStats",
	          "MonotonicClock"
	        ],
	        "subtrace": "ObservableTrace"
	      },
	      "#ekgview": {
	        "contents": [
	          [
	            {
	              "contents": "cardano.epoch-validation.benchmark",
	              "tag": "Contains"
	            },
	            [
	              {
	                "contents": ".monoclock.basic.",
	                "tag": "Contains"
	              }
	            ]
	          ],
	          [
	            {
	              "contents": "cardano.epoch-validation.benchmark",
	              "tag": "Contains"
	            },
	            [
	              {
	                "contents": "diff.RTS.cpuNs.timed.",
	                "tag": "Contains"
	              }
	            ]
	          ],
	          [
	            {
	              "contents": "#ekgview.#aggregation.cardano.epoch-validation.benchmark",
	              "tag": "StartsWith"
	            },
	            [
	              {
	                "contents": "diff.RTS.gcNum.timed.",
	                "tag": "Contains"
	              }
	            ]
	          ]
	        ],
	        "subtrace": "FilterTrace"
	      },

	      "cardano.epoch-validation.utxo-stats": {
	        "subtrace": "NoTrace"
	      },
	      "cardano.node-metrics": {
	        "subtrace": "Neutral"
	      },
	      "cardano.node.metrics": {
	        "subtrace": "Neutral"
	      }
	    }
	  }
	}

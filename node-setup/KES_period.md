## KES Periods

Before we can create a operational certificate for our stake pool, we need to figure out start of the KES validity period.
We need to know how long a period is from the genesis file:

    cat ff-genesis.json | grep KESPeriod
    > "slotsPerKESPeriod": 3600,

So one period lasts 3600 slots. What slot are we currently in?

    export CARDANO_NODE_SOCKET_PATH=node1-db/node-socket
    cardano-cli shelley query tip --testnet-magic 42
    > Tip (SlotNo {unSlotNo = 432571}) ...

Look for `unSlotNo` value. So in this example we are on slot 432571. For the current period we have:

    expr 432571 / 3600
    > 120

With this we are able to generate a operational certificate for our stake pool:

    cardano-cli shelley node issue-op-cert \
        --hot-kes-verification-key-file kes1-002.vkey \
        --cold-signing-key-file node1.skey \
        --operational-certificate-issue-counter node1.counter \
        --kes-period 120 \
        --out-file node1-002.cert

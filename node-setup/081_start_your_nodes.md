### Start your nodes:

First we restart our __relay node__ with:

    cardano-node run \
    --topology ff-topology.json \
    --database-path /db \
    --socket-path /db/node.socket \
    --host-addr <PUBLIC IP> \
    --port <PORT> \
    --config ff-config.json

then, we start our __block producing__ node with:

    cardano-node run \
    --topology ff-topology.json \
    --database-path /db \
    --socket-path /db/node.socket \
    --host-addr <PUBLIC IP> \
    --port <PORT> \
    --config ff-config.json \
    --shelley-kes-key kes.skey \
    --shelley-vrf-key vrf.skey \
    --shelley-operational-certificate node.cert

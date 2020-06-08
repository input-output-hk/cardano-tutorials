# Using the faucet

The faucet allows you to get some "test ada",
so that you can try out features that require funds.

In order to use the faucet, you first need a _payment address_,
which can optionally be associated with a _stake address_.
If you do not have such an address, find out how to create one [here](address.md) and [here](staking-key.md).

To use the faucet, simply enter

    curl -v -XPOST "https://faucet.ff.dev.cardano.org/send-money/YOUR-ADDRESS

into a terminal window.
If your address is saved to a file, for example `addr`, you can instead type

    curl -v -XPOST "https://faucet.ff.dev.cardano.org/send-money/$( cat addr )

If all goes well, you should see a bunch of lines printed to your terminal, and the last line should declare success and say how much funds where sent to your address.

    *   Trying 3.122.86.4...
    * TCP_NODELAY set
    * Connected to faucet.ff.dev.cardano.org (3.122.86.4) port 443 (#0)
    ...
    * Connection #0 to host faucet.ff.dev.cardano.org left intact
    {"success":true,"amount":1000000000,"fee":168141,"txid":"8ed4383f7af20e81c9cef88b8aab0ff2b1b284dff0ed6614480f8dbfec7d6fb5"}

Each time you use the faucet (which you can do once a day), you will get 1000 testnet-ada.

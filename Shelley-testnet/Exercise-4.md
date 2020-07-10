# Shelley Stakepool Exercise Sheet 4

LATEST TAG: 1.14.2

## Delegation

In the third exercise, we created relay and pool nodes.
In this exercise, we will set up staking keys and delegate some stake to an existing pool.

### Prerequisites

1.  Complete Exercise 3.

2. 	Read the Cardano Tutorials and General Documentation
    on Stake Key Generation, Delegation, and Pledging at:

    1. 	[https://github.com/input-output-hk/cardano-tutorials/](https://github.com/input-output-hk/cardano-tutorials/)
    2. 	[https://testnets.cardano.org/](https://testnets.cardano.org/)

3. 	Checkout and build the sources which have been tagged with `1.14.2`.

4.	Start a node and obtain the protocol parameters.
    Make sure you know what each of these is (especially the fees).

        cardano-node ...
        cardano-cli shelley query protocol-parameters \
            --testnet-magic 42 --out-file protocol.json

### Objectives

In the fourth exercise, we will make sure that you can:

1.  Create staking keys;
2.  Delegate stake to existing stake pools.

As before, if you have any questions or encounter any problems, please feel free to use the dedicated Cardano Forum channel.  IOHK staff will be monitoring the channel, and other pool operators may also be able to help you.

Please report any bugs through the `cardano-node` and `cardano-tutorials`
GitHub repositories as usual.

### Exercises

1. 	Create a new payment key pair `payment2.skey`/`payment2.vkey`.

        cardano-cli shelley address key-gen ...

    Create a new stake address key pair, `stake2.skey`/`stake2.vkey`.

        cardano-cli shelley stake-address key-gen ...

    Don’t forget to record all the keys somewhere safe!

2.  Use the stake address verification key from Step 1 to build your stake address.
    Save the address in file `stake.addr`.

        cardano-cli shelley stake-address build ...

3.  Build a payment address `payment2.addr` for the payment key `payment2.vkey` which delegates to the
    new stake address from Step 2 and transfer some funds to your new address.

        cardano-cli shelley address build ...

4. 	Before you can actually stake any ada,
    your stake address must be registered on-chain.
    Registration is just a special kind of transaction whose payload is a certificate.
    The CLI has a special command to do this, but we will build the transaction
    by hand to give you experience with this.

    First create a certificate, `stake2.cert`,
    using the `stake2.vkey` from Step 1.

	    cardano-cli shelley stake-address registration-certificate ...

    We can pay an arbitrary fee for the transaction as we did before,
    but it is more cost efficient to pay the correct amount.
    You can use a CLI command to calculate the fee.

	    cardano-cli shelley transaction calculate-min-fee \
	        --certificate-file stake2.cert ...

    You should pass in both your stake address signing key and your UTxO signing key
    from Step 1.
    The UTxO will be used to pay the fees for the transaction.
    You also need to specify the numbers of inputs to, and outputs from, the transaction.
    The fee calculation is based on the size of the transaction, plus some fixed fee.

    | Parameter                | Explanation                             | Value                    |
    | ------------------------ | --------------------------------------- | ------------------------ |
    | `--tx-in-count`          | number of inputs to the transaction     | 1                        |
    | `--tx-out-count`         | number of outputs to the transaction    | 1                        |
    | `--ttl`                  | time to live (a slot in the future)     | depends...               |
    | `--testnet-magic`        | network identifier                      | 42                       |
    | `--signing-key-file`     | singing key(s)                          | `payment2.skey`, `stake2.skey` |
    | `--certificate-file`     | certificate(s) to include               | `stake2.cert`             |
    | `--protocol-params-file` | file containing the protocol parameters | `protocol.json`            |

    Now build the transaction to register your stake address.

        cardano-cli shelley transaction build-raw ...

    You will need to provide several parameters when building the transaction, including:

    | Parameter  | Explanation                    |
    | ---------- | ------------------------------ |
    | `--tx-in`  | the UTxO to pay the fees       |
    | `--tx-out` | output address + change amount |
    | `--fee`    | transaction fee                |


    The residual amount is the amount that should be left over
    having paid for the transaction fee
    and the Key deposit (as given in the protocol parameters `protocol.json`).

    Sign the transaction with both the payment- and stake- signing keys:

        cardano-cli shelley transaction sign \
            --signing-key-file ... \
            --signing-key-file ...

    And, finally, submit the signed transaction:

        cardano-cli shelley transaction submit ...

5. 	Delegate some stake from your personal address to a running stake pool.
    Again, there is a dedicated CLI command for this,
    but we will use the basic transaction mechanism.

    First create a delegation certificate, `delegation.cert`.
    You will need to provide the verification key file for the pool
    that you wish to delegate to.
    This should be a running pool.
    one that IOHK is running, or one that a friend is running).

        cardano-cli shelley stake-address delegation-certificate \
            --stake-verification-key-file stake.vkey \
            --cold-verification-key-file cold.vkey

    Then build, sign and submit a transaction as before
    (using a UTxO that has some funds associated with it).

    As with the Incentivised Testnet, your delegation will take effect
    from the start of the next epoch.
    On the Shelley Testnet, epochs are only 6 hours long,
    so you will not have to wait too long.
    Unlike the Incentivised Testnet, each stake address must be completely delegated
    to a single pool.
    It cannot be subdivided.
    If you want to subdivide your funds, simply create several different stake addresses
    and split your funds among them.

6. 	Once the epoch has ended, check that you have received your rewards.
    Unlike the Incentivised Testnet,
    there is no separate rewards address in the Haskell Shelley system:
    All the rewards will automatically be added to your staking address.
    Congratulations, you have gained your first rewards for your (Test) Ada!

    __Note__: At the time of writing, it is not yet possible to check rewards!

7. 	_Optional Exercise (Easy)_

    How do you know how much your rewards should be?
    Did you receive the correct reward in Step 6?

    __Note__: At the time of writing, it is not yet possible to check rewards!

8. 	_Optional Exercise (Easy)_

    Delegate different amounts of ada to two different stake pools,
    and verify the rewards that you received.

    __Note__: At the time of writing, it is not yet possible to check rewards!

9. 	_Optional Exercise (Easy)_

    Delegate stake to a stake pool using a relay node that is run by another Testnet operator.

10.	_Optional Exercise (Easy)_

    How are transaction fees calculated?
    Check your formula against the node calculation.
    Is it correct?

11. _Optional Exercise (Easy)_

    What do you expect to happen if you get the leftover amount wrong?
    Feel free to experiment, but use small differences...

12. _Optional Exercise (Easy)_

    In the Haskell Shelley system, a pool may have several owners in addition
    to the operator.
    The operator and the owners will enter into an agreement on how the pool’s rewards
    are to be distributed.
    In addition, pool owner(s) may choose to delegate some ada to their own pool.
    Any ada that they delegate is referred to as the _pledge_.
    Pledging is important because it affects the rewards that the pool obtains
    and how desirable the pool is, and also provides additional
    Sybil protection for the system.
    What do you think is a sensible setting for your pledge
    given the protocol parameters that have been set on the Shelley Testnet?

You can now manage various kinds of keys,
submit transactions, start nodes and relays, and delegate stake.
In the next exercise, you will finally be able to start your own stake pool
and receive delegation from other Testnet users.

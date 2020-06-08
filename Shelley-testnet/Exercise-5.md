# Shelley Stakepool Exercise Sheet 5

LATEST TAG: 1.13.0

## Running a Stake Pool

In the fourth exercise, we learnt how to delegate to an existing pool.
In this exercise, we will register and run our own pool.

### Prerequisites

1. 	Complete [Exercise Sheet 4](Exercise-4.md).

2. 	Read the Cardano Tutorials  and General Documentation on
    Stake Pool Registration, Pledging and Stake Pool Operation at:

    1. 	[https://github.com/input-output-hk/cardano-tutorials/](https://github.com/input-output-hk/cardano-tutorials/)
    2. 	[https://testnets.cardano.org/](https://testnets.cardano.org/)

3. 	Make sure you have access to:

    1. 	One or more funded addresses;
    2. 	The keys and operational certificate for the stake pool
        that you set up in Exercise 3;
    3. 	The stake keys from Exercise 4.

4. 	Update your instances of *cardano-node* and *cardano-cli* if you need to.

5. 	Start a relay node.

### Objectives

In the fifth exercise, we will make sure that you can:

1. Register a stake pool.
2. Delegate stake to your own stake pool.
3. Start a stake pool and produce blocks.
4. Receive delegation from other Testnet users.

As before, if you have any questions or encounter any problems, please feel free to use the dedicated Cardano Forum channel.  IOHK staff will be monitoring the channel, and other pool operators may also be able to help you.

Please report any bugs through the cardano-node and cardano-tutorials github repositories.

### Exercises

1. 	Generate a registration certificate for your stake pool:

   	    cardano-cli shelley stake-pool registration-certificate ...

    You will need to decide on three key settings.

    -   The _cost_: A fixed lovelace cost per epoch (as in the Incentivised Testnet).
    -   The _margin_: The fraction of the total pool rewards (after deducting _cost_)
        that will be given to the owner(s) of the pool, as in the Incentivised Testnet,
        expressed as a floating point number between 0 and 1.
    -   The _pledge_: An amount of lovelace that the owner(s) promise(s)
        to delegate to the pool.

    If you don’t know what to choose, set the cost to 256 ada,
    the margin to 0.07 (i.e. 7%)
    and the pledge to 1,000 ada.

2. 	Pledge some stake to your stake pool.
    You do this by creating a delegation certificate as explained
    on [Exercise Sheet 4](Exercise-4.md) that delegates
    enough stake from the "owner staking key" specified in the registration certificate
    to your own pool to cover your pledge promise.

3. 	Register the pool online.
    Registration is done by submitting a transaction that contains the
    pool registration certificate.
    You can include the pledge delegation certificate in the same transaction.

    In addition to the usual transaction fees, you will also have to pay the
    pool deposit (specified in the genesis file) in that transaction.

    Note that this transaction will have to be signed by the payment key,
    the cold key and the staking key.

4. 	Start your stake pool, and link it to the relay node as you did in
    [Exercise 3](Exercise-3.md).

        cardano-node run ...

5. 	Advertise that your pool is running.

    __Note:__ At the time of writing, there is no way to determine your pool id yet.  Please use the CBOR-hex from the cold key verification file instead.

6. 	Check that you are delegating to your own pool,
    then wait until the following epoch (around 6 hours),
    and confirm that your pool is producing blocks by e.g. inspecting the log data.
    Also confirm that your pool is receiving the correct rewards.
    Congratulations, you are now a fully fledged Shelley Testnet pool operator!

    __Note:__ At the time of writing, there is no way to check rewards yet.

7. 	Optional Exercise (Easy).

    Persuade other Testnet users to delegate to your pool.

8. 	Optional Exercise (Medium).

    Join forces with one or more other Testnet stakepool operators
    to run a new stake pool that you jointly own.
    What happens if you fail to collectively meet the pledge that you have promised?

9. 	Optional Exercise (Easy).

    Change your pool’s cost, margin and pledge.
    What is the effect on the rewards that you receive?
    How long does it take for the change to take effect?

10. Optional Exercise (Easy).

    Retire (de-register) your original pool, and start a new one with different cost,
    margin and pledge.  Update your pool advertisement.

11. Optional Exercise (Medium).

    Set up two stake pools, each behind its own relay node.
    Advertise both pools.

You have now successfully set up and run your own stake pool and learnt the basics of how to manage it.  In the final exercises, we will test some operational parameters that are relevant to running a pool and see how to submit more forms of transaction.

### Feedback

Please provide any feedback or suggested changes to the tutorials or exercises by either raising an issue on the [cardano-tutorials repository](https://github.com/input-output-hk/cardano-tutorials) or by forking the repository and submitting a PR.

Please provide any feedback or suggested changes on the node itself by raising an issue at the [cardano-node repository](https://github.com/input-output-hk/cardano-node).

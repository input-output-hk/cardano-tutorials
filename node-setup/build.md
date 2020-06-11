# Installing and Running a Node

1. We need the following packages and tools on our Linux system to download the source code and build it:
    - the version control system ``git``,
    - the ``gcc`` C-compiler,
    - C++ support for ``gcc``,
    - developer libraries for the the arbitrary precision library ``gmp``,
    - developer libraries for the compression library ``zlib``,
    - developer libraries for ``systemd``,
    - developer libraries for ``ncurses``,
    - ``ncurses`` compatibility libraries,
    - the Haskell build tool ``cabal``,
    - the GHC Haskell compiler.

   If we are using an AWS instance running Amazon Linux AMI 2 (see the [AWS walk-through](AWS.md) for how to get such an instance up and running)
   or another CentOS/RHEL based system,
   we can install these dependencies as follows:

        sudo yum update -y
        sudo yum install git gcc gcc-c++ gmp-devel make tar wget zlib-devel -y
        sudo yum install systemd-devel ncurses-devel ncurses-compat-libs -y

   For Debian/Ubuntu use the following instead:

        sudo apt-get update -y
        sudo apt-get -y install build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 -y

   If you are using a different flavor of Linux, you will need to use the package manager suitable for your platform instead of `yum` or `apt-get`,
   and the names of the packages you need to install might differ.

   We download, unpack, install and update Cabal:

        wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
        tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
        rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig
        mkdir -p ~/.local/bin
        mv cabal ~/.local/bin/

   This will work on a fresh [AWS instance](AWS.md) and assumes that folder `~/.local/bin` is in your `PATH`.
   On other systems, you must either move the executable to a folder that is in your `PATH` or modify your `PATH` by adding the line

        nano ~/.bashrc

    add export PATH="~/.local/bin:$PATH" at the end of the your `.bashrc`-file.
    then run the following command to make it active:
    source ~/.bashrc

   Above instructions install Cabal version `3.2.0.0`. You can check the version by typing

        cabal update
        cabal --version
        
   __Note__: You may need to run `cabal user-config update` to make sure the cabal configuration is amended to the installed version of cabal. Doing this will make sure `cabal install ...` correctly symlinks the binaries created into `~/.cabal/bin` when the `--installdir` option is omitted.

   Finally we download and install GHC:

        wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz
        tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz
        rm ghc-8.6.5-x86_64-deb9-linux.tar.xz
        cd ghc-8.6.5
        ./configure
        sudo make install
        cd ..

2. To download the source code, we use git:

        git clone https://github.com/input-output-hk/cardano-node.git

   This should create a folder ``cardano-node``, then download the latest source code from git into it.
   After the download has finished, we can check its content by

        ls cardano-node

   ![Content of folder ``cardano-node``.](images/ls-cardano-node.png)
   Note that the content of your ``cardano-node``-folder can slightly differ from this!

3. We change our working directory to the downloaded source code folder:

        cd cardano-node

4. For reproducible builds, we should check out a specific release, a specific "tag".
   For the FF-testnet, we will use tag `1.13.0`, which we can check out as follows:

        git fetch --all --tags
        git checkout tags/1.13.0

5. Now we build and install the node with ``cabal``,
   which will take a couple of minutes the first time you do a build. Later builds will be much faster, because everything that does not change will be cached.

   		cabal install cardano-node cardano-cli

   This will build and install `cardano-node` and `cardano-cli` into your `~/.cabal/bin` folder by default, so the remark about your `PATH` from above applies here as well: Make sure folder `~/.cabal/bin` is in your path or copy the executables to a folder that is. Alternatively you can run `cabal install cardano-node cardano-cli --installdir="$HOME/.local/bin"` to install the `cardano-node` and `cardano-cli` directly into your `~/.local/bin` folder.

   __Note__: When using __cabal install__, make sure you have `overwrite-policy: always` in your `.cabal/config` or delete old version of `cardano-node` and `cardano-cli` from `~/.cabal/bin`. Otherwise cabal install will not overwrite the old executables.

6. If you ever want to update the code to a newer version, go to the `cardano-node` directory, pull the latest code with ``git`` and rebuild.

   This will be much faster than the initial build:

        cd cardano-node
        git fetch --all --tags
        git tag
        git checkout tags/<the-tag-you-want>
        cabal install cardano-node cardano-cli
        
   This will build and install `cardano-node` and `cardano-cli` into your `~/.cabal/bin` folder. Alternatively you can run `cabal install cardano-node cardano-cli --installdir="$HOME/.local/bin"` to install the `cardano-node` and `cardano-cli` directly into your `~/.local/bin` folder.

   __Note:__ It might be necessary to delete the `db`-folder (the database-folder) before running an updated version of the node.

   __Note:__ By default `cabal install` will not overwrite an existing link in `~/.cabal/bin`, so you would need to delete old versions of
   `cardano-node` and `cardano-cli` before installing new ones. Alternatively you can set

        overwrite-policy: always

   in your `cabal`-configuration at `~/.cabal/config`.

7. We can start a node on the Cardano mainnet with

        scripts/mainnet.sh

   ![Node running on mainnet.](images/mainnet.png)

Congratulations! You have installed the node, started it and connected it to the Cardano mainnet.

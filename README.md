# Project Athena builder
Builds Project Athena, an Open Source fork of the High Fidelity codebase.

## Supported platforms

* Ubuntu 16.04
* Ubuntu 18.04
* Ubuntu 19.10 (experimental)
* Linux Mint 19.3 (experimental)
* Fedora 31 (experimental, needs to build Qt)
(more coming soon)

## Instructions:

    git clone https://github.com/daleglass/athena-builder.git
    cd athena-builder
	chmod +x athena_builder
    ./athena_builder

## What it does

* Installs all required packages
* Downloads the Athena source from github
* Downloads and compiles Qt if required
* Compiles the Athena source
* Creates a wrapper script to make it run correctly
* Creates a desktop icon
* Adds it to the menu

It will ask some questions, all of which can be left with their default values.

It will detect the system's core count and amount of available memory, and do a parallel build taking care not to exhaust the system memory on high core count systems.

## Build targets

The script by default builds the GUI ('interface') but it can also build the server components using the --build option. For instance:

    $ ./athena_builder --build server

Will build only the server components. To build both, separate entries with a comma:

    $ ./athena_builder --build server,client

Have in mind that each build overwrites the previous one, so if you want to have both desktop and server components at the same time, you need to build them both in one command like above.


## Qt

The Athena codebase uses a specific, patched version of Qt. Binary packages are only available for some platforms. For platforms without a package, Qt can be built from source by the script.

## Adding support for more distributions

The script is intended to be as automatic as possible, and to set it all up for the user. For that to work, it depends on including a list of dependencies inside the script itself, but it can work without that as well. Here's how:

First, get a list of the supported distributions, and find the closest one:


    $ ./athena_builder --get-supported
    ubuntu-19.10
    linuxmint-19.3
    custom
    fedora-31
    ubuntu-16.04
    ubuntu-18.04

Tell the script to dump the list of dependencies for that distro:

    $ ./athena_builder --get-source-deps ubuntu-18.04
	...
	$ ./athena_builder --get-qt-deps ubuntu-18.04
	...

Use those results as a starting point. Choosing a similar distribution (eg, 18.04 when running on 18.10) should mostly work, and only a few package names might need fixing. With the package list figured out, install them:

    $ sudo apt-get install ...

After installing the packages, you can try the script by selecting the special distro name "custom", which will perform a build without any hardcoded dependency checking:

    $ ./athena_builder --distro custom

After that, the build process should begin. If there are problems, it's likely more packages need to be installed.

As an optional step, if you'd like to improve the script yourself, you can use the --make-pkglist argument to produce a package list formatted for pasting into the source code.

## Questions

####  How much disk space does it need?

In addition to any packages that may be needed to do the build:

* About 20 GiB for a full build including Qt.
* About 10 GiB if the binary Qt package is used.
* About 8.2 GiB after deleting downloaded source files.

#### How long does it take?

It's extremely variable, depending greatly on hardware. Here are some sample numbers, only of the compilation process:

| Processor  | Qt  | Athena   |
| ------------ | ------------ | ------------ |
| Ryzen 9 3950X, using 32 cores  |  19:01  | 4:07   |
| Ryzen 9 3950X, using 16 cores in VM | 25:32 | 4:46  |
| Core i7-8550U (Dell XPS 13 laptop) | 2:20:22 | 19:37 |


#### Why is it using such a weird number of cores for the build?

The script measures available (not total) RAM, and estimates a requirement of 1 GiB needed per build process. So if you have 8 GiB RAM free, you'll get a maximum of 8 cores used for the build.

The script is intended to be friendly and not kill the user's machine through memory exhaustion, so it's intentionally very conservative. You can specify a higher numer if you wish.

## Contact

For questions and support, contact Dale Glass#8576 on Discord.

# Secure Binary Transparency using Gooogle Trillian and SCONE

This repository contains example applications built on top of
[Trillian](https://github.com/google/trillian), showing that it's possible to apply
Transparency concepts to problems other than
[Certificates](https://github.com/google/certificate-transparency-go).

## Overview

Trillian is an implementation of the concepts described in the
[Verifiable Data Structures](docs/papers/VerifiableDataStructures.pdf) white paper,
which in turn is an extension and generalisation of the ideas which underpin
[Certificate Transparency](https://certificate-transparency.org).

Trillian implements a [Merkle tree](https://en.wikipedia.org/wiki/Merkle_tree)
whose contents are served from a data storage layer, to allow scalability to
extremely large trees.  On top of this Merkle tree, Trillian provides two
modes:

 - An append-only **Log** mode, analogous to the original
   [Certificate Transparency](https://certificate-transparency.org) logs.  In
   this mode, the Merkle tree is effectively filled up from the left, giving a
   *dense* Merkle tree.
 - An experimental **Map** mode that allows transparent storage of arbitrary
   key:value pairs derived from the contents of a source Log; this is also known
   as a **log-backed map**.  In this mode, the key's hash is used to designate a
   particular leaf of a deep Merkle tree – sufficiently deep that filled
   leaves are vastly outnumbered by unfilled leaves, giving a *sparse* Merkle
   tree.  (A Trillian Map is an *unordered* map; it does not allow enumeration
   of the Map's keys.)

Note that Trillian requires particular applications to provide their own
[personalities](#personalities) on top of the core transparent data store
functionality.

Source: [Trillian](https://github.com/google/trillian)


## Start the example

To deploy services and to demonstrate binary transparency feature it is necessary to build secure docker containers.

Prerequisites:
- Install Docker and docker-compose
- Ensure you have access to secure SCONE images (i.e. `crosscompilers`) to run this example in secure mode.


1. Clone trillian repo and build docker containers using SCONE.
```
./build.sh
```
Note! It may take 10-15 minutes.

2. Start personality service.
```
./start_personality.sh
```

3. Next we follow example [Firmware Transparency](https://github.com/google/trillian-examples/tree/master/binary_transparency/firmware).
We provide a way to run services uisng SCONE secure containers with help of additional docker-compose file.



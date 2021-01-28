# Secure Binary Transparency using Google Trillian and SCONE

This repository contains example applications built on top of
[Trillian](https://github.com/google/trillian), showing that it's possible to apply
Transparency concepts to problems other than
[Certificates](https://github.com/google/certificate-transparency-go).

## Overview

Trillian is an implementation of the concepts described in the
[Verifiable Data Structures](docs/papers/VerifiableDataStructures.pdf) white paper,
which in turn is an extension and generalization of the ideas which underpin
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


## Prerequisites

To deploy services and to demonstrate binary transparency feature it is necessary to build secure docker containers.

- Install Docker and docker-compose
- Ensure you have access to secure SCONE images (i.e. `crosscompilers`) to run this example in secure mode.


### Terminal 1 - Set up Services:
1. Clone `trillian` repo and build docker containers using SCONE.
```
./build.sh
```
Note! It may take 10-15 minutes to build the images.
Wait until this step is completed and services are running.

2. Start `personality` service.
```
./start_personality.sh
```

3. Next we follow example [Firmware Transparency](https://github.com/google/trillian-examples/tree/master/binary_transparency/firmware).
We provide a way to run services using SCONE secure containers with help of additional docker-compose file.

# Start the example

Next, we follow example of **firmware transparency** that is presented in this [link](https://github.com/google/trillian-examples/tree/master/binary_transparency/firmware), but deployment will be done in secure SCONE containers that are running in secure SGX enclaves.

## Outline
The goal is to have a system where firmware updates can not be {installed/booted} unless they have been made discoverable via a verifiable log.

In running this demo you will take on the role of several different actors within the ecosystem to see how making firmware discoverable works in practice. You will then take the role of an attacker trying to install malicious code onto a device, and see how the application of transparency has made this attack much more expensive.

### Terminal 2 - Start monitor service

The monitor "tails" the log, fetching each of the added entries and checking for inconsistencies in the structure and unexpected or malicious entries.

For our demo, we'll scan each firmware binary for the word `H4x0r3d` and consider that any binary containing that string is a bad one. Additionally, in this example, we could monitor for `trojan` keyword.

Start the monitor:
```
docker-compose -f docker-compose-example.yml up monitor
```

### Terminal 3 - Firmware Vendor

The vendor is going to publish a new, legitimate, firmware now.

To publish the firmware, run:
```
docker-compose -f docker-compose-example.yml run publisher
```
For publishing we use the binary located at in your local directory:
```
./trillian-examples/binary_transparency/firmware/testdata/firmware/dummy_device/example.wasm
```

You will see the output similar to this:
```
I0128 16:10:43.322260       1 :0] Creating update package file "/tmp/update.ota"...
I0128 16:10:43.341171       1 :0] Successfully created update package file "/tmp/update.ota"
```

Very shortly you should see that the new firmware entry has been spotted by the FT monitor above.
```
Found firmware (@0): dummy/v1 built at "2020-10-10T15:30:20.10Z" with image hash 0xbf2f21936b66a0665883716ea4b1ceda609304ad76dd48f6423128bc36d4cb0fb5effaa9c1f2e328a5cfc25d2cb89a337d4285a8bc3e22dbb99bddbed19e7095
```

> This is important! If the Firmware Vendor is paying attention to the contents of the log, they can check that every piece of firmware they see logged there is expected and corresponds to a legitimate and known-good build. If they spot something unexpected then they're now aware that there is a problem which needs investigation...

### Terminal 4 - Device Owner

Through the power of scripted narrative, the owner of the target device now has a firmware update to install (we'll re-use the `/tmp/update.ota` file created in the last step).

>  The repo contains a "dummy device" which uses the local disk to store the device's state. You'll need to choose and create a directory where this dummy device state will live - the instructions below assume that is `/tmp/dummy_device', change the path if you're using something different.

1. Boot the device.
```
docker-compose -f docker-compose-example.yml run device-boot    
```

> Because both the flash_tool and the device itself verifies the correctness of the inclusion proofs, they are convinced that the firmware is now discoverable - anybody looking at the contents of the log also knows about its existence: this doesn't guarantee that the firmware is "good", but we know at least that it can't be a covert targeted attack, and we can assume that the Firmware vendor is aware of it too.

## Terminal X - Hacker

To simulate binary injection by an external hacker.

Let's imagine the hacker has access to our device, they're going to write their malicious firmware directly over the top of our device's firmware:

1. Write malicious firmware directly onto the device.

Binary is located in example folder: `./trillian-examples/binary_transparency/firmware/testdata/firmware/dummy_device/hacked.wasm`

Run:
```
cp ./trillian-examples/binary_transparency/firmware/testdata/firmware/dummy_device/hacked.wasm ./test-device/dummy_device/firmware.bin
```

Let's watch as the device owner turns on their device in the next step...

### Terminal 4 - Device Owner

The device owner wants to use their device, however, unbeknownst to them it's been HACKED!

1. Boot the device again.
```
docker-compose -f docker-compose-example.yml run device-boot    
```

We should see that the device refuses to boot, with an error similar to this:
```
F0128 12:43:08.244147       1 :0] ROM: failed to verify bundle: firmware measurement does not match metadata (0x3f0 ...)
```

> This happened because the device measured the firmware and compared that with what the firmware manifest claimed the expected measurement should be. Since the device firmware had been overwritten, they didn't match and the device refused to boot.

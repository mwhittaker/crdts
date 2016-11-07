# CRDTs
Conflict-free (or Convergent, or Commutative, or Confluent) Replicated Data
Structures (CRDTs) are distributed data structures based on monotonic join
semilattices and commutative updates that are guaranteed to provide strong
eventual consistency. There are a [lot of papers][crdt-papers] formalizing and
explaining CRDTs. This repository contains code to visualize them.

## Table of Contents
- Counters
    - [State Based G-Counter](#state-based-g-counter)
    - [State Based PN-Counter](#state-based-pn-counter)
- Registers
    - TODO
- Sets
    - [State Based G-Set](#state-based-g-set)
    - [State Based 2P-Set](#state-based-2p-set)
    - [State Based LWW-Set](#state-based-lww-set)
    - [State Based PN-Set](#state-based-pn-set)
    - [State Based MWS-Set](#state-based-mws-set)
    - [State Based OR-Set](#state-based-or-set)

## State Based G-Counter
![GCounter1](graphs/GCounter1.png)
![GCounter2](graphs/GCounter2.png)

## State Based PN-Counter
![PnCounter1](graphs/PnCounter1.png)
![PnCounter2](graphs/PnCounter2.png)

## State Based G-Set
![GSet1](graphs/GSet1.png)
![GSet2](graphs/GSet2.png)

## State Based 2P-Set
![TwoPSet1](graphs/TwoPSet1.png)
![TwoPSet2](graphs/TwoPSet2.png)
![TwoPSet3](graphs/TwoPSet3.png)

## State Based LWW-Set
![LwwSet1](graphs/LwwSet1.png)
![LwwSet2](graphs/LwwSet2.png)
![LwwSet3](graphs/LwwSet3.png)
![LwwSet4](graphs/LwwSet4.png)
![LwwSet5](graphs/LwwSet5.png)

## State Based PN-Set
![PnSet1](graphs/PnSet1.png)
![PnSet2](graphs/PnSet2.png)

## State Based MWS-Set
![MwsSet1](graphs/MwsSet1.png)
![MwsSet2](graphs/MwsSet2.png)
![MwsSet3](graphs/MwsSet3.png)

## State Based OR-Set
![OrSet1](graphs/OrSet1.png)
![OrSet2](graphs/OrSet2.png)
![OrSet3](graphs/OrSet3.png)
![OrSet4](graphs/OrSet4.png)
![OrSet5](graphs/OrSet5.png)

## Building and Running
```bash
opam install core ocamlgraph
./build.sh
./main.byte
```

[crdt-papers]: https://christophermeiklejohn.com/crdt/2014/07/22/readings-in-crdts.html

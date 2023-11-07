# Hash Hash Hash
TODO introduction

## Building
```shell
make
```

## Running
```shell
./hash-table-tester -t [arg] -s [arg]
```
before making any changes to any function, running ./hash-table-tester outputted results of:
    Generation: 267,404 usec
    Hash table base: 285,357 usec
        - 0 missing
    Hash table v1: 501,472 usec
        - 0 missing
    Hash table v2: 471, 073 usec
        - 0 missing
## First Implementation
In the `hash_table_v1_add_entry` function, I added a single lock at the beginning of the function, then 
unlocked at the end of the function. I initialized the lock with pthread_mutex_init 
in the beginning of the *hash_table_v1_create() function. Then destroyed the lock at the end of the hash_table_v1_destroy
function 

### Performance
```shell
./hash-table-tester
```
```shell
./hash-table-tester -t 8 -s 50000
```
Version 1 is a little slower than the base version as per the spec "1. Must be slower than base implementation." 
When i run the first shell command, the base version's speed is has a roughly average speed of 307,000 usec and my
v1 has a roughly average speed of 520,000 usec. 
My v1 is a lot slower than the base version because I just added a single lock before adding any entry to the hash table, 
which is a very coarse-grained approach to locking because during the time it takes for a thread to add any entry to the table,
no other thread can do any work to add other entries to the table as well. Furthermore, I only created and initialized a single 
mutex at the beginning of the create() function, so all the threads are competing for this one lock to do work. However, 
this coarse-grained approach is quite simple and effective in assuring there are no race conditions and synchronization occurs 
without hard to find errors. 

## Second Implementation
In the `hash_table_v2_add_entry` function, I TODO

### Performance
```shell
TODO how to run and results
```

TODO more results, speedup measurement, and analysis on v2

## Cleaning up
```shell
TODO how to clean
```
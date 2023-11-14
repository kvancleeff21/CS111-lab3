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
In the `hash_table_v2_add_entry` function, my critical section was only when executing the SLIST_INSERT_HEAD macro because that is the only time where locking is necessary to prevent race conditions since if there were two threads trying to insert into the same linked list at the same time, the linking between nodes could get messed up beyond repair as nodes are added. Furthermore, I created HASH_TABLE_CAPACITY number of mutexes, specifically one mutex per bucket or per linked list because I wanted a very fine grained locking strategy and determined that the cost of initializing all these locks was worth it compared to having more threads waiting on a lock when trying to insert an element into the table. So within the add_entry function, I initialized the lock that belonged to the hash_table_entry that the linked list node was being added to and then grabbed the lock right before insertion and then released it right after insertion. Therfore, my critical section in this code is only as long as it takes for the macro to complete. 


### Performance
```shell
make
./hash_table_tester.c -t [FLAG] -s [FLAG]
```
My results when running the above program on my local M1 macbook air
Generation: 26,493 usec
Hash table base: 36,829 usec
  - 0 missing
Hash table v1: 68,553 usec
  - 0 missing
Hash table v2: 6,258 usec
  - 0 missing
As you can see, I get far more than even the required speed up since the default number of threads is 4 when no flags are supplied, with a speed up of roughly 6 times faster
## Cleaning up
```shell
make clean
```
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
Hash table base: 35,074 usec
  - 0 missing
Hash table v1: 5,894 usec
  - 3 missing
Hash table v2: 5,886 usec
  - 4 missing
## First Implementation
In the `hash_table_v1_add_entry` function, I added a single lock at the beginning of the function, then 
unlocked at the end of the function. I initialized the lock with pthread_mutex_init 
in the beginning of the *hash_table_v1_create() function. Then destroyed the lock at the end of the hash_table_v1_destroy() function 

### Performance
```shell
./hash-table-tester
```
Version 1 is a little slower than the base version as per the spec "1. Must be slower than base implementation." 
When i run the first shell command, the base version's speed is has a roughly average speed of 36,000 usec and
 my v1 has a roughly average speed of 75,000 usec. My v1 is a lot slower than the base version because I just 
 added a single lock before adding any entry to the hash table, which is a very coarse-grained approach to 
 locking because during the time it takes for a thread to add any entry to the table no other thread can do 
 any work to add other entries to the table as well. Furthermore, I only created and initialized a single 
 mutex at the beginning of the create() function, so all the threads are competing for this one lock to do 
 work. This decreases the amount of overhead to initialize the thousands of locks I create in v2, but the 
 decreased overhead of creating locks is not worth it. However, this coarse-grained approach is quite simple 
 and effective in assuring there are no race conditions and synchronization occurs without hard to find errors. 

## Second Implementation
In the `hash_table_v2_add_entry` function, my critical section is very similar to in my v1 implementation, however, since I have initialized many more mutexes, it is far more efficient. In this function, the thread acquires the lock right after the function that hashes to the correct index and corresponding linked list returns and the hash table entry is known. I lock here because even if there are two threads that hashed to the same index in the hash table, only one thread will be able to acquire the mutex, so the other thread will have to wait, and this is the worst case condition where one thread will have to wait for the other thread to execute the rest of the add_entry() function, but this condition is not common because I created a separate mutex for each individual linked list in the hash table, and since the capacity of the hash table is 4096, there is roughly a 1/4096 chance (I think) that two threads will be competing for the same index. If they are competing for the same index, then as I said before locking right after knowing the index is crucial because if you lock any later, such as when accessing the fields of the hash_table_entry struct to get the list_head or to get the list_entry, then race conditions could occur where the one of the threads is within the get_list_entry() function call where the thread is traversing through the linked list, and the other thread could be beyond that point and have calloc() a node and inserted it into the linked list, and if a linked list is modified as a thread is traversing it, that could cause huge issues, so even though it is a very rare scenario that two threads hash to same index, and then one thread modifies the linked list at the index as the other is traversing it, it is still possible, and therefore must be dealt with. I unlock the mutex either right after the add_entry function updates the value of the node, or if a new node must be created, after that node has been inserted into the linked list because then if there is a thread waiting, it can be guaranteed that no other thread will modify the linked list as the thread that acquired the lock traverses the list and adds a node itself. 


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
As you can see, I get far more than even the required speed up since the default number of threads is 4 when no flags are supplied, with a speed up of roughly 6 times faster. Since my local M1 macbook air only has four cores, I cannot adequately test for more than that. When I tested on seasnet lnxsrv13 which also has 4 cores, the results were:
Generation: 17,171 usec
Hash table base: 49,272 usec
  - 0 missing
Hash table v1: 132,332 usec
  - 0 missing
Hash table v2: 15,734 usec
  - 0 missing
  And I think the slow down occurs because the seasnet server is running many other processes and people's code in the background, so it cannot afford my process as much of the computing time towards this program like my local machine can.
## Cleaning up
```shell
make clean
```
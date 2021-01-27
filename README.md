# Tofino case study
In the case study for tofino, we run the following two queries. Query 0 is a new tcp connections query and it is run fully in the data-plane. Query 1 is UDP DDOS query and is run only partially in the data-plane till its `distinct` operator.

Query 0 --> New connections
```
q = (PacketStream(qid=0)
.filter(filter_vals=('proto',), func=('eq', 6))
.filter(filter_vals=('tcp_flags',), func=('eq', 2))
.map(keys=('ipv4_dstIP',), map_values=('count',), func=('eq', 1,))
.reduce(keys=('ipv4_dstIP',), func=('sum',))
.filter(filter_vals=('count',), func=('geq', '99.9'))
)
```


Query 1 --> UDP DDOS
```
q = (PacketStream(qid=1)
.filter(filter_vals=('proto',), func=('eq', 17))
.map(keys=('ipv4_dstIP', 'ipv4_srcIP'))
.distinct(keys=('ipv4_dstIP', 'ipv4_srcIP'))
.map(keys=('ipv4_dstIP',), map_values=('count',), func=('eq', 1,))
.reduce(keys=('ipv4_dstIP',), func=('sum',))
.filter(filter_vals=('count',), func=('geq', '99.99'))
)
```

## Data
The data for the case study can be found in data/ directory. We conduct two experiments with different inputs. However, both inputs have something in common. If we call a (srcIP, dstIP) pair a key then, the number of packets per key (counts per key) come from a uniform distribution between 1 to 20. This means any key is equally likely to have 1 or 2 or ... 19 or 20 counts. In other words P(counts = 1) = P(counts = 2) = ... = P(counts = 20) = 1/20 for each key.

### Input 1
Input 1 consists of only two windows of data.
1. W1 window consists of 10 distinct keys for TCP-syn type packets and 100 distinct keys for UDP packets.
2. In W2 window, the situtation is reversed. There are 100 distinct keys for TCP-syn and 10 distinct keys for UDP.

### Input 2
Input 2 consists of 6 different windows of data.

1. W1 - 10 keys for TCP-syn and 100 keys for UDP
2. W2 - 7 keys for TCP-syn and 98 keys for UDP
3. W3 - 11 keys for TCP-syn and 101 keys for UDP
4. W4 - 100 keys for TCP-syn and 10 keys for UDP
5. W5 - 105 keys for TCP-syn and 13 keys for UDP
6. W6 - 97 keys for TCP-syn and 9 keys for UDP

## Instructions
To run the programs 1 & 2 with the given data, follow the steps below
1. Create veth-pairs which will be used as ports for tofino-model switch.
2. Build program with the compiler shipped with Tofino's SDE.
3. Start the tofino model.
4. Run the switchd script to get a shell to interact with the switch.
5. Use PD-API in shell and execute commands in `COMMANDS.md` file to add match-action table entries.
6. Use `send_n_receive.py` script to send the packets to the tofino-model.

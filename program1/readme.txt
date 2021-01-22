Query 0 --> New connections
q = (PacketStream(qid=0)
.filter(filter_vals=('proto',), func=('eq', 6))
.filter(filter_vals=('tcp_flags',), func=('eq', 2))
.map(keys=('ipv4_dstIP',), map_values=('count',), func=('eq', 1,))
.reduce(keys=('ipv4_dstIP',), func=('sum',))
.filter(filter_vals=('count',), func=('geq', '99.9'))
)


Query 1 --> UDP DDOS
q = (PacketStream(qid=0)
.filter(filter_vals=('proto',), func=('eq', 17))
.map(keys=('ipv4_dstIP', 'ipv4_srcIP'))
.distinct(keys=('ipv4_dstIP', 'ipv4_srcIP'))
.map(keys=('ipv4_dstIP',), map_values=('count',), func=('eq', 1,))
.reduce(keys=('ipv4_dstIP',), func=('sum',))
.filter(filter_vals=('count',), func=('geq', '99.99'))
)



We are running Query 0 fully, and Query 1 partially in the data-plane. Query 2 is partitioned at its distinct operator. 

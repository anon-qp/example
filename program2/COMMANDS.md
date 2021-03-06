# Static Settings
```
pd add_out_header_1 set_default_action do_add_out_header_1
pd add_out_header_2 set_default_action do_add_out_header_2
```

```
pd execute_reduce_1 set_default_action do_execute_reduce_1
pd execute_distinct_2 set_default_action do_execute_distinct_2
```

```
pd filter_1 set_default_action drop_filter_1
pd filter_1 add_entry _nop_1 ipv4_protocol 6 tcp_flags 2
pd filter_2 set_default_action drop_filter_2
pd filter_2 add_entry _nop_2 ipv4_protocol 17
```

```
pd forward set_default_action set_egr action_egress_spec 1
```

```
pd init_hash_reduce_1 set_default_action do_init_hash_reduce_1
pd init_hash_distinct_2 set_default_action do_init_hash_distinct_2
```

```
pd mapinit_1 set_default_action do_mapinit_1
pd mapinit_2 set_default_action do_mapinit_2
```

# Dynamic Settings
Replace `?` with the corresponding `hash_size_mask` for the operation. The `hash_size_mask` controls the range of hash values genereated for indexing a register. 

```
pd update_hash_reduce_1 set_default_action do_update_hash_reduce_1 action_hash_size_mask ?
pd update_hash_distinct_2 set_default_action do_update_hash_distinct_2 action_hash_size_mask ?
```

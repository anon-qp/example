# Static Settings
```
pd add_out_header_1 add_entry _nop_3 meta_app_data_drop_exec_op_1 1
pd add_out_header_1 add_entry do_add_out_header_1 meta_app_data_drop_exec_op_1 0
pd add_out_header_2 add_entry _nop_4 meta_app_data_drop_exec_op_2 1
pd add_out_header_2 add_entry do_add_out_header_2 meta_app_data_drop_exec_op_2 0
pd filter_1 set_default_action drop_filter_1
pd filter_1 add_entry _nop_1 ipv4_protocol 6 tcp_flags 2
pd filter_2 set_default_action drop_filter_2
pd filter_2 add_entry _nop_2 ipv4_protocol 17
pd forward set_default_action drop_forward
pd forward add_entry set_egr meta_app_data_drop_exec_op_1 0 meta_app_data_drop_exec_op_1_mask 1 meta_app_data_drop_exec_op_2 0 meta_app_data_drop_exec_op_2_mask 0 priority 1 action_egress_spec 1
pd forward add_entry set_egr meta_app_data_drop_exec_op_1 0 meta_app_data_drop_exec_op_1_mask 0 meta_app_data_drop_exec_op_2 0 meta_app_data_drop_exec_op_2_mask 1 priority 1 action_egress_spec 1
pd init_hash_1 set_default_action do_init_hash_1
pd init_hash_2 set_default_action do_init_hash_2
```


# Dynamic Settings

## Change table order
To make `execute_op_1` follow `filter_1` table, execute all commands following the `+` symbol. Alternatively, if you execute all `-` symbol commands then, `execute_op_1` table will work after `filter_1` table.
+ => filter_1 $\rightarrow$ execute_op_1
- => filter_2 $\rightarrow$ execute_op_1

```
+ pd execute_op_1 add_entry do_execute_reduce_1 meta_op_1_select_prog 0 meta_op_1_select_prog_mask 1 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 1 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 0 priority 1
- pd execute_op_1 add_entry do_execute_reduce_1 meta_op_1_select_prog 0 meta_op_1_select_prog_mask 1 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 0 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 1 priority 1
```

```
+ pd execute_op_1 add_entry do_execute_distinct_1 meta_op_1_select_prog 1 meta_op_1_select_prog_mask 1 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 1 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 0 priority 1
- pd execute_op_1 add_entry do_execute_distinct_1 meta_op_1_select_prog 1 meta_op_1_select_prog_mask 1 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 0 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 1 priority 1
```

```
+ pd execute_op_1 add_entry drop_exec_op_1 meta_op_1_select_prog 0 meta_op_1_select_prog_mask 0 meta_app_data_drop_filter_1 1 meta_app_data_drop_filter_1_mask 1 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 0 priority 1
- pd execute_op_1 add_entry drop_exec_op_1 meta_op_1_select_prog 0 meta_op_1_select_prog_mask 0 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 0 meta_app_data_drop_filter_2 1 meta_app_data_drop_filter_2_mask 1 priority 1
```

+ => filter_1 $\rightarrow$ execute_op_2
- => filter_2 $\rightarrow$ execute_op_2

```
+ pd execute_op_2 add_entry do_execute_reduce_2 meta_op_2_select_prog 0 meta_op_2_select_prog_mask 1 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 1 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 0 priority 1
- pd execute_op_2 add_entry do_execute_reduce_2 meta_op_2_select_prog 0 meta_op_2_select_prog_mask 1 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 0 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 1 priority 1
```

```
+ pd execute_op_2 add_entry do_execute_distinct_2 meta_op_2_select_prog 1 meta_op_2_select_prog_mask 1 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 1 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 0 priority 1
- pd execute_op_2 add_entry do_execute_distinct_2 meta_op_2_select_prog 1 meta_op_2_select_prog_mask 1 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 0 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 1 priority 1
```

```
+ pd execute_op_2 add_entry drop_exec_op_2 meta_op_2_select_prog 0 meta_op_2_select_prog_mask 0 meta_app_data_drop_filter_1 1 meta_app_data_drop_filter_1_mask 1 meta_app_data_drop_filter_2 0 meta_app_data_drop_filter_2_mask 0 priority 1
- pd execute_op_2 add_entry drop_exec_op_2 meta_op_2_select_prog 0 meta_op_2_select_prog_mask 0 meta_app_data_drop_filter_1 0 meta_app_data_drop_filter_1_mask 0 meta_app_data_drop_filter_2 1 meta_app_data_drop_filter_2_mask 1 priority 1
```


## Change operator field
Choose only one from each `+` and `-`. These commands are used to change the fields on which the hash value is computed for an operator.

### for operator 1
```
+ pd init_hash_field_data_1_1 set_default_action do_init_src_ip_1_1 action_dynamic_mask 0xffffffff
- pd init_hash_field_data_1_1 set_default_action do_init_null_1_1
```

```
+ pd init_hash_field_data_1_2 set_default_action do_init_dst_ip_1_2 action_dynamic_mask 0xffffffff
- pd init_hash_field_data_1_2 set_default_action do_init_null_1_2
```


### for operator 2
```
+ pd init_hash_field_data_2_1 set_default_action do_init_src_ip_2_1 action_dynamic_mask 0xffffffff
- pd init_hash_field_data_2_1 set_default_action do_init_null_2_1
```

```
+ pd init_hash_field_data_2_2 set_default_action do_init_dst_ip_2_2 action_dynamic_mask 0xffffffff
- pd init_hash_field_data_2_2 set_default_action do_init_null_2_2
```


## Change operator type

+ => operator 1 is reduce
- => operator 1 is distinct

```
+ pd init_meta_op_1 set_default_action do_init_meta_op_1 action_select_prog_dynamic 0 action_qid ?
- pd init_meta_op_1 set_default_action do_init_meta_op_1 action_select_prog_dynamic 1 action_qid ?
```

+ => operator 2 is reduce
- => operator 2 is distinct

```
+ pd init_meta_op_2 set_default_action do_init_meta_op_2 action_select_prog_dynamic 0 action_qid ?
- pd init_meta_op_2 set_default_action do_init_meta_op_2 action_select_prog_dynamic 1 action_qid ?
```

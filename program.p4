#include "headers.p4"
#include "parser.p4"
#include <tofino/stateful_alu_blackbox.p4>
#include <tofino/intrinsic_metadata.p4>

header ethernet_t ethernet;
header tcp_t tcp;
header udp_t udp;
header ipv4_t ipv4;
header out_header_t out_header_1;
header out_header_t out_header_2;

metadata meta_op_t meta_op_1;
metadata meta_op_t meta_op_2;
metadata meta_app_data_t meta_app_data;
// metadata meta_program_data_t meta_program_data;
// metadata meta_field_data_t meta_field_data;



action _nop_1(){}

action drop_filter_1(){
       modify_field(meta_app_data.drop_filter_1, 1);
}

table filter_1 {
	reads {
	        ipv4.protocol : exact;
		tcp.flags : exact;
	}
	actions {
		drop_filter_1;
		_nop_1;
	}
	size : 64;
}


action _nop_2(){}

action drop_filter_2(){
       modify_field(meta_app_data.drop_filter_2, 1);
}

table filter_2 {
	reads {
		ipv4.protocol : exact;
	}
	actions {
		drop_filter_2;
		_nop_2;
	}
	size : 64;
}



action do_init_meta_op_1(select_prog_dynamic, qid) {
        modify_field(meta_op_1.select_prog, select_prog_dynamic);
	modify_field(meta_op_1.qid, qid);
}

table init_meta_op_1 {
        actions {
                do_init_meta_op_1;
        }
	default_action : do_init_meta_op_1;
        size : 1;
}


action do_init_meta_op_2(select_prog_dynamic, qid) {
        modify_field(meta_op_2.select_prog, select_prog_dynamic);
	modify_field(meta_op_2.qid, qid);
}

table init_meta_op_2 {
        actions {
                do_init_meta_op_2;
        }
	default_action : do_init_meta_op_2;
        size : 1;
}



action do_init_src_ip_1_1(dynamic_mask) {
        bit_and(meta_op_1.field_value_1, ipv4.srcIP, dynamic_mask);
}

action do_init_null_1_1() {
	modify_field(meta_op_1.field_value_1, 0);
}

table init_hash_field_data_1_1 {
        actions {
                do_init_src_ip_1_1;
                do_init_null_1_1;
        }
        size : 1;
}


action do_init_dst_ip_1_2(dynamic_mask) {
        bit_and(meta_op_1.field_value_2, ipv4.dstIP, dynamic_mask);
}

action do_init_null_1_2() {
	modify_field(meta_op_1.field_value_2, 0);
}

table init_hash_field_data_1_2 {
        actions {
                do_init_dst_ip_1_2;
                do_init_null_1_2;
        }
        size : 1;
}


action do_init_src_ip_2_1(dynamic_mask) {
        bit_and(meta_op_2.field_value_1, ipv4.srcIP, dynamic_mask);
}

action do_init_null_2_1(dynamic_mask) {
	modify_field(meta_op_2.field_value_1, 0);
}

table init_hash_field_data_2_1 {
        actions {
                do_init_src_ip_2_1;
                do_init_null_2_1;
        }
        size : 1;
}


action do_init_dst_ip_2_2(dynamic_mask) {
        bit_and(meta_op_2.field_value_2, ipv4.dstIP, dynamic_mask);
}

action do_init_null_2_2(dynamic_mask) {
	modify_field(meta_op_2.field_value_2, 0);
}

table init_hash_field_data_2_2 {
        actions {
                do_init_dst_ip_2_2;
                do_init_null_2_2;
        }
        size : 1;
}



field_list hash_op_fields_1 {
	meta_op_1.field_value_1;
	meta_op_1.field_value_2;
}

field_list_calculation hash_op_calc_1 {
	input {
		hash_op_fields_1;
	}
	algorithm: crc16;
	output_width: 16;
}

action do_init_hash_1() {
        modify_field_with_hash_based_offset(meta_op_1.index, 0, hash_op_calc_1, 65536);
}

table init_hash_1 {
        actions {
	        do_init_hash_1;
	}
	default_action : do_init_hash_1;
	size : 1;
}


field_list hash_op_fields_2 {
	meta_op_2.field_value_1;
	meta_op_2.field_value_2;
}

field_list_calculation hash_op_calc_2 {
	input {
		hash_op_fields_2;
	}
	algorithm: crc16;
	output_width: 16;
}

action do_init_hash_2() {
        modify_field_with_hash_based_offset(meta_op_2.index, 0, hash_op_calc_2, 1024);
}

table init_hash_2 {
        actions {
	        do_init_hash_2;
	}
	default_action : do_init_hash_2;
	size : 1;
}



register reg_1 {
	// Add code here
	width : 32;
	instance_count : 65536;
}

blackbox stateful_alu reduce_program_1 {
        reg: reg_1;
	// Threshold set at 2
        condition_lo: register_lo < 1;
	
        update_lo_1_value: register_lo + 1;

        output_predicate: condition_lo;
        output_value: 1;
        output_dst: meta_app_data.drop_exec_op_1;
}

blackbox stateful_alu distinct_program_1 {
        reg: reg_1;
        condition_lo: register_lo > 0;
        
        update_lo_1_value: register_lo | 1;

        output_predicate: condition_lo;
        output_value: 1;
        output_dst: meta_app_data.drop_exec_op_1;
}


register reg_2 {
	// Add code here
	width : 32;
	instance_count : 1024;
}

blackbox stateful_alu reduce_program_2 {
        reg: reg_2;
	// Threshold set at 2
        condition_lo: register_lo < 1;
	
        update_lo_1_value: register_lo + 1;

        output_predicate: condition_lo;
        output_value: 1;
        output_dst: meta_app_data.drop_exec_op_2;
}

blackbox stateful_alu distinct_program_2 {
        reg: reg_2;
        condition_lo: register_lo > 0;
        
        update_lo_1_value: register_lo | 1;

        output_predicate: condition_lo;
        output_value: 1;
        output_dst: meta_app_data.drop_exec_op_2;
}



action do_execute_reduce_1() {
	reduce_program_1.execute_stateful_alu(meta_op_1.index);
}

action do_execute_distinct_1() {
	distinct_program_1.execute_stateful_alu(meta_op_1.index);
}

action drop_exec_op_1(){
       modify_field(meta_app_data.drop_exec_op_1, 1);
 }

table execute_op_1 {
        reads {
	        meta_op_1.select_prog : ternary;
		meta_app_data.drop_filter_1 : ternary;
		meta_app_data.drop_filter_2 : ternary;
	}
	actions {
		do_execute_reduce_1;
		do_execute_distinct_1;
		drop_exec_op_1;
	}
	size : 8;
}


action do_execute_reduce_2() {
	reduce_program_2.execute_stateful_alu(meta_op_2.index);
}

action do_execute_distinct_2() {
	distinct_program_2.execute_stateful_alu(meta_op_2.index);
}

action drop_exec_op_2(){
       modify_field(meta_app_data.drop_exec_op_2, 1);
 }

table execute_op_2 {
        reads {
	        meta_op_2.select_prog : ternary;
		meta_app_data.drop_filter_1 : ternary;
		meta_app_data.drop_filter_2 : ternary;
	}
	actions {
		do_execute_reduce_2;
		do_execute_distinct_2;
		drop_exec_op_2;
	}
	size : 8;
}



action set_egr(egress_spec) {
        modify_field(ig_intr_md_for_tm.ucast_egress_port, egress_spec);
}

action drop_forward() {}

table forward {
        reads {
                meta_app_data.drop_exec_op_1 : ternary;
		meta_app_data.drop_exec_op_2 : ternary;
	}
        actions {
	        set_egr;
		drop_forward;
	 }
	size : 4;
	default_action : set_egr;
}



action do_add_out_header_1() {
	// Add code here
	add_header(out_header_1);
	modify_field(out_header_1.qid, meta_op_1.qid);
	modify_field(out_header_1.field_val_1, meta_op_1.field_value_1);
	modify_field(out_header_1.field_val_2, meta_op_1.field_value_2);
	modify_field(out_header_1.index, meta_op_1.index);
}

action _nop_3() {}

table add_out_header_1 {
        reads {
	        meta_app_data.drop_exec_op_1 : exact;
	}
	actions {
		do_add_out_header_1;
		_nop_3;
	}
	default_action : _nop_3;
	size : 2;
}


action do_add_out_header_2() {
	// Add code here
	add_header(out_header_2);
	modify_field(out_header_2.qid, meta_op_2.qid);
	modify_field(out_header_2.field_val_1, meta_op_2.field_value_1);
	modify_field(out_header_2.field_val_2, meta_op_2.field_value_2);
	modify_field(out_header_2.index, meta_op_2.index);
}

action _nop_4() {}

table add_out_header_2 {
        reads {
	        meta_app_data.drop_exec_op_2 : exact;
	}
	actions {
		do_add_out_header_2;
		_nop_4;
	}
	default_action : _nop_4;
	size : 2;
}



control ingress {
        apply(filter_1);
	apply(filter_2);

        apply(init_meta_op_1);
	apply(init_meta_op_2);

        apply(init_hash_field_data_1_1);
	apply(init_hash_field_data_1_2);
	apply(init_hash_field_data_2_1);
	apply(init_hash_field_data_2_2);

        apply(init_hash_1);
	apply(init_hash_2);

	apply(execute_op_1);
	apply(execute_op_2);
	
	apply(forward);
}


control egress {
	apply(add_out_header_1);
	apply(add_out_header_2);
}

#include "headers.p4"
#include "parser.p4"
#include <tofino/stateful_alu_blackbox.p4>
#include <tofino/intrinsic_metadata.p4>

#define reg_1_size 256
#define reg_2_size 512

header ethernet_t ethernet;
header tcp_t tcp;
header udp_t udp;
header ipv4_t ipv4;
header out_header_1_t out_header_1;
header out_header_2_t out_header_2;

metadata meta_mapinit_1_t meta_mapinit_1;
metadata meta_mapinit_2_t meta_mapinit_2;
metadata meta_app_data_t meta_app_data;




action do_mapinit_1() {
        modify_field(meta_mapinit_1.qid, 0);
	modify_field(meta_mapinit_1.ipv4_dstIP, ipv4.dstIP);
	modify_field(meta_mapinit_1.hash_overflow, 0);
}

table mapinit_1 {
        actions {
                do_mapinit_1;
        }
	default_action : do_mapinit_1;
        size : 1;
}


action do_mapinit_2() {
        modify_field(meta_mapinit_2.qid, 1);
	modify_field(meta_mapinit_2.ipv4_srcIP, ipv4.srcIP);
	modify_field(meta_mapinit_2.ipv4_dstIP, ipv4.dstIP);
	modify_field(meta_mapinit_2.hash_overflow, 0);
}

table mapinit_2 {
        actions {
                do_mapinit_2;
        }
	default_action : do_mapinit_2;
        size : 1;
}



field_list hash_reduce_fields_1 {
        meta_mapinit_1.ipv4_dstIP;
}

field_list_calculation hash_reduce_calc_1 {
	input {
		hash_reduce_fields_1;
	}
	algorithm: crc16;
	output_width: 16;
}

action do_init_hash_reduce_1() {
        modify_field_with_hash_based_offset(meta_mapinit_1.index, 0, hash_reduce_calc_1, 1024);
}

table init_hash_reduce_1 {
        actions {
	        do_init_hash_reduce_1;
	}
	default_action : do_init_hash_reduce_1;
	size : 1;
}


field_list hash_distinct_fields_2 {
	meta_mapinit_2.ipv4_srcIP;
        meta_mapinit_2.ipv4_dstIP;
}

field_list_calculation hash_distinct_calc_2 {
	input {
		hash_distinct_fields_2;
	}
	algorithm: crc16;
	output_width: 16;
}

action do_init_hash_distinct_2() {
        modify_field_with_hash_based_offset(meta_mapinit_2.index, 0, hash_distinct_calc_2, 1024);
}

table init_hash_distinct_2 {
        actions {
	        do_init_hash_distinct_2;
	}
	default_action : do_init_hash_distinct_2;
	size : 1;
}



action do_update_hash_reduce_1(hash_size_mask) {
        bit_and(meta_mapinit_1.index, meta_mapinit_1.index, hash_size_mask);
}

table update_hash_reduce_1 {
        actions {
	        do_update_hash_reduce_1;
	}
	default_action : do_update_hash_reduce_1;
	size : 1;
}

action do_update_hash_distinct_2(hash_size_mask) {
        bit_and(meta_mapinit_2.index, meta_mapinit_2.index, hash_size_mask);
}

table update_hash_distinct_2 {
        actions {
	        do_update_hash_distinct_2;
	}
	default_action : do_update_hash_distinct_2;
	size : 1;
}




action _nop_1(){}

action drop_filter_1(){
       modify_field(meta_app_data.drop_1, 1);
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
       modify_field(meta_app_data.drop_2, 1);
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



register reg_1 {
	// Add code here
	width : 32;
	instance_count : reg_1_size;
}

blackbox stateful_alu reduce_program_1 {
        reg: reg_1;
	// Threshold set at >= 4
        condition_lo: register_lo == 3;
	
        update_lo_1_value: register_lo + 1;

        output_predicate: not condition_lo;
        output_value: 1;
        output_dst: meta_app_data.drop_1;
}


register reg_2 {
	// Add code here
	width : 32;
	instance_count : reg_2_size;
}

blackbox stateful_alu distinct_program_2 {
        reg: reg_2;
        condition_lo: register_lo > 0;
        
        update_lo_1_value: register_lo | 1;

        output_predicate: condition_lo;
        output_value: 1;
        output_dst: meta_app_data.drop_2;
}



action do_execute_reduce_1() {
	reduce_program_1.execute_stateful_alu(meta_mapinit_1.index);
}


table execute_reduce_1 {
	actions {
		do_execute_reduce_1;
	}
	default_action : do_execute_reduce_1;
	size : 1;
}


action do_execute_distinct_2() {
	distinct_program_2.execute_stateful_alu(meta_mapinit_2.index);
}

table execute_distinct_2 {
	actions {
		do_execute_distinct_2;
	}
	default_action : do_execute_distinct_2;
	size : 1;
}



action do_hash_overflow_1() {
        modify_field(meta_mapinit_1.hash_overflow, 1);
}

table hash_overflow_1 {
        actions {
	        do_hash_overflow_1;
	}
	default_action : do_hash_overflow_1;
	size : 1;
}


action do_hash_overflow_2() {
        modify_field(meta_mapinit_2.hash_overflow, 1);
}

table hash_overflow_2 {
        actions {
	        do_hash_overflow_2;
	}
	default_action : do_hash_overflow_2;
	size : 1;
}



action set_egr(egress_spec) {
        modify_field(ig_intr_md_for_tm.ucast_egress_port, egress_spec);
}

action drop_forward() {}

table forward {
        actions {
	        set_egr;
	 }
	size : 1;
	default_action : set_egr;
}



action do_add_out_header_1() {
	// Add code here
	add_header(out_header_1);
	modify_field(out_header_1.qid, meta_mapinit_1.qid);
	modify_field(out_header_1.ipv4_dstIP, meta_mapinit_1.ipv4_dstIP);
	modify_field(out_header_1.index, meta_mapinit_1.index);
	modify_field(out_header_1.hash_overflow, meta_mapinit_1.hash_overflow);
}

table add_out_header_1 {
	actions {
		do_add_out_header_1;
	}
	default_action : do_add_out_header_1;
	size : 1;
}


action do_add_out_header_2() {
	// Add code here
	add_header(out_header_2);
	modify_field(out_header_2.qid, meta_mapinit_2.qid);
	modify_field(out_header_2.ipv4_dstIP, meta_mapinit_2.ipv4_dstIP);
	modify_field(out_header_2.ipv4_srcIP, meta_mapinit_2.ipv4_srcIP);
	modify_field(out_header_2.index, meta_mapinit_2.index);
	modify_field(out_header_2.hash_overflow, meta_mapinit_2.hash_overflow);
}

table add_out_header_2 {
	actions {
		do_add_out_header_2;
	}
	default_action : do_add_out_header_2;
	size : 1;
}



control ingress {
        // query 0 -- New tcp connections
	apply(mapinit_1);
	apply(init_hash_reduce_1);
	apply(update_hash_reduce_1);
        apply(filter_1);
	if (meta_app_data.drop_1 != 1) {
	        if (meta_mapinit_1.index  < reg_1_size) {
        	        apply(execute_reduce_1);
		} else {
		        apply(hash_overflow_1);
		}
	}

        apply(mapinit_2);
	apply(init_hash_distinct_2);
	apply(update_hash_distinct_2);
	apply(filter_2);
        if (meta_app_data.drop_2 != 1) {
	        if (meta_mapinit_2.index < reg_2_size) {
        	        apply(execute_distinct_2);
		} else {
		        apply(hash_overflow_2);
		}
	}

        if (meta_app_data.drop_1 != 1 or meta_app_data.drop_2 != 1) {
        	apply(forward);
	}
}


control egress {
        if (meta_app_data.drop_1 != 1) {
        	apply(add_out_header_1);
	}
	if (meta_app_data.drop_2 != 1) {
        	apply(add_out_header_2);
	}
}

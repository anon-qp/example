header_type ethernet_t {
	fields {
		dstMac : 48;
		srcMac : 48;
		ethType : 16;
	}
}

header_type tcp_t {
	fields {
		sport : 16;
		dport : 16;
		seqNo : 32;
		ackNo : 32;
		dataOffset : 4;
		res : 4;
		flags : 8;
		window : 16;
		checksum : 16;
		urgentPtr : 16;
	}
}

header_type udp_t {
    fields {
            sport : 16;
	    dport : 16;
	    length_ : 16;
	    checksum : 16;
	    }
}

header_type ipv4_t {
	fields {
		version : 4;
		ihl : 4;
		diffserv : 8;
		totalLen : 16;
		identification : 16;
		flags : 3;
		fragOffset : 13;
		ttl : 8;
		protocol : 8;
		hdrChecksum : 16;
		srcIP : 32;
		dstIP : 32;
	}
}

header_type out_header_t {
	fields {
	        qid : 16;
		field_val_1 : 32;
		field_val_2 : 32;
		index : 16;
	}
}

header_type meta_app_data_t {
	fields {
	        drop_filter_1 : 1;
		drop_filter_2 : 1;
		
		drop_exec_op_1 : 1;
		drop_exec_op_2 : 1;
        }
}

header_type meta_op_t {
	fields {
	        qid : 1;
	        select_prog : 1;
	        // value : 32;
		index : 16;
		field_value_1 : 32;
		field_value_2 : 32;
	}
}

// We also need a (qid, rid) specific metadata field
// It will be used while adding out header. Because, we can't create
// and add_out_header table for each SALU in the program. We need to create
// only as many as there are (qid, rid) pairs. 

// header_type meta_program_data_t {
//         fields {
// 	       select_prog : 1;
// 	}
// }


// header_type meta_field_data_t {
//         fields {
// 	        select_field : 1;
// 		value : 32;
// 	}
// }

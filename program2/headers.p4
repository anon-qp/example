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

header_type out_header_1_t {
	fields {
	        qid : 8;
		ipv4_dstIP : 32;
		index : 16;
		hash_overflow : 8;
	}
}

header_type out_header_2_t {
	fields {
	        qid : 8;
		ipv4_srcIP : 32;
		ipv4_dstIP : 32;
		index : 16;
		hash_overflow : 8;
	}
}

header_type meta_app_data_t {
	fields {
	        drop_1 : 1;
		drop_2 : 1;
        }
}

header_type meta_mapinit_1_t {
        fields {
	        qid : 1;
		ipv4_dstIP : 32;
		hash_overflow : 1;
		index : 16;
	}
}

header_type meta_mapinit_2_t {
        fields {
	        qid : 1;
		ipv4_srcIP : 32;
		ipv4_dstIP : 32;
		hash_overflow : 1;
	        index : 16;
	}
}

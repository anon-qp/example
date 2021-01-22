from scapy.all import *
import pandas as pd
import argparse
from tqdm.auto import tqdm
import time


def send_traffic(path_to_csv, only_tcp, only_udp):
    df = pd.read_csv(path_to_csv)
    for _, row in tqdm(df.iterrows(), total=df.shape[0]):
        if row.proto == 6 and not only_udp:
            packet = Ether() / IP(dst=row.dIP, src=row.sIP) / TCP(flags='S')
        elif row.proto == 17 and not only_tcp:
            packet = Ether() / IP(dst=row.dIP, src=row.sIP) / UDP()
        else:
            continue
        sendp(packet, iface="veth1", count=row.ct, verbose=0, inter=0.015)
        time.sleep(0.015)
    return


def main():
    parser = argparse.ArgumentParser(description='Send traffic to tofino-model')
    parser.add_argument('path_to_csv', help="Path to CSV file that has traffic data")
    parser.add_argument('log_file', help="Log file to store result(s)")
    parser.add_argument('-r', '--repeat', dest="total", type=int, default=1, help="Number of times to repeat the send-n-receive experiment [default=1]")
    parser.add_argument('--only-tcp', dest="only_tcp", action='store_true', help="Send only tcp packets")
    parser.add_argument('--only-udp', dest="only_udp", action='store_true', help="Send only udp packets")
    
    args = parser.parse_args()

    total_packet_list = []
    for i in range(args.total):
        t = AsyncSniffer(iface="veth3")
        t.start()
        send_traffic(args.path_to_csv, args.only_tcp, args.only_udp)
        total_packets = len(t.stop())
        print("Total Packets Recvd.:", total_packets)
        total_packet_list.append(total_packets)
        if i == args.total - 1:
            break
        for j in range(15):
            print(f"Resuming send_traffic again in {15-j}s...", end='\r')
            time.sleep(1)
            print('', end='\x1b[1K\r')

    with open(args.log_file, 'w') as f:
        for tp in total_packet_list:
            f.write(f"{tp}\n")
    
    print("Done!")
    return


if __name__ == "__main__":
    main()

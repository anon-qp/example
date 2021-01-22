from scapy.all import *
import pandas as pd
import argparse
from tqdm.auto import tqdm



def send_traffic(path_to_csv):
    df = pd.read_csv(path_to_csv)
    for _, row in tqdm(df.iterrows(), total=df.shape[0]):
        if row.proto == 6:
            packet = Ether() / IP(dst=row.dIP, src=row.sIP) / TCP(flags='S')
        elif row.proto == 17:
            packet = Ether() / IP(dst=row.dIP, src=row.sIP) / UDP()
        else:
            raise ValueError(f"Invalid Protocol: {row.proto}")
        sendp(packet, iface="veth1", count=row.ct, verbose=0)

    return


def main():
    parser = argparse.ArgumentParser(description='Send traffic to tofino-model')
    parser.add_argument('path_to_csv', help="Path to CSV file that has traffic data")
    parser.add_argument('log_file', help="Log file to store result(s)")
    parser.add_argument('-r', '--repeat', dest="total", type=int, default=1, help="Number of times to repeat the send-n-receive experiment [default=1]")
    args = parser.parse_args()

    total_packet_list = []
    for _ in range(args.total):
        t = AsyncSniffer(iface="veth3")
        t.start()
        send_traffic(args.path_to_csv)
        total_packets = len(t.stop())
        total_packet_list.append(total_packets)

    with open(args.log_file, 'w') as f:
        for tp in total_packet_list:
            f.write(f"{tp}\n")
    
    print("Done!")
    return


if __name__ == "__main__":
    main()

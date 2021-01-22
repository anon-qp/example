import pandas as pd
from scapy.all import *
from pathlib import Path



def generate_traffic(proto2keys, fname):
    random_ip = RandIP()
    random_ct = RandNum(5, 100)
    data = []
    for proto in [6, 17]:
        for i in range(proto2keys[proto]):
            sIP = str(random_ip)
            dIP = str(random_ip)
            ct = int(random_ct)

            data.append((sIP, dIP, proto, ct))

    pd.DataFrame(data, columns=['sIP', 'dIP', 'proto', 'ct']).to_csv(fname, index=False)
    return


def main():
    print("Generating data...")
    p1 = Path('../data/w1.csv')
    p2 = Path('../data/w2.csv')
    p1.parent.mkdir(parents=True, exist_ok=True)
    generate_traffic({6: 305, 17: 553}, p1)
    generate_traffic({6: 671, 17: 389}, p2)
    print("Done!")
    return


if __name__ == "__main__":
    main()

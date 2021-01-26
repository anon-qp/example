import pandas as pd
from scapy.all import *
from pathlib import Path



def generate_traffic(proto2keys, fname):
    random_ip = RandIP()
    random_ct = RandNum(1, 20)
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
    p1 = Path('../data/exp2/w1.csv')
    p2 = Path('../data/exp2/w2.csv')
    p3 = Path('../data/exp2/w3.csv')
    
    p4 = Path('../data/exp2/w4.csv')
    p5 = Path('../data/exp2/w5.csv')
    p6 = Path('../data/exp2/w6.csv')
    
    p1.parent.mkdir(parents=True, exist_ok=True)
    generate_traffic({6: 10, 17: 100}, p1)
    generate_traffic({6: 7, 17: 98}, p2)
    generate_traffic({6: 11, 17: 101}, p3)
    
    generate_traffic({6: 100, 17: 10}, p4)
    generate_traffic({6: 105, 17: 13}, p5)
    generate_traffic({6: 97, 17: 9}, p6)
    print("Done!")
    return


if __name__ == "__main__":
    main()

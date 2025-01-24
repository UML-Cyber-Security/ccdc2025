from dpkt import pcap, ethernet, ip, tcp, udp, icmp
from pandas import DataFrame
from socket import inet_ntoa
from hashlib import new as new_hash


PCAP_FILE = 'received.pcap'


def read_all_packets(pcap_file=PCAP_FILE):
    results = []

    with open(pcap_file, 'rb') as f:
        for timestamp, buf in pcap.Reader(f):
            eth = ethernet.Ethernet(buf)

            if isinstance(eth.data, ip.IP):
                packet = eth.data

                payload = ''
                if isinstance(packet.data, tcp.TCP) \
                        or isinstance(packet.data, udp.UDP) \
                        or isinstance(packet.data, icmp.ICMP):
                    payload = packet.data.data

                src_ip = inet_ntoa(packet.src)
                dst_ip = inet_ntoa(packet.dst)
                dst_port = packet.data.dport
                protocol = packet.p  # TCP=6, UDP=17, ICMP=1 
                packet_size = len(payload)

                results.append([
                    timestamp,
                    payload,
                    src_ip,
                    dst_ip,
                    dst_port,
                    protocol,
                    packet_size
                ])

    return results


def calculate_hash(payload, algorithm='sha256'):
    return new_hash(algorithm, payload).hexdigest()


def format_results(results):
    df = DataFrame(results, columns=[
        'timestamp',
        'payload',
        'src_ip',
        'dst_ip',
        'dst_port',
        'protocol',
        'packet_size'        
    ])

    df['hash'] = df['payload'].apply(calculate_hash)

    df = df.drop(['timestamp', 'payload'], axis=1)

    grouped = df.groupby(['hash', 'src_ip', 'dst_ip', 'dst_port', 'protocol'])
    grouped = grouped.agg(
        count=('packet_size', 'count'),
        packet_size=('packet_size', 'mean'),
    )

    grouped = grouped.sort_values(by='count', ascending=False)

    return grouped


if __name__ == '__main__':
    results = read_all_packets()
    grouped = format_results(results)

    for index, row in grouped.iterrows():
        print('')
        print(row)

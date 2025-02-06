#!/usr/bin/env python3
"""
Hidden Data PCAP Generator

Generates network capture files with malformed fragmented hidden data from JSON input.

Example:
{
    "radius": 118.53,
    "circle_area": 44138.25,
    "coordinates": {
        "lat": 54.01078,
        "lon": 38.29855
    }
}

- gl0bal01
"""

import argparse
import json
import logging
import random
import string
import sys
from typing import Dict, Any

import scapy.all as scapy
from scapy.layers.inet import IP, UDP, TCP

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

class PcapChallengeGenerator:
    @staticmethod
    def load_json_data(json_path: str) -> Dict[str, Any]:
        """Load JSON data from file."""
        try:
            with open(json_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            logger.error(f"JSON file not found: {json_path}")
            sys.exit(1)
        except json.JSONDecodeError:
            logger.error(f"Invalid JSON file: {json_path}")
            sys.exit(1)

    @staticmethod
    def fragment_data(data: Dict[str, Any], fragment_count: int) -> list:
        """Fragment JSON-encoded data."""
        try:
            json_data = json.dumps(data)
            fragment_size = len(json_data) // fragment_count
            
            fragments = [
                json_data[i * fragment_size : (i + 1) * fragment_size] 
                for i in range(fragment_count - 1)
            ]
            fragments.append(json_data[(fragment_count - 1) * fragment_size:])
            
            return fragments
        except Exception as e:
            logger.error(f"Data fragmentation error: {e}")
            return []

    @staticmethod
    def generate_random_packet():
        """Generate a random noise packet."""
        packet_type = random.choice(['udp', 'tcp'])
        
        if packet_type == 'udp':
            return (
                IP(
                    dst=f'192.168.{random.randint(1,254)}.{random.randint(1,254)}', 
                    src=f'10.{random.randint(1,254)}.{random.randint(1,254)}.{random.randint(1,254)}'
                ) / 
                UDP(dport=random.randint(1000,9999)) / 
                scapy.Raw(load=''.join(random.choices(string.ascii_letters + string.digits, k=random.randint(10,50))))
            )
        else:
            return (
                IP(
                    dst=f'192.168.{random.randint(1,254)}.{random.randint(1,254)}', 
                    src=f'10.{random.randint(1,254)}.{random.randint(1,254)}.{random.randint(1,254)}'
                ) / 
                TCP(dport=random.randint(1000,9999), flags='S') / 
                scapy.Raw(load=''.join(random.choices(string.ascii_letters + string.digits, k=random.randint(10,50))))
            )

    @classmethod
    def generate_pcap(
        cls, 
        json_path: str,
        output_filename: str = 'network_capture.pcap',
        total_packets: int = 50,
        fragment_count: int = 3
    ):
        """Generate PCAP with fragmented hidden data."""
        hidden_data = cls.load_json_data(json_path)
        packets = []
        
        fragments = cls.fragment_data(hidden_data, fragment_count)
        fragment_markers = [
            ''.join(random.choices(string.ascii_lowercase, k=5)) 
            for _ in fragments
        ]
        
        # Generate fragment packets and intersperse with noise
        for fragment, marker in zip(fragments, fragment_markers):
            # Add 1-3 noise packets before each fragment
            for _ in range(random.randint(1, 3)):
                packets.append(cls.generate_random_packet())
            
            fragment_packet = (
                IP(dst='8.8.8.8', src='192.168.1.100') / 
                UDP(dport=random.randint(1000,9999)) / 
                scapy.Raw(load=f"frag:{marker}:{fragment}")
            )
            packets.append(fragment_packet)
        
        # Generate additional noise packets to reach total_packets
        while len(packets) < total_packets:
            packets.append(cls.generate_random_packet())
        
        # Shuffle packets to further randomize order
        random.shuffle(packets)
        
        scapy.wrpcap(output_filename, packets)
        logger.info(f"PCAP file '{output_filename}' generated with {len(packets)} packets")

def main():
    parser = argparse.ArgumentParser(
        description='Hidden Data PCAP Generator',
        epilog='''
EXAMPLE USAGE:
  %(prog)s -j hidden_data.json
  %(prog)s -j hidden_data.json -o custom_capture.pcap -n 75 -f 5
''',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('json', help='Path to JSON file with hidden data')
    parser.add_argument('-o', '--output', default='network_capture.pcap', 
                        help='Output PCAP filename (default: network_capture.pcap)')
    parser.add_argument('-n', '--num-packets', type=int, default=50, 
                        help='Total number of packets to generate (default: 50)')
    parser.add_argument('-f', '--fragment-count', type=int, default=3,
                        help='Number of fragments to split the hidden data into (default: 3)')
    
    # Show help if no arguments
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)
    
    args = parser.parse_args()
    
    PcapChallengeGenerator.generate_pcap(
        json_path=args.json,
        output_filename=args.output, 
        total_packets=args.num_packets,
        fragment_count=args.fragment_count
    )

if __name__ == "__main__":
    main()

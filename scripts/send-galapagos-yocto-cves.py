#!/usr/bin/env python3

import requests
import argparse

parser = argparse.ArgumentParser(description="Utility to send CVE reports to Galapagos")

parser.add_argument("cve_json", help="Yocto generated CVE .json file")
parser.add_argument("product_name", help="Product name")
parser.add_argument("product_key", help="Product API key")
parser.add_argument("email", help="Email")
parser.add_argument("interval", help="Min interval of report: build, daily or weekly")
parser.add_argument("kernel_config", nargs='?', help="Kernel .config file for KConfig filtering")

args = parser.parse_args()

url = "https://galapagos.thegoodpenguin.co.uk/upload"

files = {"yocto_cves": open(args.cve_json, "rb")}
headers = {"Product-Key": args.product_key}
data = {"email": args.email, "product": args.product_name, "interval": args.interval}

if (args.kernel_config):
    files["config_file"] = open(args.kernel_config)

r = requests.post(url, headers=headers, data=data, files=files)
print(r.text)

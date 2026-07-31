#!/usr/bin/env python3
#
# Copyright (c) 2026 The Good Penguin Ltd
#
# SPDX-License-Identifier: MIT
#
import requests
import argparse

parser = argparse.ArgumentParser(description="Utility to send a Yocto license.manifest to Galapagos")

parser.add_argument("license_manifest", help="Yocto generated license.manifest file")
parser.add_argument("product_name", help="Product name")
parser.add_argument("product_key", help="Product API key")
parser.add_argument("email", help="Email")
parser.add_argument("interval", help="Min interval of report: build, daily or weekly")
parser.add_argument("--image_name", nargs='?', default="", help="Image name shown in the report")
parser.add_argument("--product_tag", help="Product tag")

args = parser.parse_args()

url = "https://galapagos.thegoodpenguin.co.uk/license"

files = {"license_manifest": open(args.license_manifest, "rb")}
headers = {"Product-Key": args.product_key}
data = {"email": args.email, "product": args.product_name, "interval": args.interval}

if (args.image_name):
    data["image_name"] = args.image_name
if (args.product_tag):
    data["product_tag"] = args.product_tag

r = requests.post(url, headers=headers, data=data, files=files)
print(r.text)

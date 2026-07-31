#
# Copyright (c) 2026 The Good Penguin Ltd
#
# SPDX-License-Identifier: MIT
#
# Upload files to a Galapagos endpoint

import json
import urllib.request
import urllib.error
import uuid


def _encode_multipart(fields, files):
    boundary = uuid.uuid4().hex
    body = bytearray()

    for name, value in fields.items():
        if value is None:
            continue
        body += (
            f'--{boundary}\r\n'
            f'Content-Disposition: form-data; name="{name}"\r\n'
            f'\r\n'
            f'{value}\r\n'
        ).encode()

    for name, (filename, content) in files.items():
        body += (
            f'--{boundary}\r\n'
            f'Content-Disposition: form-data; name="{name}"; '
            f'filename="{filename}"\r\n'
            f'Content-Type: application/octet-stream\r\n'
            f'\r\n'
        ).encode()
        body += content
        body += b'\r\n'

    body += f'--{boundary}--\r\n'.encode()
    return f'multipart/form-data; boundary={boundary}', bytes(body)


def _extract_server_message(raw):
    try:
        return json.loads(raw).get("message", raw)
    except (ValueError, AttributeError):
        return raw


def upload(url, product_key, fields, files, timeout=120):
    """POST form fields and files ({name: (filename, bytes)}) to a
    Galapagos endpoint. Returns (ok, message)."""
    content_type, body = _encode_multipart(fields, files)

    request = urllib.request.Request(url, data=body, method="POST")
    request.add_header("Product-Key", product_key)
    request.add_header("Content-Type", content_type)

    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            raw = response.read().decode(errors="replace")
            return True, _extract_server_message(raw)
    except urllib.error.HTTPError as e:
        raw = e.read().decode(errors="replace")
        message = _extract_server_message(raw)
        return False, f"Galapagos rejected the upload ({e.code}): {message}"
    except urllib.error.URLError as e:
        return False, f"Could not reach Galapagos at {url}: {e.reason}"
    except TimeoutError:
        return False, f"Upload to {url} timed out after {timeout}s"

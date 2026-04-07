#!/usr/bin/env python3
"""TCP client: send configured message, print server reply, exit."""
from __future__ import annotations

import os
import socket
import sys


def main() -> None:
    host = os.environ["TCP_REMOTE_HOST"]
    port = int(os.environ["TCP_REMOTE_PORT"])
    msg = os.environ["TCP_MESSAGE"]
    timeout = float(os.environ.get("TCP_TIMEOUT_SEC", "5"))
    label = os.environ.get("TCP_CLIENT_LABEL", "client")

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(timeout)
    print(f"[{label}] connecting to {host}:{port}", file=sys.stderr)
    s.connect((host, port))
    s.sendall(msg.encode("utf-8"))
    data = s.recv(65536)
    s.close()
    text = data.decode("utf-8", errors="replace")
    print(f"[{label}] reply from server: {text!r}")


if __name__ == "__main__":
    main()

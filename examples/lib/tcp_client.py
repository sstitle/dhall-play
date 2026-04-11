#!/usr/bin/env python3
"""TCP client: send configured message, print server reply, exit."""
from __future__ import annotations

import os
import socket
import sys

from tcp_support import parse_client_env


def main() -> None:
    host, port, msg, timeout, label = parse_client_env(os.environ)

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

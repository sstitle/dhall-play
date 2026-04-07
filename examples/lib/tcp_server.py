#!/usr/bin/env python3
"""One-shot TCP listener: receive one message, print it, send an ACK, exit."""
from __future__ import annotations

import os
import socket
import sys


def main() -> None:
    host = os.environ["TCP_LISTEN_HOST"]
    port = int(os.environ["TCP_LISTEN_PORT"])
    svc = os.environ.get("TCP_SERVICE_NAME", "server")

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((host, port))
    s.listen(1)
    print(f"[{svc}] listening on {host}:{port}", file=sys.stderr)

    conn, addr = s.accept()
    print(f"[{svc}] connection from {addr}", file=sys.stderr)
    data = conn.recv(65536)
    text = data.decode("utf-8", errors="replace")
    print(f"[{svc}] received message: {text!r}")

    reply = f"ACK svc={svc} bytes={len(data)}\n"
    conn.sendall(reply.encode("utf-8"))
    conn.close()
    s.close()


if __name__ == "__main__":
    main()

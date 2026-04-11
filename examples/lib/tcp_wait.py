#!/usr/bin/env python3
"""CLI: block until a TCP port is in LISTEN (bind probe; used by mask run)."""

from __future__ import annotations

import sys

from tcp_support import wait_for_listen_port


def main() -> None:
    if len(sys.argv) < 3:
        print("usage: tcp_wait.py <host> <port> [timeout_sec]", file=sys.stderr)
        sys.exit(2)
    host = sys.argv[1]
    port = int(sys.argv[2])
    timeout = float(sys.argv[3]) if len(sys.argv) > 3 else 30.0
    wait_for_listen_port(host, port, timeout_sec=timeout)


if __name__ == "__main__":
    main()

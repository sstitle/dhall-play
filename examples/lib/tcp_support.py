"""Pure helpers for TCP demo env parsing and listen readiness (bind probe; injectable for tests)."""

from __future__ import annotations

import errno
import socket
from collections.abc import Callable, Mapping


def parse_server_env(env: Mapping[str, str]) -> tuple[str, int, str]:
    host = env["TCP_LISTEN_HOST"]
    port = int(env["TCP_LISTEN_PORT"])
    svc = env.get("TCP_SERVICE_NAME", "server")
    return host, port, svc


def parse_client_env(env: Mapping[str, str]) -> tuple[str, int, str, float, str]:
    host = env["TCP_REMOTE_HOST"]
    port = int(env["TCP_REMOTE_PORT"])
    msg = env["TCP_MESSAGE"]
    timeout = float(env.get("TCP_TIMEOUT_SEC", "5"))
    label = env.get("TCP_CLIENT_LABEL", "client")
    return host, port, msg, timeout, label


def _default_listen_probe(host: str, port: int) -> bool:
    """Return True if something is already bound to (host, port) (e.g. our server).

    Uses a bind attempt so we never consume a connection from a one-shot accept() server.
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.bind((host, port))
        return False
    except OSError as e:
        if e.errno == errno.EADDRINUSE:
            return True
        raise
    finally:
        try:
            s.close()
        except OSError:
            pass


def wait_for_listen_port(
    host: str,
    port: int,
    *,
    timeout_sec: float,
    monotonic: Callable[[], float] | None = None,
    sleep_fn: Callable[[float], None] | None = None,
    listen_probe: Callable[[str, int], bool] | None = None,
) -> None:
    import time

    mono = monotonic or time.monotonic
    sleep = sleep_fn or time.sleep
    probe = listen_probe or _default_listen_probe
    deadline = mono() + timeout_sec
    while mono() < deadline:
        if probe(host, port):
            return
        sleep(0.05)
    raise TimeoutError(f"TCP {host}:{port} not listening within {timeout_sec}s")

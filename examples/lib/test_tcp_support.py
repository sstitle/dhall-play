"""Unit tests for tcp_support (env parsing + listen readiness with injected I/O)."""

from __future__ import annotations

import pytest

from tcp_support import parse_client_env, parse_server_env, wait_for_listen_port


def test_parse_server_env_required() -> None:
    env = {
        "TCP_LISTEN_HOST": "127.0.0.1",
        "TCP_LISTEN_PORT": "4100",
        "TCP_SERVICE_NAME": "alpha-peer",
    }
    assert parse_server_env(env) == ("127.0.0.1", 4100, "alpha-peer")


def test_parse_server_env_default_service_name() -> None:
    env = {
        "TCP_LISTEN_HOST": "0.0.0.0",
        "TCP_LISTEN_PORT": "9",
    }
    assert parse_server_env(env) == ("0.0.0.0", 9, "server")


def test_parse_server_env_missing_host_raises() -> None:
    with pytest.raises(KeyError):
        parse_server_env({"TCP_LISTEN_PORT": "1"})


def test_parse_client_env_required() -> None:
    env = {
        "TCP_REMOTE_HOST": "127.0.0.1",
        "TCP_REMOTE_PORT": "4100",
        "TCP_MESSAGE": "hi",
        "TCP_TIMEOUT_SEC": "3",
        "TCP_CLIENT_LABEL": "alpha-user",
    }
    assert parse_client_env(env) == ("127.0.0.1", 4100, "hi", 3.0, "alpha-user")


def test_parse_client_env_default_timeout_and_label() -> None:
    env = {
        "TCP_REMOTE_HOST": "127.0.0.1",
        "TCP_REMOTE_PORT": "1",
        "TCP_MESSAGE": "x",
    }
    assert parse_client_env(env) == ("127.0.0.1", 1, "x", 5.0, "client")


def test_wait_for_listen_port_succeeds_after_probe_flips() -> None:
    t = [0.0]
    attempts = [0]

    def mono() -> float:
        return t[0]

    def sleep(dt: float) -> None:
        t[0] += dt

    def probe(_h: str, _p: int) -> bool:
        attempts[0] += 1
        return attempts[0] >= 2

    wait_for_listen_port(
        "127.0.0.1",
        4100,
        timeout_sec=5.0,
        monotonic=mono,
        sleep_fn=sleep,
        listen_probe=probe,
    )
    assert attempts[0] == 2


def test_wait_for_listen_port_times_out() -> None:
    t = [0.0]

    def mono() -> float:
        return t[0]

    def sleep(dt: float) -> None:
        t[0] += dt

    def probe(_h: str, _p: int) -> bool:
        return False

    with pytest.raises(TimeoutError):
        wait_for_listen_port(
            "127.0.0.1",
            9,
            timeout_sec=0.2,
            monotonic=mono,
            sleep_fn=sleep,
            listen_probe=probe,
        )

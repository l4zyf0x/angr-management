def monkeypatch_rpyc():

    # The AsyncResult in rpyc has a bug that causes a race condition when clients are cascaded. this monkeypatch fixes
    # the bug.
    from rpyc.core.async_ import AsyncResult, AsyncResultTimeout

    def patched_wait(self):
        while not self._is_ready and not self._ttl.expired():
            self._conn.serve(0.01)
        if not self._is_ready:
            raise AsyncResultTimeout("result expired")

    AsyncResult.wait = patched_wait


monkeypatch_rpyc()


from .server import daemon_conn, daemon_exists, start_daemon, run_daemon_process
from .url_handler import handle_url

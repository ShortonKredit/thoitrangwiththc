#!/usr/bin/env python3
"""Tiny local server with MIME types required by Godot Web exports."""
from __future__ import annotations

import argparse
import http.server
import mimetypes
import os
from pathlib import Path

mimetypes.add_type("application/wasm", ".wasm")
mimetypes.add_type("application/octet-stream", ".pck")
mimetypes.add_type("application/javascript", ".js")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default="build/web")
    parser.add_argument("--port", type=int, default=8000)
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if not (root / "index.html").exists():
        raise SystemExit(f"Missing {root / 'index.html'}; export Web first.")
    os.chdir(root)
    server = http.server.ThreadingHTTPServer(("127.0.0.1", args.port), http.server.SimpleHTTPRequestHandler)
    print(f"Serving {root} at http://127.0.0.1:{args.port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()

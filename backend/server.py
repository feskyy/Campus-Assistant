"""Real HTTP server with DEMONSTRATION data; no university integration."""
import argparse
import json
from pathlib import Path
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit

DATA = json.loads(Path(__file__).with_name("campus_demo.json").read_text(encoding="utf-8"))

def response_data(path):
    if path == "/health":
        return {"status": "ok", "source": "demo", "universityData": False}
    return DATA.get(path.lstrip("/")) if path in {"/schedule", "/news", "/events", "/subjects", "/teachers", "/buildings"} else None

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        data = response_data(urlsplit(self.path).path)
        body = json.dumps(data if data is not None else {"error": "Not found"},
                          ensure_ascii=False).encode("utf-8")
        self.send_response(200 if data is not None else 404)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Expose-Headers", "X-Campus-Data-Source")
        self.send_header("X-Campus-Data-Source", "demo")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        # HTTP status and route only; no account data is handled by this server.
        super().log_message(fmt, *args)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8085)
    args = parser.parse_args()
    print(f"DEMONSTRATION API: http://{args.host}:{args.port}", flush=True)
    with ThreadingHTTPServer((args.host, args.port), Handler) as server:
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass

if __name__ == "__main__":
    main()

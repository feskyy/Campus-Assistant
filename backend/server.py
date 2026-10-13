"""Real HTTP server with DEMONSTRATION data; no university integration."""
import argparse
import json
from datetime import datetime, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit

DATA = {
    "/schedule": [
        {"id": "test-lesson-1", "subject": "Демонстрация: Flutter",
         "teacher": "Тестовый преподаватель", "building": "Тестовый корпус",
         "room": "101", "weekday": 1, "startMinutes": 540, "endMinutes": 630,
         "type": "lab", "group": "TEST-101"},
        {"id": "test-lesson-2", "subject": "Демонстрация: REST API",
         "teacher": "Тестовый преподаватель", "building": "Тестовый корпус",
         "room": "102", "weekday": 2, "startMinutes": 600, "endMinutes": 690,
         "type": "practice", "group": "TEST-101"},
        {"id": "test-lesson-3", "subject": "Демонстрация: базы данных",
         "teacher": "Тестовый преподаватель", "building": "Тестовый корпус",
         "room": "201", "weekday": 3, "startMinutes": 540, "endMinutes": 630,
         "type": "lecture", "group": "TEST-102"},
    ],
    "/news": [
        {"id": "test-news", "title": "Демонстрация REST API",
         "summary": "Тестовая новость; не информация университета.",
         "content": "Это полный текст тестовой новости. Приложение получило его настоящим HTTP-запросом.",
         "category": "Демонстрация", "publishedAt": "2026-10-12T09:00:00"},
    ],
}

def response_data(path):
    if path == "/health":
        return {"status": "ok", "source": "demo", "universityData": False}
    if path == "/events":
        start = datetime.now().replace(hour=10, minute=0, second=0, microsecond=0) + timedelta(days=7)
        return [{"id": "test-event", "title": "Демонстрационное событие",
                 "description": "Тестовый пример. Это не мероприятие университета.",
                 "location": "Тестовый корпус", "startAt": start.isoformat()}]
    return DATA.get(path)

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

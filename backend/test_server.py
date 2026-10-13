"""Integration checks against a real local HTTP server."""
import json
import threading
import unittest
from urllib.error import HTTPError
from urllib.request import urlopen
from http.server import ThreadingHTTPServer
from server import Handler

class ServerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()

    def test_endpoints_are_json_and_explicitly_demo(self):
        for path in ["/schedule", "/news", "/events"]:
            with self.subTest(path=path), urlopen(self.base + path, timeout=5) as response:
                self.assertEqual(response.status, 200)
                self.assertEqual(response.headers["X-Campus-Data-Source"], "demo")
                self.assertIsInstance(json.load(response), list)

    def test_query_string_does_not_break_route(self):
        with urlopen(self.base + "/schedule?group=TEST-101", timeout=5) as response:
            self.assertIsInstance(json.load(response), list)

    def test_health_marks_test_data(self):
        with urlopen(self.base + "/health", timeout=5) as response:
            data = json.load(response)
            self.assertEqual(data["source"], "demo")
            self.assertFalse(data["universityData"])

    def test_unknown_route_is_404_json(self):
        with self.assertRaises(HTTPError) as caught:
            urlopen(self.base + "/missing", timeout=5)
        self.assertEqual(caught.exception.code, 404)
        self.assertEqual(json.load(caught.exception)["error"], "Not found")
        caught.exception.close()

if __name__ == "__main__":
    unittest.main()

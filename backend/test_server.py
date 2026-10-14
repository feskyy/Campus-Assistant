"""Integration checks against a real local HTTP server."""
import json
import threading
import unittest
from urllib.error import HTTPError
from urllib.request import urlopen
from http.server import ThreadingHTTPServer
from server import Handler
from pathlib import Path
import struct

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
        for path in ["/schedule", "/news", "/events", "/subjects", "/teachers", "/buildings"]:
            with self.subTest(path=path), urlopen(self.base + path, timeout=5) as response:
                self.assertEqual(response.status, 200)
                self.assertEqual(response.headers["X-Campus-Data-Source"], "demo")
                self.assertIsInstance(json.load(response), list)

    def test_rich_content_counts_and_references(self):
        data = {}
        for resource in ["schedule", "news", "events", "subjects", "teachers", "buildings"]:
            with urlopen(self.base + "/" + resource, timeout=5) as response:
                data[resource] = json.load(response)
        self.assertGreaterEqual(len(data["news"]), 8)
        self.assertGreaterEqual(len(data["events"]), 6)
        self.assertGreaterEqual(len(data["subjects"]), 5)
        self.assertGreaterEqual(len(data["teachers"]), 5)
        self.assertEqual(len(data["buildings"]), 4)
        subjects = {item["id"]: item for item in data["subjects"]}
        teachers = {item["id"]: item for item in data["teachers"]}
        buildings = {item["id"]: item for item in data["buildings"]}
        for item in data["news"]:
            self.assertTrue(4 <= len(item["blocks"]) <= 6)
            self.assertGreater(len(item["content"]), 500)
            self.assertEqual({block["type"] for block in item["blocks"]}, {"heading", "paragraph", "quote", "keyFacts", "image"})
            self.assertIn(item["relatedBuildingId"], buildings)
        for item in data["events"]:
            self.assertIn(item["buildingId"], buildings)
            self.assertIn(item["room"], {room["number"] for room in buildings[item["buildingId"]]["rooms"]})
            self.assertGreater(item["capacity"], 0)
            self.assertGreaterEqual(item["price"], 0)
            self.assertTrue(item["organizer"] and item["tags"])
        for item in data["subjects"]:
            self.assertIn(item["teacherId"], teachers)
            self.assertGreaterEqual(len(item["syllabus"]), 4)
            self.assertTrue(item["materials"])
        for item in data["teachers"]:
            self.assertIn(item["officeBuildingId"], buildings)
            self.assertTrue(item["email"].endswith(".invalid"))
        self.assertEqual({item["weekday"] for item in data["schedule"] if item["group"] == "CS-221"}, {1,2,3,4,5})
        for item in data["schedule"]:
            self.assertIn(item["subjectId"], subjects)
            self.assertIn(item["teacherId"], teachers)
            self.assertIn(item["buildingId"], buildings)
            self.assertGreater(item["endMinutes"], item["startMinutes"])
            self.assertTrue(item["topic"] and item["notes"])
        for item in buildings.values():
            self.assertGreaterEqual(len(item["rooms"]), 6)
            self.assertTrue(0 <= item["x"] <= 1 and 0 <= item["y"] <= 1)
            for room in item["rooms"]:
                self.assertGreater(room["capacity"], 0)
                self.assertLessEqual(room["floor"], item["floors"])
                self.assertTrue(room["equipment"])
                self.assertTrue(room["hint"].startswith(f"Этаж {room['floor']}"))

    def test_all_image_paths_have_original_pngs_with_expected_sizes(self):
        root = Path(__file__).resolve().parent.parent
        for resource, field in [("news", "imageUrl"), ("events", "coverUrl"), ("subjects", "coverUrl"), ("teachers", "photoUrl"), ("buildings", "photoUrl")]:
            with urlopen(self.base + "/" + resource, timeout=5) as response:
                for item in json.load(response):
                    path = root / item[field]
                    with self.subTest(image=str(path)):
                        header = path.read_bytes()[:24]
                        self.assertEqual(header[:8], b"\x89PNG\r\n\x1a\n")
                        self.assertEqual(struct.unpack("!II", header[16:24]), (400,400) if resource == "teachers" else (1600,1000))

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

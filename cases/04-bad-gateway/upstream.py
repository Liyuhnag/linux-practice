#!/usr/bin/env python3
import http.server
import socketserver

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"upstream ok\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass

with socketserver.TCPServer(("127.0.0.1", 18082), Handler) as httpd:
    httpd.serve_forever()

#!/usr/bin/env python3
import http.server
import socketserver

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"ok\n")

    def log_message(self, *args):
        pass

with socketserver.TCPServer(("127.0.0.1", 18080), Handler) as httpd:
    httpd.serve_forever()

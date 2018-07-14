#!/usr/bin/python3

from socketserver import TCPServer, StreamRequestHandler
import socket
import logging

class Handler(StreamRequestHandler):
    def handle(self):
        self.data = self.rfile.readline().strip()
        logging.info("From <%s>: %s" % (self.client_address, self.data))
        self.wfile.write(self.data.upper() + "\r\n")

class Server(TCPServer):
    
    # The constant would be better initialized by a systemd module
    SYSTEMD_FIRST_SOCKET_FD = 3

    def __init__(self, server_address, handler_cls):
        # Invoke base but omit bind/listen steps (performed by systemd activation!)
        TCPServer.__init__(
            self, server_address, handler_cls, bind_and_activate=False)
        # Override socket
        self.socket = socket.fromfd(
            self.SYSTEMD_FIRST_SOCKET_FD, self.address_family, self.socket_type)

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    HOST, PORT = "localhost", 9999 # not really needed here
    server = Server((HOST, PORT), Handler)
    server.serve_forever()

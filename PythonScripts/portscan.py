
import socket

hosts = ['127.0.0.1', '192.168.1.5', '10.0.0.1']
ports = [22, 445, 80, 443, 3389]

s = socket.socket()

for host in hosts:
  for port in ports:
    try:
      s.connect((host, port))
      s.send('pwnd')
      banner = s.recv(1024)
      if banner:
        print "[+] Port " + str(port) + " at " + host + " OPEN"
      s.close
    except: pass

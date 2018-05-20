FILE = "/home/aaf/.aws/credentials"

with open(FILE, 'r') as myfile:
      var = myfile.read()

print(var)

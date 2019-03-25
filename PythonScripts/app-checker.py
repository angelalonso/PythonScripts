#/usr/bin/env python3

import getopt
import sys
import urllib.request
import requests
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class bcolors:
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

# Default parameters
SHOWALL = False
JUMP = ""

ENVS = ["production-asia",
        "production-eu",
        "staging"]

ENVSUFFIX = {"production-asia": "",
             "production-eu": "",
             "staging": "-st"}

CCDOMAINS = {
           "bd": "foodpanda.com.bd",
           "bn": "foodpanda.com.bn",
           "hk": "foodpanda.hk",
           "my": "foodpanda.my",
           "ph": "foodpanda.ph",
           "pk": "foodpanda.pk",
           "sg": "foodpanda.sg",
           "th": "foodpanda.co.th",
           "tw": "foodpanda.com.tw",
           "au": "foodora.com.au",
           "at": "foodora.at",
           "bg": "foodpanda.bg",
           "ca": "foodora.ca",
           "de": "foodora.de",
           "fi": "foodora.fi",
           "fr": "foodora.fr",
           "it": "foodora.it",
           "nl": "foodora.nl",
           "no": "foodora.no",
           "ro": "foodpanda.ro",
           "se": "foodora.se",
           "op": "onlinepizza.se",
           "po": "pizza-online.fi" 
           }

ASIA_CC = ['bd',
           'bn',
           'hk',
           'my',
           'ph',
           'pk',
           'sg',
           'th',
           'tw']

EU_CC = ['at',
         'au',
         'bg',
         'ca',
         'de',
         'fi',
         'fr',
         'it',
         'nl',
         'no',
         'ro',
         'se',
         'op',
         'po']

URLFORMAT = {"backend": "<cc><envsuffix>.fd-admin.com",
             "api": "<cc><envsuffix>.fd-api.com",
             "b2c": "www<envsuffix>.<ccdomain>",
             "b2b": "corporate<envsuffix>.<ccdomain>",
             "atlas": "<cc><envsuffix>.fd-api.com/atlas",
             "expositor": "<cc><envsuffix>.fd-api.com/expositor",
             "sherlock": "<cc><envsuffix>.fd-api.com/sherlock",
             "newton": "<cc><envsuffix>.fd-api.com/newton",
             "midas": "<cc><envsuffix>.fd-api.com/midas",
             "internal-api": "<cc><envsuffix>.fd-api.com/internal-api",
             "order-tracker": "<cc><envsuffix>.fd-api.com/order-tracker",
             "pidgey": "<cc><envsuffix>.fd-api.com/pidgey"}
     
def buildURL(template, env, country):
  result = template.replace("<cc>", country).replace("<envsuffix>", ENVSUFFIX[env]).replace("<ccdomain>", CCDOMAINS[country])
  return result

def buildRequests():
  for env in ENVS:
    if env == "production-asia":
      CC = ASIA_CC
    elif env == "production-eu":
      CC = EU_CC
    else:
      CC = EU_CC + ASIA_CC
    for country in CC:
      for key in URLFORMAT:
        url = buildURL(URLFORMAT[key], env, country)
        if JUMP == "":
          doRequest(env, country, key, url)
        else:
          doRequestWithJump(env, country, key, url)

def doRequest(env, cc, app, url):
  healthcheck = "https://"+url+"/health/check"
  r = requests.get(healthcheck)
  data = r.content  # Content of response
  generateOutput(env, cc, app, healthcheck, str(r.status_code))

def doRequestWithJump(env, cc, app, url):
  healthcheck = "https://"+JUMP+"/health/check"
  r = requests.get(healthcheck, headers={"Host":url}, verify=False)
  data = r.content  # Content of response
  generateOutput(env, cc, app, url, str(r.status_code))

def generateOutput(env, cc, app, url, data):
  if (data == "520" or data == "503" or data == "404"):
    print(env + " " + cc + " " + app + " - " + url + " " + bcolors.FAIL + data + bcolors.ENDC)
  elif data != "200":
    print(env + " " + cc + " " + app + " - " + url + " " + bcolors.WARNING + data + bcolors.ENDC)
  else:
    if SHOWALL:
      print(env + " " + cc + " " + app + " - " + url + " " + bcolors.OKGREEN + data + bcolors.ENDC)

def showHelp():
  print("SYNTAX")
  print("\t-e <env>         Check only the <env> environment. E.g.: production-eu")
  print("\t-j <jumppoint>   Send requests through a jump point. E.g.: A Load Balancer")
  print("\t-a               Show also successful checks")
  print("\t-h               Show this help")


if __name__ == '__main__':
  fullCmdArguments = sys.argv
  argumentList = fullCmdArguments[1:]
  unixOptions = "hj:e:a"  
  gnuOptions = ["help", "jump=", "env=", "all"]  
  try:  
    arguments, values = getopt.getopt(argumentList, unixOptions, gnuOptions)
  except getopt.error as err:  
    # output error, and return with an error code
    print (str(err))
    sys.exit(2)
  for currentArgument, currentValue in arguments:  
    if currentArgument in ("-h", "--help"):
      showHelp()
      sys.exit(0)
    elif currentArgument in ("-j", "--jump"):
      JUMP = currentValue
    elif currentArgument in ("-e", "--env"):
      ENVS = [currentValue]
    elif currentArgument in ("-a", "--all"):
      SHOWALL = True
  buildRequests()

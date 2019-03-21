#/usr/bin/env python3

import urllib.request
import requests

ENVS = ("production-asia",
        "production-eu",
        "staging")

ENVREGIONS = {"production-asia": ("asia"),
             "production-eu": ("eu"),
             "staging": ("asia", "eu")}

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
ASIA_CC = ('bd',
           'bn',
           'hk',
           'my',
           'ph',
           'pk',
           'sg',
           'th',
           'tw')

EU_CC = ('at',
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
         'po')

URLFORMAT = {"backend": "<cc><envsuffix>.fd-admin.com",
             "api": "<cc><envsuffix>.fd-api.com",
             "b2c": "www<envsuffix>.<ccdomain>"}
     
def buildURL(template, env, country):
  result = template.replace("<cc>", country).replace("<envsuffix>", ENVSUFFIX[env]).replace("<ccdomain>", CCDOMAINS[country])
  return result

def buildRequests():
  #env = "production-asia"
  env = "staging"
  for country in ASIA_CC:
    for key in URLFORMAT:
      url = buildURL(URLFORMAT[key], env, country)
      print(url)
      doRequest(url)

def doRequest(URL, ):
  r = requests.get("https://"+URL+"/health/check", headers={"Host":URL}, verify=False)
  data = r.content  # Content of response

  print(r.status_code)  # Status code of response
  #print(data)

if __name__ == '__main__':
  buildRequests()

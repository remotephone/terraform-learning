## didn't finish this, but this was to mess around and pull the file and drop it
# where it needs to be automatically. maybe if it become smore useful.

import requests
import magic
from requests_html import HTMLSession
import zipfile


session = HTMLSession()
r = session.get('https://www.terraform.io/downloads.html')

for link in r.html.links:
    if 'linux_amd64' in link:
        terrazip = requests.get(link, allow_redirects=True)


with zipfile.ZipFile(terrazip) as terrazip:

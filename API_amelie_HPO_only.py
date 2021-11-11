#! /usr/bin/env python3

import sys
import json
import requests


url = 'https://amelie.stanford.edu/api/gene_list_api/'


def main():
    response = requests.post(
        url,
        verify=False,
        data={'patientName': 'Example patient',
              'phenotypes': sys.argv[1],
              'genes': sys.argv[2]})
              
    print(json.dumps(response.json(), indent=4))


if __name__ == "__main__":
    main()
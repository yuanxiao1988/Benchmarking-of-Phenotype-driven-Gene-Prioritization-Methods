#! /usr/bin/env python3

import sys
import json
import requests


url = 'https://amelie.stanford.edu/api/vcf_api/'


def main():
    response = requests.post(
        url,
        verify=False,
        files={'vcfFile': open(sys.argv[2], 'rb')}, 
        data={'dominantAlfqCutoff': 0.1,
              'alfqCutoff': 0.5, # min. 0.1; max. 3.0 (percent)
              'filterByCount': False,
              'hmctCutoff': 1,
              'alctCutoff': 3,
              'patientName': 'Example patient',
              'patientSex': None, # 'MALE' or 'FEMALE', or None
              'onlyPassVariants': True,
              'filterRelativesOnlyHom': False,
              'phenotypes': sys.argv[1]}) #'HP:0001156,HP:0001363,HP:0011304,HP:0010055'
    print(json.dumps(response.json(), indent=4))


if __name__ == "__main__":
    main()
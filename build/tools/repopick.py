#!/usr/bin/env python2.7
#
# Copyright (C) 2013-15 The CyanogenMod Project
#           (C) 2017    The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Run repopick.py -h for a description of this utility.
#

from __future__ import print_function

import sys
import json
import os
import subprocess
import re
import argparse
import textwrap
from functools import cmp_to_key
from xml.etree import ElementTree

try:
    import requests
except ImportError:
    try:
        # For python3
        import urllib.error
        import urllib.request
    except ImportError:
        # For python2
        import imp
        import urllib2
        urllib = imp.new_module('urllib')
        urllib.error = urllib2
        urllib.request = urllib2


# Verifies whether pathA is a subdirectory (or the same) as pathB
def is_subdir(a, b):
    a = os.path.realpath(a) + '/'
    b = os.path.realpath(b) + '/'
    return b == a[:len(b)]


def fetch_query_via_ssh(remote_url, query):
    """Given a remote_url and a query, return the list of changes that fit it
       This function is slightly messy - the ssh api does not return data in the same structure as the HTTP REST API
       We have to get the data, then transform it to match what we're expecting from the HTTP RESET API"""
    if remote_url.count(':') == 2:
        (uri, userhost, port) = remote_url.split(':')
        userhost = userhost[2:]
    elif remote_url.count(':') == 1:
        (uri, userhost) = remote_url.split(':')
        userhost = userhost[2:]
        port = 29418
    else:
        raise Exception('Malformed URI: Expecting ssh://[user@]host[:port]')


    out = subprocess.check_output(['ssh', '-x', '-p{0}'.format(port), userhost, 'gerrit', 'query', '--format=JSON --patch-sets --current-patch-set', query])
    if not hasattr(out, 'encode'):
        out = out.decode()
    reviews = []
    for line in out.split('\n'):
        try:
            data = json.loads(line)
            # make our data look like the http rest api data
            review = {
                'branch': data['branch'],
                'change_id': data['id'],
                'current_revision': data['currentPatchSet']['revision'],
                'current_patch_set': data['currentPatchSet']['number'],
                'number': int(data['number']),
                'revisions': {patch_set['revision']: {
                    'number': int(patch_set['number']),
                    'fetch': {
                        'ssh': {
                            'ref': patch_set['ref'],
                            'url': 'ssh://{0}:{1}/{2}'.format(userhost, port, data['project'])
                        }
                    }
                } for patch_set in data['patchSets']},
                'subject': data['subject'],
                'project': data['project'],
                'status': data['status']
            }
            reviews.append(review)
        except:
            pass
    args.quiet or print('Found {0} reviews'.format(len(reviews)))
    return reviews


def fetch_query_via_http(remote_url, query):
    if "requests" in sys.modules:
        auth = None
        if os.path.isfile(os.getenv("HOME") + "/.gerritrc"):
            f = open(os.getenv("HOME") + "/.gerritrc", "r")
            for line in f:
                parts = line.rstrip().split("|")
                if parts[0] in remote_url:
                    auth = requests.auth.HTTPBasicAuth(username=parts[1], password=parts[2])
        statusCode = '-1'
        if auth:
            url = '{0}/a/changes/?q={1}&o=CURRENT_REVISION&o=ALL_REVISIONS&o=ALL_COMMITS'.format(remote_url, query)
            data = requests.get(url, auth=auth)
            statusCode = str(data.status_code)
        if statusCode != '200':
            #They didn't get good authorization or data, Let's try the old way
            url = '{0}/changes/?q={1}&o=CURRENT_REVISION&o=ALL_REVISIONS&o=ALL_COMMITS'.format(remote_url, query)
            data = requests.get(url)
        reviews = json.loads(data.text[5:])
    else:
        """Given a query, fetch the change numbers via http"""
        url = '{0}/changes/?q={1}&o=CURRENT_REVISION&o=ALL_REVISIONS&o=ALL_COMMITS'.format(remote_url, query)
        data = urllib.request.urlopen(url).read().decode('utf-8')
        reviews = json.loads(data[5:])

    for review in reviews:
        review['number'] = review.pop('_number')

    return reviews


def fetch_query(remote_url, query):
    """Wrapper for fetch_query_via_proto functions"""
    if remote_url[0:3] == 'ssh':
        return fetch_query_via_ssh(remote_url, query)
    elif remote_url[0:4] == 'http':
        return fetch_query_via_http(remote_url, query.replace(' ', '+'))
    else:
        raise Exception('Gerrit URL should be in the form http[s]://hostname/ or ssh://[user@]host[:port]')

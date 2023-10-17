#!/usr/bin/env python
# encoding: utf-8
"""
spstool.py

Should run in python2 and python3
Created by Ralf Weber on 2019-01-15.
Copyright (c) 2019 Akamai Inc. All rights reserved.
"""

from __future__ import print_function

import argparse
import dns.message
import requests
import threading
import time


class askdoh(threading.Thread):
    def __init__ (self,connectionnumber, dohserver, verify,
            wirequestion,sleep, iterations, debug=0):
        threading.Thread.__init__(self)
        self.connectionnumber = connectionnumber
        self.iterations = iterations
        self.dohserver = dohserver
        self.verify = verify
        self.wirequestion = wirequestion
        self.sleep = sleep
        self.iterations = iterations
        self.debug = debug
        self.goodrequests = 0
        self.badrequests = 0
    def run (self):
        if self.debug > 0:
            print ("Starting connection: {:d}".format(self.connectionnumber))
        client=requests.Session()
        headers = { 'accept': 'application/dns-message',
                'content-type': 'application/dns-message'}
        for i in range(self.iterations):
            if self.debug > 1:
                print ("Connection: {:d}\tRequest: {:d}".format(self.connectionnumber, i))
            try:
                r = client.post(self.dohserver,headers=headers, 
                    data=self.wirequestion, timeout=self.sleep, verify=self.verify)
            except Exception as e:
                self.badrequests = self.badrequests + 1
                if self.debug > 1:
                    print (e)
            else:
                self.goodrequests = self.goodrequests + 1
                if r.elapsed.total_seconds() < self.sleep:
                    time.sleep(float(self.sleep) - r.elapsed.total_seconds())
    def status (self):
        return (self.connectionnumber, self.goodrequests, self.badrequests)


def getglobalparsersettings (parser):
    parser.add_argument("-s", "--sleep", help="number of seconds to sleep between DoH questions default=%(default)s", type=int, default=5)
    parser.add_argument("-i", "--iterations", help="number of times to send the DoH questions default=%(default)s", type=int, default=5)
    parser.add_argument('-n', '--no-validation', action='store_true', help="Don't validate the SSL certificate")
    parser.add_argument('--version', action='version', 
        version='%(prog)s 0.1')
    parser.add_argument("-d", "--debug", help="debug level 0 means no \
        debug and is the default", type=int, default=0)
    parser.add_argument('connections', help='number of different connections to create', type=int)
    parser.add_argument('qname', help='query name to ask the DoH server')
    parser.add_argument('qtype', help='query type to ask the DoH server')
    parser.add_argument('dohurl', help='URL of the DoH server to ask')
    return (parser)

def getparserandenv ():
    parser = argparse.ArgumentParser(description="Flood a DoH server with multiple connections that stay active")
    parser = getglobalparsersettings (parser)
    return (parser)


def main():
    parser = getparserandenv ()
    args = parser.parse_args()
    m = dns.message.make_query(args.qname, args.qtype)
    w = m.to_wire()
    allthreads = []
    for i in range(args.connections):
        t = askdoh(i, args.dohurl,not args.no_validation, w,args.sleep,args.iterations,args.debug)
        allthreads.append(t)
        t.start()
    successfullconnections = 0
    goodrequests = 0
    badrequests = 0
    for t in allthreads:
        t.join()
        (conn, good, bad) = t.status()
        if good > 0:
            successfullconnections = successfullconnections + 1
        goodrequests =  goodrequests + good
        badrequests = badrequests + bad
    print ("Possible requests {}".format(args.connections * args.iterations))
    print ("Successful connections {}".format(successfullconnections) )
    print ("Possible successfull {}".format(successfullconnections * args.iterations))
    print ("Good requests {}".format(goodrequests))
    print ("Bad requests {}".format(badrequests))


if __name__ == '__main__':
    main()

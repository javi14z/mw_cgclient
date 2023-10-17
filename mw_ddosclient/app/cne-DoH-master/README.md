# DoH

## **DNS over HTTPS**

We have been working on the use of DoH (DNS over HTTPS) in two ways. One at the operating
system level by installing a protocol capable of handling these requests, and the other way by
using a script that is capable of launching requests by choosing a DoH server and getting the
results of the possible connections.

### Dnscrypt-Proxy

DNSCrypt is a protocol that encrypts, authenticates, and optionally anonymizes
communications between a DNS client and a DNS resolver. It prevents DNS spoofing. It uses
cryptographic signatures to verify that responses originate from the chosen DNS resolver and
have not been tampered with.

It is an open specification, with free and open source reference implementations, and it is not
affiliated with any company nor organization.
We followed this guideline (https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-linux) where you can find the instructions to install dnscrypt-proxy. Once
we have installed this, we can choose the DoH’s servers changing the script:

**dnscrypt-proxy.toml**

And here is where you decide the servers:

![image1](https://github.com/Telefonica/cne-DoH/blob/master/image1.PNG)


Then, to check if all have gone in the correct form you can open yourbrowser and type
https://1.1.1.1/help in which you are able to see if DoH is being used.

### Floodoh.py

In order to do a quick test on lots of connections to a DoH server we have been using a small
python script that generates connections and occasionally asks a question in them.

The program requires dnspython and the requests library to be installed for the python you
use (it should work with both python2 and python3). On a Redhat/Centos system you can get
those with: yum install pythonrequests python-dns.

Once you got that program running (check with flooddoh.py -h if you got all the pre requisites)
here are the parameters needed (in that order):
- connections are the number of concurrent connections to create. Given that python
multithreading has its limits, you probably don't want more then a couple of hundreds
or maybe a thousand here as it quickly can be non reliable and might go beyond
system limits for a single process.
- qname the DNS name in question to ask over and over again.
- qtype the query type to ask for.
- dohurl the URL of the DoH server.

Here is an example run with output of the program:

![image2](https://github.com/Telefonica/cne-DoH/blob/master/image2.PNG)

a normal run tries to mimik a common DoH connection asking 5 questions in a connections
with one query every five seconds. These parameters are of course tunable and here are the
common switches you want to use for doing that:
-   -i iterations are the number of times you want to send that query through the
connection
 -  -s sleep the amount of time to wait before sending the next query
with these parameters the run time of the script is the sleep time multiplied by the iterations
and the qps you will see at the server constantly is the number of connections divided by the
sleep time.

In case you want to see what the program is doing you can see every query as it is send using -
d 2.

If you want to load tens of thousands of connections it is a good idea to start multiple
instances of flooddoh.py (don't try more than 50k connections overallper machine) and then
add more machines.

In order to do this last point, we create a simple script of shell called prueba.sh in which you
can choose:

- The number of instances you want.
- The server you choose.
- The number of connections.

## Scenario

In our lab we have created a test scenario which is similar to:

![image3](https://github.com/Telefonica/cne-DoH/blob/master/Scenario.PNG)

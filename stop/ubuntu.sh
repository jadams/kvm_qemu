#!/usr/bin/bash

{ echo system_powerdown; sleep 3; } | telnet 127.0.0.1 7777

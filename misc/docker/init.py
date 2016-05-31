#!/usr/bin/python
"""
Init script for dist_test Docker Image
"""

import os
import subprocess
import sys

def log(s):
    print 'INIT: %s' % s

def run_system_daemon(daemon):
    log('Starting daemon: %s' % daemon)
    rc = subprocess.call(['service', daemon, 'start'])
    if rc != 0:
        log('Exiting with status %d..(%s)' % (rc, daemon))
        sys.exit(rc)

def run_daemon(daemon):
    log('Starting daemon: %s' % daemon)
    subprocess.Popen(daemon)

def run_command_and_exit(command):
    log('Starting command: %s' % command)
    rc = subprocess.call(command)
    log('Exiting with status %d..(%s)' % (rc, command))
    sys.exit(rc)

def get_remaining_args():
    return sys.argv[1:]

if __name__ == '__main__':
    system_daemons = ('mysql', 'beanstalkd')
    for daemon in system_daemons:
        run_system_daemon(daemon)
    run_daemon(['isolateserver'])
    log('dist_test is installed on /dist_test. Please refer to /dist_test/README.md')
    command = ['/bin/bash', '--login', '-i']
    run_command_and_exit(command + get_remaining_args())


#!/bin/sh

export > /etc/envvars

exec /sbin/runit

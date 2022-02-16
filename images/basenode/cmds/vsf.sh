#!/bin/sh
set -e

yarn install || exit $?

yarn dev

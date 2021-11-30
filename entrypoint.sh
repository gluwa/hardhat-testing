#!/bin/bash

yarn run-node &
yarn deploy

exec "$@"
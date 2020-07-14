#!/usr/bin/env bash

# Exit script as soon as a command fails.
set -o errexit

# Executes cleanup function at script exit.
trap cleanup EXIT

cleanup() {
  # Kill the ganache instance that we started (if we started one and if it's still running).
  if [ -n "$ganache_pid" ] && ps -p $ganache_pid > /dev/null; then
    kill -9 $ganache_pid
  fi
}

ganache_port=8545

ganache_running() {
  nc -z localhost "$ganache_port"
}

start_ganache() {
  if [ "$MODE" = "coverage" ]; then
    echo "Using in-process ganache-core provider for coverage"
    return
  else
    npx ganache-cli --gasLimit 0xfffffffffff -e 10000000 --port "$ganache_port" > /dev/null &
  fi

  ganache_pid=$!

  echo "Waiting for ganache to launch on port "$ganache_port"..."

  while ! ganache_running; do
    sleep 1 # wait for 1/10 of the second before checking again
  done

  echo "Ganache launched!"
}

if ganache_running; then
  echo "Using existing ganache instance"
else
  echo "Starting our own ganache instance"
  start_ganache
fi

npx truffle version

if [ "$MODE" = "coverage" ]; then
  npx truffle run coverage --solcoverjs .solcover.js
elif [ "$MODE" = "deploy" ]; then
  npx tsc --project ./tsconfig.json --outDir scripts/deploy && truffle exec scripts/deploy/index.js --network development
else
  npx truffle test
fi
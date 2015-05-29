#!/bin/bash

num_clients=$1
shift 1
flags=$@
shift 1
MAX_PACKS=$1
shift 1
shift 1
num_port=$1

./server $flags  > aux &
pid=$!
sleep 1

for ((j=1 ; $j<=$num_clients ; j++))
{
	./client --packets $(($MAX_PACKS*10)) --ip 127.0.0.1 --port $num_port > /dev/null &
}

wait $pid
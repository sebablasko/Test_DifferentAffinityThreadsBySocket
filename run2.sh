#!/bin/bash

MAX_PACKS=1000000
repetitions=6
num_port=1820
threads=(1 2 4 6 8 10 12)
num_clients=4


echo "Compilando..."
make all
echo "Done"

#Sin processor Affinity
salida=SinProcessorAffinity
for num_threads in ${threads[@]};
do
	echo "evaluando "$num_threads" threads, "$salida
	linea="$num_threads,";

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		./runTest.sh $num_clients --packets $MAX_PACKS --port $num_port --threads $num_threads
		
		linea="$linea$(cat aux)"
		rm aux
	}

	echo "$linea" >> $salida".csv"
done


#Con processor Affinity equitative
salida=EquitativeAffinity
for num_threads in ${threads[@]};
do
	echo "evaluando "$num_threads" threads, "$salida
	linea="$num_threads,";

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		./runTest.sh $num_clients --packets $MAX_PACKS --port $num_port --threads $num_threads --scheduler equitativeSched
		
		linea="$linea$(cat aux)"
		rm aux
	}

	echo "$linea" >> $salida".csv"
done


#Con processor Affinity dummy
salida=DummyAffinity
for num_threads in ${threads[@]};
do
	echo "evaluando "$num_threads" threads, "$salida
	linea="$num_threads,";

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		./runTest.sh $num_clients --packets $MAX_PACKS --port $num_port --threads $num_threads --scheduler dummySched
		
		linea="$linea$(cat aux)"
		rm aux
	}

	echo "$linea" >> $salida".csv"
done


#Con processor Affinity pair
salida=PairAffinity
for num_threads in ${threads[@]};
do
	echo "evaluando "$num_threads" threads, "$salida
	linea="$num_threads,";

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		./runTest.sh $num_clients --packets $MAX_PACKS --port $num_port --threads $num_threads --scheduler pairSched
		
		linea="$linea$(cat aux)"
		rm aux
	}

	echo "$linea" >> $salida".csv"
done


make clean
echo "Done"


# Compilar los resultados en un sólo csv para simplicidad
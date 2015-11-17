#!/bin/bash

MAX_PACKS=1000000
repetitions=60
num_port=1820
threads="1 2 4 8 16 24 32 64 128"
num_clients=4


echo "Compilando..."
make all
echo "Done"

#Sin processor Affinity
salida=SinProcessorAffinity
for num_threads in $threads
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
for num_threads in $threads
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
for num_threads in $threads
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
for num_threads in $threads
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

#Con processor Affinity impair
salida=ImpairAffinity
for num_threads in $threads
do
	echo "evaluando "$num_threads" threads, "$salida
	linea="$num_threads,";

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		./runTest.sh $num_clients --packets $MAX_PACKS --port $num_port --threads $num_threads --scheduler impairSched
		
		linea="$linea$(cat aux)"
		rm aux
	}

	echo "$linea" >> $salida".csv"
done

#Con processor Affinity Numa pair
salida=NumaPairAffinity
for num_threads in $threads
do
	echo "evaluando "$num_threads" threads, "$salida
	linea="$num_threads,";

	for ((i=1 ; $i<=$repetitions ; i++))
	{
		./runTest.sh $num_clients --packets $MAX_PACKS --port $num_port --threads $num_threads --scheduler numaPairSched
		
		linea="$linea$(cat aux)"
		rm aux
	}

	echo "$linea" >> $salida".csv"
done


make clean
echo "Done"


#Compilar los resultados en un sólo csv para simplicidad
echo "" > Resumen_afinidad.csv
for filename in *Affinity.csv; do
	echo $filename >> Resumen_afinidad.csv
	cat $filename >> Resumen_afinidad.csv
	echo "" >> Resumen_afinidad.csv
done
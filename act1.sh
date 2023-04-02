#!/bin/bash
#act1.sh

# Creation of files

sizes=(1M 10M 100M 500M 1000M)
encr=0.0000
decr=0.0000

mkdir -p "act1/fow/aes"
mkdir -p "act1/results/aes"


for i in "${!sizes[@]}";do
	if [ ! -f act1/fow/file"${sizes[$i]}".txt ]; then dd if=/dev/urandom of=act1/fow/file"${sizes[$i]}".txt bs="${sizes[$i]}" count=1; fi
done

# AES

echo "########################################################AES#################################################################"

aes_key=$(openssl rand -hex 16)
aes_iv=$(openssl rand -hex 16)

#CBC
echo "########################################################CBC#################################################################"
for i in "${!sizes[@]}"; do
	for j in {0..4};do
		diff=$({ /usr/bin/time -f "%e" sh -c 'openssl enc -aes-256-cbc -K "${aes_key}" -iv "${aes_iv}" -in "act1/fow/file'${sizes[$i]}'.txt" -out "act1/fow/aes/file'${sizes[$i]}'.aes_cbc" >/dev/null 2>&1'; } 2>&1)
		encr=$(echo "scale=4; $encr + $diff" | bc)
		diff=$({ /usr/bin/time -f "%e" sh -c 'openssl enc -d -aes-256-cbc -K "${aes_key}" -iv "${aes_iv}" -in "act1/fow/aes/file'${sizes[$i]}'.aes_cbc" -out "act1/fow/aes/file'${sizes[$i]}'.aes_cbc_dec" >/dev/null 2>&1'; } 2>&1)
		decr=$(echo "scale=4; $decr + $diff" | bc)
	done
	encr=$(echo "scale=4; $encr / 5" | bc)
	decr=$(echo "scale=4; $decr / 5" | bc)

	printf "%-10s %-10s %-10s\n" "${sizes[$i]}" "0$encr" "0$decr" >> "act1/results/aes/cbc.txt"
done

#ECB

encr=0.0
decr=0.0

echo "########################################################ECB#################################################################"

for i in "${!sizes[@]}"; do 
	for j in {0..4}; do
		diff=$({ /usr/bin/time -f "%e" sh -c 'openssl enc -aes-256-ecb -in "act1/fow/file'${sizes[$i]}'.txt" -out "act1/fow/aes/file'${sizes[$i]}'.aes_ecb" -K "${aes_key}" >/dev/null 2>&1'; } 2>&1)
		encr=$(echo "scale=4; ${encr}+${diff}" | bc)
		diff=$({ /usr/bin/time -f "%e" sh -c 'openssl enc -d -aes-256-ecb -in "act1/fow/aes/file'${sizes[$i]}'.aes_ecb" -out "act1/fow/aes/file'${sizes[$i]}'.aes_ecb_dec" -K "${aes_key}" >/dev/null 2>&1' ; } 2>&1) 
		decr=$(echo "scale=4; ${decr}+${diff}" | bc)
	done
	encr=$(echo "scale=4; $encr / 5" | bc)
	decr=$(echo "scale=4; $decr / 5" | bc)

	printf "%-10s %-10s %-10s\n" "${sizes[$i]}" "0$encr" "0$decr" >> "act1/results/aes/ecb.txt"
done

#3DES

echo "########################################################3DES#################################################################"

des_key=$(openssl rand -hex 24)
des_iv=$(openssl rand -hex 8)

encr=0.0
decr=0.0	


mkdir -p "act1/fow/3des"
mkdir -p "act1/results/3des"
#ECB

echo "########################################################ECB#################################################################"

for i in "${!sizes[@]}"; do
	for j in {0..4}; do 
		diff=$({ /usr/bin/time -f "%e" sh -c 'openssl enc -des-ede3 -in "act1/fow/file'${sizes[$i]}'.txt" -out "act1/fow/3des/file'${sizes[$i]}'.3des_ecb" -K "${des_key}" >/dev/null 2>&1'; } 2>&1 )
		encr=$(echo "scale=4; ${encr}+${diff}" | bc)
		diff=$({ /usr/bin/time -f "%e" sh -c 'openssl enc -d -des-ede3 -in "act1/fow/3des/file'${sizes[$i]}'.3des_ecb" -out "act1/fow/3des/file'${sizes[$i]}'.3des_ecb_dec" -K "${des_key}" >/dev/null 2>&1'; } 2>&1 )
		decr=$(echo "scale=4; ${decr}+${diff}" | bc)
	done
	encr=$(echo "scale=4; $encr / 5" | bc)
	decr=$(echo "scale=4; $decr / 5" | bc)
	
	printf "%-10s %-10s %-10s\n" "${sizes[$i]}" "0$encr" "0$decr" >> "act1/results/3des/ecb.txt"
done

#CBC

echo "########################################################CBC#################################################################"

for i in "${!sizes[@]}"; do
	for j in {0..4}; do 
		diff=$({ /usr/bin/time -f "%e" sh -c 'openssl enc -des-ede3-cbc -in "act1/fow/file'${sizes[$i]}'.txt" -out "act1/fow/3des/file'${sizes[$i]}'.3des_cbc" -K "${des_key}" -iv "${des_iv}" >/dev/null 2>&1'; } 2>&1 )
		encr=$(echo "scale=4; ${encr} + ${diff}" | bc)
		diff=$({ /usr/bin/time -f "%e" sh -c 'openssl enc -d -des-ede3-cbc -in "act1/fow/3des/file'${sizes[$i]}'.3des_cbc" -out "act1/fow/3des/file'${sizes[$i]}'.3des_cbc_dec" -K "${des_key}" -iv "${des_iv}" >/dev/null 2>&1'; } 2>&1 )
		decr=$(echo "scale=4; ${decr} + ${diff}" | bc)
	done
	encr=$(echo "scale=4; $encr / 5" | bc)
	decr=$(echo "scale=4; $decr / 5" | bc)
	
	printf "%-10s %-10s %-10s\n" "${sizes[$i]}" "0$encr" "0$decr" >> "act1/results/3des/cbc.txt"
done

echo "######################################################GRAPHS##################################################################"


alg=(aes 3des)
salg=(ecb cbc)

x_axis_label="File sizes"
y_axis_label="exec times"

y1_legend="Encryption"
y2_legend="Decryption"

graph_title="courbe du temps d execution en fonction de la tailles des fichiers"


mkdir -p "act1/results/graphs"


for methodes in "${alg[@]}"; do 
    for specif in "${salg[@]}"; do 

        # Define the input and output files
        input_file="act1/results/${methodes}/${specif}.txt"
        output_file="act1/results/graphs/${methodes}_${specif}.svg"
        # Define the gnuplot commands
        gnuplot_commands="set term svg size 800,600;
            set output '${output_file}';
            set title '${graph_title}';
            set xlabel '${x_axis_label}';
            set ylabel '${y_axis_label}';
            plot '${input_file}' using 1:2 with linespoints title '${y1_legend}', \
                 '${input_file}' using 1:3 with linespoints title '${y2_legend}'"

        # Use gnuplot to create the graph
        echo "$gnuplot_commands" | gnuplot
    done
done


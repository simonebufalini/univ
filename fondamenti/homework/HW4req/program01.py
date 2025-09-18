#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#NOTA: il programma test_01.py DISATTIVA la funzione print ed aggiunge alcuni controlli. 
#Per disattivarli e usare print assegnate la variabile DEBUG=True in test_01.py

'''
Obiettivo dello homework è leggere alcune stringhe contenute in una serie di
file e generare una nuova stringa a partire da tutte le stringhe lette.
Le stringhe da leggere sono contenute in diversi file, collegati fra loro a
formare una catena chiusa. Infatti, la prima stringa di ogni file è il nome di
un altro file che appartiene alla catena: partendo da un qualsiasi file e
seguendo la catena, si ritorna sempre nel file di partenza.

Esempio: il contenuto di "A.txt" inizia con "B.txt", il file "B.txt", inizia
con "C.txt" e il file "C.txt" inizia con "A.txt", formando la catena
"A.txt"-"B.txt"-"C.txt".

Oltre alla stringa con il nome del file successivo, ogni file contiene anche
altre stringhe separate da spazi, tabulazioni o caratteri di a capo. La
funzione deve leggere tutte le stringhe presenti nei file della catena e
costruire la stringa che si ottiene concatenando i caratteri con la più alta
frequenza in ogni posizione. Ovvero, nella stringa da costruire, alla
posizione p ci sarà il carattere che ha frequenza massima nella posizione p di
ogni stringa letta dai file. Nel caso in cui ci fossero più caratteri con
la stessa frequenza, si consideri l'ordine alfabetico.
La stringa da costruire ha lunghezza pari alla
lunghezza massima delle stringhe lette dai file.

Quindi, si deve scrivere una funzione che prende in ingresso una stringa A 
che rappresenta il nome di un file e restituisce una stringa.
La funzione deve costruire la stringa secondo le indicazioni illustrate sopra
e ritornare le stringa così costruita.

Esempio: se il contenuto dei tre file A.txt, B.txt e C.txt nella directory
test01 è il seguente

test01/A.txt          test01/B.txt         test01/C.txt                                                                 
-------------------------------------------------------------------------------
test01/B.txt          test01/C.txt         test01/A.txt
house                 home                 kite                                                                       
garden                park                 hello                                                                       
kitchen               affair               portrait                                                                     
balloon                                    angel                                                                                                                                               
                                           surfing                                                               

la funzione most_frequent_chars("test01/A.txt") dovrà restituire la stringa
"hareennt".
'''

def most_frequent_chars(filename: str) -> str:
    return chars_frequency(from_files_to_list_of_words(filename))


def chars_frequency(words: list[str])-> str:
    most_frequent_chars_string = ''
    words = sorted(words, key= lambda x: len(x), reverse = True)
    for i in range(len(words[0])):
        freq = dict()
        
        for word in words:
            if len(word) > i:
                if word[i] in freq:
                    freq[word[i]] += 1
                else:
                    freq[word[i]] = 1
        
        max_keys = [key for key, value in freq.items() if value == max(freq.values())]
        most_frequent_chars_string += min(max_keys)
           
    return most_frequent_chars_string


def from_files_to_list_of_words(filename: str) -> list[str]:
    files_content = ''
    with open (filename, encoding = 'utf-8') as access_file:
        first_line = access_file.readline().replace(' ','').replace('\n','')
        files_content += access_file.read()
        while first_line != filename:
            with open(first_line, encoding = 'utf-8') as file:
                first_line = file.readline().replace(' ','').replace('\n','')
                files_content += file.read()
    return files_content.split()

# -*- coding: utf-8 -*-

"""
Consideriamo la codifica dei numeri romani e la modifica suggerita da 
Randall Munroe nel suo blog XKCD.
Nella codifica dei numeri romani:
- non esiste lo zero
- si usano le lettere 'IVXLCDM' che corrispondono ai valori decimali
  'I' = 1, 'V' = 5, 'X' = 10, 'L' = 50, 'C' = 100, 'D' = 500, 'M' = 1000
- i numeri si scrivono da sinistra a destra cominciando con i valori più alti 
  (migliaia, centinaia, decine, unità)
- i valori delle lettere si sommano, tranne quando sono seguiti da lettere di peso maggiore, 
  nel qual caso si sottraggono
- si possono usare al massimo 3 lettere consecutive uguali per le lettere 'IXCM'
  ('III' = 3, 'XXX' = 30, 'CCC' = 300 , 'MMM' = 3000)
- per rappresentare i valori che hanno cifra decimale 4 o 9 si usa la sottrazione 
  dalla lettera seguente
  Es. 4 = 'IV'   9 = 'IX',    40 = 'XL'    39 = 'IXL'   499 = 'ID'

Nel suo blog XKCD, invece, Randall Munroe codifica i numeri romani con i corrispondenti numeri arabi: 
si concatenano i numeri arabi ottenuti sostituendo a ciascuna lettera il valore corrispondente.  
Es.    397 =>  'CCCXCVII' => 100 100 100 10 100 5 1 1 => '10010010010100511'
Chiamiamo questa codifica "formato XKCD".

Obiettivo dello homework è decodificare una lista di stringhe che rappresentano
numeri romani nel formato XKCD, e tornare i K valori maggiori in ordine decrescente.

Implementate quindi le seguenti funzioni:
"""

def decode_XKCD_tuple(xkcd_values : tuple[str, ...], k : int) -> list[int]:
    '''
    Riceve una lista di stringhe che rappresentano numeri nel formato XKCD
    ed un intero k positivo.
    Decodifica i numeri forniti e ne ritorna i k maggiori.

    Parameters
    valori_xkcd : list[str]     lista di stringhe in formato XKCD
    k : int                     numero di valori da tornare
    Returns
    list[int]                   i k massimi valori ottenuti in ordine decrescente
    '''
    values = sorted([decode_value(xkcd) for xkcd in xkcd_values], reverse = True)
    return values[:k]
    
def decode_value(xkcd : str ) -> int:
    '''
    Decodifica un valore nel formato XKCD e torna l'intero corrispondente.

    Parameters
    xkcd : str                  stringa nel formato XKCD
    Returns
    int                         intero corrispondente
    
    Esempio: '10010010010100511' -> 397
    '''
    return list_of_weights_to_number(xkcd_to_list_of_weights(xkcd))

def xkcd_to_list_of_weights(xkcd : str) -> list[int]:
    '''
    Spezza una stringa in codifica XKCD nella corrispondente
    lista di interi, ciascuno corrispondente al peso di una lettera romana

    Parameters
    xkcd : str              stringa nel formato XKCD
    Returns
    list[int]               lista di 'pesi' corrispondenti alle lettere romane

    Esempio: '10010010010100511' -> [100, 100, 100, 10, 100, 5, 1, 1,]
    '''
 
    weigths = []
    s = xkcd[0]
    for i in xkcd[1:]:
        if i == '0':
            s += i
        else:
            weigths.append(int(s))
            s = i
    weigths.append(int(s))
    return weigths


def list_of_weights_to_number(weigths : list[int] ) -> int:
    '''
    Trasforma una lista di 'pesi' nel corrispondente valore arabo
    tenendo conto della regola di sottrazione

    Parameters
    lista_valori : list[int]    lista di 'pesi' di lettere romane
    Returns
    int                         numero arabo risultante
    
    Esempio: [100, 100, 100, 10, 100, 5, 1, 1,] -> 397
    '''
    n = weigths[len(weigths)-1]
    
    for i in range(len(weigths)-2,-1,-1):
        
        if weigths[i+1] > weigths[i]:
            n -= weigths[i]
        else:
            n += weigths[i]
    return n


###################################################################################
if __name__ == '__main__':
    # inserisci qui i tuoi test
    print('10010010010100511', decode_value('10010010010100511'), '(397?)')
    print('111', decode_value('111'), '(3?)')
    print('1101001000', decode_value('1101001000'), '(889?)')
    print('10001000100010010001051', decode_value('10001000100010010001051'), '(3916?)')
    print('11050', decode_value('11050'), '(39?)')
    print('110100', decode_value('110100'), '(89?)')

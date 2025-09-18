# -*- coding: utf-8 -*-
'''
I Caponians, una specie aliena proviente da un non ben specificato
pianeta della galassia, stanno pianificando da un bel po' l'invasione
del pianeta Terra. Per farlo, hanno creato e installato in vari punti
del pianeta varie *mind bending machine*, macchine che riducono
l'intelligenza degli umani attraverso la rete telefonica [1].

Terminata la fase di riduzione dell'intelligenza umana, il prossimo
passo verso la conquista della Terra sara' lo sbarco sul nostro
pianeta, che avverra' non appena i Caponians avranno trovato dei punti
sufficientemente spaziosi per far atterrare le loro astronavi.

Un'astronave vista dall'alto puo' essere rappresentata come un
rettangolo di dimensioni W (larghezza) e H (altezza). Nel considerare
lo spazio necessario ad un'astronave per atterrare vanno pero' aggiunti
sui 4 lati del rettangolo 4 aree in piu'. Le aree in piu' sono una una
per lato.
Le aree sporgono tutte di una stessa quantita' D, per permettere di
aprire su ogni lato un portellone di sbarco. Ogni portellone e' quindi
largo quanto il lato dell'astronave su cui si trova e lungo D, su
qualunque lato si trovi.

I Caponians vorrebbero sbarcare con le loro astronavi in alcune nostre
citta', di cui hanno scaricato le rispettive mappe. Una citta' puo'
essere rappresentata come un'immagine rettangolare nera, in cui ogni
palazzo e' rappresentato come un rettangolo colorato (ogni palazzo ha
un colore che lo identifica univocamente).

Per definire gli ultimi dettagli del piano di sbarco, i Caponians
hanno bisogno di un algoritmo che, data la mappa di una citta' e un
elenco di astronavi definite come sopra, confermi oppure no se
ciascuna astronave ha abbastanza spazio per atterrare in quella citta',
aprire i suoi 4 portelloni e sbarcare il suo contenuto. Le astronavi
non atterrano contemporaneamente nella citta', quindi vanno valutate
separatamente le une rispetto alle altre.

(1) Quindi, data un'immagine nera (citta') con dei rettangoli colorati
pieni (palazzi) disegnati sopra, con ogni rettangolo di un colore
diverso da tutti gli altri, bisognera':

- determinare posizione, dimensioni e colore di ogni rettangolo
- salvare in un file di testo un rettangolo per riga
- nel file, ogni rettangolo e' rappresentato con una sequenza di 7 valori:
     x, y, w, h, r, g, b
  separati da virgole, in ordine di coordinata y (numero di riga)
  decrescente e, a parimerito, di x (pixel della riga) crescente.

(2) Successivamente, e' dato un file di testo contente N terne di
interi.  Ogni terna separata internamente e dalle altre terne da un
qualunque numero di spazi, tabulazioni o ritorni a capo. Ogni terna
rappresenta larghezza W, altezza H e distanza minima D (vedere sotto)
di un rettangolo (astronave) che si vorrebbe aggiungere all'immagine
al punto (1):

- restituire una lista di N valori booleani, l'i-esimo valore nella
lista e' True se nell'immagine c'e' abbastanza spazio per inserire
l'i-esimo rettangolo

- un rettangolo puo' essere inserito nell'immagine se esiste almeno una
posizione nell'immagine in cui c'e' abbastanza spazio (cioe' un'area
costituita interamente da pixel neri) per contenere il rettangolo
stesso, piu' le 4 "estensioni" del rettangolo, ossia i 4 portelloni
dell'astronave.

Ad esempio, se un'astronave da inserire ha 2 pixel di
larghezza e 3 di altezza e D = 2, bisognera' cercare uno spazio
nell'immagine adatto a contenere la seguente figura:

                              **
                              **
                            **++**
                            **++**
                            **++**
                              **
                              **

in cui i simboli + sono i pixel del rettangolo/astronave 2x3 e i *
sono i pixel delle 4 estensioni/portelloni

Esempio:
Data la seguente immagine rappresentata con un carattere per ogni
pixel, dove "." e' un pixel nero mentre caratteri diversi da "." sono
pixel colorati (*=rosso, +=verde):

**....
**....
......
......
....++
....++

Il file con i rettangoli trovati da voi salvato deve contenere le
righe:
4,4,2,2,0,255,0
0,0,2,2,255,0,0

e dati le seguenti astronavi:

(3, 3, 0)
(2, 2, 4)
(1, 1, 3)
(4, 2, 1)
(2, 4, 1)

verra' restituita la lista: [True, False, False, False, False]
infatti solo la prima astronave puo' atterrare ad esempio nella
zona marcata da 'X' (non ha sportelloni, infatti D = 0)

**.XXX
**.XXX
...XXX
......
....++
....++

mentre le altre non entrano nella mappa perche', pur avendo un punto
in cui possono atterrare, non possono aprire tutti i portelloni


[1] https://en.wikipedia.org/wiki/Zak_McKracken_and_the_Alien_Mindbenders)
'''

from pngmatrix import load_png8

def ex(file_png, file_txt, file_out):
    img = load_png8(file_png)
    
    rettangoli=calcola_rettangoli(img)   
    rettangoli.sort(key = lambda x: (-x[1],x[0]))
    salva_su_file_txt(rettangoli,file_out)  
    
    astronavi_whd = apri_astronavi(file_txt) 
    lista_booleani=funzione_principale(img,astronavi_whd)
    return lista_booleani

def calcola_rettangoli(img):
    rettangoli=[]
    colori_individuati=[]
    for y,riga in enumerate(img):
        for x,pixel in enumerate(riga):
            if pixel!=(0,0,0):
                if pixel not in colori_individuati:
                    w=determina_larghezza(img,x,y,pixel)
                    h=determina_lunghezza(img,x,y,pixel)
                    colori_individuati.append(pixel)
                    rettangoli.append([x,y,w,h,pixel[0],pixel[1],pixel[2]])
    return rettangoli

def salva_su_file_txt(rettangoli,file_out):
    s=''
    with open(file_out,mode='w') as fout:
        for rettangolo in rettangoli:
            for i,componente in enumerate(rettangolo):
                s+=str(componente)
                if i>=len(rettangolo)-1:break
                s+=','
            s+='\n'
        fout.write(s)    

def determina_lunghezza(img,x,y,pixel):
    height=0
    try:
        while img[y][x]==pixel:
            height+=1
            y+=1
    except IndexError:
        pass
    return height

def determina_larghezza(img,x,y,pixel):
    width=0
    try:
        while img[y][x]==pixel:
            width+=1
            x+=1
    except IndexError:
        pass
    return width

def apri_astronavi(file_testo):
    astronavi=[]
    with open(file_testo) as file:
        raw = file.read().replace('\t',' ').replace('\n',' ').strip().split()
        for i in range(0,len(raw),3):
            astronavi.append([int(raw[i]),int(raw[i+1]),int(raw[i+2])])
    return astronavi

def funzione_principale(img,dimensioni_astronavi):
    lista_booleani=[]
    for astronave in dimensioni_astronavi:
        lista_booleani.append(verifica_spazio_rettangolo(img,astronave[0],astronave[1],astronave[2]))
    return lista_booleani


def verifica_spazio_rettangolo(immagine, larghezza, altezza, margine):
    altezza_img = len(immagine)
    larghezza_img = len(immagine[0])
    
    for y in range(altezza_img - altezza - 2 * margine + 1):
        for x in range(larghezza_img - larghezza - 2 * margine + 1):

            parte_centrale_libera = all(
                all(pixel == (0, 0, 0) for pixel in riga[x + margine : x + margine + larghezza])
                for riga in immagine[y + margine : y + margine + altezza]
            )

            portelloni_superiori_liberi = all(
                all(pixel == (0, 0, 0) for pixel in immagine[y + dy][x + margine : x + margine + larghezza])
                for dy in range(margine)
            )
            portelloni_inferiori_liberi = all(
                all(pixel == (0, 0, 0) for pixel in immagine[y + altezza + margine + dy][x + margine : x + margine + larghezza])
                for dy in range(margine)
            )
            portelloni_sinistra_liberi = all(
                all(immagine[y + margine + dy][x + dx] == (0, 0, 0) for dx in range(margine))
                for dy in range(altezza)
            )
            portelloni_destra_liberi = all(
                all(immagine[y + margine + dy][x + larghezza + margine + dx] == (0, 0, 0) for dx in range(margine))
                for dy in range(altezza)
            )

            if parte_centrale_libera and portelloni_superiori_liberi and portelloni_inferiori_liberi and portelloni_sinistra_liberi and portelloni_destra_liberi:
                return True
            
    return False


if __name__ == "__main__":
    pass


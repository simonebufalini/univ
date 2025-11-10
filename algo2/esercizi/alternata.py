"""
Data una sequenza X di numeri interi, restituire la lunghezza della massima sottosequenza alternata
in X. Ad esempio	X = [1, 3, 8, 5, 4, 2, 6, 0, 1, 2, 8, 9, 5]
					Y = [3, 8, 2, 6, 0, 9, 5]
					
					*
					***
					********
					*****
					****
					**
					******

					*
					**
					********
					*********
					*****

"""

def alternata(X):
	prec = X[0]
	up = True
	down = True
	c = 1
	for i in range(1, len(X)):
		if X[i] > X[i-1] and up:
			up = False
			down = True
			c = c+1
		elif X[i] < X[i-1] and down:
			down = False
			up = True
			c = c+1
		prec = X[i]

	return c

def alternata2(X):
    if not X:
        return 0

    up = down = 1  # lunghezza massima terminante con salita o discesa

    for i in range(1, len(X)):
        if X[i] > X[i-1]:
            up = down + 1
        elif X[i] < X[i-1]:
            down = up + 1

    return max(up, down)

if __name__ == "__main__":
	A = [1, 3, 8, 5, 4, 2, 6, 0, 1, 2, 8, 9, 5]
	print(alternata(A))
	B = [1, 3, 2, 4, 3, 5]
	print(alternata(B))
	C = [1, 2, 1, 1, 2, 3, 2, 1, 4, 3]
	print(alternata(C))
	print(alternata2(C))

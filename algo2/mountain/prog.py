def peak(A, i):
	c, j = 0, 1
	while i+j < len(A) and i-j > 0:
		if A[i-j] <= A[i-c] and A[i+j] <= A[i+c]:
			c += 1
			j += 1
		else:
			break
	return c

def es(A):
	m, i = 0, 1
	while i < len(A):
		l = peak(A, i)
		m = max(m, l)
		i += l+1
	return m

if __name__ == "__main__":
	
	A = [
    1, 2, 3, 2, 1,       # montagna 1 (piccola, j=2)
    2, 3, 4, 6, 4, 3, 2, # montagna 2 (più alta, j=4)
    1, 1, 2, 3, 2, 1,    # montagna 3 (j=3)
    2, 3, 3, 3, 2, 1     # plateau centrale, no montagna simmetrica
	]


	print(es(A))

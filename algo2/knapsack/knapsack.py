class Ogg:
    def __init__(self, peso, valore):
        self.peso = peso
        self.valore = valore

o1 = Ogg(2, 5)
o2 = Ogg(1, 3)
o3 = Ogg(3, 8)
o4 = Ogg(4, 3)
oggetti = [o1, o2, o3, o4]

cap = 10
n = len(oggetti)

T = [[0 for _ in range(cap+1)] for _ in range(n+1)]

for i in range(1, n+1):
    for j in range(0, cap+1):
        if oggetti[i-1].peso > j:
            T[i][j] = T[i-1][j]
        else:
            T[i][j] = max(
				T[i-1][j],
				oggetti[i-1].valore + T[i-1][j - oggetti[i-1].peso]
				)

for i in range(0, n+1):
    for j in range(0, cap+1):
        print(f"{T[i][j]:2}", end=" ")
    print()

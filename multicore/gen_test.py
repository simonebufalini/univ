import sys
import random

# n is the number of points
# s in the dimension of every point
# example: gen_test(1000, 3)
# generates 1000 points of 3 dimensions.
# filename is the name of the output file.

def gen_test(n: int, s: int, filename: str):
	with open(filename, "w") as file:
		for point in range(n):
			line = ""
			for sample in range(s-1):
				line += str(random.randint(-999, 999)) + "\t"
			line += str(random.randint(-999, 999)) + "\n"
			file.write(line)
	
if __name__ == "__main__":
	if len(sys.argv) != 4:
		print("Execution error: parameters are not correct.")
		print("Usage: python* [script] [poins] [samples] [output file].")
		sys.exit(1)
	points, samples, filename = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
	gen_test(points, samples, filename)
	sys.exit(0)

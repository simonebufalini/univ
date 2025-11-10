class Node:
	def __init__(self, key):
		self._key = key
		self.adjacents = set()

	@property
	def key(self):
		# this is the getter method
		return self._key

	@key.setter
	def key(self, new):
		# this is the setter method
		self._key = new

	def add_adjacent(self, node):	
		self.adjacents.add(node)

	def remove_adjacent(self, node):
		self.adjacents.discard(node)

class Graph:
	def __init__(self, edges=None):
		self.nodes = dict()

	def add_node(self, key):
		if key not in self.nodes:
			self.nodes[key] = Node(key)
		# returns the created node
		return self.nodes[key]

	def add_edge(self, head_key, tail_key):
		head = self.add_node(head_key)
		tail = self.add_node(tail_key)
		head.add_adjacent(tail)
		# if we are considering a non-oriented graph, then
		# we should also add the head as adjacent of the tail.
		tail.add_adjacent(head)
	
	# using a classmethod as optional initializer with a text file.
	@classmethod
	def from_file(cls, filename):
		g = cls()
		with open(filename, 'r') as file:
			for line in file:
				parts = line.strip().split()
				if not parts:
					continue
				node_key = parts[0]
				neighbors = parts[1:]
				for n in neighbors:
					g.add_edge(node_key, n)
		return g
		

# [
# 	(node, node.adjacents),
# 	(),
# 	(),
# 	...
# ]

if __name__ == "__main__":
	pass

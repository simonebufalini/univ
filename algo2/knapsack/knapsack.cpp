#include <iostream>
#include <vector>

#define OBJ 4
#define CAP 10

class Item {
public:
	Item() : value{0}, weight{0} {}
	Item(size_t v, size_t w) : value{v}, weight{w} {}
	size_t get_v() {return this->value; }
	size_t get_w() {return this->weight; }

private:
	size_t value;
	size_t weight;
};

// Ignore this class
class Item_table {
public:
	Item_table(size_t l, size_t c) : lines{l}, cols{c},
		data{l, std::vector<Item>(c)} {}

	std::vector<Item>& operator[](size_t index) {
		return data[index];
	}

	const std::vector<Item>& operator[](size_t index) const {
		return data[index];
	}

private:
	size_t lines;
	size_t cols;
	std::vector<std::vector<Item>> data;
};

// tabella per memoization.
class Table {
public:
	Table(size_t l, size_t c) : lines{l}, cols{c},
		data{l, std::vector<size_t>(c, 0)} {}
	
	std::vector<size_t>& operator[](size_t index) {
		return data[index];
	}

	const std::vector<size_t>& operator[](size_t index) const {
		return data[index];
	}


private:
	size_t lines;
	size_t cols;
	std::vector<std::vector<size_t>> data;
};

size_t max(size_t a, size_t b){
	return (a >= b) ? a : b;
}

int main(void){
	std::vector<Item> items;
	items.push_back(Item(5, 2));
	items.push_back(Item(3, 1));
	items.push_back(Item(8, 3));
	items.push_back(Item(3, 4));
	
	Table t(OBJ+1, CAP+1);

	for (size_t i = 1; i < OBJ+1; i++) {
		for (size_t j = 1; j < CAP+1; j++) {
			if (items[i-1].get_w() <= j) {
				t[i][j] = max(
					t[i-1][j],
					items[i-1].get_v() + t[i-1][j-items[i-1].get_w()]
				);
			}
			else {
				t[i][j] = t[i-1][j];
			}
		}
	}
	
	std::cout << "Max value: " << t[OBJ][CAP] << std::endl;
	return 0;
}

// graph.cpp

#include "graph.h"

#define NODE_SEP ';'
#define ADJ_SEP '-'

Node::Node(int _id) : id(_id) {}

Node& Node::add_adjacent(Node* node) {
    adjacents.push_back(node);
    return *this;
}

Graph::Graph(const std::string& filename) {
    std::ifstream file(filename);
    std::string line;

    while (std::getline(file, line)) {
        if (line.empty()) continue;

        size_t sep_pos = line.find(NODE_SEP);
        if (sep_pos == std::string::npos) continue;

        std::string node_id_str = line.substr(0, sep_pos);
        std::string adj_str = line.substr(sep_pos + 1);

        int node_id = std::stoi(node_id_str);

        Node* node;
        if (nodes.find(node_id) == nodes.end()) {
            node = new Node(node_id);
            add_node(node);
        } else {
            node = nodes[node_id];
        }

        size_t start = 0;
        size_t end;
        while ((end = adj_str.find(ADJ_SEP, start)) != std::string::npos) {
            std::string adj_id_str = adj_str.substr(start, end - start);
            int adj_id = std::stoi(adj_id_str);

            Node* adj_node;
            if (nodes.find(adj_id) == nodes.end()) {
                adj_node = new Node(adj_id);
                add_node(adj_node);
            } else {
                adj_node = nodes[adj_id];
            }

            node->add_adjacent(adj_node);
            start = end + 1;
        }

        if (start < adj_str.size()) {
            int adj_id = std::stoi(adj_str.substr(start));
            Node* adj_node;
            if (nodes.find(adj_id) == nodes.end()) {
                adj_node = new Node(adj_id);
                add_node(adj_node);
            } else {
                adj_node = nodes[adj_id];
            }
            node->add_adjacent(adj_node);
        }
    }
}

Graph& Graph::add_node(Node* node) {
    nodes[node->id] = node;
    return *this;
}

Graph::~Graph() {
    for (auto& pair : nodes) {
        delete pair.second;
    }
    nodes.clear();
}

void Graph::print() const {
    for (const auto& pair : nodes) {
        std::cout << pair.first << ": ";
        for (Node* adj : pair.second->adjacents) {
            std::cout << adj->id << " ";
        }
        std::cout << "\n";
    }
}

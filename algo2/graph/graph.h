// graph.h

#ifndef GRAPH_H
#define GRAPH_H

#include <iostream>
#include <vector>
#include <unordered_map>
#include <fstream>
#include <string>

class Node {
public:
    int id;
    std::vector<Node*> adjacents;

    Node(int _id);
    Node& add_adjacent(Node* node);
};

class Graph {
private:
    std::unordered_map<int, Node*> nodes;

public:
    Graph(const std::string& filename);
    Graph& add_node(Node* node);
    ~Graph();
    void print() const;
};

#endif

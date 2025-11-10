// bfs.cpp
#include "graph.h"
#include <queue>
#include <unordered_set>
#include <iostream>
#include <string>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <graph_file>\n";
        return 1;
    }
    Graph g(std::string(argv[1]));

    std::unordered_set<int> visited;

    for (const auto &pair : g.nodes) {
        Node *start = pair.second;
        if (visited.count(start->id)) continue;

        std::queue<Node*> q;
        q.push(start);

        while (!q.empty()) {
            Node *cur = q.front();
            q.pop();

            if (visited.count(cur->id)) continue;
            
            visited.insert(cur->id);
            std::cout << cur->id << " ";
            
            for (Node *nbr : cur->adjacents) {
                if (!visited.count(nbr->id)) q.push(nbr);
            }
        }
        std::cout << "\n";
    }

    return 0;
}


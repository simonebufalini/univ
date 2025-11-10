// dfs.cpp
#include "graph.h"
#include <stack>
#include <unordered_set>
#include <iostream>
#include <string>
#include <algorithm>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <graph_file>\n";
        return 1;
    }

    // costruisce il grafo dal file
    Graph g(std::string(argv[1]));
    std::unordered_set<int> visited;

    for (const auto &pair : g.nodes) {
        Node *start = pair.second;
        if (visited.count(start->id)) continue;

        std::stack<Node*> st;
        st.push(start);
        
        while (!st.empty()) {
            Node *cur = st.top();
            st.pop();

            if (visited.count(cur->id)) continue;
            visited.insert(cur->id);

            std::cout << cur->id << " ";
            const auto &adjs = cur->adjacents;
            for (auto it = adjs.rbegin(); it != adjs.rend(); ++it) {
                Node *nbr = *it;
                if (!visited.count(nbr->id)) st.push(nbr);
            }
        }
        std::cout << "\n";
    }
    return 0;
}


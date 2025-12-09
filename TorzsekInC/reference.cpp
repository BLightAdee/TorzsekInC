//
//  reference.cpp
//  TorzsekInC
//
//  Created by BLightAdee on 09.12.2025.
//

#include <stdio.h>
#include <iostream>
#include <string>
#include "main.h"

using std::cin;
using std::cout;
using std::string;

// Data container for all inputs needed by all subprograms
struct AllInput {
    int n = 0, k = 0;
    int wars[2001][4] = {0}; // for problem 1
    int ki[2001] = {0}, kivel[2001] = {0}, mettol[2001] = {0}, meddig[2001] = {0}; // for problems 6,8,11-15
    char century[32] = {0}; // for problem 1 (C-compatible)
    int torzs = 0;       // for problem 11
    int s = 0;           // for problem 12
    char sz = 'A';       // for problem 12
    int keresett = 0;    // for problem 13
    int S = 0;           // for problems 14 and 15
};

// Collect all inputs upfront before problem selection.
static void collectAllInput(AllInput &in) {
    cout << "Input collection begins. Please provide all required data before choosing a problem.\n";
    cout << "Enter N (number of tribes) and K (number of war records): ";
    cin >> in.n >> in.k;

    // Read K war records once and map them for all tasks
    // Each record: ki kivel mettol meddig
    cout << "Enter " << in.k << " war records. Each line: ki kivel mettol meddig (from, against, startYear, endYear)\n";
    for (int i = 0; i < in.k; i++) {
        int a, b, c, d;
        cout << "  Record " << (i + 1) << "/" << in.k << " (ki kivel mettol meddig): ";
        cin >> a >> b >> c >> d;
        in.wars[i][0] = a; in.wars[i][1] = b; in.wars[i][2] = c; in.wars[i][3] = d;
        in.ki[i] = a; in.kivel[i] = b; in.mettol[i] = c; in.meddig[i] = d;
    }

    // Problem-specific scalars
    // 1: Roman century string (e.g., I, II, IV, IX, X)
    cout << "Enter Roman century for problem 1 (e.g., I, II, IV, IX, X): ";
    cin >> in.century;

    // 11: tribe index to query
    cout << "Enter tribe index 'torzs' for problem 11: ";
    cin >> in.torzs;

    // 12: tribe id and block selector (A/B/C)
    cout << "Enter tribe 's' and block selector 'sz' for problem 12 (A/B/C): ";
    cin >> in.s >> in.sz;

    // 13: keresett tribe for peace period
    cout << "Enter 'keresett' tribe for problem 13: ";
    cin >> in.keresett;

    // 14/15: S tribe for longest/shortest war
    cout << "Enter 'S' tribe for problems 14 and 15: ";
    cin >> in.S;
}

// Dispatch a single problem by index using pre-collected input. Returns true if a known problem was executed.
static bool runProblem(int index, const AllInput &in) {
    if (index == 1) {
        int result = haboruIdotartamAdottSzazad(in.n, in.k, in.wars, in.century);
        cout << result;
        return true;
    }

    if (index == 6) {
        // Count should be the number of war records (k)
        cout << csak_egyszer_haborozu_torzs(in.k, in.ki, in.kivel);
        return true;
    }

    if (index == 8) {
        // Count should be the number of war records (k)
        cout << egy_evnel_rovhab(in.k, in.mettol, in.meddig);
        return true;
    }

    if (index == 11) {
        cout << haboruPerTorzs(in.n, in.k, in.ki, in.kivel, in.mettol, in.meddig, in.torzs) << '\n';
        return true;
    }

    if (index == 12) {
        cout << calculateWarYears(in.n, in.k, in.ki, in.kivel, in.mettol, in.meddig, in.s, in.sz) << '\n';
        return true;
    }

    if (index == 13) {
        int eleje = 0, vege = 0;
        int ok = calculatePeacePeriod(in.n, in.k, in.ki, in.kivel, in.mettol, in.meddig, in.keresett, &eleje, &vege);
        if (!ok) {
            cout << "0 0";
        } else {
            cout << eleje << ' ' << vege;
        }
        return true;
    }

    if (index == 14) {
        int ellenfel = 0, kezd = 0, veg = 0;
        int ok = findLongestWar(in.n, in.k, in.ki, in.kivel, in.mettol, in.meddig, in.S, &ellenfel, &kezd, &veg);
        if (!ok) cout << "0 0 0\n";
        else cout << ellenfel << ' ' << kezd << ' ' << veg << '\n';
        return true;
    }

    if (index == 15) {
        int ellenfel = 0, kezd = 0, veg = 0;
        int ok = findShortestWar(in.n, in.k, in.ki, in.kivel, in.mettol, in.meddig, in.S, &ellenfel, &kezd, &veg);
        if (!ok) cout << "0 0 0\n";
        else cout << ellenfel << ' ' << kezd << ' ' << veg << '\n';
        return true;
    }

    cout << "NOT IMPLEMENTED YET";
    return false;
}

int main() {
    // Collect all data before problem selection
    AllInput input{};
    collectAllInput(input);

    while (true) {
        cout << "Choose a problem number (or type 'exit'): ";
        string cmd;
        if (!(cin >> cmd)) {
            cout << "\nInput stream closed. Exiting.\n";
            break;
        }

        if (cmd == "exit") {
            cout << "Are you sure you want to exit? (y/n): ";
            string confirm;
            if (!(cin >> confirm)) {
                break; // on input failure, exit
            }
            if (confirm == "y" || confirm == "Y" || confirm == "yes" || confirm == "YES") {
                break;
            } else {
                continue;
            }
        }

        int index;
        try {
            index = std::stoi(cmd);
        } catch (...) {
            cout << "Invalid selection. Please enter a problem number or 'exit'.\n";
            continue;
        }

        runProblem(index, input);
        cout << '\n';
        // Loop continues, allowing the user to select another subprogram using the same pre-collected data
    }
    return 0;
}

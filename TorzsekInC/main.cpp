//
//  main.cpp
//  TorzsekInC
//
//  Created by BLightAdee on 09.12.2025.
//

#include "main.h"
#include <cmath>

// 1. Helpers and Problem 1
int romanCenturyDecode(const char *a) {
    int decodedNum = 0;
    if (!a) return 0;
    for (size_t i = 0; a[i] != '\0'; i++) {
        if (a[i] == 'I' && a[i + 1] != '\0' && a[i + 1] == 'X') {
            decodedNum += 9;
            i++;
        } else if (a[i] == 'I' && a[i + 1] != '\0' && a[i + 1] == 'V') {
            decodedNum += 4;
            i++;
        } else if (a[i] == 'X') {
            decodedNum += 10;
        } else if (a[i] == 'V') {
            decodedNum += 5;
        } else if (a[i] == 'I') {
            decodedNum += 1;
        }
    }
    return decodedNum;
}

int haboruIdotartamAdottSzazad(int /*n*/, int k, const int wars[][4], const char *century) {
    int maxWar = 0;
    int targetCentury = romanCenturyDecode(century);
    for (int i = 0; i < k; i++) {
        int startCentury = (wars[i][2] - 1) / 100 + 1;
        int endCentury = (wars[i][3] - 1) / 100 + 1;
        if (startCentury == targetCentury || endCentury == targetCentury) {
            int d = std::abs(wars[i][2] - wars[i][3]);
            if (d > maxWar) {
                maxWar = d;
            }
        }
    }
    return maxWar;
}

// 6. Exactly-once warring tribe (no I/O)
int csak_egyszer_haborozu_torzs(int k, const int ki[], const int kivel[]) {
    long long t[9] = {0};
    for (int i = 0; i < k; i++) {
        if (ki[i] >= 0 && ki[i] < 9) t[ki[i]]++;
        if (kivel[i] >= 0 && kivel[i] < 9) t[kivel[i]]++;
    }
    for (int i = 0; i < 9; i++) {
        if (t[i] == 1) return i;
    }
    return -1;
}

// 8. Count wars shorter than one year (no I/O)
int egy_evnel_rovhab(int k, const int mettol[], const int meddig[]) {
    int h = 0;
    for (int i = 0; i < k; i++) {
        int g = meddig[i] - mettol[i];
        if (g < 1) h++;
    }
    return h;
}

// 11. Number of wars for a tribe
int haboruPerTorzs(int /*N*/, int K, const int ki[], const int kivel[], const int /*mettol*/[], const int /*meddig*/[], int torzs) {
    int db = 0;
    for (int i = 0; i < K; i++) {
        if (ki[i] == torzs || kivel[i] == torzs)
            db++;
    }
    return db;
}

// 12. Total war years for a tribe in a given century block
int calculateWarYears(int /*n*/, int k, const int ki[], const int kivel[], const int mettol[], const int meddig[], int s, char sz) {
    int kezd, veg;
    if (sz == 'A') {
        kezd = 1601;
        veg = 1700;
    } else if (sz == 'B') {
        kezd = 1701;
        veg = 1800;
    } else {
        kezd = 1801;
        veg = 1900;
    }

    bool haboru_ev[301] = {false};

    for (int i = 0; i < k; i++) {
        if (ki[i] == s || kivel[i] == s) {
            int eleje = mettol[i];
            int vege = meddig[i];

            if (vege < kezd || eleje > veg) continue;
            if (eleje < kezd) eleje = kezd;
            if (vege > veg) vege = veg;

            for (int ev = eleje; ev <= vege; ev++) {
                haboru_ev[ev - kezd] = true;
            }
        }
    }

    int ossz = 0;
    for (int i = 0; i <= veg - kezd; i++) {
        if (haboru_ev[i]) ossz++;
    }

    return ossz;
}

// 13. Longest peace period borders for a tribe
int calculatePeacePeriod(int /*torzsek*/, int haboruk, const int ki[], const int kivel[], const int mettol[], const int meddig[], int keresett, int *outEleje, int *outVege) {
    int kezdet[2000], veg[2000];
    int db = 0;

    for (int i = 0; i < haboruk; i++) {
        if (ki[i] == keresett || kivel[i] == keresett) {
            kezdet[db] = mettol[i];
            veg[db] = meddig[i];
            db++;
        }
    }

    if (db <= 1) {
        if (outEleje) *outEleje = 0;
        if (outVege) *outVege = 0;
        return 0;
    }

    for (int i = 0; i < db - 1; i++) {
        for (int j = i + 1; j < db; j++) {
            if (kezdet[i] > kezdet[j]) {
                int seged = kezdet[i]; kezdet[i] = kezdet[j]; kezdet[j] = seged;
                seged = veg[i]; veg[i] = veg[j]; veg[j] = seged;
            }
        }
    }

    int ukezdet[2000], uveg[2000], udb = 0;
    int a = kezdet[0], b = veg[0];
    for (int i = 1; i < db; i++) {
        if (kezdet[i] <= b) {
            if (veg[i] > b) b = veg[i];
        } else {
            ukezdet[udb] = a;
            uveg[udb] = b;
            udb++;
            a = kezdet[i];
            b = veg[i];
        }
    }
    ukezdet[udb] = a;
    uveg[udb] = b;
    udb++;

    int maxhossz = 0;
    int eleje = 0, vege = 0;

    for (int i = 0; i < udb - 1; i++) {
        int hossz = ukezdet[i + 1] - uveg[i];
        if (hossz > maxhossz) {
            maxhossz = hossz;
            eleje = uveg[i];
            vege = ukezdet[i + 1];
        }
    }

    if (maxhossz == 0) {
        if (outEleje) *outEleje = 0;
        if (outVege) *outVege = 0;
        return 0;
    } else {
        if (outEleje) *outEleje = eleje;
        if (outVege) *outVege = vege;
        return 1;
    }
}

// 14. Longest war for a tribe
int findLongestWar(int /*N*/, int K, const int ki[], const int kivel[], const int mettol[], const int meddig[], int S, int *outEllenfel, int *outKezd, int *outVeg) {
    int maxHossz = -1, maxEllenfel = 0, kezd = 0, veg = 0;

    for (int i = 0; i < K; i++) {
        if (ki[i] == S || kivel[i] == S) {
            int hossz = meddig[i] - mettol[i];
            if (hossz > maxHossz) {
                maxHossz = hossz;
                maxEllenfel = (ki[i] == S ? kivel[i] : ki[i]);
                kezd = mettol[i];
                veg = meddig[i];
            } else if (hossz == maxHossz && hossz != -1) {
                if (mettol[i] < kezd) {
                    maxEllenfel = (ki[i] == S ? kivel[i] : ki[i]);
                    kezd = mettol[i];
                    veg = meddig[i];
                }
            }
        }
    }

    if (maxHossz == -1) {
        if (outEllenfel) *outEllenfel = 0;
        if (outKezd) *outKezd = 0;
        if (outVeg) *outVeg = 0;
        return 0;
    } else {
        if (outEllenfel) *outEllenfel = maxEllenfel;
        if (outKezd) *outKezd = kezd;
        if (outVeg) *outVeg = veg;
        return 1;
    }
}

// 15. Shortest war for a tribe
int findShortestWar(int /*N*/, int K, const int ki[], const int kivel[], const int mettol[], const int meddig[], int S, int *outEllenfel, int *outKezd, int *outVeg) {
    int minHossz = 1000000000, minEllenfel = 0, kezd = 0, veg = 0;

    for (int i = 0; i < K; i++) {
        if (ki[i] == S || kivel[i] == S) {
            int hossz = meddig[i] - mettol[i];
            if (hossz < minHossz) {
                minHossz = hossz;
                minEllenfel = (ki[i] == S ? kivel[i] : ki[i]);
                kezd = mettol[i];
                veg = meddig[i];
            } else if (hossz == minHossz && hossz != 1000000000) {
                if (mettol[i] < kezd) {
                    minEllenfel = (ki[i] == S ? kivel[i] : ki[i]);
                    kezd = mettol[i];
                    veg = meddig[i];
                }
            }
        }
    }

    if (minHossz == 1000000000) {
        if (outEllenfel) *outEllenfel = 0;
        if (outKezd) *outKezd = 0;
        if (outVeg) *outVeg = 0;
        return 0;
    } else {
        if (outEllenfel) *outEllenfel = minEllenfel;
        if (outKezd) *outKezd = kezd;
        if (outVeg) *outVeg = veg;
        return 1;
    }
}


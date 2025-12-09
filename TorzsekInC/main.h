//
//  main.hpp
//  TorzsekInC
//
//  Created by BLightAdee on 09.12.2025.
//

#ifdef __cplusplus
extern "C"
{
#endif

inline int haboruIdotartamAdottSzazad(int /*n*/, int k, const int wars[][4], const char *century);
inline int csak_egyszer_haborozu_torzs(int k, const int ki[], const int kivel[]);
inline int egy_evnel_rovhab(int k, const int mettol[], const int meddig[]);
inline int haboruPerTorzs(int /*N*/, int K, const int ki[], const int kivel[], const int /*mettol*/[], const int /*meddig*/[], int torzs);
inline int calculateWarYears(int /*n*/, int k, const int ki[], const int kivel[], const int mettol[], const int meddig[], int s, char sz);
inline int calculatePeacePeriod(int /*torzsek*/, int haboruk, const int ki[], const int kivel[], const int mettol[], const int meddig[], int keresett, int *outEleje, int *outVege);
inline int findLongestWar(int /*N*/, int K, const int ki[], const int kivel[], const int mettol[], const int meddig[], int S, int *outEllenfel, int *outKezd, int *outVeg);
inline int findShortestWar(int /*N*/, int K, const int ki[], const int kivel[], const int mettol[], const int meddig[], int S, int *outEllenfel, int *outKezd, int *outVeg);

#ifdef __cplusplus
}
#endif

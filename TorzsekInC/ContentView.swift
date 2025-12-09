//
//  ContentView.swift
//  TorzsekInC
//
//  Created by BLightAdee on 09.12.2025.
//

import SwiftUI

struct ContentView: View {
    // All input fields needed for all problems
    @State private var n: Int = 0
    @State private var k: Int = 0
    @State private var wars: [[Int]] = Array(repeating: [0, 0, 0, 0], count: 10) // Default 10 rows, can grow
    @State private var ki: [Int] = Array(repeating: 0, count: 10)
    @State private var kivel: [Int] = Array(repeating: 0, count: 10)
    @State private var mettol: [Int] = Array(repeating: 0, count: 10)
    @State private var meddig: [Int] = Array(repeating: 0, count: 10)
    @State private var century: String = ""
    @State private var torzs: Int = 0
    @State private var s: Int = 0
    @State private var sz: String = "A"
    @State private var keresett: Int = 0
    @State private var S: Int = 0
    @State private var selectedProblem: Int = 1
    @State private var result: String = ""
    @State private var kRows: Int = 1 // Number of war records shown

    @State private var warsFlatBuffer: [Int32] = []

    // Helper to keep array sizes in sync
    private func resizeWarArrays() {
        let desired = max(1, kRows)
        if wars.count != desired { wars = Array(wars.prefix(desired)) + Array(repeating: [0,0,0,0], count: max(0, desired - wars.count)) }
        if ki.count != desired { ki = Array(ki.prefix(desired)) + Array(repeating: 0, count: max(0, desired - ki.count)) }
        if kivel.count != desired { kivel = Array(kivel.prefix(desired)) + Array(repeating: 0, count: max(0, desired - kivel.count)) }
        if mettol.count != desired { mettol = Array(mettol.prefix(desired)) + Array(repeating: 0, count: max(0, desired - mettol.count)) }
        if meddig.count != desired { meddig = Array(meddig.prefix(desired)) + Array(repeating: 0, count: max(0, desired - meddig.count)) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    Text("N (number of tribes):")
                    Stepper(value: $n, in: 0...100, step: 1) { Text("\(n)") }
                    Text("K (number of war records):")
                    Stepper(value: $kRows, in: 1...50, step: 1, onEditingChanged: { _ in resizeWarArrays() }) { Text("\(kRows)") }
                }

                Group {
                    Text("War Records (ki, kivel, mettol, meddig):")
                    ForEach(0..<kRows, id: \.self) { i in
                        HStack {
                            TextField("ki", value: $ki[i], formatter: NumberFormatter())
                                .frame(width: 40)
                            TextField("kivel", value: $kivel[i], formatter: NumberFormatter())
                                .frame(width: 40)
                            TextField("mettol", value: $mettol[i], formatter: NumberFormatter())
                                .frame(width: 60)
                            TextField("meddig", value: $meddig[i], formatter: NumberFormatter())
                                .frame(width: 60)
                        }
                    }
                }

                Group {
                    Text("Century (roman numeral, e.g., 'IX'): ")
                    TextField("Century", text: $century)
                        .frame(width: 120)
                    HStack {
                        Text("torzs (problem 11):")
                        TextField("torzs", value: $torzs, formatter: NumberFormatter())
                            .frame(width: 40)
                    }
                    HStack {
                        Text("s (problem 12):")
                        TextField("s", value: $s, formatter: NumberFormatter())
                            .frame(width: 40)
                        Text("sz (A/B/C):")
                        TextField("sz", text: $sz)
                            .frame(width: 30)
                    }
                    HStack {
                        Text("keresett (problem 13):")
                        TextField("keresett", value: $keresett, formatter: NumberFormatter())
                            .frame(width: 40)
                    }
                    HStack {
                        Text("S (problems 14/15):")
                        TextField("S", value: $S, formatter: NumberFormatter())
                            .frame(width: 40)
                    }
                }

                Divider()
                Text("Select Problem to Run:")
                Picker("Problem", selection: $selectedProblem) {
                    Text("1. Max war length in century").tag(1)
                    Text("6. Exactly-once warring tribe").tag(6)
                    Text("8. Wars shorter than 1 year").tag(8)
                    Text("11. Number of wars for a tribe").tag(11)
                    Text("12. Total war years for a tribe/block").tag(12)
                    Text("13. Longest peace period for a tribe").tag(13)
                    Text("14. Longest war for a tribe").tag(14)
                    Text("15. Shortest war for a tribe").tag(15)
                }.pickerStyle(.menu)

                Button("Run") {
                    result = runSelectedProblem()
                }.padding(.top, 10)

                Divider()
                Text("Result:").font(.headline)
                Text(result).padding().frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 700)
    }

    // MARK: - Call C++ functions
    func runSelectedProblem() -> String {
        switch selectedProblem {
        case 1:
            // int haboruIdotartamAdottSzazad(int n, int k, const int wars[][4], const char *century)
            return String(haboruIdotartamAdottSzazad(Int32(n), Int32(kRows), asWarsCArray(), century))
        case 6:
            return String(csak_egyszer_haborozu_torzs(Int32(kRows), asInt32Array(ki), asInt32Array(kivel)))
        case 8:
            return String(egy_evnel_rovhab(Int32(kRows), asInt32Array(mettol), asInt32Array(meddig)))
        case 11:
            return String(haboruPerTorzs(Int32(n), Int32(kRows), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(torzs)))
        case 12:
            guard let szChar = sz.uppercased().first else { return "Block selector (sz) required (A/B/C)" }
            let cChar = CChar(szChar.asciiValue!)
            return String(calculateWarYears(Int32(n), Int32(kRows), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(s), cChar))
        case 13:
            var eleje: Int32 = 0, vege: Int32 = 0
            let ok = calculatePeacePeriod(Int32(n), Int32(kRows), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(keresett), &eleje, &vege)
            if ok == 0 { return "0 0" } else { return "\(eleje) \(vege)" }
        case 14:
            var ellenfel: Int32 = 0, kezd: Int32 = 0, veg: Int32 = 0
            let ok = findLongestWar(Int32(n), Int32(kRows), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(S), &ellenfel, &kezd, &veg)
            if ok == 0 { return "0 0 0" } else { return "\(ellenfel) \(kezd) \(veg)" }
        case 15:
            var ellenfel: Int32 = 0, kezd: Int32 = 0, veg: Int32 = 0
            let ok = findShortestWar(Int32(n), Int32(kRows), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(S), &ellenfel, &kezd, &veg)
            if ok == 0 { return "0 0 0" } else { return "\(ellenfel) \(kezd) \(veg)" }
        default:
            return "Not implemented."
        }
    }

    // MARK: - C bridging helpers
    func asInt32Array(_ arr: [Int]) -> UnsafePointer<Int32> {
        let buffer = arr.map { Int32($0) }
        return UnsafePointer(buffer)
    }
    
    func asWarsCArray() -> UnsafePointer<(Int32, Int32, Int32, Int32)> {
        warsFlatBuffer = wars.prefix(kRows).flatMap { row in row.prefix(4).map { Int32($0) } }
        let tuplePtr = warsFlatBuffer.withUnsafeBufferPointer { ptr -> UnsafePointer<(Int32, Int32, Int32, Int32)> in
            unsafeBitCast(ptr.baseAddress, to: UnsafePointer<(Int32, Int32, Int32, Int32)>.self)
        }
        return tuplePtr
    }
}

#Preview {
    ContentView()
}

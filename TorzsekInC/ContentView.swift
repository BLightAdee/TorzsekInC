//
//  ContentView.swift
//  TorzsekInC
//
//  Created by BLightAdee on 09.12.2025.
//

import SwiftUI

struct ContentView: View {
    // Removed @State var n and kRows
    
    @State private var ki: [Int] = [0]
    @State private var kivel: [Int] = [0]
    @State private var mettol: [Int] = [0]
    @State private var meddig: [Int] = [0]
    @State private var wars: [[Int]] = [[0, 0, 0, 0]]
    
    @State private var century: String = ""
    @State private var torzs: Int = 0
    @State private var s: Int = 0
    @State private var sz: String = "A"
    @State private var keresett: Int = 0
    @State private var S: Int = 0
    @State private var selectedProblem: Int = 1
    @State private var result: String = ""
    
    @State private var warsFlatBuffer: [Int32] = []
    
    // Computed property for n (number of tribes)
    var n: Int {
        let maxKi = ki.max() ?? 0
        let maxKivel = kivel.max() ?? 0
        return max(maxKi, maxKivel)
    }
    
    var k: Int {
        // Number of war records (length of ki or kivel arrays)
        return ki.count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Group {
                    Text("Number of tribes: \(n)")
                        .fontWeight(.semibold)
                }
                
                Group {
                    Text("War Records (ki, kivel, mettol, meddig):")
                    ForEach(0..<k, id: \.self) { i in
                        HStack {
                            TextField("ki", value: Binding<Int>(
                                get: { ki[i] },
                                set: { newValue in
                                    ki[i] = newValue
                                    syncWarsRow(index: i)
                                }
                            ), formatter: NumberFormatter())
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                            TextField("kivel", value: Binding<Int>(
                                get: { kivel[i] },
                                set: { newValue in
                                    kivel[i] = newValue
                                    syncWarsRow(index: i)
                                }
                            ), formatter: NumberFormatter())
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                            TextField("mettol", value: Binding<Int>(
                                get: { mettol[i] },
                                set: { newValue in
                                    mettol[i] = newValue
                                    syncWarsRow(index: i)
                                }
                            ), formatter: NumberFormatter())
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                            TextField("meddig", value: Binding<Int>(
                                get: { meddig[i] },
                                set: { newValue in
                                    meddig[i] = newValue
                                    syncWarsRow(index: i)
                                }
                            ), formatter: NumberFormatter())
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                            
                            if k > 1 {
                                Button(action: {
                                    removeRow(at: i)
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(.plain)
                                .padding(.leading, 8)
                            }
                        }
                    }
                    Button(action: addRow) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add War Record")
                        }
                    }
                    .padding(.top, 5)
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
                }
                .pickerStyle(.menu)
                
                if selectedProblem == 1 {
                    Text("Century (roman numeral, e.g., 'IX'): ")
                    TextField("Century", text: $century)
                        .frame(width: 120)
                        .textFieldStyle(.roundedBorder)
                }
                if selectedProblem == 11 {
                    HStack {
                        Text("torzs (problem 11):")
                        TextField("torzs", value: $torzs, formatter: NumberFormatter())
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                if selectedProblem == 12 {
                    HStack {
                        Text("s (problem 12):")
                        TextField("s", value: $s, formatter: NumberFormatter())
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                        Text("sz (A/B/C):")
                        TextField("sz", text: $sz)
                            .frame(width: 30)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                if selectedProblem == 13 {
                    HStack {
                        Text("keresett (problem 13):")
                        TextField("keresett", value: $keresett, formatter: NumberFormatter())
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                if selectedProblem == 14 || selectedProblem == 15 {
                    HStack {
                        Text("S (problems 14/15):")
                        TextField("S", value: $S, formatter: NumberFormatter())
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                Button("Run") {
                    result = runSelectedProblem()
                }
                .padding(.top, 10)
                
                Divider()
                Text("Result:").font(.headline)
                Text(result)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 700)
    }
    
    // MARK: - Row management
    private func addRow() {
        ki.append(0)
        kivel.append(0)
        mettol.append(0)
        meddig.append(0)
        wars.append([0, 0, 0, 0])
    }
    
    private func removeRow(at index: Int) {
        guard ki.count > 1 else { return }
        ki.remove(at: index)
        kivel.remove(at: index)
        mettol.remove(at: index)
        meddig.remove(at: index)
        wars.remove(at: index)
    }
    
    // Synchronize wars array row with individual arrays
    private func syncWarsRow(index: Int) {
        if index < wars.count {
            wars[index][0] = ki[index]
            wars[index][1] = kivel[index]
            wars[index][2] = mettol[index]
            wars[index][3] = meddig[index]
        } else if index == wars.count {
            wars.append([ki[index], kivel[index], mettol[index], meddig[index]])
        }
    }
    
    // MARK: - Call C++ functions
    func runSelectedProblem() -> String {
        switch selectedProblem {
        case 1:
            // int haboruIdotartamAdottSzazad(int n, int k, const int wars[][4], const char *century)
            return String(haboruIdotartamAdottSzazad(Int32(n), Int32(k), asWarsCArray(), century))
        case 6:
            return String(csak_egyszer_haborozu_torzs(Int32(k), asInt32Array(ki), asInt32Array(kivel)))
        case 8:
            return String(egy_evnel_rovhab(Int32(k), asInt32Array(mettol), asInt32Array(meddig)))
        case 11:
            return String(haboruPerTorzs(Int32(n), Int32(k), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(torzs)))
        case 12:
            guard let szChar = sz.uppercased().first else { return "Block selector (sz) required (A/B/C)" }
            let cChar = CChar(szChar.asciiValue!)
            return String(calculateWarYears(Int32(n), Int32(k), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(s), cChar))
        case 13:
            var eleje: Int32 = 0, vege: Int32 = 0
            let ok = calculatePeacePeriod(Int32(n), Int32(k), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(keresett), &eleje, &vege)
            if ok == 0 { return "0 0" } else { return "\(eleje) \(vege)" }
        case 14:
            var ellenfel: Int32 = 0, kezd: Int32 = 0, veg: Int32 = 0
            let ok = findLongestWar(Int32(n), Int32(k), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(S), &ellenfel, &kezd, &veg)
            if ok == 0 { return "0 0 0" } else { return "\(ellenfel) \(kezd) \(veg)" }
        case 15:
            var ellenfel: Int32 = 0, kezd: Int32 = 0, veg: Int32 = 0
            let ok = findShortestWar(Int32(n), Int32(k), asInt32Array(ki), asInt32Array(kivel), asInt32Array(mettol), asInt32Array(meddig), Int32(S), &ellenfel, &kezd, &veg)
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
        // Make sure wars matches ki.count
        if wars.count < k {
            wars += Array(repeating: [0, 0, 0, 0], count: k - wars.count)
        } else if wars.count > k {
            wars = Array(wars.prefix(k))
        }
        warsFlatBuffer = wars.flatMap { $0.prefix(4).map { Int32($0) } }
        let tuplePtr = warsFlatBuffer.withUnsafeBufferPointer { ptr -> UnsafePointer<(Int32, Int32, Int32, Int32)> in
            unsafeBitCast(ptr.baseAddress, to: UnsafePointer<(Int32, Int32, Int32, Int32)>.self)
        }
        return tuplePtr
    }
}

#Preview {
    ContentView()
}

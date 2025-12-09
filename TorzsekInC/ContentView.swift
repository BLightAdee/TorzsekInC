//
//  ContentView.swift
//  TorzsekInC
//
//  Created by BLightAdee on 09.12.2025.
//
//

import SwiftUI

struct ContentView: View {
    // Removed @State var n and kRows

    @State private var ki: [Int?] = [nil]
    @State private var kivel: [Int?] = [nil]
    @State private var mettol: [Int?] = [nil]
    @State private var meddig: [Int?] = [nil]
    @State private var wars: [[Int]] = [[0, 0, 0, 0]]

    @State private var century: String = ""
    @State private var torzs: Int? = nil
    @State private var s: Int? = nil
    @State private var sz: String = "A"
    @State private var keresett: Int? = nil
    @State private var S: Int? = nil
    @State private var selectedProblem: Int = 1
    @State private var result: String = ""
    @State private var showWarning: Bool = false
    @State private var warningMessage: String = "Please fill in all required fields."

    @State private var warsFlatBuffer: [Int32] = []

    // Computed property for n (number of tribes)
    var n: Int {
        let maxKi = ki.compactMap({ $0 }).max() ?? 0
        let maxKivel = kivel.compactMap({ $0 }).max() ?? 0
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
                            TextField("ki", text: binding(for: i, array: $ki))
                                .frame(width: 40)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: ki[i]) { _ in syncWarsRow(index: i) }

                            TextField("kivel", text: binding(for: i, array: $kivel))
                                .frame(width: 40)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: kivel[i]) { _ in syncWarsRow(index: i) }

                            TextField("mettol", text: binding(for: i, array: $mettol))
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: mettol[i]) { _ in syncWarsRow(index: i) }

                            TextField("meddig", text: binding(for: i, array: $meddig))
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: meddig[i]) { _ in syncWarsRow(index: i) }

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
                        TextField("torzs", text: optionalIntBinding($torzs))
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                if selectedProblem == 12 {
                    HStack {
                        Text("s (problem 12):")
                        TextField("s", text: optionalIntBinding($s))
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
                        TextField("keresett", text: optionalIntBinding($keresett))
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                if selectedProblem == 14 || selectedProblem == 15 {
                    HStack {
                        Text("S (problems 14/15):")
                        TextField("S", text: optionalIntBinding($S))
                            .frame(width: 40)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Button("Run") {
                    if validateInputs() {
                        result = runSelectedProblem()
                    } else {
                        showWarning = true
                    }
                }
                .padding(.top, 10)
                .alert(isPresented: $showWarning) {
                    Alert(
                        title: Text("Missing Input"), message: Text(warningMessage),
                        dismissButton: .default(Text("OK")))
                }

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

    // MARK: - Binding Helpers

    private func binding(for index: Int, array: Binding<[Int?]>) -> Binding<String> {
        return Binding<String>(
            get: {
                if index < array.wrappedValue.count, let value = array.wrappedValue[index] {
                    return String(value)
                }
                return ""
            },
            set: { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if let intValue = Int(filtered) {
                    if index < array.wrappedValue.count {
                        array.wrappedValue[index] = intValue
                    }
                } else {
                    if index < array.wrappedValue.count {
                        array.wrappedValue[index] = nil
                    }
                }
            }
        )
    }

    private func optionalIntBinding(_ value: Binding<Int?>) -> Binding<String> {
        return Binding<String>(
            get: {
                if let v = value.wrappedValue {
                    return String(v)
                }
                return ""
            },
            set: { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if let intValue = Int(filtered) {
                    value.wrappedValue = intValue
                } else {
                    value.wrappedValue = nil
                }
            }
        )
    }

    // MARK: - Validation
    private func validateInputs() -> Bool {
        // Validate table rows
        for i in 0..<k {
            if ki[i] == nil || kivel[i] == nil || mettol[i] == nil || meddig[i] == nil {
                warningMessage = "Please fill in all values in the War Records table."
                return false
            }
        }

        // Validate problem specifics
        switch selectedProblem {
        case 1:
            if century.isEmpty {
                warningMessage = "Please enter a century."
                return false
            }
        case 11:
            if torzs == nil {
                warningMessage = "Please enter 'torzs'."
                return false
            }
        case 12:
            if s == nil {
                warningMessage = "Please enter 's'."
                return false
            }
            if sz.isEmpty {
                warningMessage = "Please enter 'sz'."
                return false
            }
        case 13:
            if keresett == nil {
                warningMessage = "Please enter 'keresett'."
                return false
            }
        case 15, 14:
            if S == nil {
                warningMessage = "Please enter 'S'."
                return false
            }
        default:
            break
        }

        return true
    }

    // MARK: - Row management
    private func addRow() {
        ki.append(nil)
        kivel.append(nil)
        mettol.append(nil)
        meddig.append(nil)
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
    // We default nil to 0 in the wars cache just to keep structure, but we rely on validation before use.
    private func syncWarsRow(index: Int) {
        let v_ki = ki[index] ?? 0
        let v_kivel = kivel[index] ?? 0
        let v_mettol = mettol[index] ?? 0
        let v_meddig = meddig[index] ?? 0

        if index < wars.count {
            wars[index][0] = v_ki
            wars[index][1] = v_kivel
            wars[index][2] = v_mettol
            wars[index][3] = v_meddig
        } else if index == wars.count {
            wars.append([v_ki, v_kivel, v_mettol, v_meddig])
        }
    }

    // MARK: - Call C++ functions
    func runSelectedProblem() -> String {
        // Force unwrap safe arrays because validation passed
        let safeKi = ki.compactMap { $0! }
        let safeKivel = kivel.compactMap { $0! }
        let safeMettol = mettol.compactMap { $0! }
        let safeMeddig = meddig.compactMap { $0! }

        switch selectedProblem {
        case 1:
            // int haboruIdotartamAdottSzazad(int n, int k, const int wars[][4], const char *century)
            return String(haboruIdotartamAdottSzazad(Int32(n), Int32(k), asWarsCArray(), century))
        case 6:
            return String(
                csak_egyszer_haborozu_torzs(Int32(k), asInt32Array(safeKi), asInt32Array(safeKivel))
            )
        case 8:
            return String(
                egy_evnel_rovhab(Int32(k), asInt32Array(safeMettol), asInt32Array(safeMeddig)))
        case 11:
            return String(
                haboruPerTorzs(
                    Int32(n), Int32(k), asInt32Array(safeKi), asInt32Array(safeKivel),
                    asInt32Array(safeMettol), asInt32Array(safeMeddig), Int32(torzs!)))
        case 12:
            guard let szChar = sz.uppercased().first else {
                return "Block selector (sz) required (A/B/C)"
            }
            let cChar = CChar(szChar.asciiValue!)
            return String(
                calculateWarYears(
                    Int32(n), Int32(k), asInt32Array(safeKi), asInt32Array(safeKivel),
                    asInt32Array(safeMettol), asInt32Array(safeMeddig), Int32(s!), cChar))
        case 13:
            var eleje: Int32 = 0
            var vege: Int32 = 0
            let ok = calculatePeacePeriod(
                Int32(n), Int32(k), asInt32Array(safeKi), asInt32Array(safeKivel),
                asInt32Array(safeMettol), asInt32Array(safeMeddig), Int32(keresett!), &eleje, &vege)
            if ok == 0 { return "0 0" } else { return "\(eleje) \(vege)" }
        case 14:
            var ellenfel: Int32 = 0
            var kezd: Int32 = 0
            var veg: Int32 = 0
            let ok = findLongestWar(
                Int32(n), Int32(k), asInt32Array(safeKi), asInt32Array(safeKivel),
                asInt32Array(safeMettol), asInt32Array(safeMeddig), Int32(S!), &ellenfel, &kezd,
                &veg)
            if ok == 0 { return "0 0 0" } else { return "\(ellenfel) \(kezd) \(veg)" }
        case 15:
            var ellenfel: Int32 = 0
            var kezd: Int32 = 0
            var veg: Int32 = 0
            let ok = findShortestWar(
                Int32(n), Int32(k), asInt32Array(safeKi), asInt32Array(safeKivel),
                asInt32Array(safeMettol), asInt32Array(safeMeddig), Int32(S!), &ellenfel, &kezd,
                &veg)
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
        let tuplePtr = warsFlatBuffer.withUnsafeBufferPointer {
            ptr -> UnsafePointer<(Int32, Int32, Int32, Int32)> in
            unsafeBitCast(ptr.baseAddress, to: UnsafePointer<(Int32, Int32, Int32, Int32)>.self)
        }
        return tuplePtr
    }
}

#Preview {
    ContentView()
}

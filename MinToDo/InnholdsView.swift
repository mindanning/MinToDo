//
//  InnholdsVisning.swift
//  MinToDo
//
//  Created by yDag on 20/09/2025.
//

import SwiftUI

// Når appen starter, begynner den her.
enum Status: String, CaseIterable, Identifiable { //referanse fra samling 22.september
    case ikkeStartet = "Ikke startet"
    case pågår = "Pågår"
    case fullført = "Fullført"

    var id: String { rawValue }
    
    // Endret label med ikon
    var ikon: String {
        switch self {
        case .ikkeStartet: return "clock"
        case .pågår: return "hourglass"
        case .fullført: return "checkmark.circle.fill"
        }
    }
    // Brukt litt tilpasset farge
    var farge: Color {
        switch self {
        case .ikkeStartet: return .orange
        case .pågår: return .blue
        case .fullført: return .green
        }
    }
}

struct Oppgave: Identifiable {
    let id = UUID()
    var tittel: String
    var beskrivelse: String = ""
    var frist: Date = .now
    var status: Status = .ikkeStartet
}

// Hovedvisning
struct InnholdsView: View {
    @State private var oppgaver: [Oppgave] = [
        Oppgave(tittel: "Readme til ToDo ", beskrivelse: "Skriv innledning og oppsummering", frist: .now.addingTimeInterval(60*60*24*2), status: .pågår),
        Oppgave(tittel: "Legg til GitHub", beskrivelse: "Lag en Rapository", frist: .now.addingTimeInterval(60*60*24*5), status: .ikkeStartet),
        Oppgave(tittel: "Lever ToDo oppgave", beskrivelse: "Skriv kort logg", frist: .now.addingTimeInterval(-60*60*24), status: .fullført)
    ]
    
    
    
    @State private var viserLeggTil = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient bakgrunn
                LinearGradient(
                    colors: [.orange, .teal],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea() // gjør at gradient dekker hele skjermen
                
                VStack {
                    // Info-tekst henter fra Global fil
                    Text(Global.velkomstTekst)
                        .font(.subheadline)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Selve listen med oppgaver
                    List {
                        ForEach($oppgaver) { $oppgave in
                            NavigationLink {
                                OppgaveDetaljVisning(oppgave: $oppgave)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: oppgave.status.ikon)
                                        .foregroundStyle(oppgave.status.farge)
                                        .imageScale(.large)
                                    
                                    VStack(alignment: .leading) {
                                        Text(oppgave.tittel).font(.headline)
                                        Text(oppgave.status.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .onDelete { indeks in oppgaver.remove(atOffsets: indeks) }
                    }
                    .scrollContentBackground(.hidden) // gjør at lista blir "gjennomsiktig"
                    .background(Color.clear) // viktig for å se gradienten bak
                }
            }
            .navigationTitle("Oppgaver")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viserLeggTil = true
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                }
            }
            .sheet(isPresented: $viserLeggTil) {
                NavigationStack {
                    LeggTilOppgaveVisning(oppgaver: $oppgaver)
                }
            }
        }
    }
    
}
struct OppgaveDetaljVisning: View {
    @Binding var oppgave: Oppgave

    var body: some View {
        Form {
            Section("Tittel og beskrivelse") {
                TextField("Tittel", text: $oppgave.tittel)
                TextField("Beskrivelse", text: $oppgave.beskrivelse, axis: .vertical)
            }

            Section("Frist og status") {
                DatePicker("Frist", selection: $oppgave.frist, displayedComponents: .date)
                Picker("Status", selection: $oppgave.status) {
                    ForEach(Status.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
            }
        }
        .navigationTitle("Detaljer")
    }
}

//Legg til
struct LeggTilOppgaveVisning: View {
    // gjør at skjermen kan lukkes.
    @Environment(\.dismiss) private var lukk
    // brukes slik at vi kan sende den nye oppgaven tilbake til hovedlisten.
    @Binding var oppgaver: [Oppgave]
    
    // midlertidige variabler der vi skriver inn i skjemaet
    @State private var tittel: String = ""
    @State private var beskrivelse: String = ""
    @State private var frist: Date = .now
    @State private var status: Status = .ikkeStartet

    var body: some View {
        Form {
            Section("Ny oppgave") {
                TextField("Tittel", text: $tittel)
                TextField("Beskrivelse", text: $beskrivelse, axis: .vertical)
                DatePicker("Frist", selection: $frist, displayedComponents: .date)
                Picker("Status", selection: $status) {
                    ForEach(Status.allCases) { s in
                        Text(s.rawValue).tag(s)
                    }
                }
            }
        }
        .navigationTitle("Legg til oppgave")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Avbryt") { lukk() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Lagre") {
                    let nyOppgave = Oppgave(tittel: tittel, beskrivelse: beskrivelse, frist: frist, status: status)
                    oppgaver.append(nyOppgave)
                    lukk()
                }
                .disabled(tittel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

#Preview {
    InnholdsView()
}

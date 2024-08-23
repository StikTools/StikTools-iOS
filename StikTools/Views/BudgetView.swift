//
//  BudgetView.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

struct BudgetView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showingAddEntry = false

    var body: some View {
        NavigationView {
            ZStack {
                // Set the custom background and ensure it covers the whole screen
                Color.primaryBackground
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 20) {
                    BudgetOverviewView(viewModel: viewModel)
                        .padding(.horizontal)

                    List {
                        ForEach(viewModel.entries) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.category)
                                        .font(.headline)
                                        .foregroundColor(.primaryText)
                                    Text(entry.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("$\(entry.amount, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(entry.isIncome ? .green : .red)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(entry.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(15)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        }
                        .onDelete(perform: viewModel.deleteEntry)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(Color.clear) // Set the background to clear for custom background visibility
                    .navigationTitle("Expense Tracker")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton()
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingAddEntry = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .sheet(isPresented: $showingAddEntry) {
                        AddEntryView(viewModel: viewModel)
                    }
                }
                .padding(.bottom, 0) // Ensure the VStack covers the entire height
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.accentColor)
    }
}

// BudgetEntry Model and ViewModel
struct BudgetEntry: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var category: String
    var amount: Double
    var isIncome: Bool
}

class BudgetViewModel: ObservableObject {
    @AppStorage("budgetEntries") private var budgetEntriesData: Data = Data()
    @Published var entries: [BudgetEntry] = []

    init() {
        loadEntries()
    }

    var totalIncome: Double {
        entries.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        entries.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        totalIncome - totalExpenses
    }

    func addEntry(_ entry: BudgetEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func deleteEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            budgetEntriesData = encoded
        }
    }

    private func loadEntries() {
        if let decoded = try? JSONDecoder().decode([BudgetEntry].self, from: budgetEntriesData) {
            entries = decoded
        }
    }
}

// BudgetOverviewView
struct BudgetOverviewView: View {
    @ObservedObject var viewModel: BudgetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Income")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("$\(viewModel.totalIncome, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Expenses")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("$\(viewModel.totalExpenses, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("$\(viewModel.balance, specifier: "%.2f")")
                        .font(.title)
                        .bold()
                        .foregroundColor(viewModel.balance >= 0 ? .white : .red)
                }
                Spacer()
                Image(systemName: viewModel.balance >= 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(viewModel.balance >= 0 ? .blue : .red)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// AddEntryView
struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel

    @State private var date = Date()
    @State private var category = ""
    @State private var amount = ""
    @State private var isIncome = false

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Category", text: $category)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                Toggle(isOn: $isIncome) {
                    Text("Income")
                }
            }
            .navigationTitle("Add Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(amount) {
                            let entry = BudgetEntry(date: date, category: category, amount: amount, isIncome: isIncome)
                            viewModel.addEntry(entry)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .accentColor(.purple)
    }
}

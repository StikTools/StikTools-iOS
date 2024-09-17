//
//  UnitConverterView.swift
//  StikTools
//
//  Created by TechGuy on 8/23/24.
//

import SwiftUI

struct UnitConverterView: View {
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @State private var inputValue = ""
    @State private var selectedCategoryIndex = 0
    @State private var selectedInputUnitIndex = 0
    @State private var selectedOutputUnitIndex = 1
    @State private var selectedBackgroundColor: Color = Color.primaryBackground
    @State private var showingBetaAlert = false

    let categories = ["Length", "Weight", "Temperature"]
    let units = [
        ["Meters", "Kilometers", "Feet", "Miles"],
        ["Grams", "Kilograms", "Pounds", "Ounces"],
        ["Celsius", "Fahrenheit", "Kelvin"]
    ]
    
    var selectedCategory: String {
        categories[selectedCategoryIndex]
    }
    
    var selectedInputUnit: String {
        units[selectedCategoryIndex][selectedInputUnitIndex]
    }
    
    var selectedOutputUnit: String {
        units[selectedCategoryIndex][selectedOutputUnitIndex]
    }
    
    var convertedValue: Double {
        guard let value = Double(inputValue) else { return 0 }
        
        switch selectedCategory {
        case "Length":
            return convertLength(value: value, from: selectedInputUnit, to: selectedOutputUnit)
        case "Weight":
            return convertWeight(value: value, from: selectedInputUnit, to: selectedOutputUnit)
        case "Temperature":
            return convertTemperature(value: value, from: selectedInputUnit, to: selectedOutputUnit)
        default:
            return 0
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    selectedCategoryIndex = (selectedCategoryIndex - 1 + categories.count) % categories.count
                    resetUnitIndexes()
                }) {
                    Image(systemName: "arrowshape.left")
                        .foregroundColor(.primaryText)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Spacer()
                
                Text(selectedCategory)
                    .font(.titleFont)
                    .bold()
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedCategoryIndex = (selectedCategoryIndex + 1) % categories.count
                    resetUnitIndexes()
                }) {
                    Image(systemName: "arrowshape.right")
                        .foregroundColor(.primaryText)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 20)

            TextField("Enter value", text: $inputValue)
                .keyboardType(.decimalPad)
                .textFieldStyle(CustomTextFieldStyle())
                .foregroundColor(.white)
            
            VStack(spacing: 10) {
                UnitSelectionView(
                    title: "From: \(selectedInputUnit)",
                    actionLeft: {
                        selectedInputUnitIndex = (selectedInputUnitIndex - 1 + units[selectedCategoryIndex].count) % units[selectedCategoryIndex].count
                    },
                    actionRight: {
                        selectedInputUnitIndex = (selectedInputUnitIndex + 1) % units[selectedCategoryIndex].count
                    }
                )
                
                UnitSelectionView(
                    title: "To: \(selectedOutputUnit)",
                    actionLeft: {
                        selectedOutputUnitIndex = (selectedOutputUnitIndex - 1 + units[selectedCategoryIndex].count) % units[selectedCategoryIndex].count
                    },
                    actionRight: {
                        selectedOutputUnitIndex = (selectedOutputUnitIndex + 1) % units[selectedCategoryIndex].count
                    }
                )
            }
            
            Text("Converted Value: \(convertedValue, specifier: "%.2f")")
                .font(.titleFont)
                .padding()
                .foregroundColor(.primaryText)
            
            Spacer()
        }
        .padding()
        .background(selectedBackgroundColor.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.light)
        .onAppear {
            loadCustomBackgroundColor()
            showingBetaAlert = true // Show the alert when the view appears
        }
        .alert(isPresented: $showingBetaAlert) {
            Alert(
                title: Text("Warning"),
                message: Text("This tool is in beta. Use at your own risk."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }
    
    func resetUnitIndexes() {
        selectedInputUnitIndex = 0
        selectedOutputUnitIndex = 1
    }
    
    func convertLength(value: Double, from: String, to: String) -> Double {
        let conversionTable: [String: Double] = [
            "Meters": 1.0,
            "Kilometers": 1000.0,
            "Feet": 0.3048,
            "Miles": 1609.34
        ]
        
        if let fromValue = conversionTable[from], let toValue = conversionTable[to] {
            return value * fromValue / toValue
        }
        
        return value
    }
    
    func convertWeight(value: Double, from: String, to: String) -> Double {
        let conversionTable: [String: Double] = [
            "Grams": 1.0,
            "Kilograms": 1000.0,
            "Pounds": 453.592,
            "Ounces": 28.3495
        ]
        
        if let fromValue = conversionTable[from], let toValue = conversionTable[to] {
            return value * fromValue / toValue
        }
        
        return value
    }
    
    func convertTemperature(value: Double, from: String, to: String) -> Double {
        switch (from, to) {
        case ("Celsius", "Fahrenheit"):
            return (value * 9/5) + 32
        case ("Fahrenheit", "Celsius"):
            return (value - 32) * 5/9
        case ("Celsius", "Kelvin"):
            return value + 273.15
        case ("Kelvin", "Celsius"):
            return value - 273.15
        case ("Fahrenheit", "Kelvin"):
            return (value - 32) * 5/9 + 273.15
        case ("Kelvin", "Fahrenheit"):
            return (value - 273.15) * 9/5 + 32
        default:
            return value
        }
    }
}

struct UnitSelectionView: View {
    let title: String
    let actionLeft: () -> Void
    let actionRight: () -> Void
    
    var body: some View {
        HStack {
            Button(action: actionLeft) {
                Image(systemName: "arrowshape.left")
                    .foregroundColor(.primaryText)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Button(action: actionRight) {
                Image(systemName: "arrowshape.right")
                    .foregroundColor(.primaryText)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 20)
    }
}

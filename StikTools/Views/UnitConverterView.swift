//
//  UnitConverterView.swift
//  StikTools
//
//  Created by TechGuy on 8/23/24.
//

import SwiftUI

struct UnitConverterView: View {
    @State private var inputValue = ""
    @State private var selectedCategoryIndex = 0
    @State private var selectedInputUnitIndex = 0
    @State private var selectedOutputUnitIndex = 1
    
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
        VStack {
            HStack {
                Button(action: {
                    selectedCategoryIndex = (selectedCategoryIndex - 1 + categories.count) % categories.count
                    resetUnitIndexes()
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                
                Spacer()
                
                Text(selectedCategory)
                    .font(.title)
                    .bold()
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedCategoryIndex = (selectedCategoryIndex + 1) % categories.count
                    resetUnitIndexes()
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            }
            .padding()

            TextField("Enter value", text: $inputValue)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(8)
            
            HStack {
                Button(action: {
                    selectedInputUnitIndex = (selectedInputUnitIndex - 1 + units[selectedCategoryIndex].count) % units[selectedCategoryIndex].count
                }) {
                    Image(systemName: "arrow.left.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
                
                Text("From: \(selectedInputUnit)")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedInputUnitIndex = (selectedInputUnitIndex + 1) % units[selectedCategoryIndex].count
                }) {
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .padding()
            
            HStack {
                Button(action: {
                    selectedOutputUnitIndex = (selectedOutputUnitIndex - 1 + units[selectedCategoryIndex].count) % units[selectedCategoryIndex].count
                }) {
                    Image(systemName: "arrow.left.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
                
                Text("To: \(selectedOutputUnit)")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedOutputUnitIndex = (selectedOutputUnitIndex + 1) % units[selectedCategoryIndex].count
                }) {
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .padding()
            
            Text("Converted Value: \(convertedValue, specifier: "%.2f")")
                .font(.title)
                .padding()
                .foregroundColor(.primaryText)
            
            Spacer()
        }
        .padding()
        .background(Color.primaryBackground.edgesIgnoringSafeArea(.all))
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

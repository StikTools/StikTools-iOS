//
//  QRCodeGeneratorView.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color.cardBackground)
            .foregroundColor(.white) // Text color
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 1)
            )
    }
}

struct QRCodeGeneratorView: View {
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @State private var qrCodeText = ""
    @State private var qrCodeImage: UIImage?
    @State private var showingAlert = false
    @State private var selectedBackgroundColor: Color = Color.primaryBackground

    var body: some View {
        VStack(spacing: 20) {
            Text("QR Code Generator")
                .font(.titleFont)
                .foregroundColor(.primaryText)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
                TextField("Enter text for QR code", text: $qrCodeText)
                    .textFieldStyle(CustomTextFieldStyle()) // Apply custom style
                    .foregroundColor(.white) // Ensure text color is white
                
                Button(action: generateQRCode) {
                    Text("Generate QR Code")
                        .font(.bodyFont)
                        .foregroundColor(.primaryText)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button(action: exportQRCode) {
                    Text("Export QR Code")
                        .font(.bodyFont)
                        .foregroundColor(.primaryText)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("QR Code Saved"),
                        message: Text("QR Code saved to Photos."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding(.horizontal, 20)
            
            if let image = qrCodeImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding()
            } else {
                Text("No QR Code available")
                    .foregroundColor(.secondaryText)
                    .font(.body)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .background(selectedBackgroundColor.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.light)
        .onAppear {
            loadCustomBackgroundColor()
        }
    }
    
    private func generateQRCode() {
        guard let data = qrCodeText.data(using: .utf8) else {
            qrCodeImage = nil
            return
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue(data, forKey: "inputMessage")
        
        let qrCodeSize = CGSize(width: 500, height: 500)
        
        guard let ciImage = filter.outputImage else {
            qrCodeImage = nil
            return
        }
        
        let scaleX = qrCodeSize.width / ciImage.extent.width
        let scaleY = qrCodeSize.height / ciImage.extent.height
        
        let scaledCIImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else {
            qrCodeImage = nil
            return
        }
        
        qrCodeImage = UIImage(cgImage: cgImage)
    }
    
    private func exportQRCode() {
        guard let image = qrCodeImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        showingAlert = true
    }

    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }
}

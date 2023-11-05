//
//  ContentView.swift
//  Klima
//
//  Created by luegm.dev on 03.11.23.
//

import SwiftUI
import PhotosUI
import PassKit
import CodeScanner

class FormData: ObservableObject {
    @Published var fullName: String = ""
    @Published var cardNr: String = ""
    @Published var dateFrom: String = ""
    @Published var dateTo: String = ""
    @Published var dateBirth: String = ""
    @Published var type: String = "Classic"
    @Published var aztecCode: String = ""
    @Published var imgBase64: String = ""
    
    var isComplete: Bool {
        return !fullName.isEmpty && !cardNr.isEmpty && !dateFrom.isEmpty && !dateTo.isEmpty && !dateBirth.isEmpty && !type.isEmpty && !aztecCode.isEmpty && !imgBase64.isEmpty
    }
}


struct ContentView: View {
    
    @StateObject private var formData = FormData()
    
    @State private var isLoading: Bool = false
    
    @State private var pass: PKPass?
    @State private var showPassView: Bool = false
    @State private var showScanner: Bool = false
    @State private var showError: Bool = false
    @State private var showSetting = false
    @State private var errorText: String = "An error occurred while importing the pass."
    @State private var serverIP = "192.168.1.1:3000"
    
    @State private var dateFrom: Date = Date()
    @State private var dateTo: Date = Date()
    @State private var dateBirth: Date = Date()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Full Name", text: $formData.fullName)
                    DatePicker("Birth Date", selection: $dateBirth, displayedComponents: .date)
                        .onChange(of: dateBirth) { newDate in
                            formData.dateBirth = dateFormatter.string(from: newDate)
                        }
                } header: {
                    Text("Personal Infos")
                }
                
                Section {
                    TextField("Type", text: $formData.type)
                    TextField("Card Number", text: $formData.cardNr)
                    DatePicker("Valid From", selection: $dateFrom, displayedComponents: .date)
                        .onChange(of: dateFrom) { newDate in
                            formData.dateFrom = dateFormatter.string(from: newDate)
                        }
                    DatePicker("Valid Until", selection: $dateTo, displayedComponents: .date)
                        .onChange(of: dateTo) { newDate in
                            formData.dateTo = dateFormatter.string(from: newDate)
                        }
                } header: {
                    Text("Card Infos")
                }
                
                Section {
                    Button(action: {
                        showScanner.toggle()
                    }, label: {
                        Label {
                            HStack {
                                Text("Scan Code")
                                Spacer()
                                if formData.aztecCode != "" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        } icon: {
                            Image(systemName: "qrcode")
                        }
                    })
                    
                    
                    PhotosPicker(selection: $avatarItem, matching: .images, label: {
                        Label {
                            HStack {
                                Text("Picture")
                                Spacer()
                                if formData.imgBase64 != "" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        } icon: {
                            Image(systemName: "face.smiling")
                        }
                    })
                }
                
                Section {
                    Button(action: {
                        postAndPreviewPass()
                    }) {
                        Label {
                            HStack {
                                Text("Fetch and Open Pass")
                                Spacer()
                                if isLoading {
                                    ProgressView()
                                }
                            }
                        } icon: {
                            Image(systemName: "wallet.pass.fill")
                                .foregroundStyle(formData.isComplete ? .blue : .gray.opacity(0.5))
                        }
                    }
                    .disabled(!formData.isComplete)
                }
            }
            .onChange(of: avatarItem) { _ in
                Task {
                    if let data = try? await avatarItem?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            // Determine the dimensions of the original image
                            let originalSize = uiImage.size
                            let minDimension = min(originalSize.width, originalSize.height)
                            
                            // Calculate the cropping rectangle
                            let croppingRect = CGRect(x: (originalSize.width - minDimension) / 2,
                                                      y: (originalSize.height - minDimension) / 2,
                                                      width: minDimension,
                                                      height: minDimension)
                            
                            // Crop the image to a square
                            let croppedImage = uiImage.cropping(to: croppingRect)
                            
                            // Proceed with your existing code...
                            let maxDimension: CGFloat = 300 // Set the maximum dimension you want
                            let scaledImage = croppedImage!.scaledDown(to: maxDimension)
                            
                            // Create a new image context
                            UIGraphicsBeginImageContextWithOptions(scaledImage.size, false, 0.0)
                            defer { UIGraphicsEndImageContext() }
                            
                            // Create a path that is a circle
                            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: scaledImage.size))
                            path.addClip()
                            
                            // Draw the image in the current context
                            scaledImage.draw(in: CGRect(origin: .zero, size: scaledImage.size))
                            
                            // Get the clipped image
                            let clippedImage = UIGraphicsGetImageFromCurrentImageContext()
                            
                            // Convert the clipped image to Data, then to Base64
                            formData.imgBase64 = clippedImage?.pngData()?.base64EncodedString() ?? ""
                            print(formData.imgBase64)
                            return
                        }
                    }
                    print("Failed")
                }
            }
            
            
            
            .sheet(isPresented: $showPassView) {
                AddPassView(pass: $pass)
            }
            .sheet(isPresented: $showScanner) {
                CodeScannerView(codeTypes: [.aztec], showViewfinder: true, simulatedData: "Paul Hudson") { response in
                    switch response {
                    case .success(let result):
                        formData.aztecCode = result.string
                        print("Found code: \(result.string)")
                        showScanner.toggle()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .ignoresSafeArea()
                .presentationDetents([.medium])
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorText), dismissButton: .default(Text("OK")))
            }
            .alert("Server IP", isPresented: $showSetting) {
                TextField("Name", text: $serverIP)
            }
            .navigationTitle("KlimaWallet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSetting.toggle()
                    }, label: {
                        Image(systemName: "gear")
                    })
                }
            }
        }
    }
    
    func postAndPreviewPass() {
        isLoading = true
        
        // Replace this URL with your own
        guard let url = URL(string: "http://\(serverIP)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "name": formData.fullName,
            "cardNr": formData.cardNr,
            "dateFrom": formData.dateFrom,
            "dateTo": formData.dateTo,
            "dateBirth": formData.dateBirth,
            "aztecCode": formData.aztecCode,
            "type": formData.type,
            "image" : formData.imgBase64
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                defer { self.isLoading = false }
                guard let data = data, error == nil else {
                    print("Request failed: \(error?.localizedDescription ?? "No data")")
                    return
                }
                
                print("Received data from server: \(data)")
                
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = dir.appendingPathComponent("file.pkpass")
                    
                    do {
                        try data.write(to: fileURL, options: .atomic)
                        print("pkpass file saved")
                        
                        let passData = try Data(contentsOf: fileURL)
                        print("Read \(passData.count) bytes from saved file")
                        
                        do {
                            let pass = try PKPass(data: passData)
                            print("Created PKPass object")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.pass = pass
                                self.showPassView = true
                            }
                        } catch {
                            print("Error creating PKPass object: \(error)")
                            DispatchQueue.main.async {
                                self.errorText = "Error creating PKPass object: \(error)"
                                self.showError = true
                            }
                        }
                    } catch {
                        print("An error occurred: \(error)")
                        DispatchQueue.main.async {
                            self.errorText = "An error occurred: \(error)"
                            self.showError = true
                        }
                    }
                    
                }
            }
            
            task.resume()
            
        } catch {
            print("Failed to serialize JSON: \(error)")
            DispatchQueue.main.async {
                self.errorText = "Failed to serialize JSON: \(error)"
                self.showError = true
            }
        }
    }
}

#Preview {
    ContentView()
}

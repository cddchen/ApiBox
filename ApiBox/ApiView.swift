//
//  ApiView.swift
//  ApiBox
//
//  Created by 陈东 on 30/7/2023.
//

import SwiftUI

struct ApiView: View {
//    @State var jsonData: Data
    @State var storedRequest: StoredRequest
    @State var isRequestStored: Bool
    @State private var responseData = ""
    @State private var responseStatusCode = 404
    @State private var responseHeaders: [(String, String)] = [] // Array of (key, value) pairs
    @State private var isShowingResponseSheet = false // Boolean to control the sheet presentation
    @State private var newRequestName = ""
    @State private var isEditingTitle = false
    @State private var alertAboutName = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("REQUEST LINE")
                    .font(.title2)
                    .padding(10)
                    .hSpacing(.leading)
                VStack {
                    Divider()
                    ItemView(name: "Method", value: storedRequest.request.method)
                    ItemView(name: "URL", value: storedRequest.request.url)
                }
                .background(.white)
                Text("REQUEST Header")
                    .font(.title3)
                    .padding(10)
                    .hSpacing(.leading)
                VStack {
                    Divider()
                    ForEach(storedRequest.request.headers, id: \.self) { header in
                        ItemView(name: header.name, value: header.value)
                    }
                }
                .background(.white)
            }
            .vSpacing(.top)
            .background(Color.gray.opacity(0.1))
            .onAppear() {
                newRequestName = storedRequest.name
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            if (newRequestName == "请输入api名称") {
                                alertAboutName = true
                            } else {
                                saveRequestWithName()
                            }
                        }) {
                            Image(systemName: "square.and.arrow.down")
                        }
                        .disabled(isRequestStored)
                        Spacer()
                        Button(action: {
                            sendHttp(request: storedRequest.request)
                        }) {
                            Image(systemName: "play")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if (isEditingTitle) {
                        TextField(newRequestName, text: $newRequestName)
                            .multilineTextAlignment(.center)
                            .font(.headline)
                            .foregroundColor(.blue)
                    } else {
                        Button(action: {
                            if !isRequestStored {
                                isEditingTitle = true
                            }
                        }) {
                            Text(newRequestName)
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingResponseSheet) {
                ResponseSheet(responseStatusCode: $responseStatusCode, responseText: $responseData, responseHeaders: $responseHeaders)
            }
            .alert(isPresented: $alertAboutName) {
                Alert(
                    title: Text("Enter Request Name"),
                    message: Text("Please provide a name for the request."),
                    primaryButton: .cancel(Text("Cancel")),
                    secondaryButton: .default(Text("OK"), action: {
                        alertAboutName = false
                    })
                )
            }
        }
    }
    private func saveRequestWithName() {
        let appGroupIdentifier = "group.cn.cdd.harFile" // Replace with your App Group identifier
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        
        let storedRequest = StoredRequest(request: storedRequest.request, name: newRequestName)
        
        var storedRequests: [StoredRequest]
        if let storedRequestsData = sharedDefaults?.data(forKey: "storedRequests") {
            storedRequests = (try? JSONDecoder().decode([StoredRequest].self, from: storedRequestsData)) ?? []
        } else {
            storedRequests = []
        }
        
        storedRequests.append(storedRequest)
        
        if let encodedRequests = try? JSONEncoder().encode(storedRequests) {
            sharedDefaults?.set(encodedRequests, forKey: "storedRequests")
            sharedDefaults?.synchronize()
            isRequestStored = true
            isEditingTitle = false
        }
    }
    private func sendHttp(request: Request) {
        guard let url = URL(string: request.url) else {
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = request.method
        for header in request.headers {
            req.setValue(header.value, forHTTPHeaderField: header.name)
        }
        for cookie in request.cookies {
            let cookieValue = "\(cookie.name)=\(cookie.value)"
            if let currentCookie = req.value(forHTTPHeaderField: "Cookie") {
                req.setValue("\(currentCookie); \(cookieValue)", forHTTPHeaderField: "Cookie")
            } else {
                req.setValue(cookieValue, forHTTPHeaderField: "Cookie")
            }
        }
        if let postData = request.postData {
            req.httpBody = postData.text.data(using: .utf8)
            req.setValue(postData.mimeType, forHTTPHeaderField: "Content-Type")
        }
        URLSession.shared.dataTask(with: req) { data, response, error in
            if let data = data {
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    let headers = httpResponse.allHeaderFields
                    let headerArray = headers.map { (key: $0.key as? String ?? "", value: $0.value as? String ?? "") }

                    if let responseString = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            print("Status Code: \(statusCode)\nHeaders: \(headers)\nResponse: \(responseString)")
                            responseStatusCode = statusCode
                            responseData = responseString
                            responseHeaders = headerArray
                            isShowingResponseSheet = true
                        }
                    }
                }
            }
        }.resume()
    }
}


@ViewBuilder
func ItemView(name: String, value: String) -> some View {
    HStack {
        Text(name)
            .font(.title3)
        
        HStack() {
            Spacer()
            Text(value)
                .lineLimit(3)
                .font(.body)
                .foregroundColor(.black.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
    .padding(8)
    Divider()
}

struct ResponseSheet: View {
    @Binding var responseStatusCode: Int
    @Binding var responseText: String
    @Binding var responseHeaders: [(String, String)]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("RESPONSE LINE")
                    .font(.title2)
                    .padding(10)
                    .hSpacing(.leading)
                VStack {
                    Divider()
                    ItemView(name: "Status Code", value: "\(responseStatusCode)")
                }
                .background(.white)
                Text("RESPONSE Header")
                    .font(.title3)
                    .padding(10)
                    .hSpacing(.leading)
                VStack {
                    Divider()
                    ForEach(responseHeaders, id: \.0) { header in
                        ItemView(name: header.0, value: header.1)
                    }
                }
                .background(.white)
                Text("RESPONSE Data")
                    .font(.title3)
                    .padding(10)
                    .hSpacing(.leading)
                VStack {
                    Divider()
                    Text(responseText)
                        .lineLimit(5)
                }
                .background(.white)
            }
            .vSpacing(.top)
            .background(Color.gray.opacity(0.1))
        }
    }
}

struct NameInputDialog: View {
    @Binding var isInputVisible: Bool
    @Binding var newRequestName: String
    let onSave: () -> Void

    var body: some View {
        VStack {
            Text("Record Request Name")
                .font(.headline)
                .padding()
            
            TextField("Request Name", text: $newRequestName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Cancel") {
                    isInputVisible = false
                }
                .padding()
                
                Spacer()
                
                Button("Save") {
                    if !newRequestName.isEmpty {
                        onSave()
                        isInputVisible = false
                    }
                }
                .padding()
            }
        }
        .frame(width: 300)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}


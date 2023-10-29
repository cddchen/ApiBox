//
//  ContentView.swift
//  ApiBox
//
//  Created by cdd on 8/8/23.
//

//
//  ContentView.swift
//  ApiBox
//
//  Created by 陈东 on 7/27/23.
//

import SwiftUI

extension UserDefaults {
    static let storedRequestsKey = "storedRequests"
}

struct MainView: View {
    @State private var showApiView = false
    @State private var req: Request?
    @AppStorage(UserDefaults.storedRequestsKey, store: UserDefaults(suiteName: "group.cn.cdd.harFile"))
    var storedRequestsData: Data = Data()
    
    var storedRequests: [StoredRequest] {
        get {
            if let decodedRequests = try? JSONDecoder().decode([StoredRequest].self, from: storedRequestsData) {
                return decodedRequests
            }
            return []
        }
    }

    var body: some View {
        NavigationView {
            LazyVStack() {
                ForEach(storedRequests) { stored_req in
                    NavigationLink(destination: ApiView(storedRequest: stored_req, isRequestStored: true)) {
                        ListViewItem(storedRequest: stored_req)
                    }
                }
            }
            .vSpacing(.top)
            .navigationTitle("Main")
            .navigationBarItems(trailing: Button("Refresh", action: refreshData))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: refreshData)
        .onOpenURL() { url in
          guard url.scheme == "cn.cddchen.ApiBox" else {
            return
          }
          
        }
    }
    
    func refreshData() {
        // 3. Update the decoding method
        if let sharedDefaults = UserDefaults(suiteName: "group.cn.cdd.harFile"),
           let newStoredRequestsData = sharedDefaults.data(forKey: UserDefaults.storedRequestsKey) {
            storedRequestsData = newStoredRequestsData
        }
    }
}

//#Preview {
//  MainView()
//}

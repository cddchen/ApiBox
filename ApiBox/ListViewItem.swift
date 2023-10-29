//
//  ListViewItem.swift
//  ApiBox
//
//  Created by 陈东 on 7/27/23.
//

import SwiftUI

struct ListViewItem: View {
    @State var storedRequest: StoredRequest
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text(storedRequest.request.method)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(5)
                        .background() {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.red)
                        }
                        
                    
                    Text(storedRequest.name)
                        .font(.title3.bold())
                        .foregroundColor(.black)
                }
                .hSpacing(.leading)
                
                Text(storedRequest.request.url)
                    .lineLimit(1)
                    .font(.callout)
                    .accentColor(.black.opacity(0.5))
                    
            }
            
            Divider()
        }
        .padding(5)
        .background() {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white)
        }
    }
}

//#Preview {
//    ListViewItem()
//}

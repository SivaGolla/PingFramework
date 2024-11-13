//
//  HostView.swift
//  NetworkLatencyAnalyzer
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import PingFramework
import SwiftUI

struct HostView: View {
    @State private var image: UIImage? = nil
    var viewModel: HostViewModel
    
    var body: some View {
        HStack {
            
            Image(uiImage: viewModel.host?.image ?? UIImage())
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(viewModel.hostName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(viewModel.averageLatency)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}


#Preview {
    HostView(viewModel: HostViewModel(hostInfo: nil))
}

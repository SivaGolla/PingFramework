//
//  HostListView.swift
//  NetworkLatencyAnalyzer
//
//  Created by Venkata Sivannarayana Golla on 08/11/24.
//

import SwiftUI

struct HostListView: View {
    @StateObject private var viewModel = HostListViewModel()
    
    var body: some View {
        VStack {
            if viewModel.loading {
                ProgressView()
            } else {
                List(viewModel.latencies) { host in
                    HostView(viewModel: HostViewModel(hostInfo: host))
                }
            }
            
            Spacer()
            
            Button {
                viewModel.loadLatencies()
            } label: {
                Text("Start")
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(.blue)
            .cornerRadius(4.0)
            .padding(.horizontal)

        }
        .padding()
        .background(ignoresSafeAreaEdges: .all)
        .background(.gray)
    }
}

#Preview {
    HostListView()
}

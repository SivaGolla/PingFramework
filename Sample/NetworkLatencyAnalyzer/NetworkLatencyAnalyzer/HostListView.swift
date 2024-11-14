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
            } else if viewModel.latencies.isEmpty {
                // Show an empty background view when there are no latencies
                VStack {
                    Spacer()
                    Text("Want to find latencies? \n Lets Start")
                        .font(.title2)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(.gray)
                .cornerRadius(4.0)
                .padding()
            } else {
                List(viewModel.latencies) { host in
                    HostView(viewModel: HostViewModel(hostInfo: host))
                }.background(.green)
            }
            
            Spacer()
            
            Button {
                viewModel.loadLatencies()
//                Task {
//                    do {
//                        try await viewModel.loadAsyncLatencies()
//                    } catch {
//                        print("Error loading latencies: \(error.localizedDescription)")
//                    }
//                }
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

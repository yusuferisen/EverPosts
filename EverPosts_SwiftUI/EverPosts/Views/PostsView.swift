//
//  PostsView.swift
//  EverPosts
//

import SwiftUI

struct PostsView: View {
    @StateObject private var viewModel = PostsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.posts) { post in
                Text(post.title)
            }
            .navigationTitle("Posts")
            .refreshable {
                let startTime = Date()
                await viewModel.fetchPosts(clearCache: true)
                let elapsedTime = Date().timeIntervalSince(startTime)
                let minimumDuration: TimeInterval = 1.0
                if elapsedTime < minimumDuration {
                    try? await Task.sleep(nanoseconds: UInt64((minimumDuration - elapsedTime) * 1_000_000_000))
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchPosts()
                }
            }
            .alert(item: $viewModel.errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }
}

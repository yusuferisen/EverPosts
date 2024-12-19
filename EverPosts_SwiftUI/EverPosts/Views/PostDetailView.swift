//
//  PostDetailView.swift
//  EverPosts
//

import SwiftUI

struct PostDetailView: View {
    @StateObject private var viewModel: PostDetailViewModel

    init(post: Post) {
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                Text("Author: \(viewModel.authorName)")
                    .font(.headline)
                
                Text(viewModel.postDescription)
                    .font(.body)
                
                Text("Number of comments: \(viewModel.comments.count)")
                    .font(.subheadline)

                if !viewModel.comments.isEmpty {
                    List(viewModel.comments) { comment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(comment.name)
                                .font(.headline)
                            Text(comment.body)
                                .font(.body)
                            Text("By: \(comment.email)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .padding()
        .navigationTitle("Post Details")
        .onAppear {
            Task {
                await viewModel.fetchPostDetails()
            }
        }
    }
}

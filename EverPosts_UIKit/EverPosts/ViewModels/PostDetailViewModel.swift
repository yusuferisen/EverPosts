//
//  PostDetailViewModel.swift
//  EverPosts
//

import Foundation

@MainActor
class PostDetailViewModel: ObservableObject {
    @Published var authorName: String = ""
    @Published var postDescription: String = ""
    @Published var comments: [Comment] = []
    @Published var errorMessage: ErrorMessage?

    private let repository: PostRepositoryProtocol
    private let post: Post

    init(post: Post, repository: PostRepositoryProtocol = PostRepository()) {
        self.post = post
        self.repository = repository
    }

    func fetchPostDetails() async {
        do {
            let author = try await repository.fetchUser(for: post.userId)
            self.authorName = author.name

            let comments = try await repository.fetchComments(for: post.id)
            self.comments = comments
        } catch {
            self.errorMessage = ErrorMessage(message: error.localizedDescription)
        }
    }
}

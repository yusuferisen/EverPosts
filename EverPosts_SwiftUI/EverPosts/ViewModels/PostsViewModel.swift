//
//  PostsViewModel.swift
//  EverPosts
//

import Foundation
import Combine

@MainActor
class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var errorMessage: ErrorMessage?
    
    private let repository: PostRepositoryProtocol
    
    init(repository: PostRepositoryProtocol = PostRepository()) {
        self.repository = repository
    }
    
    func fetchPosts(clearCache: Bool = false) async {
        do {
            self.posts = try await repository.fetchPosts(clearCache: clearCache)
        } catch {
            self.errorMessage = ErrorMessage(message: error.localizedDescription)
        }
    }
}

//
//  PostRepository.swift
//  EverPosts
//

import Foundation

protocol PostRepositoryProtocol {
    func fetchPosts(clearCache: Bool) async throws -> [Post]
    func fetchUser(for userId: Int) async throws -> User
    func fetchComments(for postId: Int) async throws -> [Comment]
}

class PostRepository: PostRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let localStorage: LocalStorageProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService(),
         localStorage: LocalStorageProtocol = UserDefaultsStorage()) {
        self.networkService = networkService
        self.localStorage = localStorage
    }
    
    func fetchPosts(clearCache: Bool = false) async throws -> [Post] {
        if clearCache {
            localStorage.clear(key: "posts")
            localStorage.clear(key: "users")
            localStorage.clear(key: "comments")
        }
        
        if let cachedPosts: [Post] = localStorage.retrieve(key: "posts") {
            return cachedPosts
        }
        
        let posts: [Post] = try await networkService.fetch([Post].self, from: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
        localStorage.save(posts, key: "posts")
        return posts
    }
    
    func fetchUser(for userId: Int) async throws -> User {
        if let cachedUsers: [User] = localStorage.retrieve(key: "users"),
           let user = cachedUsers.first(where: { $0.id == userId }) {
            return user
        }
        let user: User = try await networkService.fetch(User.self, from: URL(string: "https://jsonplaceholder.typicode.com/users/\(userId)")!)
        localStorage.append(user, key: "users")
        return user
    }
    
    func fetchComments(for postId: Int) async throws -> [Comment] {
        if let cachedComments: [Comment] = localStorage.retrieve(key: "comments") {
            let comments = cachedComments.filter({ $0.postId == postId })
            return comments
        }
        let comments: [Comment] = try await networkService.fetch([Comment].self, from: URL(string: "https://jsonplaceholder.typicode.com/comments?postId=\(postId)")!)
        localStorage.append(contentsOf: comments, key: "comments")
        return comments
    }
}

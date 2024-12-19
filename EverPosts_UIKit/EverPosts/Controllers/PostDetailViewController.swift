//
//  PostDetailViewController.swift
//  EverPosts
//

import UIKit
import Combine

class PostDetailViewController: UIViewController {
    private var viewModel: PostDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var authorLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var commentCountLabel: UILabel!
    private var tableView: UITableView!
    
    init(post: Post) {
        self.viewModel = PostDetailViewModel(post: post)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindViewModel()
        fetchPostDetails()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Post Details"
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        authorLabel = UILabel()
        authorLabel.font = .systemFont(ofSize: 18, weight: .bold)
        authorLabel.numberOfLines = 0
        
        descriptionLabel = UILabel()
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        
        commentCountLabel = UILabel()
        commentCountLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
        
        stackView.addArrangedSubview(authorLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(commentCountLabel)
        
        view.addSubview(stackView)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$authorName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authorName in
                self?.authorLabel.text = authorName
            }
            .store(in: &cancellables)

        viewModel.$postDescription
            .receive(on: DispatchQueue.main)
            .sink { [weak self] description in
                self?.descriptionLabel.text = description
            }
            .store(in: &cancellables)
        
        viewModel.$comments
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.commentCountLabel.text = "Number of comments: \(self?.viewModel.comments.count ?? 0)"
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let message = errorMessage?.message else { return }
                self?.showErrorAlert(message: message)
            }
            .store(in: &cancellables)
    }
    
    private func fetchPostDetails() {
        Task {
            await viewModel.fetchPostDetails()
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PostDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let comment = viewModel.comments[indexPath.row]
        cell.textLabel?.text = "\(comment.name)\n\(comment.body)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}

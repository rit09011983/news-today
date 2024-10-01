//
//  DashboardViewController.swift
//  NewsToday
//
//  Created by iRitesh on 28/09/24.
//

import UIKit
import CoreData
import SDWebImage

class DashboardViewController: UIViewController {
    
    var result: News?
    var totNumOfRows: Int!
    var category = Categories(rawValue: 0)?.getCategotyName() ?? "All"
    var desc = ""
    var content = ""
    var img = ""
    var url = ""
    var previousTime: Date!
    var index = 0
    var catIndex = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var newsViewModel:NewsViewModel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var articlesArray = [ArticleEntity]()
    var bookMarkArray = [BookMark]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.newsViewModel = NewsViewModel()
        self.allBindData()
        articlesArray = CoreDataManager.shared.getAllRecords(category: self.category, fetchOffset: 0)
        
        // MARK: - When CoreData is Empty
        if articlesArray.count == 0 {
            
            print("articlesArray.count: ", articlesArray.count)
            activityIndicator.startAnimating()
            self.newsViewModel.isFreash = false
            self.newsViewModel.getNewsFromCateory(category: self.category)
        }
        else {
            tableView.reloadData()
        }
        
        // MARK: - Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        
        // MARK: - Auto refresh
        let timeBool = UserDefaults.standard.bool(forKey: Identifier.timeKeyBool)
        
        if timeBool == false {
            UserDefaults.standard.set(Date(), forKey: Identifier.timeKey)
            UserDefaults.standard.set(true, forKey: Identifier.timeKeyBool)
        }
        
        autoRefreshAfterCertainTime()
    }
    
    @objc func refresh() {
        CoreDataManager.shared.deleteWithCategory(category: self.category, context: context)
        self.newsViewModel.isFreash = true
        self.newsViewModel.getNewsFromCateory(category: self.category)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.HomeToDetail {
            let destinationVC = segue.destination as! DetailNewsViewController
            destinationVC.desc = desc
            destinationVC.content = content
            destinationVC.img = img
            destinationVC.url = url
        }
    }
}

// MARK: - Collection View
extension DashboardViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        if let catName = Categories(rawValue: index) {
            category =   catName.getCategotyName()
        } else {
            category = "All"
        }
        
        print(indexPath)
        print(category)
        
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.categoryLabel.textColor = .black
            
        }
        articlesArray = CoreDataManager.shared.getAllRecords(category: category, fetchOffset: 0)
        
        if articlesArray.count == 0 {
            activityIndicator.startAnimating()
            self.newsViewModel.getNewsFromCateory(category: self.category)
        }
        
        tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCollectionViewCell {
            cell.categoryLabel.textColor = .systemGray
        }
    }
}

extension DashboardViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Categories.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.collectionViewCell, for: indexPath) as! CustomCollectionViewCell
        if let catName = Categories(rawValue: indexPath.row) {
            cell.categoryLabel.text =   catName.getCategotyName()
        } else {
            cell.categoryLabel.text = "All"
        }
        
        if index == indexPath.row {
            cell.categoryLabel.textColor = .black
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition:.top)
        } else {
            cell.categoryLabel.textColor = .gray
        }
        
        
        return cell
    }
}

// MARK: - Table View
extension DashboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if let desc1 = articlesArray[indexPath.row].desc, let content1 = articlesArray[indexPath.row].content, let img1 = articlesArray[indexPath.row].urlToImage, let url1 = articlesArray[indexPath.row].url {
            desc = desc1
            content = content1
            img = img1
            url = url1
        }
        performSegue(withIdentifier: Identifier.HomeToDetail, sender: nil)
    }
}

extension DashboardViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.tableViewCell, for: indexPath) as! CustomTableViewCell
        
        if !articlesArray.isEmpty {
            guard articlesArray.count > indexPath.row else {
                return cell
            }
            let image = articlesArray[indexPath.row].urlToImage
            if let image = image {
                cell.imgView.sd_setImage(with: URL(string: image))
                //print("SD Image: ", image)
            }
            else {
                cell.imgView.image = UIImage(systemName: "trash")
            }
            
            cell.titleLabel.text = articlesArray[indexPath.row].title
            cell.authorLabel.text = articlesArray[indexPath.row].author
            
            var hour = 0.0
            
            if let publishedAt = articlesArray[indexPath.row].publishedAt {
                hour = TimeConvertion.shared.timeSubtract(dateTimeString: publishedAt)
            }
            
            if Int(hour) == 0 {
                cell.dateLabel.text = "Recent News"
            }
            else if Int(hour) > 0 && Int(hour) < 24 {
                cell.dateLabel.text = "\(String(Int(hour))) hour(s) ago"
            }
            
            else {
                cell.dateLabel.text = "\(String(Int(hour))) day(s) ago"
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var paginationArray = [ArticleEntity]()
        if indexPath.row == articlesArray.count - 1 {
            paginationArray = CoreDataManager.shared.getAllRecords(category: category, fetchOffset: articlesArray.count)
            articlesArray.append(contentsOf: paginationArray)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        category = articlesArray[indexPath.row].category!
        
        let bookMarkAction = UIContextualAction(style: .destructive, title: nil) {[weak self] _,_,completed in
            guard let self = self else {return}
            if CoreDataManager.shared.matchUrl(url: self.articlesArray[indexPath.row].url ?? "", context: self.context) {
                self.alertFunc(title: "Book Mark Status", message: "Already BookMarked")
            }
            else {
                self.addRecordBookMark(title: (self.articlesArray[indexPath.row].title) ?? "", author: (self.articlesArray[indexPath.row].author) ?? "", publishedAt: (self.articlesArray[indexPath.row].publishedAt) ?? "", url: (self.articlesArray[indexPath.row].url) ?? "", urlToImage: self.articlesArray[indexPath.row].urlToImage ?? "", desc: (self.articlesArray[indexPath.row].desc) ?? "", content: (self.articlesArray[indexPath.row].content) ?? "", category: self.category)
                
                tableView.reloadData()
                self.alertFunc(title: "Book Mark Status", message: "Successfully BookMarked")
            }
            
        }
        bookMarkAction.image = UIImage(systemName: "bookmark")
        bookMarkAction.backgroundColor = UIColor.blue
        
        let swipAction = UISwipeActionsConfiguration(actions: [bookMarkAction])
        return swipAction
    }
}

// MARK: - Functions
extension DashboardViewController {
    func getAllRecords(category: String) {
        articlesArray = CoreDataManager.shared.getAllRecords(category: category, fetchOffset: 0)
        tableView.reloadData()
    }
    
    func addRecord(title: String, author: String, publishedAt: String, url: String, urlToImage: String, desc: String, content: String, category: String) {
        articlesArray = CoreDataManager.shared.addRecord(title: title, author: author, publishedAt: publishedAt, url: url, urlToImage: urlToImage, desc: desc, content: content, category: category, context: context)
    }
    
    func addRecordBookMark(title: String, author: String, publishedAt: String, url: String, urlToImage: String, desc: String, content: String, category: String) {
        bookMarkArray = CoreDataManager.shared.addRecordBookMark(title: title, author: author, publishedAt: publishedAt, url: url, urlToImage: urlToImage, desc: desc, content: content, category: category, context: context)
    }
    
    func autoRefreshAfterCertainTime() {
        
        let time = UserDefaults.standard.object(forKey: "timeKey") as? Date
        print(time ?? "")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: time!)
        
        let calculatedTime = TimeConvertion.shared.timeSubtractForCertainTime(dateTimeString: dateString) // calculatedTime is in minute
        
        if Int(calculatedTime) >= 30 {
            
            print("Delete all data from entity")
            CoreDataManager.shared.deleteAll(context: context)
            
            print("autoRefreshAfterCertainTime")
            activityIndicator.startAnimating()
            self.newsViewModel.isFreash = false
            self.newsViewModel.getNewsFromCateory(category: self.category)
            print("Print calculatedTime: ", Int(calculatedTime))
            UserDefaults.standard.set(Date(), forKey: Identifier.timeKey) // Updating the time agaain
        }
    }
    
    func alertFunc(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension DashboardViewController {
    
    func allBindData() {
        self.newsViewModel.success.bind {
            guard let _news = $0 else { return }
            print(_news)
            DispatchQueue.main.async {
                self.result = _news
                for j in 0..<(self.result!.articles.count) {
                    var catName = "All"
                    if let _catName = Categories(rawValue: self.index) {
                        catName =   _catName.getCategotyName()
                    }
                    
                    self.addRecord(title: (self.result?.articles[j].title) ?? " ", author: (self.result?.articles[j].author) ?? " ", publishedAt: (self.result?.articles[j].publishedAt) ?? " ", url: (self.result?.articles[j].url) ?? " ", urlToImage: self.result?.articles[j].urlToImage ?? " ", desc: (self.result?.articles[j].description) ?? " ", content: (self.result?.articles[j].content) ?? "", category: catName)
                }
                print("Category: ",self.category)
                print("self.result?.articles", self.result?.articles)
                if  self.newsViewModel.isFreash {
                    self.tableView.refreshControl?.endRefreshing()
                }
                self.articlesArray = CoreDataManager.shared.getAllRecords(category:self.category, fetchOffset: 0)
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
        
        self.newsViewModel.errorMessage.bind {
            guard let errorMessage = $0 else { return }
            print(errorMessage)
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                print(errorMessage)
                var message = ""
                if let _msg = errorMessage["errorMessage"] as? String {
                    message = _msg
                }
                self.alertFunc(title: "Error", message: message)
            }
        }
    }
}

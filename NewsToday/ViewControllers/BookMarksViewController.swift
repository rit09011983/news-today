//
//  BookMarksViewController.swift
//  NewsToday
//
//  Created by iRitesh on 28/09/24.
//

import UIKit

class BookMarksViewController: UIViewController {
  
    var articlesArray = [ArticleEntity]()
    var bookMarkArray = [BookMark]()
    var category = Categories(rawValue: 0)!.getCategotyName()
    var desc = ""
    var content = ""
    var img = ""
    var url = ""
    var index = 0
        
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        
        bookMarkArray = CoreDataManager.shared.getAllRecordsBookMark(category: category)
        tableView.reloadData()

        tableView.delegate = self
        tableView.dataSource = self

        collectionView.delegate = self
        collectionView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        bookMarkArray = CoreDataManager.shared.getAllRecordsBookMark(category: category)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.BookMarksToDetail {
            let destinationVC = segue.destination as! DetailNewsViewController
            destinationVC.desc = desc
            destinationVC.content = content
            destinationVC.img = img
            destinationVC.url = url
        }
    }
}

extension BookMarksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        if let desc1 = bookMarkArray[indexPath.row].desc, let content1 = bookMarkArray[indexPath.row].content, let img1 = bookMarkArray[indexPath.row].urlToImage, let url1 = bookMarkArray[indexPath.row].url {
            desc = desc1
            content = content1
            img = img1
            url = url1
        }
        performSegue(withIdentifier: Identifier.BookMarksToDetail, sender: nil)
    }
}

extension BookMarksViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookMarkArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.BookmarksTableViewCell, for: indexPath) as! CustomBookmarksTableViewCell
        
        let image = bookMarkArray[indexPath.row].urlToImage
        if let image = image {
            cell.imgView.sd_setImage(with: URL(string: image))
            print("SD Image: ", image)
        }
        else {
            cell.imgView.image = UIImage(systemName: "trash")
        }

        cell.titleLabel.text = bookMarkArray[indexPath.row].title
        cell.authorLabel.text = bookMarkArray[indexPath.row].author
        
        var hour = 0.0
        
        // publishedAt
        if let publishedAt = bookMarkArray[indexPath.row].publishedAt {
            hour = TimeConvertion.shared.timeSubtract(dateTimeString: publishedAt)
        }
        
        if Int(hour) == 0 {
            cell.dateLabel.text = "Recent News"
        }
        else {
            cell.dateLabel.text = "\(String(Int(hour))) hour(s) ago"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {[weak self] _,_,completed in
            guard let self = self else {return}
            
            self.bookMarkArray = CoreDataManager.shared.deleteRecords(index: indexPath.row, bookMarkArray: &self.bookMarkArray, context: self.context)
            self.tableView.reloadData()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        let swipAction = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipAction
    }
}

extension BookMarksViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        index = indexPath.row
        print(index)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomBookmarksCollectionViewCell {
            cell.categoryLabel.textColor = .black
        }
        if let catName = Categories(rawValue: indexPath.row) {
            category =   catName.getCategotyName()
        } else {
            category  = Categories(rawValue: 0)!.getCategotyName()
        }
        print(category)

        bookMarkArray = CoreDataManager.shared.getAllRecordsBookMark(category: category)
        tableView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print(indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomBookmarksCollectionViewCell {
            cell.categoryLabel.textColor = .systemGray
        }
    }
}

extension BookMarksViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Categories.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.BookmarksCollectionViewCell, for: indexPath) as! CustomBookmarksCollectionViewCell
        if let catName = Categories(rawValue: indexPath.row) {
            cell.categoryLabel.text =   catName.getCategotyName()
        } else {
            cell.categoryLabel.text = Categories(rawValue: 0)?.getCategotyName()
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

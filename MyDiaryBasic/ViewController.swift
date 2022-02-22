//
//  ViewController.swift
//  MyDiaryBasic
//
//  Created by leejungchul on 2021/12/15.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary]() {
        didSet {
            self.saveDiaryList()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("viewDidLoad")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )
        self.configureCollectionView()
        self.loadDiaryList()
        // Do any additional setup after loading the view.
    }
    
    @objc func editDiaryNotification(_ notification: Notification) {
        print("???")
        guard let diary = notification.object as? Diary else { return }
        guard let index = self.diaryList.firstIndex(where: {
            $0.uuidString == diary.uuidString
        }) else { return }
        
        print("aaa")
        
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
        
    }
    
    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let index = self.diaryList.firstIndex(where: {
            $0.uuidString == uuidString
        }) else { return }
    
        self.diaryList[index].isStar = isStar
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.diaryList.firstIndex(where: {
            $0.uuidString == uuidString
        }) else { return }
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])

    }
    
    private func configureCollectionView() {
        // UICollectionViewFlowLayout을 할당해주어야함
        // UICollectionViewLayout을 할당해주면 collectionView가 그려지지 않음
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        // 컬랙션뷰 사이의 간격
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
    }
    
    private func saveDiaryList() {
        debugPrint("save")
        let date = self.diaryList.map {
            [
                "title" : $0.title,
                "contents" : $0.content,
                "date" : $0.date,
                "isStar" : $0.isStar,
                "uuidString" : $0.uuidString
            ]
        }
    
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(date, forKey: "diaryList")
    }
    
    private func loadDiaryList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        print("data : \(data)")
        self.diaryList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let content = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            return Diary(title: title, content: content, date: date, isStar: isStar, uuidString: uuidString)
        }
        self.diaryList = self.diaryList.sorted(by: {
            // 날짜 최신순으로 정렬
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    private func dateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row]
        debugPrint(diary)
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}

extension ViewController: WriteDiaryViewDelegate {
    func didSelectRegister(diary: Diary) {
        self.diaryList.append(diary)
        self.diaryList = self.diaryList.sorted(by: {
            // 날짜 최신순으로 정렬
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        vc.diary = diary
        vc.indexPath = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

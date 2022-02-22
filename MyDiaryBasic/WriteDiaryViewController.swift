//
//  WriteDiaryViewController.swift
//  MyDiaryBasic
//
//  Created by leejungchul on 2021/12/15.
//

import UIKit


enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var dateTextfield: UITextField!
    @IBOutlet weak var confirmBtn: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    
    weak var delegate: WriteDiaryViewDelegate?
    
    var diaryEditorMode: DiaryEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditMode()
        self.confirmBtn.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    private func configureEditMode() {
        switch self.diaryEditorMode {
        case let .edit(_, diary):
            self.titleTextfield.text = diary.title
            self.contentTextView.text = diary.content
            self.dateTextfield.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmBtn.title = "수정"
        default:
            break
        }
    }
    
    private func dateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter.string(from: date)
    }
    
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentTextView.layer.borderColor = borderColor.cgColor
        self.contentTextView.layer.borderWidth = 0.6
        self.contentTextView.layer.cornerRadius = 5.0
    }
    // datePicker 설정
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko-KR")
        // 키보드 대신 데이트 피커 등장
        self.dateTextfield.inputView = self.datePicker
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 년 MM 월 dd 일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko-KR")
        self.diaryDate = datePicker.date
        self.dateTextfield.text = formatter.string(from: datePicker.date)
        // 날짜가 변경될 때 마다 editingChanged 가 실행되도록
        self.dateTextfield.sendActions(for: .editingChanged)
    }
    
    @objc private func titleTextfieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func dateTextfieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configureInputField() {
        self.contentTextView.delegate = self
        // .editingChanged : 값이 변경될때 마다 호출
        titleTextfield.addTarget(self, action: #selector(titleTextfieldDidChange(_:)), for: .editingChanged)
        dateTextfield.addTarget(self, action: #selector(dateTextfieldDidChange(_:)), for: .editingChanged)
    }
    
    private func validateInputField() {
        self.confirmBtn.isEnabled = !(self.titleTextfield.text?.isEmpty ?? true) && !(self.dateTextfield.text?.isEmpty ?? true) && !(self.contentTextView.text.isEmpty)
    }
    
    @IBAction func tapConfirmBtn(_ sender: Any) {
        guard let title = self.titleTextfield.text else { return }
        guard let content = self.contentTextView.text else { return }
        guard let date = self.diaryDate else { return }
        
        switch self.diaryEditorMode {
        case .new:
            let diary = Diary(title: title, content: content, date: date, isStar: false, uuidString: UUID().uuidString)
            self.delegate?.didSelectRegister(diary: diary)
        case let .edit(_, diary):
            let diary = Diary(title: title, content: content, date: date, isStar: diary.isStar, uuidString: diary.uuidString)
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: nil
            )
        }
        self.navigationController?.popViewController(animated: true)
    }

}

extension WriteDiaryViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}

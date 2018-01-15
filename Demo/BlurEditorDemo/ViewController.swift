//
//  ViewController.swift
//  BlurEditorDemo
//
//  Created by SaitoYuta on 2017/12/19.
//  Copyright © 2017年 bangohan. All rights reserved.
//

import UIKit
//import BlurEditor

class ViewController: UIViewController {

    @IBOutlet weak var blurEditorView: BlurEditorView! {
        didSet {
//            blurEditorView.blurRadius = 50.0
            blurEditorView.lineColor = .black
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectPhoto() {
        let picker = UIImagePickerController.init()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func savePhoto() {
        guard let image = blurEditorView.exportCanvas() else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    @IBAction func setEraserMode() {
        blurEditorView.mode = .erase
    }
    @IBAction func setPenMode() {
        blurEditorView.mode = .pen
    }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer { picker.dismiss(animated: true) }
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        blurEditorView.originalImage = image
    }
}

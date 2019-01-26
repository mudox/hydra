import UIKit

import MudoxKit

class PlaceholderView: View {

  var imageView: UIImageView!

  var label: UILabel!

  var retryButton: UIButton!

  override func setupView() {

  }

  func setupImageView() {
    imageView = UIImageView().then {
      $0.contentMode = .scaleAspectFit

      $0.layer.masksToBounds = false
    }

    addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.centerX.equalToSuperview()
    }
  }

  func setupLabel() {
    label = UILabel().then {
      $0.text = ""
      $0.textColor = .emptyDark
      $0.font = .text
      $0.textAlignment = .center

      // Auto shrink
      $0.numberOfLines = 1
      $0.lineBreakMode = .byTruncatingTail

      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.7
      $0.allowsDefaultTighteningForTruncation = true
    }
    
    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(20)
    }
  }

  func setupRetryButton() {
    retryButton = UIButton(type: .custom).then {
      $0.setTitle("Retry", for: .normal)
      
      $0.layer.cornerRadius = 3
      $0.layer.borderColor = UIColor.emptyDark.cgColor
    }
    
    addSubview(retryButton)
    retryButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(label.snp.bottom).offset(20)
      make.size.equalTo(CGSize(width: 60, height: 17))
    }
  }

}

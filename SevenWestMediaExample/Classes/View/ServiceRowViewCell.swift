//
//  ServiceRowViewCell.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/2/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import UIKit

class ServiceRowViewCell: UITableViewCell {

    var titleLabel = UILabel()
    var descriptionLabel = UILabel()
    var rowImageView = UIImageView()
    
    var disposal : Disposal = []
    
    deinit {
        disposal.removeAll()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override func prepareForReuse() {
        disposal.removeAll()
        
        self.titleLabel.text = nil
        self.descriptionLabel.text = nil
        self.rowImageView.image = nil
        
        super.prepareForReuse()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func commonInit(){
        let fakeView = UIView()
        self.contentView.addSubview(fakeView)
        fakeView.backgroundColor = nil
        fakeView.pinToSuperviewEdges()
        fakeView.heightAnchor.constraint(greaterThanOrEqualToConstant: 85.0)
        
        
        // Added Subview
        self.contentView.addSubview(self.rowImageView)
        self.contentView.addSubview(self.descriptionLabel)
        self.contentView.addSubview(self.titleLabel)
        
        self.rowImageView.contentMode = .scaleAspectFit
        self.rowImageView.backgroundColor = .gray
        
        self.titleLabel.numberOfLines = 3
        self.titleLabel.textColor = .black
        self.titleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .regular)
        
        
        // set autolayout for rowImageView
        self.rowImageView.pinToSuperviewEdge(.leading, inset: 16, priority:.required).isActive = true
        self.rowImageView.set(.height, to: 50)
        
        self.rowImageView.topAnchor.constraint(greaterThanOrEqualTo: self.contentView.topAnchor, constant: 16).isActive = true
        let imageBottomCont = self.rowImageView.bottomAnchor.constraint(greaterThanOrEqualTo: self.contentView.bottomAnchor, constant: 16)
        imageBottomCont.priority = UILayoutPriority(rawValue: 850)
        imageBottomCont.isActive = true
        
        self.rowImageView.alignToSuperviewAxis(.vertical)
        self.rowImageView.widthAnchor.constraint(equalTo: self.rowImageView.heightAnchor, multiplier: 1/1, constant: 0).isActive = true
        
        
        // create autolayout for titleLabel with content compression resistance required
        self.titleLabel.pinToSuperviewEdge(.top, inset: 16, priority: .required).isActive = true
        self.titleLabel.pinToSuperviewEdge(.trailing, inset: 16, priority: .required).isActive = true
        self.titleLabel.setContentCompressionResistance(for: .vertical, to: .required)
        
        // pin titleLabel leading edge to trailing of rowImageView with 8 inset
        self.titleLabel.pinEdge(.leading, to:.trailing, of: self.rowImageView, inset: 16, priority: .required).isActive = true
        // pin titleLabel bottom edge to top of descriptionLabel with 8 inset
        self.titleLabel.pinEdge(.bottom, to: .top, of: self.descriptionLabel, inset: 16, priority: .required).isActive = true
        
        // create autolayout for descriptionLabel with content compression resistance required
        self.descriptionLabel.pinToSuperviewEdge(.trailing, inset: 16, priority: .required).isActive = true
        self.descriptionLabel.pinToSuperviewEdge(.bottom, inset: 16, priority: .required).isActive = true
        self.descriptionLabel.pinEdge(.leading, to: .leading, of: self.titleLabel, inset: 0, priority: .required).isActive = true
        self.descriptionLabel.setContentCompressionResistance(for: .vertical, to: .required)
        self.descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        
        if #available(iOS 11.0, *) {
            self.rowImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        } else {
            // Fallback on earlier versions
        }

        
    }
    
    func config(viewModal : ServerRowViewModel) {
        
        bind(viewModal: viewModal)
      
        guard viewModal.image?.value == nil else {
            return
        }
        
        viewModal.loadImage { (image, error) in
            
            guard let error = error else {
                return
            }
            
            debugPrint("error on fetch Image \(error)")
        }
        
    }
    
    private func bind(viewModal : ServerRowViewModel) {
        
        viewModal.title?.observe {[weak self] (newValue, _) in
            self?.titleLabel.text = newValue
        }
        
        viewModal.image?.observe({[weak self] (image, _) in
            self?.rowImageView.image = image
        }).add(to: &disposal)
        
        viewModal.description?.observe {[weak self] (newValue, _) in
            self?.descriptionLabel.text = newValue
        }
    }

}

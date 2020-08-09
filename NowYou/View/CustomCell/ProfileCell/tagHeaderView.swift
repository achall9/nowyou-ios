//
//  tagHeaderView.swift
//  NowYou
//
//  Created by 111 on 6/1/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

class TagHeader: UICollectionViewCell  {

override init(frame: CGRect)    {
    super.init(frame: frame)
    setupHeaderViews()
}

let dateLabel: UILabel = {
    let title = UILabel()
    title.textColor = .gray
    title.font = UIFont(name: "Montserrat", size: 0)
    title.translatesAutoresizingMaskIntoConstraints = false
    return title
}()

func setupHeaderViews()   {
    addSubview(dateLabel)

    dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
    dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
    dateLabel.widthAnchor.constraint(equalToConstant: 0).isActive = true
    dateLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
}


required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}
}

//
//  StringExtension.swift
//  NowYou
//
//  Created by 111 on 6/12/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
extension String {

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

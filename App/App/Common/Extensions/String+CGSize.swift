//
//  String+CGSize.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/03/06.
//

import UIKit

extension String {
    func height(withGivenWidth width: CGFloat, font: UIFont) -> CGFloat {
        let boundingRect = self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                             options: .usesLineFragmentOrigin,
                                             attributes: [.font: font],
                                             context: nil)
        return boundingRect.height
    }

    func width(withGivenHeight height: CGFloat, font: UIFont) -> CGFloat {
        let boundingRect = self.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height),
                                             options: .usesLineFragmentOrigin,
                                             attributes: [.font: font],
                                             context: nil)
        return boundingRect.width
    }
}

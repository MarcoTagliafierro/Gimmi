//
//  TitleBar.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 23/12/21.
//

import SwiftUI


struct TitleBar: View {
    
    var title       : String
    var subTitle    : String?
    var closeAction : (() -> ())?
    
    var body: some View {
        
        HStack(alignment: .center) {
            
            // Close Button
            if let closeAction = closeAction {
                
                Button {
                    closeAction()
                } label: {
                    Image(systemName: "multiply")
                        .renderingMode(.original)
                        .foregroundColor(Color.textColor)
                }.frame(width: 45, height: 45, alignment: .center)
                
            }
            
            // Title
            VStack(alignment: .leading) {
                PageTitle(text: title)
                if let subTitle = subTitle {
                    ElementTitle(text: subTitle)
                }
            }
            
        }
            .frame(maxWidth: .infinity, minHeight: .titleBarHeight, alignment: .topLeading)
            .padding(.leading, .stdBorder)
            .padding(.top, .stdBorder)
            .padding(.trailing, .stdBorder)
            .background(.clear)
        
    }
    
}

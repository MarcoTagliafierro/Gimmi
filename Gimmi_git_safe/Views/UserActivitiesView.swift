//
//  UserActivitiesView.swift
//  Gimmi
//
//  Created by Gianmarco Vuolo on 04/12/21.
//

import SwiftUI


struct UserActivitiesView: View {
    
    // Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserActivitiesViewModel
    
    
    // Init
    init(viewModel: UserActivitiesViewModel) {
        
        self.viewModel = viewModel
        
        // Modify UITableView appearence in order to have a custom background in the list
        UITableView.appearance().backgroundColor = .clear
        
    }
    
    
    // Body
    var body: some View {
    
        ZStack(alignment: .leading) {
            
            // Background Color
            Color.backgroundColor
                .ignoresSafeArea()
            
            
            // Activities List
            List(viewModel.activitiesRepresentables) { activity in
                
                Section(
                    content: {
                        ForEach(activity.products) { item in
                            ActivityCell(name: item.name, count: item.count)
                        }
                    },
                    header: {
                        ElementTitle(text: activity.date)
                            .padding(.bottom, 5.0)
                    },
                    footer: {
                        
                        VStack(spacing: 10.0) {
                            
                            // Points
                            HStack(alignment: .center) {
                                ElementText(text: "Points")
                                Spacer()
                                ElementText(text: activity.totalPoints, fontWeight: .medium)
                            }
                                .padding(.top, .stdBorder)
                                .padding(.leading, .stdBorder)
                                .padding(.trailing, .stdBorder)
                                .padding(.bottom, .smallBorder)
                            
                            // Total
                            HStack(alignment: .center) {
                                ElementSubtitle(text: "Total")
                                Spacer()
                                ElementText(text: "€ ")
                                ElementText(text: activity.totalCost, fontWeight: .bold)
                            }
                            .padding(.leading, .stdBorder)
                            .padding(.trailing, .stdBorder)
                            .padding(.bottom, .stdBorder)
                            
                        }
                            .frame(maxWidth: .infinity, minHeight: 0)
                            .background(Color.secondaryDarkColor)
                            .cornerRadius(.radius)
                    }
                )
                    .textCase(nil) // Avoid upper-case in the header
                
            }
                .padding(.top, .titleBarHeight + .bigBorder)
                .frame(maxHeight: .infinity)
            
            // Title
            VStack() {
                TitleBar(title: "Activities") {
                    dismiss()
                }
                
                Spacer()
            }
            
        }
        
    }
    
}

// Activity Cell
private struct ActivityCell: View {
    
    var name    : String
    var count   : String
    
    var body: some View {
        
        HStack(alignment: .center, spacing: .stdBorder) {
        
            ElementText(text: count)
            ElementSubtitle(text: name, fontWeight: .regular)
            Spacer()
            
        }
            .frame(maxWidth: .infinity)
        
    }
    
}

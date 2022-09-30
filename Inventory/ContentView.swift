//
//  ContentView.swift
//  InventoryWatch
//
//  Created by Ramik Sadana on 9/29/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model: Model
    
    @AppStorage("lastUpdateDate") private var lastUpdateDate: String = ""
    @AppStorage("preferredProductType") private var preferredProductType: String = "MacBookPro"
    @AppStorage("useLargeText") private var useLargeText: Bool = false
    @AppStorage("shouldIncludeNearbyStores") private var shouldIncludeNearbyStores: Bool = true
    
    @State var showSettingsView: Bool = false
    
    private var onlyShowingPreferredResults: Bool {
        return UserDefaults.standard.bool(forKey: "showResultsOnlyForPreferredModels")
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    
                    VStack {
                        let font = Font.title
                        if let product = ProductType(rawValue: preferredProductType) {
                            Text("\(product.presentableName)")
                                .font(font)
                                .fontWeight(.semibold)
                                .minimumScaleFactor(0.5)
                        } else {
                            Text("Available Models")
                                .font(font)
                                .fontWeight(.semibold)
                                .minimumScaleFactor(0.5)
                        }
                        if lastUpdateDate.isEmpty == false {
                            Text("Updated: \(lastUpdateDate)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button(
                        action: {
                            showSettingsView = true
                        },
                        label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    )
                    .buttonStyle(BorderlessButtonStyle())
                    .padding()
                }
                .padding(.bottom)
                
                if model.isLoading {
                    ProgressView()
                        .tint(.white)
                        .progressViewStyle(CircularProgressViewStyle())
//                        .scaleEffect(2, anchor: .center)
                        .padding(.top, 8)
                }
                
                VStack(alignment: .leading) {
                    if let error = model.errorState {
                        Text(error.errorMessage)
                            .font(.subheadline)
                            .italic()
                            .padding(.bottom)
                    }
                    
                    let storeFont = Font.title3.weight(.semibold)
                    let cityFont = Font.headline.weight(.regular)
                    let productFont = Font.body.weight(.regular)
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(model.availableParts, id: \.0.storeNumber) { data in
                            Text(data.0.storeName)
                                .font(storeFont)
                            Text(data.0.locationDescription)
                                .font(cityFont)
                                .padding(.bottom, 4)
                                .foregroundColor(.white.opacity(0.6))
                            
                            let sortedProductNames = data.1.map { model.productName(forSKU: $0.partNumber) }
                                .sortedNumerically()
                            
                            ForEach(sortedProductNames, id: \.self) { productName in
                                HStack(alignment: .top,
                                       spacing: 0) {
                                    Text("•")
                                Text(productName)
                                    .font(productFont)
                                    .padding(.leading)
                                }
                            }
                            
                            Divider()
                                .overlay(.gray)
                                .padding(.vertical, 20)
                        }
                    }
                    
                    if model.availableParts.isEmpty && model.isLoading == false {
                        Text("No models available in-store.")
                            .foregroundColor(.white)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 4)
                
                HStack {
                    let font = useLargeText ? Font.title3 : Font.caption
                    
                    if onlyShowingPreferredResults {
                        Text("Only showing results for preferred models.")
                            .font(font)
                            .padding(.leading, 8)
                    }
                }
                .padding(.bottom, 8)
                
            }
            .foregroundColor(.white)
        }
        .onAppear {
            model.fetchLatestInventory()
            UIRefreshControl.appearance().tintColor = UIColor.white
        }
        .refreshable {
            model.fetchLatestInventory()
        }
        .background(.black)
        .fullScreenCover(isPresented: $showSettingsView) {
            SettingsView(isPresenting: $showSettingsView)
                .environmentObject(model)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model.testData)
    }
}

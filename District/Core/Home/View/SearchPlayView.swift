import SwiftUI

struct SearchPlayView: View {
    @State private var searchText = ""
    let tabs = ["Dining", "Movies", "Events", "Stores", "Activities", "Play"]
    @State private var selectedTab = "Play"
    
    let columns = [
        GridItem(.flexible(), spacing: 16, alignment: .top),
        GridItem(.flexible(), spacing: 16, alignment: .top)
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(tabs, id: \.self) { tab in
                            VStack(spacing: 8) {
                                Text(tab)
                                    .font(.system(size: 15, weight: selectedTab == tab ? .semibold : .medium))
                                    .foregroundColor(selectedTab == tab ? Theme.primaryText : Theme.secondaryText)
                                
                                Rectangle()
                                    .fill(selectedTab == tab ? Theme.offerPurple : Color.clear)
                                    .frame(height: 2)
                            }
                            .onTapGesture {
                                withAnimation {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .overlay(
                    Divider().background(Theme.surface),
                    alignment: .bottom
                )
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Trending in New Delhi")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.secondaryText)
                            .padding(.horizontal, 16)
                            .padding(.top, 24)
                        
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(SearchPlayCategory.mocks) { category in
                                HStack(alignment: .top, spacing: 12) {
                                    // Placeholder Image
                                    Rectangle()
                                        .fill(LinearGradient(colors: [Color.green.opacity(0.4), Color.blue.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(category.title)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(Theme.primaryText)
                                            .lineLimit(2)
                                        
                                        Text(category.subtitle)
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(Theme.secondaryText)
                                    }
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search for 'Turf Football'")
    }
}

struct SearchPlayView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPlayView()
    }
}

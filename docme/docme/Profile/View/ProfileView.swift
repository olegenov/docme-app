import Foundation
import SwiftUI


struct ProfileView<ViewModel: ProfileViewModel>: View {
    @StateObject var viewModel: ViewModel
    
    @ObservedObject private var themeController = DS.shared
    
    var body: some View {
        MainContent {
            tabbar
            
            title
            
            userInfo

            settings
        }
    }
    
    private var tabbar: some View {
        ProfileTabbarView {
            
        }.padding(.horizontal, DS.Spacing.m8)
    }
    
    private var title: some View {
        TitleView(text: Captions.profile)
            .padding(.horizontal, DS.Spacing.m8)
    }
    
    private var userInfo: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m4) {
            TextSectionView(text: viewModel.profile.name)
            TextSectionView(text: viewModel.profile.username)
        }
        .frame(width: 270)
        .padding(.horizontal, DS.Spacing.m8)
    }
    
    private var settings: some View {
        ItemsListView {
            LargeListItemView(
                title: Captions.offlineMode,
                trailingView: .toggle(
                    value: $viewModel.offlineMode
                )
            )
            
            SeparatorView()
            
            LargeListItemView(
                title: Captions.theme,
                trailingView: .empty
            ) {
                settingsThemeBottomView
            }
        }.padding(.horizontal, DS.Spacing.m8)
    }
    
    private var settingsThemeBottomView: some View {
        HStack(spacing: DS.Spacing.m4) {
            FabView(
                content: .text(Captions.themeLight),
                isSelected: themeController.mode == .light,
                longPaddings: true
            ) {
                themeController.mode = .light
            }
            
            FabView(
                content: .text(Captions.themeDark),
                isSelected: themeController.mode == .dark,
                longPaddings: true
            ) {
                themeController.mode = .dark
            }
            
            FabView(
                content: .text(Captions.themeSystem),
                isSelected: themeController.mode == .system,
                longPaddings: true
            ) {
                themeController.mode = .system
            }
        }
    }
}

#Preview {
    ProfileView(viewModel: ProfileViewModelImpl(provider: ProfileProviderImpl()))
}

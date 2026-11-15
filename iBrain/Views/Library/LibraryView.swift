import SwiftUI

struct LibraryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Space.l) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("My Library")
                        .font(Theme.Fonts.display)
                        .foregroundStyle(Theme.textPrimary)
                        .tracking(-0.8)
                    Text("Your saved anatomy and topics")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, Theme.Space.xs)

                VStack(spacing: Theme.Space.m) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(Theme.accentSoft))

                    Text("Nothing saved yet")
                        .font(Theme.Fonts.headline)
                        .foregroundStyle(Theme.textPrimary)

                    Text("Soon you'll be able to save brain regions and neuroscience topics here, so you can return to them whenever you want.")
                        .font(Theme.Fonts.body)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .frame(maxWidth: 300)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Space.xl)
                .padding(.horizontal, Theme.Space.l)
                .cardSurface()
            }
            .padding(.horizontal, Theme.Space.m)
            .padding(.bottom, Theme.Space.xl)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

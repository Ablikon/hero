//
//  HistoryView.swift
//  hero
//
//  Created by Абылайхан Бегимкулов on 12.12.2025.
//

import SwiftUI

struct HistoryView: View {
    let heroes: [Superhero]
    let favorites: Set<Int>
    let onSelectHero: (Superhero) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.35, blue: 0.75),
                        Color(red: 0.25, green: 0.15, blue: 0.55)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(heroes) { hero in
                            HeroHistoryCard(
                                hero: hero,
                                isFavorite: favorites.contains(hero.id)
                            )
                            .onTapGesture {
                                onSelectHero(hero)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Recently Viewed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct HeroHistoryCard: View {
    let hero: Superhero
    let isFavorite: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: hero.images.sm)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty, .failure:
                    Color.white.opacity(0.2)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white.opacity(0.3))
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(hero.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Text(hero.biography.publisher ?? "Unknown")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(alignmentColor(hero.biography.alignment))
                        .frame(width: 8, height: 8)
                    Text(hero.biography.alignment.capitalized)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
        )
    }
    
    private func alignmentColor(_ alignment: String) -> Color {
        switch alignment.lowercased() {
        case "good": return .green
        case "bad": return .red
        default: return .gray
        }
    }
}

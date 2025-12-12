//
//  SuperheroDetailView.swift
//  hero
//
//  Created by Абылайхан Бегимкулов on 12.12.2025.
//

import SwiftUI

struct SuperheroDetailView: View {
    let superhero: Superhero
    var isFavorite: Bool = false
    var onFavoriteToggle: (() -> Void)?
    
    @State private var imageLoaded = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Image card with favorite button
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: superhero.images.lg)) { phase in
                    switch phase {
                    case .empty:
                        shimmerPlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 360)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.4), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                            .scaleEffect(imageLoaded ? 1.0 : 0.9)
                            .opacity(imageLoaded ? 1.0 : 0)
                            .onAppear {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    imageLoaded = true
                                }
                            }
                    case .failure:
                        failurePlaceholder
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 300, height: 360)
                
                // Favorite button overlay
                if let toggle = onFavoriteToggle {
                    Button(action: toggle) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(isFavorite ? .red : .white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .black.opacity(0.2), radius: 4)
                            )
                    }
                    .padding(14)
                    .scaleEffect(imageLoaded ? 1.0 : 0.5)
                    .opacity(imageLoaded ? 1.0 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2), value: imageLoaded)
                }
            }
            .padding(.top, 15)
            
            // Alignment badge
            AlignmentBadge(alignment: superhero.biography.alignment)
                .scaleEffect(imageLoaded ? 1.0 : 0.8)
                .opacity(imageLoaded ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: imageLoaded)
            
            VStack(spacing: 12) {
                // Name section
                VStack(spacing: 5) {
                    Text(superhero.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if !superhero.biography.fullName.isEmpty && 
                       superhero.biography.fullName != "-" && 
                       superhero.biography.fullName.lowercased() != superhero.name.lowercased() {
                        Text(superhero.biography.fullName)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.bottom, 4)
                
                // Info cards
                InfoCard(title: "Profile", icon: "person.text.rectangle.fill") {
                    InfoRow(title: "Publisher", value: superhero.biography.publisher ?? "Unknown", icon: "building.2.fill")
                    InfoRow(title: "Gender", value: superhero.appearance.gender, icon: "person.fill")
                    if let race = superhero.appearance.race, race != "-" {
                        InfoRow(title: "Race", value: race, icon: "sparkles")
                    }
                    InfoRow(title: "Height", value: superhero.appearance.height.last ?? "Unknown", icon: "arrow.up.and.down")
                    InfoRow(title: "Weight", value: superhero.appearance.weight.last ?? "Unknown", icon: "scalemass.fill")
                    
                    HStack(spacing: 12) {
                        ColorBadge(title: "Eyes", color: superhero.appearance.eyeColor)
                        ColorBadge(title: "Hair", color: superhero.appearance.hairColor)
                    }
                }
                
                // Power stats
                InfoCard(title: "Power Stats", icon: "bolt.fill") {
                    StatBar(title: "Intelligence", value: superhero.powerstats.intelligence, icon: "brain.head.profile")
                    StatBar(title: "Strength", value: superhero.powerstats.strength, icon: "figure.strengthtraining.traditional")
                    StatBar(title: "Speed", value: superhero.powerstats.speed, icon: "hare.fill")
                    StatBar(title: "Durability", value: superhero.powerstats.durability, icon: "shield.fill")
                    StatBar(title: "Power", value: superhero.powerstats.power, icon: "flame.fill")
                    StatBar(title: "Combat", value: superhero.powerstats.combat, icon: "figure.boxing")
                    
                    let totalPower = superhero.powerstats.intelligence + 
                                   superhero.powerstats.strength +
                                   superhero.powerstats.speed +
                                   superhero.powerstats.durability +
                                   superhero.powerstats.power +
                                   superhero.powerstats.combat
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Total Score")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(totalPower)/600")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
                
                // Career info
                InfoCard(title: "Career", icon: "briefcase.fill") {
                    InfoRow(title: "Occupation", value: superhero.work.occupation, icon: "person.badge.key.fill")
                    InfoRow(title: "Base", value: superhero.work.base, icon: "house.fill")
                    InfoRow(title: "First Seen", value: superhero.biography.firstAppearance, icon: "calendar")
                    
                    if !superhero.biography.placeOfBirth.isEmpty && superhero.biography.placeOfBirth != "-" {
                        InfoRow(title: "Birthplace", value: superhero.biography.placeOfBirth, icon: "mappin.circle.fill")
                    }
                }
                
                // Affiliations
                if !superhero.connections.groupAffiliation.isEmpty && superhero.connections.groupAffiliation != "-" {
                    InfoCard(title: "Team Affiliations", icon: "person.3.fill") {
                        Text(superhero.connections.groupAffiliation)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.top, 10)
    }
    
    private var shimmerPlaceholder: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.25), Color.white.opacity(0.15)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 300, height: 360)
    }
    
    private var failurePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .frame(width: 300, height: 360)
            
            VStack(spacing: 12) {
                Image(systemName: "photo")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.4))
                Text("Image unavailable")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.yellow)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 9) {
                content
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 18)
    }
}

struct ColorBadge: View {
    let title: String
    let color: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Text(color)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.15))
        .cornerRadius(8)
    }
}

// Section header component
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.yellow)
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

// Alignment badge
struct AlignmentBadge: View {
    let alignment: String
    
    var badgeColor: Color {
        switch alignment.lowercased() {
        case "good":
            return .green
        case "bad":
            return .red
        default:
            return .gray
        }
    }
    
    var body: some View {
        Text(alignment.capitalized)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(badgeColor)
                    .shadow(color: badgeColor.opacity(0.5), radius: 8, x: 0, y: 4)
            )
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    var icon: String = ""
    
    var body: some View {
        HStack(spacing: 12) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 24)
            }
            
            Text(title + ":")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatBar: View {
    let title: String
    let value: Int
    var icon: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(value)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getColorForValue(value).opacity(0.3))
                    .cornerRadius(6)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [getColorForValue(value), getColorForValue(value).opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geometry.size.width * CGFloat(value) / 100, 20), height: 10)
                        .shadow(color: getColorForValue(value).opacity(0.5), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 10)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func getColorForValue(_ value: Int) -> Color {
        switch value {
        case 0..<25:
            return .red
        case 25..<50:
            return .orange
        case 50..<75:
            return .yellow
        default:
            return .green
        }
    }
}

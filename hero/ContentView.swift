//
//  ContentView.swift
//  hero
//
//  Created by Абылайхан Бегимкулов on 12.12.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var superhero: Superhero?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var animateContent = false
    @State private var viewedHeroes: [Superhero] = []
    @State private var showHistory = false
    @State private var favoriteHeroes: Set<Int> = []
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Compact header
                HStack {
                    if !viewedHeroes.isEmpty {
                        Button(action: { showHistory.toggle() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("\(viewedHeroes.count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Text("Superhero")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    
                    Spacer()
                    
                    if !viewedHeroes.isEmpty {
                        if !favoriteHeroes.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                Text("\(favoriteHeroes.count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                        } else {
                            Color.clear
                                .frame(width: 60)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .scaleEffect(animateContent ? 1.0 : 0.9)
                .opacity(animateContent ? 1.0 : 0)
                
                if isLoading {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 4)
                                .opacity(0.3)
                                .foregroundColor(.white)
                            
                            Circle()
                                .trim(from: 0.0, to: 0.7)
                                .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                                .foregroundColor(.white)
                                .rotationEffect(Angle(degrees: 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
                        }
                        .frame(width: 50, height: 50)
                        
                        Text("Searching for hero...")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    
                    Spacer()
                } else if let hero = superhero {
                    GeometryReader { geometry in
                        ScrollView(showsIndicators: false) {
                            SuperheroDetailView(
                                superhero: hero,
                                isFavorite: favoriteHeroes.contains(hero.id),
                                onFavoriteToggle: { toggleFavorite(hero) }
                            )
                            .padding(.bottom, 100)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                    }
                } else {
                    Spacer()
                    
                    VStack(spacing: 25) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [.white.opacity(0.3), .clear]),
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 70
                                    )
                                )
                                .frame(width: 140, height: 140)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .symbolEffect(.pulse, options: .repeating, value: animateContent)
                        }
                        
                        VStack(spacing: 10) {
                            Text("Ready to Meet Heroes?")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Discover amazing superheroes from across the universe!")
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    .scaleEffect(animateContent ? 1.0 : 0.85)
                    .opacity(animateContent ? 1.0 : 0)
                    
                    Spacer()
                }
            }
            
            // Floating button at bottom
            VStack {
                Spacer()
                
                Button(action: { fetchRandomSuperhero() }) {
                    HStack(spacing: 12) {
                        Image(systemName: "shuffle.circle.fill")
                            .font(.title3)
                        Text(superhero == nil ? "Discover Hero" : "Next Hero")
                            .fontWeight(.bold)
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(isLoading ? 0.96 : 1.0)
                }
                .disabled(isLoading)
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(
                heroes: viewedHeroes.reversed(),
                favorites: favoriteHeroes,
                onSelectHero: { hero in
                    showHistory = false
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        superhero = hero
                    }
                }
            )
        }
        .alert("Oops!", isPresented: $showError) {
            Button("OK", role: .cancel) { }
            Button("Try Again") {
                fetchRandomSuperhero()
            }
        } message: {
            Text(errorMessage ?? "Something went wrong")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateContent = true
            }
        }
    }
    
    private func fetchRandomSuperhero() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isLoading = true
            errorMessage = nil
            superhero = nil
        }
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 300_000_000)
                let hero = try await NetworkManager.shared.getRandomSuperhero()
                
                await MainActor.run {
                    if !viewedHeroes.contains(where: { $0.id == hero.id }) {
                        viewedHeroes.append(hero)
                        if viewedHeroes.count > 20 {
                            viewedHeroes.removeFirst()
                        }
                    }
                    
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        superhero = hero
                        isLoading = false
                    }
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Unable to load superhero"
                    showError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func toggleFavorite(_ hero: Superhero) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if favoriteHeroes.contains(hero.id) {
                favoriteHeroes.remove(hero.id)
            } else {
                favoriteHeroes.insert(hero.id)
            }
        }
    }
}

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.15, green: 0.35, blue: 0.75),
                Color(red: 0.45, green: 0.25, blue: 0.75),
                Color(red: 0.25, green: 0.15, blue: 0.55)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
}

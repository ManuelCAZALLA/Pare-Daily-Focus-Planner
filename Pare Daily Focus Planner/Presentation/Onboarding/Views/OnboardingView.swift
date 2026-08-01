import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        ZStack {
            Color.pareBackground.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                TabView(selection: $viewModel.currentStep) {
                    OnboardingStepView(
                        icon: "sun.max.fill",
                        title: "Organiza tu Día",
                        description: "Planifica tus tareas diarias y mantén el foco en lo que realmente importa con una vista de línea de tiempo.",
                        color: .pareGreen
                    ).tag(0)
                    
                    OnboardingStepView(
                        icon: "moon.stars.fill",
                        title: "Establece Rutinas",
                        description: "Crea y haz seguimiento de tus hábitos diarios, tanto por la mañana como por la noche.",
                        color: .blue
                    ).tag(1)
                    
                    OnboardingStepView(
                        icon: "doc.text.fill",
                        title: "Gestiona Trámites",
                        description: "No olvides tus papeleos importantes, facturas y obligaciones con recordatorios dedicados.",
                        color: .orange
                    ).tag(2)
                    
                    OnboardingStepView(
                        icon: "bell.badge.fill",
                        title: "Mantente al Día",
                        description: "Permite las notificaciones para que podamos recordarte tus tareas y trámites a tiempo.",
                        color: .red
                    ).tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 400)
                
                Spacer()
                
                Button(action: {
                    if viewModel.currentStep == viewModel.totalSteps - 1 {
                        // Last step, ask for notifications and finish
                        viewModel.requestNotificationPermission { _ in
                            hasSeenOnboarding = true
                        }
                    } else {
                        viewModel.nextStep()
                    }
                }) {
                    Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Comenzar" : "Siguiente")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pareGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.pareGreen.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingStepView: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let color: Color
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(color)
                .symbolEffect(.bounce, options: .repeating)
                .frame(width: 160, height: 160)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.pareTextPrimary)
                
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.pareTextSecondary)
                    .padding(.horizontal, 32)
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}

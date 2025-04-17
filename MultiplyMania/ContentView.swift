import SwiftUI

struct ContentView: View {
    @State private var numberQuestion = 5
    @State private var firstValue = 1
    @State private var secondValue = 1

    
    private let questions = [5, 10, 20]

    private var operationArithmeticImage = ["plus", "minus", "multiply", "divide"]
    @State private var operation = "plus"
    
    private let numberRange = 1..<11
    @State private var playerResponse = ""
    
    @State private var countQuestion = 0
    @State private var WinAnswer = 0
    @State private var ErrorAnswer = 0
    
    @State private var showAlert = false
    @State private var AnswerStatus = ""
    @State private var AnswerMessage = ""
    @FocusState private var isInputActive: Bool
    
    @State private var isGameOver = false
    
   
    @State private var showAlertError = false
    @State private var AnswerStatusError = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                GlassGradientBackground()
                
                ScrollView {
                    VStack(spacing: 24) {                        VStack {
                            HeaderView(title: "Настройки игры", icon: "gear")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Количество вопросов:")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                
                                Picker("", selection: $numberQuestion) {
                                    ForEach(questions, id: \.self) { index in
                                        Text("\(index)")
                                            .tag(index)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(.horizontal, 8)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Арифметическиая операция:")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                
                                Picker("", selection: $operation) {
                                    ForEach(operationArithmeticImage, id: \.self) { icon in
                                        Image(systemName: icon)
                                            .imageScale(.medium)
                                            
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(.vertical, 16)
                        .modifier(GlassCardModifier())
                        
                        VStack {
                            HeaderView(title: "Выбор чисел", icon: "number")
                            
                            HStack {
                                NumberPicker(
                                    label: "Первое число",
                                    selection: $firstValue,
                                    range: numberRange,
                                    accentColor: .blue
                                )
                                
                                NumberPicker(
                                    label: "Второе число",
                                    selection: $secondValue,
                                    range: numberRange,
                                    accentColor: .green
                                )
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(.vertical, 16)
                        .modifier(GlassCardModifier())
                        
                        VStack {
                            HeaderView(title: "Вопрос", icon: "questionmark")
                            
                            VStack() {
                                Text("Сколько будет?")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    NumberBadge(value: firstValue, color: .blue)
                                    Image(systemName: operation)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.orange)
                                    
                                    NumberBadge(value: secondValue, color: .green)
                                    
                                    Image(systemName: "equal")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.orange)
                                    TextField("Ответ", text: $playerResponse)
                                        .keyboardType(.numberPad)
                                        .focused($isInputActive)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 100)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 24, weight: .bold))
                                        .onChange(of: playerResponse) { newValue in
                                            var filtered = newValue.filter { $0.isNumber }
                                            
                                            if operation == "minus" {
                                                if newValue.first == "-" {
                                                    filtered = "-" + filtered
                                                }
                                            }
                                            
                                            if filtered != newValue {
                                                playerResponse = filtered
                                            }
                                        }
                                        .onSubmit {
                                            checkAnswer(first: firstValue, second: secondValue, operation: operation)
                                        }
                                }
                            }
                            .padding(.bottom, 10)
 
                        }
                        .modifier(GlassCardModifier())
                        
                        VStack(spacing: 7) {
                            HeaderView(title: "Рельтаты", icon: "chart.bar.fill")
                            HStack {
                                Text("Ответы: \(countQuestion) из \(numberQuestion)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            
                            VStack(spacing: 12) {
                                HStack(spacing: 16) {
                                    HStack {
                                        NumberBadgeResault(value: WinAnswer, color: .green)
                                        Text("Верно")
                                    }
                                    HStack {
                                        NumberBadgeResault(value: ErrorAnswer, color: .red)
                                        Text("Ошибок")
                                        
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .modifier(GlassCardModifier())
                        
                        Button(action: {
                            checkAnswer(first: firstValue, second: secondValue, operation: operation)
                        }) {
                            HStack {
                                Text("Следующий вопрос")
                                Image(systemName: "play.fill")
                            }
                        }
                        .buttonStyle(GradientButtonStyle())
                        .frame(maxWidth: 300)
                        .frame(height: 50)
                    }
                   
                }
            }
            .navigationTitle("Multiply Mania")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Multiply Mania")
                        .font(.headline.bold())
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Важно!"),
                    message: Text(AnswerMessage),
                    primaryButton: .default(Text("OK")),
                    secondaryButton: .cancel(Text("Отмена"))
                )
            }
        }
        .ignoresSafeArea()
    }

    func checkAnswer(first: Int, second: Int, operation: String) {
        var correctAnswer = 0
        switch operation {
        case "plus":
             correctAnswer = first + second
        case "minus":
             correctAnswer = first - second
        case "multiply":
            let (result, overflow) = first.multipliedReportingOverflow(by: second)
            if overflow {
                AnswerMessage = "Слишком большое число!"
                showAlert = true
                return
            }
            correctAnswer = result
        case "divide":
            if secondValue == 0 {
                AnswerMessage = "Деление на ноль невозможно!"
                showAlert = true
                return
            }
            correctAnswer = first / second
        default:
            AnswerMessage = "Error"
            let correctAnswer = 0
        }

            if numberQuestion == 0 {
                AnswerMessage = "Выберите количество вопросов!"
                showAlert = true
                return
            }
            
            if playerResponse.isEmpty {
                AnswerMessage = "Введите ответ!"
                showAlert = true
                return
            }
            
            if String(playerResponse) == String(correctAnswer) {
                WinAnswer += 1
                AnswerMessage = "Правильный ответ"
                countQuestion += 1
               
            } else {
                ErrorAnswer += 1
                showAlert = true
                AnswerMessage  = "Ошибка, правильный ответ: \(correctAnswer)"
                countQuestion += 1
            }
            
            
            playerResponse = ""
            firstValue = Int.random(in: 1..<11)
            secondValue = Int.random(in: 1..<11)
            
            if countQuestion >= numberQuestion {
                AnswerMessage = "Игра окончена! Правильных ответов: \(WinAnswer) из \(numberQuestion)"
                showAlert = true
                countQuestion = 0
                WinAnswer = 0
                ErrorAnswer = 0
                
            }
        }
}


// MARK: - Вспомогательные компоненты

struct HeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
            Image(systemName: icon)
                .imageScale(.medium)
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
    }
}

struct NumberPicker: View {
    let label: String
    @Binding var selection: Int
    let range: Range<Int>
    let accentColor: Color
    
    var body: some View {
        VStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Picker(label, selection: $selection) {
                ForEach(range, id: \.self) { number in
                    Text("\(number)")
                        .tag(number)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)
            .clipped()
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentColor.opacity(0.1))
            )
        }
    }
}

struct NumberBadge: View {
    let value: Int
    let color: Color
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .frame(width: 60, height: 60)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
            )
    }
}

struct NumberBadgeResault: View {
    let value: Int
    let color: Color
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .frame(width: 28, height: 28)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
            )
    }
}

// MARK: - Стили

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundColor(.white)
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: .purple.opacity(0.4), radius: 10, y: 5)
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                Material.ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 4)
    }
}

// MARK: - Фоновые компоненты

struct GlassGradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.95, green: 0.97, blue: 1.00),
                Color(red: 0.85, green: 0.90, blue: 1.00),
                Color(red: 0.78, green: 0.85, blue: 1.00)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Превью

#Preview {
    ContentView()
}

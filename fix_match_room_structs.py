with open('District/Core/Home/View/MatchRoomView.swift', 'r') as f:
    content = f.read()

# Add extension for BookingParticipant
extension_code = """
extension BookingParticipant {
    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\\(parts[0].prefix(1))\\(parts[1].prefix(1))".uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
    
    var color: Color {
        let colors: [Color] = [.blue, .purple, .orange, .pink, .green, .red]
        return colors[abs(uid.hashValue) % colors.count]
    }
    
    var status: PlayerStatus {
        if hasPaid { return .confirmed }
        return .pendingPayment
    }
}
"""

content = content.replace("// MARK: - Match Room View", extension_code + "\n// MARK: - Match Room View")

# Fix teamColumn signature
content = content.replace("players: [MatchPlayer]", "players: [BookingParticipant]")

# Fix messages ForEach
content = content.replace("ForEach(viewModel.messages) { msg in", "ForEach(viewModel.messages, id: \\.id) { msg in")

with open('District/Core/Home/View/MatchRoomView.swift', 'w') as f:
    f.write(content)

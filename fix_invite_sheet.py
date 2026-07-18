import re

with open('District/Core/Home/View/MatchRoomView.swift', 'r') as f:
    text = f.read()

# Replace struct InvitePlayersSheet signature
text = text.replace(
    'let matchType: String\n',
    'let matchType: String\n    let joinCode: String\n'
)

# Replace "SHARE MATCH LINK" UI block
old_ui = """                // Match Link
                VStack(alignment: .leading, spacing: 12) {
                    Text("SHARE MATCH LINK")
                        .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)

                    HStack {
                        Image(systemName: "link").foregroundColor(DS.textSecondary)
                        Text("district.app/match/CLQ7X")
                            .font(.subheadline).foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Button {} label: {
                            Text("Copy")
                                .font(.caption).fontWeight(.bold).foregroundColor(.black)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(Color.white).cornerRadius(10)
                        }
                    }
                    .padding(14)
                    .background(DS.surface).cornerRadius(14)"""

new_ui = """                // Join Code
                VStack(alignment: .leading, spacing: 12) {
                    Text("JOIN CODE")
                        .font(.caption).fontWeight(.bold).foregroundColor(DS.textSecondary)

                    HStack {
                        Image(systemName: "number.square.fill").foregroundColor(DS.textSecondary).font(.title2)
                        Text(joinCode.isEmpty ? "N/A" : joinCode)
                            .font(.title3).fontWeight(.heavy).foregroundColor(.white)
                            .tracking(4)
                        Spacer()
                        Button {
                            UIPasteboard.general.string = joinCode
                        } label: {
                            Text("Copy")
                                .font(.caption).fontWeight(.bold).foregroundColor(.black)
                                .padding(.horizontal, 14).padding(.vertical, 7)
                                .background(Color.white).cornerRadius(10)
                        }
                    }
                    .padding(14)
                    .background(DS.surface).cornerRadius(14)"""

text = text.replace(old_ui, new_ui)

with open('District/Core/Home/View/MatchRoomView.swift', 'w') as f:
    f.write(text)

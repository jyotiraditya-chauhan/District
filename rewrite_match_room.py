import re

with open('District/Core/Home/View/MatchRoomView.swift', 'r') as f:
    text = f.read()

# 1. Remove Tabs state
text = re.sub(r'// Tabs\s*@State private var activeTab = "Room"\s*@State private var showInviteSheet = false\s*@State private var chatText = ""\s*var tabs = \["Room", "Roster", "Chat", "Teams"\]',
              '@State private var showInviteSheet = false', text)

# 2. Update Body
body_pattern = r'// ── Tab Bar ───────────────────────────────────────────────.*?// ── Chat Input \(only on Chat tab\) ─────────────────────────────.*?chatInputBar\s*\}'
body_replacement = '''// ── Room Content ───────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    roomTab
                }'''
text = re.sub(body_pattern, body_replacement, text, flags=re.DOTALL)

# 3. Pass joinCode to InvitePlayersSheet
text = re.sub(
    r'InvitePlayersSheet\(matchType: viewModel\.booking\?\.matchType \?\? "Public"\)',
    'InvitePlayersSheet(matchType: viewModel.booking?.matchType ?? "Public", joinCode: viewModel.booking?.joinCode ?? "N/A")',
    text
)

# 4. Remove all tabs methods from tabBar to ChatMessage
remove_pattern = r'// MARK: Tab Bar.*?// MARK: Room Tab'
text = re.sub(remove_pattern, '// MARK: Room Tab', text, flags=re.DOTALL)

remove_pattern_2 = r'// MARK: Roster Tab.*?// MARK: - Invite Players Sheet'
text = re.sub(remove_pattern_2, '// MARK: - Invite Players Sheet', text, flags=re.DOTALL)

with open('District/Core/Home/View/MatchRoomView.swift', 'w') as f:
    f.write(text)

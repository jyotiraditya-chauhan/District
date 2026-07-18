import re

with open('District/Core/Home/View/MatchRoomView.swift', 'r') as f:
    content = f.read()

# 1. Remove Tabs state
content = re.sub(r'// Tabs\n\s*@State private var activeTab = "Room"\n\s*@State private var showInviteSheet = false\n\s*@State private var chatText = ""\n\s*var tabs = \["Room", "Roster", "Chat", "Teams"\]',
                 '@State private var showInviteSheet = false', content)

# 2. Update Body
body_old = """                // ── Tab Bar ───────────────────────────────────────────────
                tabBar

                // ── Tab Content ───────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    switch activeTab {
                    case "Room":   roomTab
                    case "Roster": rosterTab
                    case "Chat":   chatTab
                    case "Teams":  teamsTab
                    default:       EmptyView()
                    }
                }
            }

            // ── Chat Input (only on Chat tab) ─────────────────────────────
            if activeTab == "Chat" {
                chatInputBar
            }"""

body_new = """                // ── Room Content ───────────────────────────────────────────
                ScrollView(showsIndicators: false) {
                    roomTab
                }
            }"""

content = content.replace(body_old, body_new)

# 3. Pass joinCode to InvitePlayersSheet
content = content.replace(
    'InvitePlayersSheet(matchType: viewModel.booking?.matchType ?? "Public")',
    'InvitePlayersSheet(matchType: viewModel.booking?.matchType ?? "Public", joinCode: viewModel.booking?.joinCode ?? "N/A")'
)

# 4. Remove all the unused tabs components (from `private var tabBar` down to `teamsTab`)
# It's safer to use regex to cut out sections from `private var tabBar` to `private var roomTab`
# Wait, roomTab comes AFTER tabBar? Let's check where roomTab is.

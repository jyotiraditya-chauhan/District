import re

with open('District/Core/Home/View/MatchRoomView.swift', 'r') as f:
    content = f.read()

# Replace properties
props_start = content.find("struct MatchRoomView: View {") + len("struct MatchRoomView: View {\n")
props_end = content.find("    var tabs = [\"Room\", \"Roster\", \"Chat\", \"Teams\"]")

new_props = """    @Environment(\\.presentationMode) var presentationMode
    @Environment(AuthViewModel.self) private var authViewModel

    let bookingId: String
    @State private var viewModel: MatchRoomViewModel

    init(bookingId: String) {
        self.bookingId = bookingId
        self._viewModel = State(initialValue: MatchRoomViewModel(bookingId: bookingId))
    }

    // Tabs
    @State private var activeTab = "Room"
    @State private var showInviteSheet = false
    @State private var chatText = ""
    
"""

content = content[:props_start] + new_props + content[props_end:]

# Add onAppear/onDisappear to ZStack
zstack_end = content.find("        .navigationTitle(\"Match Room\")")
on_appear_code = """        .onAppear { viewModel.startListening() }
        .onDisappear { viewModel.stopListening() }
"""
content = content[:zstack_end] + on_appear_code + content[zstack_end:]

# Replace venue.name
content = content.replace("venue.name", "viewModel.booking?.venueName ?? \"\"")

# Replace date and time
content = content.replace("Text(\"\\(date)  ·  \\(time)  ·  \\(matchType)\")", "Text(\"\\(viewModel.booking?.slotDateLabel ?? \"\")  ·  \\(viewModel.booking?.slotTimeLabel ?? \"\")  ·  \\(viewModel.booking?.matchType ?? \"\")\")")
content = content.replace("value: \"\\(date)  ·  \\(time)\"", "value: \"\\(viewModel.booking?.slotDateLabel ?? \"\")  ·  \\(viewModel.booking?.slotTimeLabel ?? \"\")\"")

# Replace matchType
content = content.replace("matchType", "viewModel.booking?.matchType ?? \"Public\"")
content = content.replace("viewModel.booking?.matchType ?? \"Public\": String", "String")

# Replace totalPlayers
content = content.replace("totalPlayers", "viewModel.booking?.totalSpots ?? 0")

# Replace perPlayerCost
content = content.replace("perPlayerCost", "viewModel.booking?.perPlayerCost ?? 0")

# Replace totalCost
content = content.replace("totalCost", "viewModel.booking?.totalCost ?? 0")

# Replace skillLevel
content = content.replace("skillLevel", "viewModel.booking?.skillLevel ?? \"\"")

# Replace confirmedCount
content = content.replace("confirmedCount", "viewModel.confirmedCount")

# Replace pendingCount
content = content.replace("pendingCount", "0") # Pending doesn't exist yet

# Replace openSlots
content = content.replace("openSlots", "viewModel.openSlots")

# Replace collectedAmount
content = content.replace("collectedAmount", "viewModel.totalCollected")

# Replace fillPercent
content = content.replace("fillPercent", "viewModel.fillPercent")

# Replace roster logic
content = content.replace("roster.filter", "viewModel.participants.filter")
content = content.replace("roster.count", "viewModel.participants.count")
content = content.replace("ForEach(roster)", "ForEach(viewModel.participants)")
content = content.replace("players: Array(roster", "players: Array(viewModel.participants")

# Replace message logic
content = content.replace("messages.append(ChatMessage(sender: \"You\", text: chatText, isSystem: false))", "let text = chatText\n                    chatText = \"\"\n                    if let u = authViewModel.currentUser { Task { await viewModel.sendMessage(text: text, sender: u) } }")
content = content.replace("messages.append", "//")
content = content.replace("ForEach(messages)", "ForEach(viewModel.messages)")

with open('District/Core/Home/View/MatchRoomView.swift', 'w') as f:
    f.write(content)

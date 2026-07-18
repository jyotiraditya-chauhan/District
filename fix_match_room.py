with open('District/Core/Home/View/MatchRoomView.swift', 'r') as f:
    content = f.read()

content = content.replace("InvitePlayersSheet(viewModel.booking?.matchType ?? \"Public\": viewModel.booking?.matchType ?? \"Public\")", "InvitePlayersSheet(matchType: viewModel.booking?.matchType ?? \"Public\")")
content = content.replace("\\(viewModel.booking?.viewModel.booking?.matchType ?? \"Public\" ?? \"\")", "\\(viewModel.booking?.matchType ?? \"Public\")")
content = content.replace("viewModel.booking?.totalSpots ?? 0 / 2", "(viewModel.booking?.totalSpots ?? 0) / 2")

with open('District/Core/Home/View/MatchRoomView.swift', 'w') as f:
    f.write(content)

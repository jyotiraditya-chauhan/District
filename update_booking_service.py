import re

with open('District/Core/Booking/Service/BookingService.swift', 'r') as f:
    text = f.read()

# Add host check in joinBooking
host_check = """
            guard booking.hostId != user.uid else {
                errorPointer?.pointee = BookingError.lobbyFull as NSError; return nil // or custom host error
            }"""
text = text.replace(
    "guard booking.participantIds.count < booking.totalSpots else {",
    "guard booking.hostId != user.uid else {\n                errorPointer?.pointee = NSError(domain: \"Booking\", code: 403, userInfo: [NSLocalizedDescriptionKey: \"Host cannot join their own lobby.\"])\n                return nil\n            }\n            guard booking.participantIds.count < booking.totalSpots else {"
)

# Remove sendMessage and listenForMessages
text = re.sub(r'// MARK: - Chat.*?// MARK: - Internal', '// MARK: - Internal', text, flags=re.DOTALL)

with open('District/Core/Booking/Service/BookingService.swift', 'w') as f:
    f.write(text)

//
//  BookingService.swift
//  District
//

import FirebaseFirestore

@Observable
@MainActor
final class BookingService {
    private var db: Firestore { Firestore.firestore() }

    // MARK: - Create

    func createBooking(
        venue: BoxVenue,
        sport: String,
        host: UserEntity,
        slotDateLabel: String,
        slotTimeLabel: String,
        startDate: Date,
        durationHours: Double,
        isPublic: Bool,
        title: String?,
        matchType: String,
        skillLevel: String,
        ageGroup: String?,
        rules: String?,
        totalSpots: Int,
        totalCost: Double,
        perPlayerCost: Double,
        paymentWindowHours: Int
    ) async throws -> String {
        let code = try await generateUniqueInviteCode()
        let now = Date()
        let deadline = now.addingTimeInterval(Double(paymentWindowHours) * 3600)

        let ref = db.collection(Constants.bookingsCollectionPath).document()

        let booking = BookingEntity(
            venueId: venue.venueId,
            gameId: venue.gameId,
            venueName: venue.name,
            venueImageName: venue.imageNames.first,
            venueAddress: venue.location,
            sport: sport,
            turfName: venue.name,
            hostId: host.uid,
            hostName: host.name,
            slotDateLabel: slotDateLabel,
            slotTimeLabel: slotTimeLabel,
            startDate: startDate,
            durationHours: durationHours,
            isPublic: isPublic,
            title: title,
            matchType: matchType,
            skillLevel: skillLevel,
            ageGroup: ageGroup,
            rules: rules,
            totalSpots: totalSpots,
            totalCost: totalCost,
            perPlayerCost: perPlayerCost,
            platformFee: Constants.platformFee,
            inviteCode: code,
            participantIds: [host.uid],
            paymentWindowHours: paymentWindowHours,
            paymentDeadline: deadline,
            status: .open,
            createdAt: now
        )

        try ref.setData(from: booking)

        // Write host as first participant
        let hostParticipant = BookingParticipant(
            uid: host.uid,
            name: host.name,
            profileImageURL: host.profileImageURL,
            isHost: true,
            joinedAt: now,
            hasPaid: false,
            amountPaid: 0,
            team: nil
        )
        try ref.collection(Constants.participantsSubcollection)
            .document(host.uid)
            .setData(from: hostParticipant)

        let createdMsg = BookingMessage(
            senderId: "system",
            senderName: "District",
            text: "🎉 Match created! Share the code \(code) to invite players.",
            sentAt: now,
            isSystem: true
        )
        try? ref.collection(Constants.messagesSubcollection).addDocument(from: createdMsg)

        return ref.documentID
    }

    // MARK: - Join

    func joinBooking(id: String, user: UserEntity) async throws {
        let ref = db.collection(Constants.bookingsCollectionPath).document(id)
        let participantRef = ref.collection(Constants.participantsSubcollection).document(user.uid)

        try await db.runTransaction { tx, errorPointer in
            let snap: DocumentSnapshot
            do { snap = try tx.getDocument(ref) }
            catch { errorPointer?.pointee = error as NSError; return nil }

            guard let booking = try? snap.data(as: BookingEntity.self) else {
                errorPointer?.pointee = BookingError.notFound as NSError; return nil
            }
            guard booking.status == .open else {
                errorPointer?.pointee = BookingError.windowClosed as NSError; return nil
            }
            guard Date() < booking.paymentDeadline else {
                errorPointer?.pointee = BookingError.windowClosed as NSError; return nil
            }
            guard booking.hostId != user.uid else {
                errorPointer?.pointee = NSError(domain: "Booking", code: 403, userInfo: [NSLocalizedDescriptionKey: "Host cannot join their own lobby."])
                return nil
            }
            guard booking.participantIds.count < booking.totalSpots else {
                errorPointer?.pointee = BookingError.lobbyFull as NSError; return nil
            }
            guard !booking.participantIds.contains(user.uid) else {
                errorPointer?.pointee = BookingError.alreadyJoined as NSError; return nil
            }

            // Atomic: bump participantIds AND write the participant doc together,
            // so a mid-write interruption can never leave a counted-but-docless participant.
            tx.updateData([
                "participantIds": FieldValue.arrayUnion([user.uid])
            ], forDocument: ref)

            let participant = BookingParticipant(
                uid: user.uid,
                name: user.name,
                profileImageURL: user.profileImageURL,
                isHost: false,
                joinedAt: Date(),
                hasPaid: false,
                amountPaid: 0,
                team: nil
            )
            do {
                try tx.setData(from: participant, forDocument: participantRef)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            return nil
        }

        // Non-critical, best-effort — post after the atomic join commits.
        let joinedMsg = BookingMessage(
            senderId: "system",
            senderName: "District",
            text: "\(user.name) joined the match!",
            sentAt: Date(),
            isSystem: true
        )
        try? ref.collection(Constants.messagesSubcollection).addDocument(from: joinedMsg)
    }

    func joinByCode(_ code: String, user: UserEntity) async throws -> String {
        let snap = try await db.collection(Constants.bookingsCollectionPath)
            .whereField("inviteCode", isEqualTo: code.uppercased())
            .limit(to: 1)
            .getDocuments()

        guard let doc = snap.documents.first else {
            throw BookingError.notFound
        }
        try await joinBooking(id: doc.documentID, user: user)
        return doc.documentID
    }

    // MARK: - Observers (real-time)

    func observeBooking(id: String, onChange: @escaping (BookingEntity?) -> Void) -> ListenerRegistration {
        db.collection(Constants.bookingsCollectionPath).document(id)
            .addSnapshotListener { snap, _ in
                onChange(try? snap?.data(as: BookingEntity.self))
            }
    }

    func observeParticipants(bookingId: String, onChange: @escaping ([BookingParticipant]) -> Void) -> ListenerRegistration {
        db.collection(Constants.bookingsCollectionPath).document(bookingId)
            .collection(Constants.participantsSubcollection)
            .order(by: "joinedAt")
            .addSnapshotListener { snap, _ in
                let list = snap?.documents.compactMap { try? $0.data(as: BookingParticipant.self) } ?? []
                onChange(list)
            }
    }

    func observePublicLobbies(venueId: String, onChange: @escaping ([BookingEntity]) -> Void) -> ListenerRegistration {
        db.collection(Constants.bookingsCollectionPath)
            .whereField("venueId", isEqualTo: venueId)
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: BookingStatus.open.rawValue)
            .addSnapshotListener { snap, _ in
                let list = snap?.documents.compactMap { try? $0.data(as: BookingEntity.self) } ?? []
                onChange(list)
            }
    }

    func observeAllOpenPublicLobbies(onChange: @escaping ([BookingEntity]) -> Void) -> ListenerRegistration {
        db.collection(Constants.bookingsCollectionPath)
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: BookingStatus.open.rawValue)
            .addSnapshotListener { snap, _ in
                let list = snap?.documents.compactMap { try? $0.data(as: BookingEntity.self) } ?? []
                onChange(list)
            }
    }

    func observeMyBookings(uid: String, onChange: @escaping ([BookingEntity]) -> Void) -> ListenerRegistration {
        db.collection(Constants.bookingsCollectionPath)
            .whereField("participantIds", arrayContains: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snap, _ in
                let list = snap?.documents.compactMap { try? $0.data(as: BookingEntity.self) } ?? []
                onChange(list)
            }
    }

    func observeMessages(bookingId: String, onChange: @escaping ([BookingMessage]) -> Void) -> ListenerRegistration {
        db.collection(Constants.bookingsCollectionPath).document(bookingId)
            .collection(Constants.messagesSubcollection)
            .order(by: "sentAt")
            .addSnapshotListener { snap, _ in
                let list = snap?.documents.compactMap { try? $0.data(as: BookingMessage.self) } ?? []
                onChange(list)
            }
    }

    // MARK: - Chat

    func sendMessage(bookingId: String, sender: UserEntity, text: String) async throws {
        let msg = BookingMessage(
            senderId: sender.uid,
            senderName: sender.name,
            text: text,
            sentAt: Date(),
            isSystem: false
        )
        try db.collection(Constants.bookingsCollectionPath).document(bookingId)
            .collection(Constants.messagesSubcollection)
            .addDocument(from: msg)
    }

    // MARK: - Payment

    func markPaid(bookingId: String, uid: String, amount: Double) async throws {
        let ref = db.collection(Constants.bookingsCollectionPath).document(bookingId)
            .collection(Constants.participantsSubcollection).document(uid)

        try await ref.setData(["hasPaid": true, "amountPaid": amount], merge: true)

        // Check if all paid → flip to confirmed (best-effort)
        let allSnap = try await db.collection(Constants.bookingsCollectionPath).document(bookingId)
            .collection(Constants.participantsSubcollection).getDocuments()
        let allPaid = allSnap.documents.allSatisfy { doc in
            (try? doc.data(as: BookingParticipant.self))?.hasPaid == true
        }
        if allPaid {
            try await db.collection(Constants.bookingsCollectionPath).document(bookingId)
                .updateData(["status": BookingStatus.confirmed.rawValue])
        }
    }

    // MARK: - Cancel

    func cancelBooking(id: String) async throws {
        try await db.collection(Constants.bookingsCollectionPath).document(id)
            .updateData(["status": BookingStatus.cancelled.rawValue])
    }

    // MARK: - Payment window expiry

    /// Flips `open` → `awaitingPayment` and logs `paymentEnabledAt`, once, when the
    /// payment window has actually expired. Guarded by a transaction so concurrent
    /// observers (multiple devices in the room) can't double-flip or race a join.
    func expirePaymentWindowIfNeeded(bookingId: String) async {
        let ref = db.collection(Constants.bookingsCollectionPath).document(bookingId)
        _ = try? await db.runTransaction { tx, errorPointer in
            let snap: DocumentSnapshot
            do { snap = try tx.getDocument(ref) }
            catch { errorPointer?.pointee = error as NSError; return nil }

            guard let booking = try? snap.data(as: BookingEntity.self) else { return nil }
            guard booking.status == .open, Date() >= booking.paymentDeadline else { return nil }

            tx.updateData([
                "status": BookingStatus.awaitingPayment.rawValue,
                "paymentEnabledAt": Timestamp(date: Date())
            ], forDocument: ref)
            return nil
        }
    }

    // MARK: - Helpers

    private func generateUniqueInviteCode() async throws -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        for _ in 0..<10 {
            let code = String((0..<Constants.inviteCodeLength).map { _ in chars.randomElement()! })
            let snap = try await db.collection(Constants.bookingsCollectionPath)
                .whereField("inviteCode", isEqualTo: code)
                .limit(to: 1)
                .getDocuments()
            if snap.documents.isEmpty { return code }
        }
        throw BookingError.unknown("Failed to generate unique invite code")
    }
}

enum BookingError: LocalizedError {
    case lobbyFull
    case alreadyJoined
    case notFound
    case windowClosed
    case notAuthenticated
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .lobbyFull: "This match is full."
        case .alreadyJoined: "You've already joined this match."
        case .notFound: "Match not found."
        case .windowClosed: "The payment window has closed."
        case .notAuthenticated: "Please sign in first."
        case .unknown(let msg): msg
        }
    }
}

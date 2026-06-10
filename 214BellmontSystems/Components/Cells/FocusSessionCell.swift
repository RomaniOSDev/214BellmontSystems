import SwiftUI

struct FocusSessionCell: View {
    let session: FocusSessionRecord

    var body: some View {
        HStack(spacing: 14) {
            AppIconCircle(icon: "timer", size: 44, iconColor: Color("AppAccent"))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(session.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Spacer()
                    Text("\(session.durationMinutes) min")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color("AppPrimary").opacity(0.22)))
                }

                Text("Session \(session.sessionNumber)")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))

                if let taskTitle = session.linkedTaskTitle {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.caption2)
                        Text(taskTitle)
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(Color("AppAccent"))
                }

                if let note = session.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
        }
        .padding(14)
        .appDepth(.flat, cornerRadius: 14)
    }
}

struct FocusLinkedTaskCell: View {
    let taskTitle: String
    let focusMinutes: Int?
    let action: () -> Void

    var body: some View {
        AppCardButton(action: action) {
            HStack(spacing: 14) {
                AppIconCircle(icon: "link", size: 44, iconColor: Color("AppPrimary"))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Linked Task")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(taskTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if let focusMinutes, focusMinutes > 0 {
                        Text("\(focusMinutes) min focused")
                            .font(.caption)
                            .foregroundStyle(Color("AppAccent"))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
    }
}


import SwiftUI

struct ScheduleInputView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel

    @State private var title: String = ""
    @State private var selectedCategory: Category = .other
    @State private var showCategoryPicker: Bool = false

    var onSave: ((String, Category) -> Void)?

    // MARK: - Design Constants (from Figma)
    private enum Design {
        static let labelFontSize: CGFloat = 14
        static let inputFontSize: CGFloat = 15
        static let inputHeight: CGFloat = 44
        static let inputCornerRadius: CGFloat = 8
        static let buttonHeight: CGFloat = 47
        static let buttonWidth: CGFloat = 200
        static let buttonCornerRadius: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date Navigation (reusing shared component)
            DateIndicatorView(dateType: .day)
                .frame(maxWidth: .infinity)
                .frame(height: 46)

            // Title Input
            titleInputView

            // Category Picker
            categoryPickerView

            // Save Button
            saveButtonView
        }
        .padding(.horizontal, Design.horizontalPadding)
    }

    // MARK: - Title Input
    private var titleInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("title")
                .font(.system(size: Design.labelFontSize))
                .foregroundColor(AppColors.textSecondary)

            TextField("일정을 입력하세요", text: $title)
                .font(.system(size: Design.inputFontSize))
                .padding(.horizontal, Design.horizontalPadding)
                .frame(height: Design.inputHeight)
                .background(AppColors.surface)
                .cornerRadius(Design.inputCornerRadius)
        }
    }

    // MARK: - Category Picker
    private var categoryPickerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("카테고리 선택")
                .font(.system(size: Design.labelFontSize))
                .foregroundColor(AppColors.textSecondary)

            Menu {
                ForEach(Category.allCases) { category in
                    Button(action: { selectedCategory = category }) {
                        Label(category.rawValue, systemImage: category.icon)
                    }
                }
            } label: {
                HStack {
                    Text(selectedCategory == .other && title.isEmpty ? "선택하기" : selectedCategory.rawValue)
                        .font(.system(size: Design.inputFontSize))
                        .foregroundColor(selectedCategory == .other && title.isEmpty ? AppColors.textPrimary : AppColors.textPrimary)

                    Spacer()

                    Text("▶")
                        .font(.system(size: Design.labelFontSize))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, Design.horizontalPadding)
                .frame(height: Design.inputHeight)
                .background(AppColors.surface)
                .cornerRadius(Design.inputCornerRadius)
            }
        }
    }

    // MARK: - Save Button
    private var saveButtonView: some View {
        HStack {
            Spacer()

            Button(action: saveSchedule) {
                Text("저장")
                    .font(.system(size: Design.inputFontSize, weight: .bold))
                    .foregroundColor(AppColors.accentText)
                    .frame(width: Design.buttonWidth, height: Design.buttonHeight)
                    .background(AppColors.accent)
                    .cornerRadius(Design.buttonCornerRadius)
            }
            .disabled(title.isEmpty)
            .opacity(title.isEmpty ? 0.6 : 1.0)

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Actions
    private func saveSchedule() {
        guard !title.isEmpty else { return }
        onSave?(title, selectedCategory)
        // Reset form
        title = ""
        selectedCategory = .other
    }
}

// MARK: - Preview

#Preview {
    ScheduleInputView { title, category in
        print("Saved: \(title) - \(category.rawValue)")
    }
    .environment(CalendarViewModel())
}

#Preview("With Content") {
    ScheduleInputView()
        .environment(CalendarViewModel())
}

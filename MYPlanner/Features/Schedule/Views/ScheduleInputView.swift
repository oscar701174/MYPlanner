//
//  ScheduleInputView.swift
//  MYPlanner
//
//  Schedule input form - saves to SwiftData
//

import SwiftUI
import SwiftData

struct ScheduleInputView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var title: String = ""
    @State private var selectedCategory: Category = .other
    @State private var showCategoryPicker: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSizes.Spacing.extraLarge) {
            // Date Navigation (reusing shared component)
            DateIndicatorView(dateType: .day)
                .frame(maxWidth: .infinity)
                .frame(height: AppSizes.Height.dateIndicator)

            // Title Input
            titleInputView

            // Category Picker
            categoryPickerView

            // Save Button
            saveButtonView
        }
        .padding(.horizontal, AppSizes.Padding.horizontal)
    }

    // MARK: - Title Input
    private var titleInputView: some View {
        VStack(alignment: .leading, spacing: AppSizes.Spacing.medium) {
            Text("title")
                .font(.system(size: AppSizes.FontSize.body))
                .foregroundColor(AppColors.textSecondary)

            TextField("일정을 입력하세요", text: $title)
                .font(.system(size: AppSizes.FontSize.body))
                .padding(.horizontal, AppSizes.Padding.horizontal)
                .frame(height: AppSizes.Height.input)
                .background(AppColors.surface)
                .cornerRadius(AppSizes.Radius.medium)
        }
    }

    // MARK: - Category Picker
    private var categoryPickerView: some View {
        VStack(alignment: .leading, spacing: AppSizes.Spacing.medium) {
            Text("카테고리 선택")
                .font(.system(size: AppSizes.FontSize.body))
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
                        .font(.system(size: AppSizes.FontSize.body))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Text("▶")
                        .font(.system(size: AppSizes.FontSize.body))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, AppSizes.Padding.horizontal)
                .frame(height: AppSizes.Height.input)
                .background(AppColors.surface)
                .cornerRadius(AppSizes.Radius.medium)
            }
        }
    }

    // MARK: - Save Button
    private var saveButtonView: some View {
        HStack {
            Spacer()

            Button(action: saveSchedule) {
                Text("저장")
                    .font(.system(size: AppSizes.FontSize.body, weight: .bold))
                    .foregroundColor(AppColors.accentText)
                    .frame(width: AppSizes.Width.buttonSave, height: AppSizes.Height.buttonSave)
                    .background(AppColors.accent)
                    .cornerRadius(AppSizes.Radius.large)
            }
            .disabled(title.isEmpty)
            .opacity(title.isEmpty ? 0.6 : 1.0)

            Spacer()
        }
        .padding(.top, AppSizes.Spacing.medium)
    }

    // MARK: - Actions
    private func saveSchedule() {
        guard !title.isEmpty else { return }

        let schedule = Schedule(
            title: title,
            date: calendarViewModel.selectedDate,
            category: selectedCategory
        )

        modelContext.insert(schedule)

        // Reset form
        title = ""
        selectedCategory = .other
    }
}

// MARK: - Preview

#Preview {
    ScheduleInputView()
        .environment(CalendarViewModel())
        .modelContainer(PreviewData.container)
}

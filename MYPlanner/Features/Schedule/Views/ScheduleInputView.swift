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
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    private let aiService = AIService()

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
        VStack(spacing: AppSizes.Spacing.medium) {
            HStack {
                Spacer()

                Button(action: saveSchedule) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: AppSizes.Width.buttonSave, height: AppSizes.Height.buttonSave)
                            .background(AppColors.accent)
                            .cornerRadius(AppSizes.Radius.large)
                    } else {
                        Text("저장")
                            .font(.system(size: AppSizes.FontSize.body, weight: .bold))
                            .foregroundColor(AppColors.accentText)
                            .frame(width: AppSizes.Width.buttonSave, height: AppSizes.Height.buttonSave)
                            .background(AppColors.accent)
                            .cornerRadius(AppSizes.Radius.large)
                    }
                }
                .disabled(title.isEmpty || isLoading)
                .opacity(title.isEmpty ? 0.6 : 1.0)

                Spacer()
            }

            // Error message
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: AppSizes.FontSize.small))
                    .foregroundColor(.red)
            }
        }
        .padding(.top, AppSizes.Spacing.medium)
    }

    // MARK: - Actions
    private func saveSchedule() {
        guard !title.isEmpty else { return }

        let scheduleTitle = title
        let scheduleDate = calendarViewModel.selectedDate
        let scheduleCategory = selectedCategory

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Generate English expressions from AI
                let aiResponse = try await aiService.generateExpression(for: scheduleTitle)

                // Parse response into expressions
                let expressions = parseExpressions(from: aiResponse)

                await MainActor.run {
                    // Create schedule with expressions
                    let schedule = Schedule(
                        title: scheduleTitle,
                        date: scheduleDate,
                        category: scheduleCategory
                    )

                    // Add expressions to schedule
                    for expression in expressions {
                        schedule.expressions.append(expression)
                    }

                    modelContext.insert(schedule)

                    // Reset form
                    title = ""
                    selectedCategory = .other
                    isLoading = false

                    print("✅ [ScheduleInputView] Saved schedule with \(expressions.count) expressions")
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    print("🔴 [ScheduleInputView] Error: \(error)")
                }
            }
        }
    }

    // Parse AI response into Expression objects
    private func parseExpressions(from response: String) -> [Expression] {
        // Split by newlines and filter empty lines
        let lines = response
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .compactMap { line -> String? in
                var cleaned = line

                // Remove numbering like "1.", "2.", etc.
                if let range = cleaned.range(of: #"^\d+\.\s*"#, options: .regularExpression) {
                    cleaned = String(cleaned[range.upperBound...])
                }

                // Remove markdown reference links like [(출처15)](url)
                cleaned = cleaned.replacingOccurrences(
                    of: #"\[\(출처\d+\)\]\([^)]+\)"#,
                    with: "",
                    options: .regularExpression
                )

                // Extract text inside quotes if present
                if let quoteMatch = cleaned.range(of: #""([^"]+)""#, options: .regularExpression) {
                    let quoted = cleaned[quoteMatch]
                    // Remove the surrounding quotes
                    cleaned = String(quoted.dropFirst().dropLast())
                }

                cleaned = cleaned.trimmingCharacters(in: .whitespaces)

                // Skip lines that don't start with English letters (ASCII a-z, A-Z)
                guard !cleaned.isEmpty,
                      let firstChar = cleaned.first,
                      firstChar.isASCII && (firstChar.isLetter || firstChar == "\"") else {
                    return nil
                }

                return cleaned
            }

        print("🔵 [ScheduleInputView] Parsed \(lines.count) expressions")

        return lines.map { line in
            // Accent auto-generated by AccentFormatter via CMU Dictionary
            Expression(english: line)
        }
    }
}

// MARK: - Preview

#Preview {
    ScheduleInputView()
        .environment(CalendarViewModel())
        .modelContainer(PreviewData.container)
}

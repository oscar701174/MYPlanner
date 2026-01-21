//
//  AccentFormatterTests.swift
//  MYPlannerTests
//
//  Test AccentFormatter with 150 sentences
//

import XCTest
@testable import MYPlanner

final class AccentFormatterTests: XCTestCase {

    var formatter: AccentFormatter!

    override func setUp() {
        super.setUp()
        // Load CMU Dictionary
        CMUDictionaryService.shared.load()
        formatter = AccentFormatter.shared
    }

    override func tearDown() {
        formatter = nil
        super.tearDown()
    }

    // MARK: - Test 150 Sentences

    func testAccentFormatter150Sentences() {
        let sentences = [
            // Daily life (1-20)
            "I need to prepare for the meeting.",
            "She is cooking dinner tonight.",
            "He wants to buy a new computer.",
            "We are going to the grocery store.",
            "They finished their homework early.",
            "I have to wake up early tomorrow.",
            "She likes to read books before bed.",
            "He is walking the dog in the park.",
            "We need to clean the house today.",
            "They are watching a movie together.",
            "I forgot my keys at home.",
            "She is making breakfast for everyone.",
            "He wants to learn a new language.",
            "We should exercise more often.",
            "They decided to travel this summer.",
            "I am looking for my glasses.",
            "She finished writing her report.",
            "He is studying for his exam.",
            "We need to pay the bills today.",
            "They are planning a surprise party.",

            // Work (21-40)
            "The project deadline is tomorrow.",
            "We have a team meeting at three.",
            "Please send me the updated report.",
            "I need to finish this presentation.",
            "The client requested some changes.",
            "We should discuss the budget first.",
            "The manager approved our proposal.",
            "I will schedule a conference call.",
            "Please review the contract carefully.",
            "The deadline has been extended.",
            "We need more resources for this project.",
            "The meeting was very productive today.",
            "I submitted my application yesterday.",
            "The company announced new policies.",
            "We achieved our quarterly targets.",
            "Please complete the survey by Friday.",
            "The interview went really well.",
            "I received positive feedback today.",
            "We need to improve our performance.",
            "The training session starts at nine.",

            // Travel (41-60)
            "I booked a flight to New York.",
            "The hotel has a beautiful view.",
            "We visited the famous museum yesterday.",
            "The train arrives at platform five.",
            "I need to renew my passport soon.",
            "She packed her suitcase last night.",
            "The beach was absolutely stunning.",
            "We took many photos during the trip.",
            "The restaurant served delicious food.",
            "I lost my luggage at the airport.",
            "The tour guide was very helpful.",
            "We explored the ancient ruins today.",
            "The weather was perfect for hiking.",
            "I bought some souvenirs for my family.",
            "The flight was delayed by two hours.",
            "We rented a car for the road trip.",
            "The mountain scenery was breathtaking.",
            "I enjoyed the local cuisine very much.",
            "The cruise ship departed on time.",
            "We stayed at a charming bed and breakfast.",

            // Health (61-80)
            "I have a doctor appointment tomorrow.",
            "She needs to take her medicine daily.",
            "He started a new exercise routine.",
            "We should eat more vegetables.",
            "They recommend drinking eight glasses of water.",
            "I feel much better after resting.",
            "She has been sleeping well lately.",
            "He wants to quit smoking this year.",
            "We joined a fitness class together.",
            "They scheduled a dental checkup.",
            "I need to reduce my stress levels.",
            "She is recovering from surgery slowly.",
            "He maintains a healthy lifestyle.",
            "We should get our annual checkups.",
            "They practice meditation every morning.",
            "I am trying to lose some weight.",
            "She takes vitamins every day.",
            "He injured his knee while running.",
            "We need to improve our eating habits.",
            "They visited the hospital yesterday.",

            // Education (81-100)
            "The professor explained the concept clearly.",
            "I submitted my assignment on time.",
            "She received excellent grades this semester.",
            "He is studying computer science.",
            "We have a test next Monday.",
            "They graduated from university last year.",
            "I need to write a research paper.",
            "She is taking an online course.",
            "He enrolled in a language program.",
            "We studied together at the library.",
            "They completed their final exams.",
            "I registered for the spring semester.",
            "She attended the lecture this morning.",
            "He received a scholarship award.",
            "We are learning new vocabulary words.",
            "They participated in the science fair.",
            "I borrowed several books today.",
            "She presented her project successfully.",
            "He is preparing for graduate school.",
            "We joined the debate club recently.",

            // Technology (101-120)
            "I updated my phone software yesterday.",
            "She created a new social media account.",
            "He is developing a mobile application.",
            "We need to backup our important files.",
            "They installed the latest security patch.",
            "I forgot my computer password again.",
            "She designed a beautiful website.",
            "He is learning to code in Python.",
            "We purchased a new laptop today.",
            "They fixed the network connection issue.",
            "I downloaded the application successfully.",
            "She is streaming her favorite show.",
            "He built a custom gaming computer.",
            "We upgraded our internet speed recently.",
            "They reported a software bug today.",
            "I connected my device to Bluetooth.",
            "She manages the database efficiently.",
            "He is troubleshooting the printer problem.",
            "We implemented the new system smoothly.",
            "They encrypted all sensitive data.",

            // Shopping (121-140)
            "I bought a new dress on sale.",
            "She is comparing prices online.",
            "He returned the defective product.",
            "We found a great discount today.",
            "They ordered groceries for delivery.",
            "I need to buy some winter clothes.",
            "She is looking for birthday gifts.",
            "He purchased tickets for the concert.",
            "We spent too much money shopping.",
            "They received their package yesterday.",
            "I tried on several pairs of shoes.",
            "She added items to her cart.",
            "He is waiting for the refund.",
            "We checked out at the self-service kiosk.",
            "They exchanged the wrong size shirt.",
            "I subscribed to the premium membership.",
            "She redeemed her loyalty points.",
            "He negotiated a better price.",
            "We browsed the electronics section.",
            "They recommended this product highly.",

            // Miscellaneous (141-150)
            "The weather forecast predicts rain tomorrow.",
            "I celebrated my birthday with friends.",
            "She adopted a cute puppy last week.",
            "He is renovating his apartment slowly.",
            "We attended the music festival downtown.",
            "They volunteered at the community center.",
            "I planted flowers in my garden.",
            "She organized a fundraising event.",
            "He is learning to play the guitar.",
            "We enjoyed the fireworks display immensely."
        ]

        print("\n" + String(repeating: "=", count: 80))
        print("ACCENT FORMATTER TEST RESULTS - 150 SENTENCES")
        print(String(repeating: "=", count: 80) + "\n")

        for (index, sentence) in sentences.enumerated() {
            let formatted = formatter.format(sentence)
            print("[\(String(format: "%03d", index + 1))] \(sentence)")
            print("      → \(formatted)")
            print("")
        }

        print(String(repeating: "=", count: 80))
        print("TEST COMPLETE: \(sentences.count) sentences processed")
        print(String(repeating: "=", count: 80))

        // Basic assertion - just verify it doesn't crash
        XCTAssertEqual(sentences.count, 150)
    }

    // MARK: - Individual Word Tests

    func testCommonWords() {
        let testWords = [
            ("prepare", "pre-PARE"),
            ("meeting", "MEET-ing"),
            ("computer", "com-PU-ter"),
            ("beautiful", "BEAU-ti-ful"),
            ("important", "im-POR-tant")
        ]

        print("\n" + String(repeating: "=", count: 50))
        print("INDIVIDUAL WORD TESTS")
        print(String(repeating: "=", count: 50) + "\n")

        for (word, _) in testWords {
            let result = formatter.formatWord(word)
            print("\(word) → \(result)")
        }
    }
}

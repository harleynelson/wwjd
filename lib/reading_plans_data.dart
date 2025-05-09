// lib/reading_plans_data.dart
import 'models.dart';

final List<ReadingPlan> allReadingPlans = [
  ReadingPlan(
    id: "rp_genesis_intro",
    title: "First Steps: Genesis",
    description: "Explore the book of beginnings, covering creation, the fall, early patriarchs, and God's covenant promises. A 7-day introduction.",
    category: "Old Testament",
    isPremium: false,
    // coverImageUrl: "assets/images/plan_genesis.png", // REMOVED
    dailyReadings: [
      // ... (daily readings remain the same)
      ReadingPlanDay(
        dayNumber: 1,
        title: "Creation",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 31, displayText: "Genesis 1")],
        reflectionPrompt: "What aspect of God's creation amazes you the most today?",
      ),
      ReadingPlanDay(
        dayNumber: 2,
        title: "The First Man and Woman",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 25, displayText: "Genesis 2")],
        reflectionPrompt: "Reflect on the concept of 'made in God's image'.",
      ),
      ReadingPlanDay(
        dayNumber: 3,
        title: "The Fall",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 24, displayText: "Genesis 3")],
        reflectionPrompt: "How does understanding the fall help you appreciate God's grace?",
      ),
      ReadingPlanDay(
        dayNumber: 4,
        title: "Cain and Abel / Noah's Calling",
        passages: [
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 4, startVerse: 1, endChapter: 4, endVerse: 16, displayText: "Genesis 4:1-16"),
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 6, startVerse: 9, endChapter: 6, endVerse: 22, displayText: "Genesis 6:9-22"),
        ],
        reflectionPrompt: "Consider the themes of obedience and consequence.",
      ),
      ReadingPlanDay(
        dayNumber: 5,
        title: "The Flood and God's Covenant",
        passages: [
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 7, startVerse: 1, endChapter: 7, endVerse: 24, displayText: "Genesis 7"),
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 8, startVerse: 1, endChapter: 8, endVerse: 22, displayText: "Genesis 8"),
        ],
        reflectionPrompt: "What does God's covenant with Noah reveal about His character?",
      ),
      ReadingPlanDay(
        dayNumber: 6,
        title: "The Call of Abram",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 12, startVerse: 1, endChapter: 12, endVerse: 9, displayText: "Genesis 12:1-9")],
        reflectionPrompt: "What does it mean to step out in faith when God calls?",
      ),
      ReadingPlanDay(
        dayNumber: 7,
        title: "God's Covenant with Abram",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 15, startVerse: 1, endChapter: 15, endVerse: 21, displayText: "Genesis 15")],
        reflectionPrompt: "Reflect on the promises God has made to you.",
      ),
    ],
  ),
  ReadingPlan(
    id: "rp_john_gospel_7day",
    title: "Meet Jesus: Gospel of John",
    description: "A 7-day journey through key passages in the Gospel of John, revealing who Jesus is and what He offers.",
    category: "Gospels",
    isPremium: false,
    // coverImageUrl: "assets/images/plan_john.png", // REMOVED
    dailyReadings: [
      // ... (daily readings remain the same)
      ReadingPlanDay(
        dayNumber: 1,
        title: "The Word Became Flesh",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 18, displayText: "John 1:1-18")],
        reflectionPrompt: "What does it mean to you that Jesus is the 'Word'?",
      ),
      ReadingPlanDay(
        dayNumber: 2,
        title: "The Wedding at Cana & Temple Cleansing",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 25, displayText: "John 2")],
        reflectionPrompt: "How do these first signs reveal Jesus's authority and mission?",
      ),
      ReadingPlanDay(
        dayNumber: 3,
        title: "Born Again: Nicodemus",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 21, displayText: "John 3:1-21")],
        reflectionPrompt: "Reflect on the meaning of being 'born again'.",
      ),
      ReadingPlanDay(
        dayNumber: 4,
        title: "The Woman at the Well",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 4, startVerse: 1, endChapter: 4, endVerse: 42, displayText: "John 4:1-42")],
        reflectionPrompt: "How does Jesus break down barriers to offer living water?",
      ),
      ReadingPlanDay(
        dayNumber: 5,
        title: "I AM the Bread of Life",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 6, startVerse: 25, endChapter: 6, endVerse: 40, displayText: "John 6:25-40")],
        reflectionPrompt: "In what ways do you need Jesus to be your spiritual nourishment today?",
      ),
      ReadingPlanDay(
        dayNumber: 6,
        title: "The Good Shepherd",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 10, startVerse: 1, endChapter: 10, endVerse: 18, displayText: "John 10:1-18")],
        reflectionPrompt: "How do you experience Jesus as your Good Shepherd?",
      ),
      ReadingPlanDay(
        dayNumber: 7,
        title: "The Resurrection and the Life",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 11, startVerse: 1, endChapter: 11, endVerse: 44, displayText: "John 11:1-44")],
        reflectionPrompt: "How does the raising of Lazarus build your faith in Jesus's power over death?",
      ),
    ],
  ),
  ReadingPlan(
    id: "rp_proverbs_wisdom_5day",
    title: "Daily Wisdom from Proverbs",
    description: "A 5-day plan to gain practical wisdom for everyday living from the book of Proverbs.",
    category: "Wisdom Literature",
    isPremium: true,
    // coverImageUrl: "assets/images/plan_proverbs.png", // REMOVED
    dailyReadings: [
      // ... (daily readings remain the same)
       ReadingPlanDay(
        dayNumber: 1, title: "The Value of Wisdom",
        passages: [BiblePassagePointer(bookAbbr: "PRO", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 33, displayText: "Proverbs 1")],
        reflectionPrompt: "Where do you need to apply more wisdom in your life this week?",
      ),
      ReadingPlanDay(
        dayNumber: 2, title: "Wisdom in Relationships",
        passages: [BiblePassagePointer(bookAbbr: "PRO", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 35, displayText: "Proverbs 3")],
        reflectionPrompt: "How can you cultivate trust and integrity in your relationships using today's reading?",
      ),
      ReadingPlanDay(
        dayNumber: 3, title: "Wisdom with Words",
        passages: [BiblePassagePointer(bookAbbr: "PRO", startChapter: 10, startVerse: 1, endChapter: 10, endVerse: 32, displayText: "Proverbs 10 (selections)")],
        reflectionPrompt: "Reflect on the power of your words. How can you use them more wisely?",
      ),
      ReadingPlanDay(
        dayNumber: 4, title: "Wisdom in Work & Diligence",
        passages: [BiblePassagePointer(bookAbbr: "PRO", startChapter: 6, startVerse: 6, endChapter: 6, endVerse: 11, displayText: "Proverbs 6:6-11"), BiblePassagePointer(bookAbbr: "PRO", startChapter: 12, startVerse: 24, endChapter: 12, endVerse: 24, displayText: "Proverbs 12:24"), BiblePassagePointer(bookAbbr: "PRO", startChapter: 13, startVerse: 4, endChapter: 13, endVerse: 4, displayText: "Proverbs 13:4")],
        reflectionPrompt: "What steps can you take to be more diligent and wise in your responsibilities?",
      ),
      ReadingPlanDay(
        dayNumber: 5, title: "The Fear of the Lord",
        passages: [BiblePassagePointer(bookAbbr: "PRO", startChapter: 9, startVerse: 10, endChapter: 9, endVerse: 12, displayText: "Proverbs 9:10-12"), BiblePassagePointer(bookAbbr: "PRO", startChapter: 14, startVerse: 26, endChapter: 14, endVerse: 27, displayText: "Proverbs 14:26-27")],
        reflectionPrompt: "What does 'the fear of the Lord' mean to you in a practical sense?",
      ),
    ],
  ),
];
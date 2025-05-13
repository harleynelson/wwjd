// lib/reading_plans_data.dart
import '../models/models.dart';

final List<ReadingPlan> allReadingPlans = [
  // --- EXISTING PLANS (from previous response) ---
  ReadingPlan(
    id: "rp_genesis_intro",
    title: "First Steps: Genesis",
    description: "Explore the book of beginnings, covering creation, the fall, early patriarchs, and God's covenant promises. A 7-day introduction.",
    category: "Old Testament",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_genesis_intro.png",
    isPremium: false,
    dailyReadings: [
      ReadingPlanDay(
        dayNumber: 1,
        title: "Creation",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 31, displayText: "Genesis 1")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After the entire Genesis 1 reading
            text: "The poetic rhythm of these verses paints a picture of order emerging from chaos, of intention and goodness in every act of creation. It invites us to see the world not as a random accident, but as a thoughtfully crafted space, brimming with potential and declared 'good'."
          ),
        ],
        reflectionPrompt: "What aspect of God's creation amazes you the most today, and how does it speak to you about its Source?",
      ),
      ReadingPlanDay(
        dayNumber: 2,
        title: "The First Man and Woman",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 25, displayText: "Genesis 2")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Genesis 2
            text: "This chapter offers a more intimate look at the creation of humanity and the beginnings of relationship—with the Creator, with the earth, and with each other. Notice the emphasis on companionship and the naming of creatures, suggesting a deep connection and responsibility."
          ),
        ],
        reflectionPrompt: "Reflect on the concept of being 'made in God's image' and the idea of 'not good for man to be alone.' What does this suggest about our inherent relational nature and purpose?",
      ),
      ReadingPlanDay(
        dayNumber: 3,
        title: "The Fall",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 24, displayText: "Genesis 3")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Genesis 3
            text: "This narrative explores themes of choice, consequence, and the introduction of brokenness into the world. It's a story that has shaped much thought about human nature and our relationship with the divine. It also subtly introduces the idea of redemption, even amidst hardship."
          ),
        ],
        reflectionPrompt: "How does this story of 'the fall' resonate with your understanding of human struggles and the longing for restoration or grace in your own life?",
      ),
      ReadingPlanDay(
        dayNumber: 4,
        title: "Cain and Abel / Noah's Calling",
        passages: [
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 4, startVerse: 1, endChapter: 4, endVerse: 16, displayText: "Genesis 4:1-16"),
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 6, startVerse: 9, endChapter: 6, endVerse: 22, displayText: "Genesis 6:9-22"),
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Genesis 4:1-16 (Cain and Abel)
            text: "The story of Cain and Abel introduces challenging themes of jealousy, anger, and the devastating consequences of unchecked negative emotions. It also shows, even in judgment, a measure of divine protection."
          ),
          InterspersedInsight(
            afterPassageIndex: 1, // After Genesis 6:9-22 (Noah's Calling)
            text: "Amidst a world described as corrupt, Noah stands out for his righteousness. His story is one of heeding a difficult call and trusting in a divine plan for preservation, even when it seemed overwhelming."
          ),
        ],
        reflectionPrompt: "Consider the themes of human choice, its consequences, and the idea of finding favor or being called to a unique purpose even in challenging times.",
      ),
      ReadingPlanDay(
        dayNumber: 5,
        title: "The Flood and God's Covenant",
        passages: [
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 7, startVerse: 1, endChapter: 7, endVerse: 24, displayText: "Genesis 7"),
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 8, startVerse: 1, endChapter: 8, endVerse: 22, displayText: "Genesis 8"),
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Genesis 7
            text: "The flood narrative is a powerful and complex story of judgment and preservation. It speaks to the seriousness of human actions and the sweeping nature of divine response in ancient storytelling."
          ),
          InterspersedInsight(
            afterPassageIndex: 1, // After Genesis 8
            text: "Emerging from the flood, there's a sense of a new beginning, culminating in a promise. The covenant symbolized by the rainbow is a profound statement of divine commitment to the earth and its inhabitants."
          ),
        ],
        reflectionPrompt: "What does God's covenant with Noah, symbolized by the rainbow, reveal about the nature of divine promises and the hope for renewal after devastation?",
      ),
      ReadingPlanDay(
        dayNumber: 6,
        title: "The Call of Abram",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 12, startVerse: 1, endChapter: 12, endVerse: 9, displayText: "Genesis 12:1-9")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Genesis 12:1-9
            text: "Abram's call involves leaving the familiar and stepping into the unknown, based purely on a promise. This is a foundational story about faith as trust and obedience, even without all the answers."
          ),
        ],
        reflectionPrompt: "What does it mean to step out in faith when you feel a divine calling or a deep inner prompting, even if the path ahead isn't entirely clear?",
      ),
      ReadingPlanDay(
        dayNumber: 7,
        title: "God's Covenant with Abram",
        passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 15, startVerse: 1, endChapter: 15, endVerse: 21, displayText: "Genesis 15")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Genesis 15
            text: "This chapter deepens the covenant theme, with Abram expressing doubt and God providing reassurance through a powerful, symbolic ritual. It shows that even foundational figures of faith had moments of questioning."
          ),
        ],
        reflectionPrompt: "Reflect on the nature of promises—both human and divine. How does the concept of covenant shape your understanding of relationship and commitment?",
      ),
    ],
  ),
  ReadingPlan(
    id: "rp_john_gospel_7day",
    title: "Meet Jesus: Gospel of John",
    description: "A 7-day journey through key passages in the Gospel of John, revealing who Jesus is and what He offers.",
    category: "Gospels",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_john_gospel_7day.png",
    isPremium: false,
    dailyReadings: [
      ReadingPlanDay(
        dayNumber: 1,
        title: "The Word Became Flesh",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 18, displayText: "John 1:1-18")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "John begins his account with such profound and poetic language. He's not just telling a story; he's inviting us into a cosmic understanding of who Jesus is—the eternal Word, the source of life and light, now present with us in a tangible way."
          ),
        ],
        reflectionPrompt: "What does it mean to you that the divine 'Word became flesh and dwelt among us'? How does this idea of God's closeness impact your perspective?",
      ),
      ReadingPlanDay(
        dayNumber: 2,
        title: "The Wedding at Cana & Temple Cleansing",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 25, displayText: "John 2")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "These first 'signs' in John's Gospel are powerful. Turning water into wine speaks of abundance and transformation, while clearing the temple courts speaks to a passion for true worship and reverence. Both hint at a new way of experiencing the divine that Jesus is introducing."
          ),
        ],
        reflectionPrompt: "How do these initial actions of Jesus—providing joy and challenging misuse of sacred space—reveal His authority and the nature of His mission?",
      ),
      ReadingPlanDay(
        dayNumber: 3,
        title: "Born Again: Nicodemus",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 21, displayText: "John 3:1-21")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "This intimate conversation with Nicodemus touches on one of the most transformative ideas: spiritual rebirth. Jesus speaks of a profound inner change, a new beginning that allows us to truly see and enter a different kind of reality—the kingdom of God."
          ),
        ],
        reflectionPrompt: "Reflect on the meaning of being 'born again' or experiencing a spiritual awakening. What might this look like in a person's life today?",
      ),
      ReadingPlanDay(
        dayNumber: 4,
        title: "The Woman at the Well",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 4, startVerse: 1, endChapter: 4, endVerse: 42, displayText: "John 4:1-42")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Notice how Jesus crosses several social and cultural boundaries to engage this Samaritan woman. Their conversation moves from physical thirst to a deep spiritual longing, revealing Jesus' offer of 'living water' that satisfies the soul."
          ),
        ],
        reflectionPrompt: "Jesus offers 'living water' to someone who was an outsider by many standards. How does this story challenge our own barriers and invite us to share hope and acceptance with all?",
      ),
      ReadingPlanDay(
        dayNumber: 5,
        title: "I AM the Bread of Life",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 6, startVerse: 25, endChapter: 6, endVerse: 40, displayText: "John 6:25-40")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "After feeding thousands, Jesus redirects the crowd's focus from physical bread to spiritual nourishment. His claim to be the 'Bread of Life' is an invitation to find ultimate sustenance and eternal life in relationship with him."
          ),
        ],
        reflectionPrompt: "In what ways do you seek spiritual nourishment in your life? How does the idea of Jesus as the 'Bread of Life' speak to your deepest needs?",
      ),
      ReadingPlanDay(
        dayNumber: 6,
        title: "The Good Shepherd",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 10, startVerse: 1, endChapter: 10, endVerse: 18, displayText: "John 10:1-18")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "The imagery of a shepherd who knows, leads, and lays down his life for his sheep is rich with care and protection. Jesus uses this to describe his intimate relationship with those who follow him."
          ),
        ],
        reflectionPrompt: "How do you experience guidance, care, or protection in your spiritual journey? What does it mean to 'know his voice'?",
      ),
      ReadingPlanDay(
        dayNumber: 7,
        title: "The Resurrection and the Life",
        passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 11, startVerse: 1, endChapter: 11, endVerse: 44, displayText: "John 11:1-44")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "The raising of Lazarus is a dramatic demonstration of Jesus's power over death and his profound compassion. His declaration, 'I am the resurrection and the life,' offers hope beyond our earthly existence."
          ),
        ],
        reflectionPrompt: "How does the story of Lazarus and Jesus's claim to be 'the resurrection and the life' impact your understanding of hope, loss, and eternal life?",
      ),
    ],
  ),
  ReadingPlan(
    id: "rp_proverbs_wisdom_5day",
    title: "Daily Wisdom from Proverbs",
    description: "A 5-day plan to gain practical wisdom for everyday living from the book of Proverbs.",
    category: "Wisdom Literature",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_proverbs_wisdom_5day.png",
    isPremium: true,
    dailyReadings: [
      ReadingPlanDay(
        dayNumber: 1, title: "The Value of Wisdom",
        passages: [BiblePassagePointer(bookAbbr: "PRO", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 33, displayText: "Proverbs 1")],
        // No interspersed insights added to this plan yet
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
  ReadingPlan(
    id: "rp_biblical_silences_5day",
    title: "Biblical Silences & Modern Questions",
    description: "Explore how ancient scriptures speak to (or are silent on) contemporary issues, inviting us to interpret principles of wisdom, love, and justice for today. A 5-day reflective journey.",
    category: "Topical / Ethics",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_biblical_silences_5day.png", // Placeholder
    isPremium: false,
    dailyReadings: [
      ReadingPlanDay(
        dayNumber: 1,
        title: "Wisdom for New Frontiers",
        passages: [
          BiblePassagePointer(bookAbbr: "PRO", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 11, displayText: "Proverbs 2:1-11"),
          BiblePassagePointer(bookAbbr: "JAS", startChapter: 1, startVerse: 5, endChapter: 1, endVerse: 5, displayText: "James 1:5"),
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Proverbs 2
            text: "The pursuit of wisdom, as described here, is an active and earnest endeavor. It suggests that when facing new complexities, a foundational step is to deeply value and seek understanding and discernment."
          ),
          InterspersedInsight(
            afterPassageIndex: 1, // After James 1
            text: "This invitation from James is a quiet reassurance: when faced with decisions, especially in uncharted territory, the resource of divine wisdom is generously available to those who sincerely ask."
          ),
        ],
        reflectionPrompt: "The Bible doesn't mention technologies like AI or stem cell research. How can principles of wisdom, stewardship (Genesis 1:28), and seeking understanding guide our approach to new ethical challenges?",
      ),
      ReadingPlanDay(
        dayNumber: 2,
        title: "The Spirit of the Law: Love & Inclusion",
        passages: [
          BiblePassagePointer(bookAbbr: "MAT", startChapter: 22, startVerse: 36, endChapter: 22, endVerse: 40, displayText: "Matthew 22:36-40"),
          BiblePassagePointer(bookAbbr: "GAL", startChapter: 3, startVerse: 28, endChapter: 3, endVerse: 28, displayText: "Galatians 3:28"),
          BiblePassagePointer(bookAbbr: "ROM", startChapter: 14, startVerse: 1, endChapter: 14, endVerse: 4, displayText: "Romans 14:1-4"),
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Matthew 22
            text: "Jesus centers the entire law on these two expressions of love. This suggests that love should be the primary lens through which we interpret all other teachings and interact with one another."
          ),
          InterspersedInsight(
            afterPassageIndex: 1, // After Galatians 3:28
            text: "Paul's declaration here points towards a radical vision of unity that transcends common societal divisions. It invites reflection on how such a vision challenges us to foster belonging for everyone."
          ),
          InterspersedInsight(
            afterPassageIndex: 2, // After Romans 14
            text: "The call to welcome others without passing judgment on disputable matters speaks to a posture of humility and grace in community, especially when navigating diverse perspectives."
          ),
        ],
        reflectionPrompt: "Scripture contains varied passages regarding social inclusion. How do overarching commands to love God and neighbor, and statements about unity in Christ, inform our approach to those who have been historically marginalized (e.g., LGBTQ+ individuals, other communities)?",
      ),
      ReadingPlanDay(
        dayNumber: 3,
        title: "Caring for Our Common Home",
        passages: [
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 2, startVerse: 15, endChapter: 2, endVerse: 15, displayText: "Genesis 2:15"),
          BiblePassagePointer(bookAbbr: "PSA", startChapter: 24, startVerse: 1, endChapter: 24, endVerse: 2, displayText: "Psalm 24:1-2"),
          BiblePassagePointer(bookAbbr: "LEV", startChapter: 25, startVerse: 23, endChapter: 25, endVerse: 24, displayText: "Leviticus 25:23-24"),
        ],
        interspersedInsights: [
           InterspersedInsight(
            afterPassageIndex: 0, // After Genesis 2:15
            text: "This early instruction to 'work it and take care of it' frames humanity's relationship with the Earth not as one of sheer domination, but of responsible cultivation and preservation."
          ),
          InterspersedInsight(
            afterPassageIndex: 1, // After Psalm 24:1-2
            text: "The affirmation that the Earth belongs to God fundamentally shifts our perspective from ownership to stewardship, implying accountability for how we treat this shared inheritance."
          ),
        ],
        reflectionPrompt: "While the Bible doesn't use terms like 'climate change,' what responsibilities do its teachings on stewardship and the Earth being the Lord's imply for our environmental ethics today?",
      ),
      ReadingPlanDay(
        dayNumber: 4,
        title: "Navigating Conflict: Diverse Voices on Peace",
        passages: [
          BiblePassagePointer(bookAbbr: "EXO", startChapter: 21, startVerse: 23, endChapter: 21, endVerse: 25, displayText: "Exodus 21:23-25 ('An eye for an eye')"),
          BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 38, endChapter: 5, endVerse: 41, displayText: "Matthew 5:38-41 ('Turn the other cheek')"),
          BiblePassagePointer(bookAbbr: "ISA", startChapter: 2, startVerse: 4, endChapter: 2, endVerse: 4, displayText: "Isaiah 2:4 ('Nation shall not lift up sword against nation')"),
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Exodus 21
            text: "The principle of 'an eye for an eye' in its original context was often about limiting retribution to proportionality, preventing escalating vengeance, rather than a mandate for personal revenge."
          ),
          InterspersedInsight(
            afterPassageIndex: 1, // After Matthew 5
            text: "Jesus' teaching here introduces a transformative ethic that moves beyond mere reciprocal justice towards non-retaliation and proactive peacemaking, challenging conventional responses to offense."
          ),
          InterspersedInsight(
            afterPassageIndex: 2, // After Isaiah 2
            text: "This prophetic vision offers a powerful hope for ultimate global peace, where instruments of war are converted into tools of sustenance and cooperative living. It calls us to imagine and work towards such a future."
          ),
        ],
        reflectionPrompt: "The Bible presents a range of responses to conflict, from retributive justice to radical peacemaking. How do we discern a path forward when scriptures themselves seem to offer differing perspectives?",
      ),
      ReadingPlanDay(
        dayNumber: 5,
        title: "Faith and Governance",
        passages: [
          BiblePassagePointer(bookAbbr: "1SA", startChapter: 8, startVerse: 10, endChapter: 8, endVerse: 18, displayText: "1 Samuel 8:10-18 (Samuel's warning about a king)"),
          BiblePassagePointer(bookAbbr: "ROM", startChapter: 13, startVerse: 1, endChapter: 13, endVerse: 2, displayText: "Romans 13:1-2 (Submit to governing authorities)"),
          BiblePassagePointer(bookAbbr: "ACT", startChapter: 5, startVerse: 29, endChapter: 5, endVerse: 29, displayText: "Acts 5:29 ('We must obey God rather than men')"),
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After 1 Samuel 8
            text: "Samuel's warning highlights the potential for human power structures to become oppressive, urging a degree of caution and a reminder of where ultimate allegiance lies."
          ),
          InterspersedInsight(
            afterPassageIndex: 2, // After Acts 5:29
            text: "The apostles' stance here underscores a crucial principle: while civic order is valued, allegiance to divine conscience and justice must take precedence when human laws conflict with fundamental moral truth."
          ),
        ],
        reflectionPrompt: "Scripture offers varied perspectives on human governance. How do principles of justice, coupled with these texts, help us navigate our civic responsibilities and critique power structures today?",
      ),
    ],
  ),


  ReadingPlan(
    id: "rp_evolving_understandings_5day",
    title: "Evolving Understandings: The Bible in Context",
    description: "A 5-day plan examining biblical texts that present challenges when read without historical, cultural, or literary context, inviting growth and nuanced interpretation.",
    category: "Biblical Interpretation",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_evolving_understandings_5day.png", // Placeholder
    isPremium: false,
    dailyReadings: [
      ReadingPlanDay(
        dayNumber: 1,
        title: "Ancient Worldviews: Cosmology",
        passages: [
          BiblePassagePointer(bookAbbr: "GEN", startChapter: 1, startVerse: 6, endChapter: 1, endVerse: 8, displayText: "Genesis 1:6-8 (The Firmament)"),
          BiblePassagePointer(bookAbbr: "PSA", startChapter: 19, startVerse: 1, endChapter: 19, endVerse: 6, displayText: "Psalm 19:1-6 (Sun's circuit)"),
        ],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: -1, 
                text: "Engaging with ancient texts often means encountering worldviews different from our own. It's an invitation to explore the primary purpose of these writings, which frequently focus on theological truths rather than precise scientific descriptions."
            ),
            InterspersedInsight(
                afterPassageIndex: 0, 
                text: "The imagery of a 'firmament' or a solid dome reflects common ancient Near Eastern understandings of the cosmos. This framework helped ancient peoples articulate a sense of divine order and structure in creation."
            ),
        ],
        reflectionPrompt: "Ancient texts describe the cosmos based on their era's understanding (e.g., a solid dome, flat earth). How does recognizing the Bible's primary theological purpose, rather than as a science textbook, help us appreciate its message while embracing modern scientific discovery?",
      ),
      ReadingPlanDay(
        dayNumber: 2,
        title: "Interpreting Difficult Laws: Slavery",
        passages: [
          BiblePassagePointer(bookAbbr: "EXO", startChapter: 21, startVerse: 2, endChapter: 21, endVerse: 6, displayText: "Exodus 21:2-6 (Laws concerning Hebrew slaves)"),
          BiblePassagePointer(bookAbbr: "PHM", startChapter: 1, startVerse: 8, endChapter: 1, endVerse: 17, displayText: "Philemon 1:8-17 (Paul's appeal for Onesimus)"),
        ],
        interspersedInsights: [ 
            InterspersedInsight(
                afterPassageIndex: 0, 
                text: "Confronting passages that regulate practices like slavery requires careful contextualization. These ancient legal codes often operated within existing societal structures, sometimes aiming to mitigate harshness rather than outright abolish common practices of the era."
            ),
            InterspersedInsight(
                afterPassageIndex: 1, 
                text: "Paul's appeal for Onesimus, though not a direct condemnation of slavery as an institution, subtly introduces transformative principles of brotherhood and love in Christ that challenge the very underpinnings of such hierarchical systems."
            ),
        ],
        reflectionPrompt: "The Bible contains laws that regulated, but didn't abolish, slavery in ancient contexts. How can we reconcile this with a progressive ethic of liberation and equality? How does focusing on the Bible's overall trajectory towards justice and love help us interpret such passages today?",
      ),
      ReadingPlanDay(
        dayNumber: 3,
        title: "Women in Scripture: Context and Trajectory",
        passages: [
          BiblePassagePointer(bookAbbr: "1TI", startChapter: 2, startVerse: 11, endChapter: 2, endVerse: 12, displayText: "1 Timothy 2:11-12 (Women to be silent)"),
          BiblePassagePointer(bookAbbr: "JDG", startChapter: 4, startVerse: 4, endChapter: 4, endVerse: 5, displayText: "Judges 4:4-5 (Deborah as a leader)"),
          BiblePassagePointer(bookAbbr: "ROM", startChapter: 16, startVerse: 1, endChapter: 16, endVerse: 2, displayText: "Romans 16:1-2 (Phoebe as a deacon/patron)"),
          BiblePassagePointer(bookAbbr: "GAL", startChapter: 3, startVerse: 28, endChapter: 3, endVerse: 28, displayText: "Galatians 3:28 (Neither male nor female in Christ)"),
        ],
        interspersedInsights: [ 
            InterspersedInsight(
                afterPassageIndex: 0, 
                text: "Passages like this one in 1 Timothy are often understood by scholars as addressing specific situations within a particular early church community, rather than laying down universal rules for all time. Context is key to interpretation."
            ),
            InterspersedInsight(
                afterPassageIndex: 2, 
                text: "The presence of figures like Deborah, a judge and prophetess, and Phoebe, a recognized deacon and patron in the early church, alongside Paul's inclusive declaration in Galatians, offers a broader, more complex picture of women's roles and spiritual significance within the biblical tradition."
            ),
        ],
        reflectionPrompt: "Some biblical texts reflect patriarchal norms of their time regarding women's roles, while others highlight women in significant leadership. How can understanding historical context and a broader theological vision of equality (e.g., Galatians 3:28) guide our interpretation and application?",
      ),
      ReadingPlanDay(
        dayNumber: 4,
        title: "Conquest and Violence: Understanding Difficult Narratives",
        passages: [
          BiblePassagePointer(bookAbbr: "JOS", startChapter: 6, startVerse: 20, endChapter: 6, endVerse: 21, displayText: "Joshua 6:20-21 (Fall of Jericho)"),
          BiblePassagePointer(bookAbbr: "DEU", startChapter: 20, startVerse: 16, endChapter: 20, endVerse: 18, displayText: "Deuteronomy 20:16-18 (Commands to destroy nations)"),
        ],
        interspersedInsights: [ 
            InterspersedInsight(
                afterPassageIndex: -1, 
                text: "The conquest narratives are undeniably among the most ethically challenging texts. Approaching them requires acknowledging their difficulty and exploring various interpretive lenses, including historical context and the nature of ancient Near Eastern war accounts."
            ),
            InterspersedInsight(
                afterPassageIndex: 1, 
                text: "Many theologians grapple with these texts by considering the progressive nature of revelation in scripture, culminating in the teachings of Jesus which emphasize love, even for enemies. This invites a critical reflection on how divine character is portrayed and understood across the biblical narrative."
            ),
        ],
        reflectionPrompt: "Narratives of conquest and divinely sanctioned violence are among the most challenging in scripture. How might considering literary genre (e.g., ancient Near Eastern war rhetoric), historical context, and the evolving understanding of God's character (as revealed fully in Jesus) help us grapple with these texts responsibly?",
      ),
      ReadingPlanDay(
        dayNumber: 5,
        title: "Science and Ancient Knowledge: The Mustard Seed",
        passages: [
          BiblePassagePointer(bookAbbr: "MRK", startChapter: 4, startVerse: 30, endChapter: 4, endVerse: 32, displayText: "Mark 4:30-32 (Parable of the Mustard Seed)"),
        ],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: 0,
                text: "Parables, like this one, often use common, everyday illustrations from their time to convey deeper spiritual truths. The emphasis is on the message—the expansive growth of the Kingdom from humble beginnings—rather than on literal, scientific precision regarding which seed is truly the smallest."
            ),
        ],
        reflectionPrompt: "Jesus uses the mustard seed, described as 'smallest of all seeds' in its context, to illustrate a spiritual truth. Botanically, other seeds are smaller. How does understanding the use of common analogies and the primary teaching goal (rather than scientific precision) help us appreciate such parables? How can faith and reason coexist and enrich each other?",
      ),
    ],
  ),
  ReadingPlan(
    id: "rp_love_your_neighbor_7day",
    title: "Love Your Neighbor: A Call to Compassion",
    description: "Discover the radical call to love and compassion found in scripture. This 7-day plan explores how to extend empathy and justice to all.",
    category: "Topical",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_love_your_neighbor_7day.png",
    isPremium: false,
    dailyReadings: [
      ReadingPlanDay(
        dayNumber: 1,
        title: "The Greatest Commandment",
        passages: [
          BiblePassagePointer(bookAbbr: "MAT", startChapter: 22, startVerse: 34, endChapter: 22, endVerse: 40, displayText: "Matthew 22:34-40"),
          BiblePassagePointer(bookAbbr: "LEV", startChapter: 19, startVerse: 18, endChapter: 19, endVerse: 18, displayText: "Leviticus 19:18"),
        ],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: 0,
                text: "Jesus distills countless laws into two core principles: love for God and love for neighbor. This pairing suggests that our spiritual devotion is intrinsically linked to our human connections and ethical actions."
            ),
            InterspersedInsight(
                afterPassageIndex: 1,
                text: "It's significant that Jesus draws the command to love neighbors from Leviticus, rooting this central teaching deeply within the Hebraic tradition. It's not a new idea, but one with enduring importance."
            ),
        ],
        reflectionPrompt: "Who is your 'neighbor' in today's world? How can you show them love actively?",
      ),
      ReadingPlanDay(
        dayNumber: 2,
        title: "The Good Samaritan",
        passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 10, startVerse: 25, endChapter: 10, endVerse: 37, displayText: "Luke 10:25-37")],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: 0,
                text: "This parable radically redefines 'neighbor' from someone within our own group to anyone in need whom we encounter. It challenges social, religious, and ethnic boundaries, emphasizing action over affiliation."
            ),
        ],
        reflectionPrompt: "What excuses do we make for not helping others? How can this parable challenge those excuses and call us to compassionate action?",
      ),
      ReadingPlanDay(
        dayNumber: 3,
        title: "Empathy and Shared Burdens",
        passages: [
          BiblePassagePointer(bookAbbr: "GAL", startChapter: 6, startVerse: 2, endChapter: 6, endVerse: 2, displayText: "Galatians 6:2"),
          BiblePassagePointer(bookAbbr: "ROM", startChapter: 12, startVerse: 15, endChapter: 12, endVerse: 15, displayText: "Romans 12:15"),
        ],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: 1,
                text: "Bearing burdens and sharing in both joy and sorrow are practical expressions of love. They speak to the importance of presence, solidarity, and deep empathy in our relationships and communities."
            ),
        ],
        reflectionPrompt: "Reflect on a time someone showed you empathy or helped bear your burden. How can you practice 'rejoicing with those who rejoice and mourning with those who mourn' this week?",
      ),
      ReadingPlanDay(
        dayNumber: 4,
        title: "Love for the 'Other'",
        passages: [
          BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 43, endChapter: 5, endVerse: 48, displayText: "Matthew 5:43-48"),
          BiblePassagePointer(bookAbbr: "LUK", startChapter: 6, startVerse: 27, endChapter: 6, endVerse: 36, displayText: "Luke 6:27-36"),
        ],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: 0,
                text: "The call to love even enemies and pray for persecutors is one of the most challenging and counter-cultural teachings. It pushes the boundaries of compassion far beyond our natural inclinations."
            ),
        ],
        reflectionPrompt: "Who are the people or groups you find it hardest to love? What would it mean to extend God-like love—love that seeks the other's good—even there?",
      ),
      ReadingPlanDay(
        dayNumber: 5,
        title: "Justice for the Oppressed",
        passages: [
          BiblePassagePointer(bookAbbr: "ISA", startChapter: 1, startVerse: 17, endChapter: 1, endVerse: 17, displayText: "Isaiah 1:17"),
          BiblePassagePointer(bookAbbr: "MIC", startChapter: 6, startVerse: 8, endChapter: 6, endVerse: 8, displayText: "Micah 6:8"),
        ],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: 1,
                text: "The prophetic tradition consistently links true spirituality with a commitment to justice. Micah's summary—acting justly, loving mercy, and walking humbly—provides a powerful three-fold guide for a life that honors God and cares for others."
            ),
        ],
        reflectionPrompt: "How can loving your neighbor practically involve seeking justice, defending the oppressed, and working to correct systemic wrongs?",
      ),
      ReadingPlanDay(
        dayNumber: 6,
        title: "Hospitality and Welcome",
        passages: [
          BiblePassagePointer(bookAbbr: "ROM", startChapter: 12, startVerse: 13, endChapter: 12, endVerse: 13, displayText: "Romans 12:13"),
          BiblePassagePointer(bookAbbr: "HEB", startChapter: 13, startVerse: 2, endChapter: 13, endVerse: 2, displayText: "Hebrews 13:2"),
        ],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: 1,
                text: "Hospitality in the ancient world was a vital social and ethical practice. These reminders to welcome strangers and share generously extend that spirit, suggesting that our homes and resources can be places of blessing and connection."
            ),
        ],
        reflectionPrompt: "In what practical ways can you show hospitality and create a welcoming space for others, including those who might be considered 'strangers' or are in need?",
      ),
      ReadingPlanDay(
        dayNumber: 7,
        title: "Love in Action",
        passages: [
          BiblePassagePointer(bookAbbr: "1JN", startChapter: 3, startVerse: 16, endChapter: 3, endVerse: 18, displayText: "1 John 3:16-18"),
          BiblePassagePointer(bookAbbr: "JAS", startChapter: 2, startVerse: 14, endChapter: 2, endVerse: 17, displayText: "James 2:14-17"),
        ],
        interspersedInsights: [
            InterspersedInsight(
                afterPassageIndex: 1,
                text: "Both John and James emphasize that true love and faith are not merely matters of words or feelings, but are demonstrated through tangible actions that meet the needs of others. Our deeds are the evidence of our heart's orientation."
            ),
        ],
        reflectionPrompt: "Commit to one specific, tangible action this week to put your love for your neighbor into practice, moving beyond sentiment to service.",
      ),
    ],
  ),
  ReadingPlan(
    id: "rp_justice_renewal_14day",
    title: "Justice & Renewal: Prophetic Voices",
    description: "A 14-day plan exploring the prophets' calls for social justice, care for the vulnerable, and a renewed relationship with God and creation.",
    category: "Prophetic Literature",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_justice_renewal_14day.png",
    isPremium: true, // This plan was marked as premium in your provided list
    dailyReadings: [
      ReadingPlanDay(
        dayNumber: 1, 
        title: "What God Requires", 
        passages: [BiblePassagePointer(bookAbbr: "MIC", startChapter: 6, startVerse: 6, endChapter: 6, endVerse: 8, displayText: "Micah 6:6-8")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Micah beautifully distills complex religious observance down to three core actions. It's a powerful reminder that true spirituality is deeply intertwined with our ethical behavior and relational posture."
          )
        ],
        reflectionPrompt: "Reflect on 'acting justly,' 'loving mercy,' and 'walking humbly.' How can you embody these in your interactions and choices today?"
      ),
      ReadingPlanDay(
        dayNumber: 2, 
        title: "True Fasting", 
        passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 58, startVerse: 6, endChapter: 58, endVerse: 11, displayText: "Isaiah 58:6-11")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Isaiah challenges the notion of ritual fasting disconnected from compassionate action. The 'fast' God chooses involves actively working to free the oppressed and care for the needy, suggesting our spiritual practices should have tangible, positive impacts on the world."
          )
        ],
        reflectionPrompt: "What does 'true fasting,' as described by Isaiah, look like in terms of social action and care for others in our contemporary world?"
      ),
      ReadingPlanDay(
        dayNumber: 3, 
        title: "Justice for the Poor", 
        passages: [BiblePassagePointer(bookAbbr: "AMO", startChapter: 5, startVerse: 21, endChapter: 5, endVerse: 24, displayText: "Amos 5:21-24")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Amos delivers a startling message: religious assemblies and offerings are detestable if not accompanied by justice and righteousness. This calls for a profound integration of our worship and our commitment to fairness for all, especially the vulnerable."
          )
        ],
        reflectionPrompt: "How can our communal worship and personal spiritual life be authentically connected to the active pursuit of justice for marginalized people?"
      ),
      ReadingPlanDay(
        dayNumber: 4, 
        title: "A New Heart and Spirit", 
        passages: [BiblePassagePointer(bookAbbr: "EZK", startChapter: 36, startVerse: 24, endChapter: 36, endVerse: 28, displayText: "Ezekiel 36:24-28")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Ezekiel's vision speaks of a deep, internal transformation—a new heart and spirit—as foundational for true renewal. This suggests that lasting societal change begins with a change within individuals, enabling them to live according to divine principles."
          )
        ],
        reflectionPrompt: "Consider the idea of inner transformation—a 'heart of flesh' replacing a 'heart of stone'—as a necessary precursor or companion to societal renewal and justice."
      ),
      ReadingPlanDay(
        dayNumber: 5, 
        title: "The Year of the Lord's Favor", 
        passages: [
          BiblePassagePointer(bookAbbr: "ISA", startChapter: 61, startVerse: 1, endChapter: 61, endVerse: 4, displayText: "Isaiah 61:1-4"), 
          BiblePassagePointer(bookAbbr: "LUK", startChapter: 4, startVerse: 16, endChapter: 4, endVerse: 21, displayText: "Luke 4:16-21")
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0, // After Isaiah 61
            text: "This passage from Isaiah beautifully describes a mission of holistic restoration—good news to the poor, healing for the brokenhearted, freedom for captives. It's a vision of comprehensive societal and spiritual renewal."
          ),
          InterspersedInsight(
            afterPassageIndex: 1, // After Luke 4
            text: "When Jesus reads from Isaiah and declares 'Today this scripture has been fulfilled in your hearing,' he is identifying his own mission with this prophetic call for liberation and restoration. It's a powerful claim about the nature of his work."
          )
        ],
        reflectionPrompt: "How did Jesus embody this prophetic call outlined in Isaiah? How can we, as individuals and communities, participate in bringing 'good news to the poor' and proclaiming 'the year of the Lord's favor' today?"
      ),
      ReadingPlanDay(
        dayNumber: 6, 
        title: "Caring for the Foreigner", 
        passages: [
          BiblePassagePointer(bookAbbr: "LEV", startChapter: 19, startVerse: 33, endChapter: 19, endVerse: 34, displayText: "Leviticus 19:33-34"), 
          BiblePassagePointer(bookAbbr: "DEU", startChapter: 10, startVerse: 17, endChapter: 10, endVerse: 19, displayText: "Deuteronomy 10:17-19")
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 1,
            text: "Both Leviticus and Deuteronomy emphasize that the memory of Israel's own experience as 'foreigners in Egypt' should fuel their compassion and just treatment of immigrants and sojourners in their midst. This calls for empathy rooted in shared human experience."
          )
        ],
        reflectionPrompt: "How can the principle of 'loving the foreigner as yourself,' rooted in empathy and divine command, inform our attitudes and actions towards immigrants, refugees, and those perceived as 'strangers' in our communities today?"
      ),
      ReadingPlanDay(
        dayNumber: 7, 
        title: "Integrity in Business", 
        passages: [
          BiblePassagePointer(bookAbbr: "PRO", startChapter: 11, startVerse: 1, endChapter: 11, endVerse: 1, displayText: "Proverbs 11:1"), 
          BiblePassagePointer(bookAbbr: "AMO", startChapter: 8, startVerse: 4, endChapter: 8, endVerse: 6, displayText: "Amos 8:4-6")
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 1,
            text: "The prophets strongly condemned dishonest economic practices that exploited the vulnerable. These passages remind us that ethical conduct in commerce and daily transactions is a matter of spiritual integrity and social justice."
          )
        ],
        reflectionPrompt: "In what ways can we ensure fairness, honesty, and ethical considerations in our economic dealings, both personal and systemic, and advocate for practices that don't harm the poor or vulnerable?"
      ),
      ReadingPlanDay(
        dayNumber: 8, 
        title: "Swords into Plowshares: Peace", 
        passages: [
          BiblePassagePointer(bookAbbr: "ISA", startChapter: 2, startVerse: 2, endChapter: 2, endVerse: 4, displayText: "Isaiah 2:2-4"), 
          BiblePassagePointer(bookAbbr: "MIC", startChapter: 4, startVerse: 1, endChapter: 4, endVerse: 4, displayText: "Micah 4:1-4")
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 1,
            text: "This powerful shared vision from Isaiah and Micah of transforming weapons of war into tools of agriculture symbolizes a profound shift from conflict to constructive peace and sustenance. It's a guiding image for global reconciliation."
          )
        ],
        reflectionPrompt: "What does this prophetic vision of ultimate peace and demilitarization mean to you in a world still rife with conflict? How can we actively work towards becoming peacemakers in our spheres of influence?"
      ),
      ReadingPlanDay(
        dayNumber: 9, 
        title: "Healing the Land", 
        passages: [
          BiblePassagePointer(bookAbbr: "HOS", startChapter: 4, startVerse: 1, endChapter: 4, endVerse: 3, displayText: "Hosea 4:1-3"), 
          BiblePassagePointer(bookAbbr: "2CH", startChapter: 7, startVerse: 14, endChapter: 7, endVerse: 14, displayText: "2 Chronicles 7:14")
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Hosea draws a direct link between the moral and spiritual state of the people—lack of faithfulness, love, and acknowledgment of God—and the suffering of the land itself. This suggests a deep interconnectedness between human ethics and environmental well-being."
          )
        ],
        reflectionPrompt: "How is the well-being of the land and creation connected to our collective actions and spiritual state? What does 'humbling ourselves, praying, seeking God's face, and turning from wicked ways' mean in the context of environmental stewardship and healing today?"
      ),
      ReadingPlanDay(
        dayNumber: 10, 
        title: "Speaking Truth to Power", 
        passages: [
          BiblePassagePointer(bookAbbr: "JER", startChapter: 1, startVerse: 4, endChapter: 1, endVerse: 10, displayText: "Jeremiah 1:4-10"), 
          BiblePassagePointer(bookAbbr: "JER", startChapter: 1, startVerse: 17, endChapter: 1, endVerse: 19, displayText: "Jeremiah 1:17-19")
        ],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 1,
            text: "The call of a prophet often involves speaking difficult truths to those in power, even in the face of opposition. Jeremiah's experience highlights the courage required for such a task, sustained by a sense of divine commission and presence."
          )
        ],
        reflectionPrompt: "When and how might we be called to speak uncomfortable truths to systems or individuals in authority for the sake of justice, righteousness, or the well-being of others?"
      ),
      ReadingPlanDay(
        dayNumber: 11, 
        title: "The Inclusive Kingdom", 
        passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 56, startVerse: 6, endChapter: 56, endVerse: 8, displayText: "Isaiah 56:6-8")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Isaiah's vision here radically expands the boundaries of God's covenant community, explicitly including foreigners and eunuchs—groups often marginalized. It emphasizes devotion and covenant-keeping over lineage or physical wholeness as criteria for belonging."
          )
        ],
        reflectionPrompt: "How does this passage challenge notions of exclusivity in religious or social communities and affirm God's expansive welcome to all who sincerely seek to join in covenant?"
      ),
      ReadingPlanDay(
        dayNumber: 12, 
        title: "Hope for Restoration", 
        passages: [BiblePassagePointer(bookAbbr: "JOL", startChapter: 2, startVerse: 25, endChapter: 2, endVerse: 27, displayText: "Joel 2:25-27")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Even after times of devastation (symbolized by the locusts), the prophet Joel speaks of a divine promise to restore what was lost. This is a powerful message of hope, suggesting that no situation is beyond the possibility of renewal and restored abundance."
          )
        ],
        reflectionPrompt: "Even after periods of hardship, injustice, or personal loss, the prophets speak of hope and restoration. Where do you see or long for this potential for renewal in your life or in the world today?"
      ),
      ReadingPlanDay(
        dayNumber: 13, 
        title: "The Faithful Remnant", 
        passages: [BiblePassagePointer(bookAbbr: "ZEP", startChapter: 3, startVerse: 12, endChapter: 3, endVerse: 13, displayText: "Zephaniah 3:12-13")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "The concept of a 'remnant'—a group that remains humble, trusts in God, and does no wrong—appears throughout prophetic literature. It suggests that even a small number of people committed to integrity and justice can be a powerful force for good and a locus of divine presence."
          )
        ],
        reflectionPrompt: "Consider the potential impact of a small group of individuals deeply committed to ethical living and divine principles. How might such a 'remnant' influence broader society?"
      ),
      ReadingPlanDay(
        dayNumber: 14, 
        title: "A Vision of New Creation", 
        passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 65, startVerse: 17, endChapter: 65, endVerse: 25, displayText: "Isaiah 65:17-25")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "Isaiah concludes with a breathtaking vision of new heavens and a new earth, characterized by joy, longevity, peace, security, and harmony between humanity and creation. This is the ultimate hope towards which the prophetic voice calls us."
          )
        ],
        reflectionPrompt: "What aspects of Isaiah's vision for a renewed and reconciled world inspire you most? How can we live today as signs and agents of this future hope, contributing to its unfolding?"
      ),
    ],
  ),
  ReadingPlan(
    id: "rp_parables_inclusion_7day",
    title: "Parables of Inclusion: Rethinking Boundaries",
    description: "A 7-day journey through Jesus' parables that challenge social norms and religious exclusivity, revealing a radically inclusive vision of God's kingdom.",
    category: "Gospels / Parables",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_parables_inclusion_7day.png",
    isPremium: true, // This plan was marked as premium in your provided list
    dailyReadings: [
      ReadingPlanDay(
        dayNumber: 1,
        title: "The Lost Sheep & Lost Coin",
        passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 15, startVerse: 1, endChapter: 15, endVerse: 10, displayText: "Luke 15:1-10")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "These parables emphasize the immense value God places on each individual, especially those who might seem 'lost' or overlooked by society. The active seeking and joyous celebration highlight a divine compassion that leaves no one behind."
          )
        ],
        reflectionPrompt: "Who are the 'lost' or marginalized in our society that God actively seeks? How do these parables challenge our ideas of who 'belongs' and the effort we extend towards inclusion?"
      ),
      ReadingPlanDay(
        dayNumber: 2,
        title: "The Prodigal Son (and the Elder Brother)",
        passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 15, startVerse: 11, endChapter: 15, endVerse: 32, displayText: "Luke 15:11-32")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "This rich story explores not only the unconditional welcome offered to the repentant 'outsider' but also the challenge faced by the 'insider' to embrace such radical grace. It's a call to move beyond resentment and scorekeeping to joyful reconciliation."
          )
        ],
        reflectionPrompt: "This parable highlights unconditional forgiveness but also the resentment of the 'insider.' How can we cultivate a heart that celebrates restoration rather than focusing on perceived fairness or personal merit?",
      ),
      ReadingPlanDay(
        dayNumber: 3,
        title: "The Workers in the Vineyard",
        passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 20, startVerse: 1, endChapter: 20, endVerse: 16, displayText: "Matthew 20:1-16")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "The landowner's seemingly 'unfair' generosity challenges our human tendency to compare and to base worthiness on effort or timing. This parable suggests that divine grace operates on principles beyond our conventional understanding of merit."
          )
        ],
        reflectionPrompt: "God's generosity can seem disruptive to our notions of fairness. How does this parable challenge our ideas about who 'deserves' blessing and the nature of divine grace?",
      ),
      ReadingPlanDay(
        dayNumber: 4,
        title: "The Great Banquet",
        passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 14, startVerse: 15, endChapter: 14, endVerse: 24, displayText: "Luke 14:15-24")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "When the initially invited guests make excuses, the invitation is extended to those on the fringes of society. This parable highlights the unexpected and inclusive nature of God's kingdom, often embracing those the 'establishment' might deem unworthy."
          )
        ],
        reflectionPrompt: "Those initially invited made excuses, so the invitation extended to the 'poor, crippled, blind, and lame.' Who is being invited into God's community today that conventional structures might overlook or exclude?",
      ),
      ReadingPlanDay(
        dayNumber: 5,
        title: "The Unforgiving Servant",
        passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 18, startVerse: 21, endChapter: 18, endVerse: 35, displayText: "Matthew 18:21-35")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "This parable starkly illustrates the disconnect between receiving immense forgiveness and failing to extend it to others. It suggests that our own experience of grace should fundamentally shape how we treat those who have wronged us."
          )
        ],
        reflectionPrompt: "Having received boundless grace and forgiveness in our lives, how does withholding forgiveness from others obstruct the flow of divine love and reconciliation in our communities and personal relationships?"
      ),
      ReadingPlanDay(
        dayNumber: 6,
        title: "The Talents (or Minas)",
        passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 25, startVerse: 14, endChapter: 25, endVerse: 30, displayText: "Matthew 25:14-30")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "While often interpreted regarding financial stewardship, this parable also speaks to the responsibility of using all God-given gifts and resources—time, abilities, opportunities—productively and faithfully, rather than out of fear or neglect."
          )
        ],
        reflectionPrompt: "This parable can be understood as a call to utilize all our diverse gifts for positive impact. How can recognizing, cultivating, and employing these varied gifts build a more vibrant and inclusive community?"
      ),
      ReadingPlanDay(
        dayNumber: 7,
        title: "The Sheep and the Goats",
        passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 25, startVerse: 31, endChapter: 25, endVerse: 46, displayText: "Matthew 25:31-46")],
        interspersedInsights: [
          InterspersedInsight(
            afterPassageIndex: 0,
            text: "In this powerful depiction of final judgment, the criteria for entering the kingdom are based on tangible acts of compassion towards those in need—the hungry, thirsty, stranger, naked, sick, and imprisoned. It implies that our treatment of the 'least of these' is a direct reflection of our relationship with the Divine."
          )
        ],
        reflectionPrompt: "The ultimate standard for judgment in this parable is compassionate action towards the vulnerable. How does this radical call to identify with and serve the marginalized define true belonging and righteousness in God's eyes?",
      ),
    ],
  ),
  
  ReadingPlan(
    id: "rp_peace_troubled_times_7day",
    title: "Peace in Troubled Times",
    description: "Discover scriptural anchors for peace and hope amidst personal struggles or global uncertainties. A 7-day plan for finding calm.",
    category: "Topical",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_peace_troubled_times_7day.png", // Placeholder - Assuming you have an image asset
    isPremium: false,
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1, title: "The Peace of God",
            passages: [BiblePassagePointer(bookAbbr: "PHP", startChapter: 4, startVerse: 6, endChapter: 4, endVerse: 7, displayText: "Philippians 4:6-7")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Philippians 4:6-7
                    text: "It's remarkable how this passage links letting go of anxiety directly with prayer and thanksgiving. It suggests peace isn't just the absence of trouble, but an active presence found when we connect with God, even before circumstances change."
                )
            ],
            reflectionPrompt: "What anxieties are you holding today? How can you practice prayer and gratitude to experience God's peace?",
        ),
        ReadingPlanDay(
            dayNumber: 2, title: "He Will Not Forsake You",
            passages: [
                BiblePassagePointer(bookAbbr: "DEU", startChapter: 31, startVerse: 6, endChapter: 31, endVerse: 6, displayText: "Deuteronomy 31:6"),
                BiblePassagePointer(bookAbbr: "HEB", startChapter: 13, startVerse: 5, endChapter: 13, endVerse: 6, displayText: "Hebrews 13:5-6")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Hebrews 13:5-6
                    text: "These promises, echoed across the Old and New Testaments, offer a bedrock assurance. The peace here comes from knowing we're not alone in our struggles; God's commitment to be with us is unwavering, a constant presence in uncertainty."
                )
            ],
            reflectionPrompt: "How does the assurance of God's presence bring you peace in times of fear or loneliness?",
        ),
        ReadingPlanDay(
            dayNumber: 3, title: "The Lord is My Shepherd",
            passages: [BiblePassagePointer(bookAbbr: "PSA", startChapter: 23, startVerse: 1, endChapter: 23, endVerse: 6, displayText: "Psalm 23")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Psalm 23
                    text: "Psalm 23 paints such a tender picture of constant care. Whether it's finding rest, navigating darkness ('the darkest valley'), or dwelling in safety, the core message is deep trust in a loving Guide whose presence itself brings profound peace."
                )
            ],
            reflectionPrompt: "Which image or promise in Psalm 23 resonates most with your need for peace and guidance today?",
        ),
        ReadingPlanDay(
            dayNumber: 4, title: "Do Not Let Your Hearts Be Troubled",
            passages: [
                BiblePassagePointer(bookAbbr: "JHN", startChapter: 14, startVerse: 1, endChapter: 14, endVerse: 3, displayText: "John 14:1-3"),
                BiblePassagePointer(bookAbbr: "JHN", startChapter: 14, startVerse: 27, endChapter: 14, endVerse: 27, displayText: "John 14:27")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After John 14:27
                    text: "Jesus acknowledges the world offers a kind of 'peace,' often fleeting and based on circumstances. But the peace He gives is fundamentally different—an inner calm rooted in trust and His abiding presence, stable even amidst external turmoil."
                )
            ],
            reflectionPrompt: "Jesus offers a peace different from the world's. What does this divine peace mean to you personally?",
        ),
        ReadingPlanDay(
            dayNumber: 5, title: "God is Our Refuge",
            passages: [
                BiblePassagePointer(bookAbbr: "PSA", startChapter: 46, startVerse: 1, endChapter: 46, endVerse: 3, displayText: "Psalm 46:1-3"),
                BiblePassagePointer(bookAbbr: "PSA", startChapter: 46, startVerse: 10, endChapter: 46, endVerse: 10, displayText: "Psalm 46:10")
            ],
            interspersedInsights: [
                 InterspersedInsight(
                    afterPassageIndex: 0, // After Psalm 46:1-3
                    text: "This Psalm starts by grounding us in a powerful truth: even when everything feels like it's shaking, God remains a reliable source of strength and immediate help. Peace begins with remembering where our true security lies."
                ),
                InterspersedInsight(
                    afterPassageIndex: 1, // After Psalm 46:10
                    text: "In the midst of dramatic descriptions of upheaval, the call to 'be still' is powerful. It suggests that consciously pausing and recognizing God's ultimate sovereignty allows us to find an anchor of peace—not by denying the chaos, but by knowing who holds us through it."
                )
            ],
            reflectionPrompt: "How can being 'still' and knowing God is in control bring peace even when the 'earth gives way'?",
        ),
        ReadingPlanDay(
            dayNumber: 6, title: "Casting All Your Anxieties",
            passages: [BiblePassagePointer(bookAbbr: "1PE", startChapter: 5, startVerse: 6, endChapter: 5, endVerse: 7, displayText: "1 Peter 5:6-7")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After 1 Peter 5:6-7
                    text: "Notice the connection Peter makes between humility ('Humble yourselves') and casting anxieties onto God. It suggests that letting go of our burdens involves the humble act of acknowledging we don't have to carry them alone, trusting instead in God's deep, personal care for us."
                )
            ],
            reflectionPrompt: "What specific anxieties can you consciously 'cast' on God today, trusting in His care for you?",
        ),
        ReadingPlanDay(
            dayNumber: 7, title: "The Fruit of the Spirit: Peace",
            passages: [
                BiblePassagePointer(bookAbbr: "GAL", startChapter: 5, startVerse: 22, endChapter: 5, endVerse: 23, displayText: "Galatians 5:22-23"),
                BiblePassagePointer(bookAbbr: "ISA", startChapter: 26, startVerse: 3, endChapter: 26, endVerse: 3, displayText: "Isaiah 26:3")
            ],
             interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Isaiah 26:3
                    text: "Peace is presented here both as a 'fruit'—something that grows organically within us through the Spirit's presence—and as a state maintained by keeping our minds focused steadfastly on God. It reminds us that inner peace is deeply connected to our spiritual posture and ongoing trust."
                )
            ],
           reflectionPrompt: "How can cultivating other fruits of the Spirit (love, joy, patience) contribute to a deeper experience of peace?",
        ),
    ],
),

  ReadingPlan(
    id: "rp_creation_care_7day",
    title: "Creation Care Challenge",
    description: "Explore our sacred call to be stewards of the Earth. This 7-day plan reflects on biblical mandates for environmental care and action.",
    category: "Topical / Creation",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_creation_care_7day.png", // Placeholder - Assuming you have an image asset
    isPremium: false,
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1, title: "The Earth is the Lord's",
            passages: [
                BiblePassagePointer(bookAbbr: "PSA", startChapter: 24, startVerse: 1, endChapter: 24, endVerse: 2, displayText: "Psalm 24:1-2"),
                BiblePassagePointer(bookAbbr: "GEN", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 1, displayText: "Genesis 1:1")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After both passages
                    text: "Starting with the understanding that the Earth isn't ultimately ours, but God's, changes everything. It shifts our perspective from one of entitlement to one of gratitude, from seeing ourselves as owners to seeing ourselves as responsible partners in caring for God's creation."
                )
            ],
            reflectionPrompt: "If the Earth and everything in it belongs to God, what responsibilities does this imply for us?",
        ),
        ReadingPlanDay(
            dayNumber: 2, title: "Dominion and Stewardship",
            passages: [
                BiblePassagePointer(bookAbbr: "GEN", startChapter: 1, startVerse: 26, endChapter: 1, endVerse: 28, displayText: "Genesis 1:26-28"),
                BiblePassagePointer(bookAbbr: "GEN", startChapter: 2, startVerse: 15, endChapter: 2, endVerse: 15, displayText: "Genesis 2:15")
            ],
             interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Genesis 2:15
                    text: "Placed side-by-side, these verses help clarify our role. 'Dominion' seems less about unchecked power and more like the caring responsibility of a gardener. The specific instruction to 'work' and 'take care of' the garden points towards active cultivation and protection, not passive ownership or exploitation."
                )
            ],
           reflectionPrompt: "What is the difference between 'dominion' as responsible stewardship versus exploitative domination of creation?",
        ),
        ReadingPlanDay(
            dayNumber: 3, title: "Creation Groans",
            passages: [BiblePassagePointer(bookAbbr: "ROM", startChapter: 8, startVerse: 19, endChapter: 8, endVerse: 23, displayText: "Romans 8:19-23")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Romans 8:19-23
                    text: "Paul uses such powerful, empathetic language here – 'groaning as in the pains of childbirth.' It gives creation a voice, suggesting its suffering under brokenness is real and deeply felt. This passage connects creation's longing for renewal with our own hope, inviting us to listen and respond with care."
                )
            ],
            reflectionPrompt: "In what ways do you see creation 'groaning' today? How does this motivate a desire for its renewal and our role in it?",
        ),
        ReadingPlanDay(
            dayNumber: 4, title: "Sabbath for the Land",
            passages: [BiblePassagePointer(bookAbbr: "LEV", startChapter: 25, startVerse: 1, endChapter: 25, endVerse: 7, displayText: "Leviticus 25:1-7")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Leviticus 25:1-7
                    text: "This idea of a Sabbath rest extending to the land itself is quite profound. It acknowledges that the Earth, like us, needs periods of recovery and renewal. It's a built-in limit on human exploitation, reminding us that sustainable rhythms, not constant productivity, are part of God's loving design for creation."
                )
            ],
            reflectionPrompt: "The concept of Sabbath extended to the land, allowing it to rest and recover. How can we apply principles of rest and sustainability to our environment today?",
        ),
        ReadingPlanDay(
            dayNumber: 5, title: "Wisdom from Creation",
            passages: [
                BiblePassagePointer(bookAbbr: "JOB", startChapter: 12, startVerse: 7, endChapter: 12, endVerse: 10, displayText: "Job 12:7-10"),
                BiblePassagePointer(bookAbbr: "PRO", startChapter: 6, startVerse: 6, endChapter: 6, endVerse: 8, displayText: "Proverbs 6:6-8")
            ],
             interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After both passages
                    text: "Scripture encourages us to look closely at the natural world not just as a resource, but as a source of wisdom and revelation. From the diligence of the ant to the unspoken testimony of the birds and fish, creation itself reflects aspects of God's character and design, inviting us to observe, listen, and learn."
                )
            ],
           reflectionPrompt: "What lessons can we learn about diligence, interconnectedness, or God's providence by observing the natural world?",
        ),
        ReadingPlanDay(
            dayNumber: 6, title: "Justice for the Earth and Poor",
            passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 24, startVerse: 4, endChapter: 24, endVerse: 6, displayText: "Isaiah 24:4-6")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Isaiah 24:4-6
                    text: "Isaiah draws a stark connection between breaking covenant—our relationship with God and ethical responsibilities—and the suffering of the land itself ('The earth mourns and withers'). It's a powerful reminder that environmental justice and social justice are often deeply linked; how we treat the planet frequently reflects how we treat its most vulnerable people."
                )
            ],
            reflectionPrompt: "How are environmental degradation and social injustice often linked? Who is most affected by environmental damage?",
        ),
        ReadingPlanDay(
            dayNumber: 7, title: "Hope for a Renewed Creation",
            passages: [
                BiblePassagePointer(bookAbbr: "REV", startChapter: 21, startVerse: 1, endChapter: 21, endVerse: 5, displayText: "Revelation 21:1-5"),
                BiblePassagePointer(bookAbbr: "ISA", startChapter: 11, startVerse: 6, endChapter: 11, endVerse: 9, displayText: "Isaiah 11:6-9")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After both passages
                    text: "These beautiful visions point towards God's ultimate goal: not abandoning the world, but renewing and restoring *all* things—a new heaven and a new earth where peace and harmony reign. This ultimate hope fuels our present efforts, reminding us that our work towards healing and caring for creation aligns with God's loving, redemptive purpose for the future."
                )
            ],
            reflectionPrompt: "Scripture offers a vision of a renewed heaven and earth. What is one practical step you can take this week to contribute to the healing and care of our planet?",
        ),
    ],
),

  // --- PREMIUM PLANS ---
  ReadingPlan(
    id: "rp_questioning_faith_10day",
    title: "Questioning Faith: Stories of Doubt & Discovery",
    description: "Explore biblical narratives of doubt, questioning, and wrestling with faith. This 10-day plan affirms that honest inquiry can lead to deeper understanding.",
    category: "Topical / Character Study",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_questioning_faith_10day.png", // Placeholder - Add your image path
    isPremium: true,
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1, title: "Job: The Cry of the Righteous Sufferer",
            passages: [
                BiblePassagePointer(bookAbbr: "JOB", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 11, displayText: "Job 3:1-11"),
                BiblePassagePointer(bookAbbr: "JOB", startChapter: 3, startVerse: 20, endChapter: 3, endVerse: 26, displayText: "Job 3:20-26")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Job 3:20-26
                    text: "Job doesn't hold back his anguish or his profound questions about life and suffering. His words are raw, almost uncomfortable. Yet, their inclusion in scripture offers a powerful validation: even our most painful cries and difficult questions have a place before God."
                )
            ],
            reflectionPrompt: "Job questions his suffering. Is it okay to voice our deepest pains and questions to God? Why or why not?"
        ),
        ReadingPlanDay(
            dayNumber: 2, title: "Job: Demanding Answers",
            passages: [BiblePassagePointer(bookAbbr: "JOB", startChapter: 23, startVerse: 1, endChapter: 23, endVerse: 9, displayText: "Job 23:1-9")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Job 23:1-9
                    text: "Job's longing to find God and 'lay his case before him' shows a faith that is active and engaged, not passive. He believes God *is* there, even when hidden, and wrestles for connection and clarity. It demonstrates that deep faith isn't afraid to engage directly, even demandingly."
                )
            ],
            reflectionPrompt: "Job wishes he could find God to plead his case. What does his raw honesty teach us about wrestling with faith?"
        ),
        ReadingPlanDay(
            dayNumber: 3, title: "Thomas: The Need for Evidence",
            passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 20, startVerse: 24, endChapter: 20, endVerse: 29, displayText: "John 20:24-29")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After John 20:24-29
                    text: "Jesus meets Thomas right in his place of doubt, offering the very evidence Thomas felt he needed. It's a grace-filled moment that affirms the value of honest seeking, while gently inviting towards a faith that can trust even beyond tangible proof."
                )
            ],
            reflectionPrompt: "Thomas needed to see to believe. How does Jesus respond to his doubt? Is there room for intellectual seeking in faith?"
        ),
        ReadingPlanDay(
            dayNumber: 4, title: "The Psalmist's Anguish (Psalm 77)",
            passages: [BiblePassagePointer(bookAbbr: "PSA", startChapter: 77, startVerse: 1, endChapter: 77, endVerse: 10, displayText: "Psalm 77:1-10")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Psalm 77:1-10
                    text: "The psalmist voices fears that echo through many hearts in difficult times: Has God forgotten? Is His love gone forever? Simply voicing these deep anxieties, bringing them out into the open before God, is often the necessary first step in navigating seasons of doubt."
                )
            ],
            reflectionPrompt: "The psalmist questions if God has forgotten or rejected him. How can remembering God's past actions help in times of present doubt?"
        ),
        ReadingPlanDay(
            dayNumber: 5, title: "Jeremiah: The Prophet's Complaint",
            passages: [
                BiblePassagePointer(bookAbbr: "JER", startChapter: 20, startVerse: 7, endChapter: 20, endVerse: 9, displayText: "Jeremiah 20:7-9"),
                BiblePassagePointer(bookAbbr: "JER", startChapter: 20, startVerse: 14, endChapter: 20, endVerse: 18, displayText: "Jeremiah 20:14-18")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Jeremiah 20:14-18
                    text: "Jeremiah's words swing dramatically between a burning commitment he feels compelled to follow and profound personal despair. His story powerfully illustrates that genuine faithfulness and deep internal struggle, even questioning one's calling, can often reside within the same heart."
                )
            ],
            reflectionPrompt: "Jeremiah feels deceived and overwhelmed by his calling. Can doubt and faithfulness coexist?"
        ),
        ReadingPlanDay(
            dayNumber: 6, title: "Asaph's Crisis of Faith (Psalm 73)",
            passages: [BiblePassagePointer(bookAbbr: "PSA", startChapter: 73, startVerse: 1, endChapter: 73, endVerse: 17, displayText: "Psalm 73:1-17 (Focus on v. 1-3, 12-14, 16-17)")],
            interspersedInsights: [
                 InterspersedInsight(
                    afterPassageIndex: 0, // After Psalm 73:1-17
                    text: "Asaph is brutally honest about his envy and how the apparent injustice he saw shook his faith ('I almost slipped'). His turning point wasn't an immediate answer, but a shift in perspective gained by entering 'the sanctuary of God.' It suggests that seeking a different, perhaps spiritual, viewpoint can reframe our understanding, even when difficult circumstances persist."
                )
            ],
            reflectionPrompt: "The psalmist doubts God's justice when seeing the wicked prosper. What helps shift his perspective?"
        ),
        ReadingPlanDay(
            dayNumber: 7, title: "John the Baptist: Doubts from Prison",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 11, startVerse: 2, endChapter: 11, endVerse: 6, displayText: "Matthew 11:2-6")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 11:2-6
                    text: "It's deeply humanizing that even John the Baptist, the powerful forerunner of Jesus, faced moments of uncertainty from his prison cell. Jesus responds not with rebuke, but by pointing to the evidence of His work ('the blind receive sight...'), gently encouraging John to hold onto the truth he proclaimed."
                )
            ],
            reflectionPrompt: "Even John the Baptist had moments of questioning. How does Jesus' answer affirm his ministry while addressing John's doubts?"
        ),
        ReadingPlanDay(
            dayNumber: 8, title: "The Father of the Afflicted Boy",
            passages: [BiblePassagePointer(bookAbbr: "MRK", startChapter: 9, startVerse: 21, endChapter: 9, endVerse: 24, displayText: "Mark 9:21-24")],
            interspersedInsights: [
                 InterspersedInsight(
                    afterPassageIndex: 0, // After Mark 9:21-24
                    text: "This father's desperate, honest cry, 'I believe; help my unbelief!' resonates with so many on the faith journey. It's a beautiful picture of faith not as absolute certainty, but as a dynamic process of trusting and reaching out, even amidst our acknowledged doubts and struggles."
                )
            ],
            reflectionPrompt: "'I believe; help my unbelief!' What does this honest prayer teach us about faith and doubt existing together?"
        ),
        ReadingPlanDay(
            dayNumber: 9, title: "Habakkuk's Dialogue with God",
            passages: [
                BiblePassagePointer(bookAbbr: "HAB", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 4, displayText: "Habakkuk 1:1-4"),
                BiblePassagePointer(bookAbbr: "HAB", startChapter: 1, startVerse: 12, endChapter: 1, endVerse: 13, displayText: "Habakkuk 1:12-13")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Habakkuk 1:12-13
                    text: "Habakkuk doesn't just lament; he directly confronts God with his confusion and challenges what seems unjust ('Why are you silent?'). The entire book unfolds as a genuine dialogue, demonstrating that wrestling with God and bringing our hardest questions honestly can be a vital pathway toward deeper trust, rather than a sign of faltering faith."
                )
            ],
            reflectionPrompt: "Habakkuk questions God's methods. How can honest dialogue, even if challenging, strengthen our relationship with the Divine?"
        ),
        ReadingPlanDay(
            dayNumber: 10, title: "Embracing Mystery",
            passages: [
                BiblePassagePointer(bookAbbr: "ECC", startChapter: 3, startVerse: 11, endChapter: 3, endVerse: 11, displayText: "Ecclesiastes 3:11"),
                BiblePassagePointer(bookAbbr: "1CO", startChapter: 13, startVerse: 12, endChapter: 13, endVerse: 12, displayText: "1 Corinthians 13:12")
            ],
             interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After 1 Corinthians 13:12
                    text: "Throughout scripture, there's an acknowledgement that we won't always have all the answers. Phrases like 'cannot fathom' (Ecclesiastes) and seeing 'in a mirror dimly' (Paul) invite us into a faith that makes space for mystery. It suggests that maturity in faith involves humbly accepting the limits of our understanding, while continuing to trust the One who sees and knows fully."
                )
            ],
           reflectionPrompt: "We may not have all the answers. How can embracing mystery and 'seeing in a mirror dimly' be a part of a mature faith?"
        ),
    ],
),
  ReadingPlan(
    id: "rp_beyond_borders_7day",
    title: "Beyond Borders: Welcoming the Stranger",
    description: "A 7-day deep dive into biblical teachings on hospitality, immigration, and our call to care for the 'stranger' or 'foreigner' among us.",
    category: "Topical / Social Justice",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_beyond_borders_7day.png", // Placeholder - Add your image path
    isPremium: true,
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1, title: "Love the Sojourner",
            passages: [BiblePassagePointer(bookAbbr: "DEU", startChapter: 10, startVerse: 17, endChapter: 10, endVerse: 19, displayText: "Deuteronomy 10:17-19")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Deuteronomy 10:17-19
                    text: "The reason given here for loving the sojourner is profound: because God does, and because the Israelites themselves knew what it felt like to be foreigners ('you yourselves were sojourners'). This roots the command not just in obedience, but in empathy born from shared experience and reflecting God's own compassionate character."
                )
            ],
            reflectionPrompt: "Why does God emphasize loving the sojourner, reminding Israel of their own past? How does this apply today?"
        ),
        ReadingPlanDay(
            dayNumber: 2, title: "Hospitality as a Virtue",
            passages: [
                BiblePassagePointer(bookAbbr: "HEB", startChapter: 13, startVerse: 1, endChapter: 13, endVerse: 2, displayText: "Hebrews 13:1-2"),
                BiblePassagePointer(bookAbbr: "ROM", startChapter: 12, startVerse: 13, endChapter: 12, endVerse: 13, displayText: "Romans 12:13")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Romans 12:13
                    text: "Hospitality is presented here as more than just basic politeness; it's an active 'practice' and a way to generously 'share' what we have. The hint about possibly entertaining 'angels unaware' adds a layer of sacred wonder, suggesting we might encounter the divine in unexpected ways when we open our lives to others."
                )
            ],
            reflectionPrompt: "What are the practical implications of 'practicing hospitality' in our modern context, especially towards those from different backgrounds?"
        ),
        ReadingPlanDay(
            dayNumber: 3, title: "One Law for All",
            passages: [
                BiblePassagePointer(bookAbbr: "LEV", startChapter: 24, startVerse: 22, endChapter: 24, endVerse: 22, displayText: "Leviticus 24:22"),
                BiblePassagePointer(bookAbbr: "NUM", startChapter: 15, startVerse: 15, endChapter: 15, endVerse: 16, displayText: "Numbers 15:15-16")
            ],
             interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Numbers 15:15-16
                    text: "The repetition of this command for 'the same standard' or 'one law' for both the native-born and the foreigner living among them is striking. It establishes a core principle of legal equality and inclusion, challenging any system or attitude that would treat newcomers as inherently lesser or lacking basic rights within the community."
                )
            ],
            reflectionPrompt: "The Law often stressed equal treatment for the native-born and the foreigner. How does this challenge discriminatory attitudes or policies today?"
        ),
        ReadingPlanDay(
            dayNumber: 4, title: "Jesus as a Refugee",
            passages: [
                BiblePassagePointer(bookAbbr: "MAT", startChapter: 2, startVerse: 13, endChapter: 2, endVerse: 15, displayText: "Matthew 2:13-15"),
                BiblePassagePointer(bookAbbr: "MAT", startChapter: 2, startVerse: 19, endChapter: 2, endVerse: 21, displayText: "Matthew 2:19-21")
            ],
             interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Matthew 2:19-21
                    text: "It’s a powerful and humbling reality that Jesus' own story includes the experience of being a refugee – his family fleeing violence and seeking safety across borders in Egypt. This aspect of his life deeply connects him to the plight of millions today, inviting us towards a response rooted in compassion and the recognition of shared human vulnerability."
                )
            ],
            reflectionPrompt: "Reflecting on Jesus' own experience as a refugee, how might this shape our compassion and response to those fleeing persecution today?"
        ),
        ReadingPlanDay(
            dayNumber: 5, title: "Welcoming the 'Least of These'",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 25, startVerse: 34, endChapter: 25, endVerse: 40, displayText: "Matthew 25:34-40 (focus on 'I was a stranger and you welcomed me')")],
            interspersedInsights: [
                 InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 25:34-40
                    text: "Jesus makes the connection incredibly direct and personal: welcoming the stranger *is* welcoming Him. This passage elevates acts of hospitality and inclusion beyond mere social kindness; they become profound encounters with Christ himself, present in the person needing welcome and care."
                )
            ],
           reflectionPrompt: "How is welcoming the stranger directly linked to serving Christ himself, according to this passage?"
        ),
        ReadingPlanDay(
            dayNumber: 6, title: "Ruth: An Immigrant's Story",
            passages: [BiblePassagePointer(bookAbbr: "RUT", startChapter: 2, startVerse: 8, endChapter: 2, endVerse: 12, displayText: "Ruth 2:8-12")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Ruth 2:8-12
                    text: "Boaz's interaction with Ruth, a Moabite woman in Israelite territory, goes far beyond simple tolerance. He actively ensures her safety, provides for her sustenance, acknowledges her character, and blesses her journey. His actions model a proactive, dignifying welcome that facilitates integration and offers genuine support to a newcomer."
                )
            ],
            reflectionPrompt: "Boaz showed kindness and provision to Ruth, a Moabite foreigner. What can we learn from his example about integrating and supporting newcomers?"
        ),
        ReadingPlanDay(
            dayNumber: 7, title: "The Inclusive Vision of God's People",
            passages: [
                BiblePassagePointer(bookAbbr: "ISA", startChapter: 56, startVerse: 3, endChapter: 56, endVerse: 8, displayText: "Isaiah 56:3-8"),
                BiblePassagePointer(bookAbbr: "GAL", startChapter: 3, startVerse: 28, endChapter: 3, endVerse: 28, displayText: "Galatians 3:28")
            ],
             interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1, // After Galatians 3:28
                    text: "From Isaiah's explicit welcome to foreigners joining God's people to Paul's radical declaration that in Christ 'there is neither Jew nor Gentile,' scripture consistently points towards a community defined by faith, not borders or ethnicity. This expansive vision challenges us to actively build communities that reflect God's embrace, breaking down barriers that divide."
                )
            ],
           reflectionPrompt: "How do these passages paint a picture of God's community as one that transcends national, ethnic, and social barriers? What is our role in building such a community?"
        ),
    ],
),
  ReadingPlan(
    id: "rp_beatitudes_reimagined_8day",
    title: "Reimagining The Beatitudes: Blessings for Today",
    description: "An 8-day exploration of Jesus' Beatitudes from the Sermon on the Mount, applying their counter-cultural wisdom to modern life and societal challenges.",
    category: "Gospels / Sermon on the Mount",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_beatitudes_reimagined_8day.png", // Placeholder - Add your image path
    isPremium: true,
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1, title: "Blessed are the Poor in Spirit",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 3, endChapter: 5, endVerse: 3, displayText: "Matthew 5:3")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 5:3
                    text: "In a culture often celebrating relentless self-reliance, Jesus begins by blessing those who recognize their deep need. This 'poverty of spirit' isn't about material lack, but an inner openness and humility—the very posture that allows us to receive the gifts and presence of the 'kingdom'."
                )
            ],
            reflectionPrompt: "What does it mean to be 'poor in spirit' in a world that values self-sufficiency? How does recognizing our need for God/Goodness open us to the 'kingdom of heaven' within and among us?"
        ),
        ReadingPlanDay(
            dayNumber: 2, title: "Blessed are Those Who Mourn",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 4, endChapter: 5, endVerse: 4, displayText: "Matthew 5:4")],
             interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 5:4
                    text: "This blessing invites us to resist the pressure to always appear strong or quickly 'get over' sadness. Allowing ourselves to genuinely mourn—our personal losses, the world's brokenness—creates space for authentic comfort and often fuels the deep empathy needed for compassionate action."
                )
            ],
           reflectionPrompt: "How can allowing ourselves to truly mourn personal and societal losses lead to genuine comfort and inspire compassionate action?"
        ),
        ReadingPlanDay(
            dayNumber: 3, title: "Blessed are the Meek",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 5, endChapter: 5, endVerse: 5, displayText: "Matthew 5:5")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 5:5
                    text: "Often misunderstood as weakness, 'meekness' in the biblical sense suggests a gentle strength, a power held with restraint and humility. In a world prizing dominance, Jesus proposes that this quiet confidence finds its true, secure place—'inheriting the earth' not through force, but through groundedness and right relationship."
                )
            ],
            reflectionPrompt: "Meekness isn't weakness, but power under control. In a world that often rewards aggression, how can meekness (gentle strength, humility) lead to 'inheriting the earth' or finding our true place?"
        ),
        ReadingPlanDay(
            dayNumber: 4, title: "Blessed are Those Who Hunger for Righteousness",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 6, endChapter: 5, endVerse: 6, displayText: "Matthew 5:6")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 5:6
                    text: "This isn't just a polite wish for things to be better; it's described as a deep, driving 'hunger and thirst' for justice, fairness, and right relationships in the world. Jesus blesses this passionate, gut-level longing, promising that such deep desire for goodness ultimately leads to profound fulfillment and satisfaction."
                )
            ],
            reflectionPrompt: "What does it mean to hunger and thirst for 'righteousness' (justice, fairness, right-relationships) today? How can this deep desire lead to fulfillment and positive change?"
        ),
        ReadingPlanDay(
            dayNumber: 5, title: "Blessed are the Merciful",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 7, endChapter: 5, endVerse: 7, displayText: "Matthew 5:7")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 5:7
                    text: "Mercy involves seeing beyond faults and failures to the shared humanity beneath. This blessing highlights a beautiful spiritual dynamic: the act of extending compassion and forgiveness often softens our own hearts, making us more open and able to receive the mercy we ourselves need, from others and from God."
                )
            ],
            reflectionPrompt: "In what areas of your life or in society is mercy most needed? How does extending mercy to others open us to receiving it more fully?"
        ),
        ReadingPlanDay(
            dayNumber: 6, title: "Blessed are the Pure in Heart",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 8, endChapter: 5, endVerse: 8, displayText: "Matthew 5:8")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 5:8
                    text: "Purity of heart suggests an inner alignment—integrity, sincerity, an undivided devotion where our intentions and actions aim for goodness. Jesus links this inner clarity and authenticity directly to a profound ability to perceive the divine ('see God') woven into the fabric of life and relationships."
                )
            ],
            reflectionPrompt: "Purity of heart implies integrity and undivided devotion to good. How can cultivating inner clarity and sincere motives allow us to 'see God' in ourselves, others, and the world?"
        ),
        ReadingPlanDay(
            dayNumber: 7, title: "Blessed are the Peacemakers",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 9, endChapter: 5, endVerse: 9, displayText: "Matthew 5:9")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 5:9
                    text: "Notice Jesus blesses the peace*makers*, not just the peace*keepers*. This implies active work—mending brokenness, building bridges, fostering reconciliation, and addressing the roots of conflict. This challenging, creative effort, Jesus says, deeply reflects the restorative nature of God, marking peacemakers as God's own children."
                )
            ],
            reflectionPrompt: "What does it mean to be a 'peacemaker' (not just a peacekeeper) in our relationships, communities, and world? How are they recognized as 'children of God'?"
        ),
        ReadingPlanDay(
            dayNumber: 8, title: "Blessed are the Persecuted for Righteousness",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 5, startVerse: 10, endChapter: 5, endVerse: 12, displayText: "Matthew 5:10-12")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0, // After Matthew 5:10-12
                    text: "This final Beatitude realistically acknowledges that living out these values—standing for justice, truth, and peace—can sometimes provoke resistance or opposition. Yet, Jesus reframes this potential hardship not as failure, but as a blessing—a sign of deep alignment with God's kingdom values and participation in a long, honorable tradition of prophetic witness."
                )
            ],
            reflectionPrompt: "Standing for justice and truth can sometimes lead to opposition. How can we find blessing and maintain joy even when facing challenges for doing what is right?"
        ),
    ],
),

// Reading Plan: Luke - The Inclusive Gospel
// A 7-day journey through Luke's Gospel, highlighting Jesus' radical welcome
// for the poor, marginalized, women, and outsiders. Explore parables of
// compassion and justice.

ReadingPlan(
    id: "rp_luke_inclusive_gospel_7day",
    title: "Luke: The Inclusive Gospel",
    description: "Journey through Luke's Gospel, highlighting Jesus' radical welcome for the poor, marginalized, women, and outsiders. Explore parables of compassion and justice. (7 days)",
    category: "Gospels / Life of Jesus",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_luke_inclusive_gospel_7day.png", // Placeholder - Add your image path
    isPremium: false, // Or true, depending on your app's model
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1,
            title: "Mary's Song: Good News for the Lowly",
            passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 1, startVerse: 46, endChapter: 1, endVerse: 55, displayText: "Luke 1:46-55 (The Magnificat)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Mary's powerful song sets the stage for Luke's Gospel. It celebrates a God who notices the humble, lifts up the lowly, and challenges oppressive power structures. It's a radical vision of hope from the margins, reminding us that God's good news often starts where we least expect it."
                )
            ],
            reflectionPrompt: "Mary sings about God bringing down the powerful and lifting up the humble. Where do you see this kind of 'great reversal' needed in the world or in your own life today?"
        ),
        ReadingPlanDay(
            dayNumber: 2,
            title: "Jesus' Mission: Good News to the Poor",
            passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 4, startVerse: 16, endChapter: 4, endVerse: 21, displayText: "Luke 4:16-21")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "In his hometown synagogue, Jesus announces his mission by quoting Isaiah. He explicitly aligns himself with bringing good news to the poor, freedom for the oppressed, and sight for the blind. This defines his ministry from the start—one centered on liberation, healing, and justice."
                )
            ],
            reflectionPrompt: "Jesus declared 'good news to the poor' as central to his purpose. What does 'good news' look like for those struggling economically or socially in our communities?"
        ),
        ReadingPlanDay(
            dayNumber: 3,
            title: "Calling the Unlikely",
            passages: [
                // Focus on calling fishermen, ordinary people
                BiblePassagePointer(bookAbbr: "LUK", startChapter: 5, startVerse: 1, endChapter: 5, endVerse: 11, displayText: "Luke 5:1-11"),
                // Focus on calling Levi, a tax collector (seen as a sinner/outsider)
                BiblePassagePointer(bookAbbr: "LUK", startChapter: 5, startVerse: 27, endChapter: 5, endVerse: 32, displayText: "Luke 5:27-32")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Jesus doesn't call the religious elite or the obviously 'qualified'. He calls ordinary fishermen and even a tax collector—someone viewed as a collaborator and sinner. His statement, 'I have not come to call the righteous, but sinners to repentance,' radically redefines who belongs in God's kingdom."
                )
            ],
            reflectionPrompt: "Jesus intentionally sought out those considered 'sinners' or outsiders by the religious establishment. Who might be the 'tax collectors' or 'sinners' our society marginalizes today, and how are we called to engage with them?"
        ),
        ReadingPlanDay(
            dayNumber: 4,
            title: "Compassion Beyond Boundaries",
            passages: [
                // Healing a Centurion's servant (a Gentile, Roman soldier)
                BiblePassagePointer(bookAbbr: "LUK", startChapter: 7, startVerse: 1, endChapter: 7, endVerse: 10, displayText: "Luke 7:1-10"),
                // Raising a widow's son (showing compassion for grief and social vulnerability)
                BiblePassagePointer(bookAbbr: "LUK", startChapter: 7, startVerse: 11, endChapter: 7, endVerse: 17, displayText: "Luke 7:11-17")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Here, Jesus extends healing and compassion across significant social divides—to a Roman centurion (an outsider) and a grieving widow (vulnerable in that society). His actions demonstrate that God's care and power are not limited by ethnicity, social status, or circumstance."
                )
            ],
            reflectionPrompt: "Jesus showed compassion to a Roman soldier and a grieving widow, crossing social barriers. What barriers (cultural, political, social) might prevent us from showing compassion today, and how can we overcome them?"
        ),
        ReadingPlanDay(
            dayNumber: 5,
            title: "Who Is My Neighbor? The Good Samaritan",
            passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 10, startVerse: 25, endChapter: 10, endVerse: 37, displayText: "Luke 10:25-37")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This famous parable flips the question 'Who is my neighbor?' to 'Who *acted* like a neighbor?' The hero is a Samaritan—despised by the religious establishment—who showed mercy. Jesus challenges us to define neighborliness not by affiliation, but by compassionate action, especially towards those different from us."
                )
            ],
            reflectionPrompt: "The Good Samaritan showed mercy when the religious figures passed by. What does this parable teach us about the difference between religious observance and genuine compassion? Who is the unexpected 'neighbor' in your life?"
        ),
        ReadingPlanDay(
            dayNumber: 6,
            title: "Lost and Found: Extravagant Grace",
            passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 15, startVerse: 11, endChapter: 15, endVerse: 32, displayText: "Luke 15:11-32 (The Prodigal Son)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This story reveals the heart of a God who waits with open arms, ready to celebrate the return of the lost with extravagant grace. It challenges both the rebellious 'younger son' and the resentful 'older son,' inviting everyone into the Father's embrace, regardless of their past or their self-righteousness."
                )
            ],
            reflectionPrompt: "The father's love extends to both the prodigal son and the resentful older brother. Which character do you relate to more in this story, and what does the father's response teach you about God's inclusive grace?"
        ),
        ReadingPlanDay(
            dayNumber: 7,
            title: "Seeking and Saving the Lost: Zacchaeus",
            passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 19, startVerse: 1, endChapter: 19, endVerse: 10, displayText: "Luke 19:1-10")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Jesus seeks out Zacchaeus, a wealthy but despised chief tax collector, initiating relationship despite public disapproval. This encounter leads to Zacchaeus's radical transformation and restitution. It's a beautiful picture of how being seen and welcomed by Jesus can inspire profound change and restoration."
                )
            ],
            reflectionPrompt: "Jesus initiated the encounter with Zacchaeus, leading to transformation. How can actively seeking out and welcoming those often judged or excluded lead to positive change in their lives and ours?"
        ),
    ]
),

// Reading Plan: Isaiah - Justice, Hope, and Comfort
// Explore key passages from Isaiah, hearing his powerful calls for social justice,
// his breathtaking visions of peace, and his comforting words of hope for a broken people.

ReadingPlan(
    id: "rp_isaiah_justice_hope_7day",
    title: "Isaiah: Justice, Hope, and Comfort",
    description: "Explore key passages from Isaiah, hearing his powerful calls for social justice, his breathtaking visions of peace, and his comforting words of hope for a broken people. (7 days)",
    category: "Prophets / Old Testament",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_isaiah_justice_hope_7day.png", // Placeholder - Add your image path
    isPremium: false, // Or true, depending on your app's model
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1,
            title: "True Worship: Justice, Not Ritual",
            passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 1, startVerse: 11, endChapter: 1, endVerse: 17, displayText: "Isaiah 1:11-17")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Isaiah starts with a powerful critique: God isn't impressed by religious rituals if they aren't accompanied by justice and compassion. The call is clear: 'Learn to do right; seek justice. Defend the oppressed. Take up the cause of the fatherless; plead the case of the widow.' True worship involves caring for the vulnerable."
                )
            ],
            reflectionPrompt: "God prioritizes justice and defending the oppressed over religious sacrifices here. What does 'seeking justice' look like in our daily lives and communities today?"
        ),
        ReadingPlanDay(
            dayNumber: 2,
            title: "A Song of Justice Denied",
            passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 5, startVerse: 1, endChapter: 5, endVerse: 7, displayText: "Isaiah 5:1-7 (Song of the Vineyard)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This poignant song uses the image of a vineyard carefully tended by God, which then yields only bad fruit. The 'bad fruit' is identified as bloodshed and distress instead of justice and righteousness. It's a lament over how God's hopes for a just society have been disappointed by injustice and oppression."
                )
            ],
            reflectionPrompt: "God looked for justice but saw bloodshed, for righteousness but heard cries of distress. Where do you see a similar gap between the hope for justice and the reality of suffering in the world?"
        ),
         ReadingPlanDay(
            dayNumber: 3,
            title: "Vision of Lasting Peace",
            passages: [
                // Swords into plowshares
                BiblePassagePointer(bookAbbr: "ISA", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 5, displayText: "Isaiah 2:1-5"),
                // Harmony in creation
                BiblePassagePointer(bookAbbr: "ISA", startChapter: 11, startVerse: 1, endChapter: 11, endVerse: 9, displayText: "Isaiah 11:1-9")
            ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Amidst critique, Isaiah offers breathtaking visions of a future transformed by God's peace. Nations converting weapons into farming tools, and natural enemies living in harmony—these images paint a powerful picture of shalom, a world restored to wholeness, justice, and right relationship."
                )
            ],
            reflectionPrompt: "Isaiah envisions a world where weapons become tools for life and harmony replaces conflict. What does this vision of peace inspire in you? What small steps can contribute to such a future?"
        ),
        ReadingPlanDay(
            dayNumber: 4,
            title: "Comfort, Comfort My People",
            passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 40, startVerse: 1, endChapter: 40, endVerse: 11, displayText: "Isaiah 40:1-11")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This passage marks a shift, offering words of profound comfort and hope to a people feeling defeated and exiled. God speaks tenderly, promising restoration and gentle care, like a shepherd gathering lambs. It reminds us that even in difficult times, God's presence offers deep reassurance and strength."
                )
            ],
            reflectionPrompt: "The call here is to 'speak tenderly' and offer comfort. Who in your life or community might need words of comfort and reassurance today? How can you be a voice of hope?"
        ),
        ReadingPlanDay(
            dayNumber: 5,
            title: "An Invitation to Life",
            passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 55, startVerse: 1, endChapter: 55, endVerse: 7, displayText: "Isaiah 55:1-7")],
            interspersedInsights: [
                 InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This beautiful invitation calls everyone who is thirsty and hungry to come freely and receive life-giving nourishment from God. It emphasizes that God's grace and sustenance are available to all, regardless of their ability to 'pay.' It's an open door to relationship and abundant life."
                )
            ],
            reflectionPrompt: "God offers satisfaction 'without money and without cost.' What things do we often chase after for fulfillment that ultimately don't satisfy? How can we accept God's free invitation to true life?"
        ),
        ReadingPlanDay(
            dayNumber: 6,
            title: "The Suffering Servant",
            passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 53, startVerse: 3, endChapter: 53, endVerse: 7, displayText: "Isaiah 53:3-7")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This passage describes a figure who suffers unjustly, bearing the pain and wrongdoing of others to bring about healing and peace. While Christians see this fulfilled in Jesus, the image itself speaks powerfully about redemptive suffering and finding meaning even in hardship borne for the sake of others."
                )
            ],
            reflectionPrompt: "The servant suffers silently for the healing of others. How does this image challenge our understanding of strength, suffering, and bringing about positive change?"
        ),
        ReadingPlanDay(
            dayNumber: 7,
            title: "A New Heaven and a New Earth",
            passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 65, startVerse: 17, endChapter: 65, endVerse: 25, displayText: "Isaiah 65:17-25")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Isaiah concludes with a stunning vision of complete renewal—a new creation where weeping, distress, and injustice are no more. People will enjoy the fruits of their labor, live long lives in peace, and experience deep harmony with God and each other. This ultimate hope fuels our present work for justice and restoration."
                )
            ],
            reflectionPrompt: "Isaiah paints a picture of God's ultimate future: a world of joy, justice, peace, and meaningful work. How does this vision of hope motivate you to live differently today?"
        ),
    ]
),
// Reading Plan: James - Faith That Works
// Discover the practical wisdom of James, exploring how genuine faith translates
// into tangible actions like controlling speech, caring for the needy, and seeking
// wisdom in trials.

ReadingPlan(
    id: "rp_james_faith_works_5day",
    title: "James: Faith That Works",
    description: "Discover the practical wisdom of James, exploring how genuine faith translates into tangible actions like controlling speech, caring for the needy, and seeking wisdom in trials. (5 days)",
    category: "Epistles / Christian Living",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_james_faith_works_5day.png", // Placeholder - Add your image path
    isPremium: false, // Or true, depending on your app's model
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1,
            title: "Wisdom Through Trials",
            passages: [BiblePassagePointer(bookAbbr: "JAS", startChapter: 1, startVerse: 2, endChapter: 1, endVerse: 8, displayText: "James 1:2-8")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "James doesn't shy away from life's difficulties. He suggests that facing trials can actually develop perseverance and maturity. Notice the immediate link to wisdom – when facing challenges, we're invited to ask generously for guidance, trusting we'll receive it without judgment."
                )
            ],
            reflectionPrompt: "James encourages finding joy even in trials because they build perseverance. How can reframing challenges as opportunities for growth change your perspective? When facing difficulty, how easy or hard is it for you to ask for wisdom?"
        ),
        ReadingPlanDay(
            dayNumber: 2,
            title: "Listen More, Speak Less",
            passages: [BiblePassagePointer(bookAbbr: "JAS", startChapter: 1, startVerse: 19, endChapter: 1, endVerse: 21, displayText: "James 1:19-21"), BiblePassagePointer(bookAbbr: "JAS", startChapter: 3, startVerse: 2, endChapter: 3, endVerse: 12, displayText: "James 3:2-12 (Focus on the power of the tongue)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "James places great emphasis on the power of our words. Being 'quick to listen, slow to speak and slow to become angry' is presented as practical wisdom. Chapter 3 uses vivid imagery (like a ship's rudder or a small spark) to show how much influence our tongue has, for good or ill."
                )
            ],
            reflectionPrompt: "Consider your communication patterns. In what situations could you practice being 'quicker to listen' and 'slower to speak'? How have you seen words build up or tear down relationships?"
        ),
        ReadingPlanDay(
            dayNumber: 3,
            title: "Faith and Deeds: Beyond Words",
            passages: [BiblePassagePointer(bookAbbr: "JAS", startChapter: 1, startVerse: 22, endChapter: 1, endVerse: 27, displayText: "James 1:22-27 (Doers of the word)"), BiblePassagePointer(bookAbbr: "JAS", startChapter: 2, startVerse: 14, endChapter: 2, endVerse: 17, displayText: "James 2:14-17 (Faith without deeds is dead)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "This is a core theme for James: genuine faith isn't just about hearing or believing; it's about doing. He contrasts merely listening to the word with actively putting it into practice. True religion, he argues, involves tangible actions like caring for orphans and widows and keeping oneself ethically grounded."
                )
            ],
            reflectionPrompt: "James challenges us to be 'doers of the word, and not hearers only.' What is one specific way you can put your beliefs or values into practice this week, particularly in caring for someone in need?"
        ),
        ReadingPlanDay(
            dayNumber: 4,
            title: "No Partiality: Treating Everyone Equally",
            passages: [BiblePassagePointer(bookAbbr: "JAS", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 9, displayText: "James 2:1-9")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "James strongly condemns favoritism, especially based on wealth or status. He argues that showing partiality violates the core command to 'love your neighbor as yourself.' Genuine faith requires treating all people with equal dignity and respect, regardless of their appearance or social standing."
                )
            ],
            reflectionPrompt: "Think about your community or social circles. Are there subtle (or not-so-subtle) ways that favoritism based on wealth, status, or appearance shows up? How can you actively practice treating everyone with equal honor?"
        ),
        ReadingPlanDay(
            dayNumber: 5,
            title: "Patience, Prayer, and Healing",
            passages: [BiblePassagePointer(bookAbbr: "JAS", startChapter: 5, startVerse: 7, endChapter: 5, endVerse: 11, displayText: "James 5:7-11 (Patience in suffering)"), BiblePassagePointer(bookAbbr: "JAS", startChapter: 5, startVerse: 13, endChapter: 5, endVerse: 16, displayText: "James 5:13-16 (Prayer for the sick)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Concluding his letter, James circles back to perseverance, urging patience like a farmer waiting for rain. He then emphasizes the power of prayer in all circumstances—in trouble, happiness, or sickness. He encourages praying for one another, linking it to healing and restoration within the community."
                )
            ],
            reflectionPrompt: "James encourages patience in hardship and persistent prayer. What situation currently requires patience from you? How can you incorporate prayer, both for yourself and others, more intentionally into your daily rhythm?"
        ),
    ]
),
// Reading Plan: Ecclesiastes - Finding Meaning Under the Sun
// Wrestle alongside the ancient Teacher with life's big questions about meaning,
// work, wisdom, and mortality, discovering invitations to find joy in the present moment.

ReadingPlan(
    id: "rp_ecclesiastes_meaning_5day",
    title: "Ecclesiastes: Finding Meaning Under the Sun",
    description: "Wrestle alongside the ancient Teacher with life's big questions about meaning, work, wisdom, and mortality, discovering invitations to find joy in the present moment. (5 days)",
    category: "Wisdom Literature / Old Testament",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_ecclesiastes_meaning_5day.png", // Placeholder - Add your image path
    isPremium: true, // Often considered a more challenging/mature text
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1,
            title: "Everything is Meaningless?",
            passages: [BiblePassagePointer(bookAbbr: "ECC", startChapter: 1, startVerse: 2, endChapter: 1, endVerse: 11, displayText: "Ecclesiastes 1:2-11")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "The Teacher starts with a stark, almost jarring observation: 'Meaningless! Meaningless! Utterly meaningless! Everything is meaningless.' This isn't necessarily despair, but a radically honest assessment of life's cycles and the limits of human effort when viewed 'under the sun.' Acknowledging this apparent futility can be a surprising first step toward finding deeper meaning."
                )
            ],
            reflectionPrompt: "The Teacher observes the endless cycles of nature and human striving, calling much of it 'meaningless.' What activities or pursuits in your own life sometimes feel repetitive or ultimately unsatisfying? Is it freeing or unsettling to acknowledge this?"
        ),
        ReadingPlanDay(
            dayNumber: 2,
            title: "The Limits of Pleasure and Toil",
            passages: [BiblePassagePointer(bookAbbr: "ECC", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 11, displayText: "Ecclesiastes 2:1-11")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Here, the Teacher explores seeking meaning through pleasure, possessions, and great achievements. While these things offer temporary enjoyment, he concludes they too are 'meaningless, a chasing after the wind.' It's a caution against believing that external success or constant entertainment can provide lasting satisfaction."
                )
            ],
            reflectionPrompt: "The Teacher pursued pleasure, wealth, and accomplishment but found them ultimately empty. What does our culture tell us will bring happiness? How does the Teacher's experience challenge those assumptions?"
        ),
        ReadingPlanDay(
            dayNumber: 3,
            title: "A Time for Everything",
            passages: [BiblePassagePointer(bookAbbr: "ECC", startChapter: 3, startVerse: 1, endChapter: 3, endVerse: 15, displayText: "Ecclesiastes 3:1-15")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This famous passage reflects on the rhythms and seasons of life—times for joy and sorrow, work and rest, birth and death. There's an invitation here to accept life's complexities and uncertainties, recognizing God has 'made everything beautiful in its time' even if we can't fully grasp the big picture. Finding meaning involves embracing the present season."
                )
            ],
            reflectionPrompt: "Ecclesiastes 3 lists contrasting seasons of life ('a time to weep and a time to laugh...'). Which 'season' are you currently in? How can accepting the rhythm of life, with its ups and downs, help you find meaning in the present moment?"
        ),
        ReadingPlanDay(
            dayNumber: 4,
            title: "Oppression, Toil, and Companionship",
            passages: [BiblePassagePointer(bookAbbr: "ECC", startChapter: 4, startVerse: 1, endChapter: 4, endVerse: 12, displayText: "Ecclesiastes 4:1-12")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "The Teacher observes the pain of oppression and the emptiness of competitive, isolated toil. In contrast, he highlights the profound value of companionship: 'Two are better than one... If either of them falls down, one can help the other up.' Meaning is often found not in solitary striving, but in mutual support and relationship."
                )
            ],
            reflectionPrompt: "The Teacher contrasts the pain of isolation and oppression with the strength found in companionship ('A cord of three strands is not quickly broken'). Where do you see the value of community and mutual support in your life or in society?"
        ),
        ReadingPlanDay(
            dayNumber: 5,
            title: "Enjoy Life's Gifts & Remember Your Creator",
            passages: [
                BiblePassagePointer(bookAbbr: "ECC", startChapter: 9, startVerse: 7, endChapter: 9, endVerse: 10, displayText: "Ecclesiastes 9:7-10"), // Enjoy simple gifts
                BiblePassagePointer(bookAbbr: "ECC", startChapter: 12, startVerse: 1, endChapter: 12, endVerse: 1, displayText: "Ecclesiastes 12:1"), // Remember Creator in youth
                BiblePassagePointer(bookAbbr: "ECC", startChapter: 12, startVerse: 13, endChapter: 12, endVerse: 14, displayText: "Ecclesiastes 12:13-14") // Fear God and keep commandments
                ],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 2, // After all passages for the day
                    text: "After wrestling with life's big questions, the Teacher arrives at some core conclusions: Find joy in the simple, everyday gifts of life—food, drink, work, relationships—as gifts from God. And ultimately, orient your life towards reverence for God and responsible living ('Fear God and keep his commandments'). Meaning is found in both present enjoyment and ultimate accountability."
                )
            ],
            reflectionPrompt: "The Teacher advises enjoying simple daily pleasures (food, work, relationships) while also remembering our Creator and ultimate responsibility. How can you cultivate both simple joys and a sense of deeper purpose in your life this week?"
        ),
    ]
),
// Reading Plan: Parables - Stories that Turn the World Upside Down
// Dive into Jesus' most famous stories, exploring how these simple narratives
// challenge conventional wisdom about power, wealth, religion, and who's 'in' or 'out'.

ReadingPlan(
    id: "rp_parables_upside_down_7day",
    title: "Parables: Stories that Turn the World Upside Down",
    description: "Dive into Jesus' most famous stories, exploring how these simple narratives challenge conventional wisdom about power, wealth, religion, and who's 'in' or 'out'. (7 days)",
    category: "Gospels / Teachings of Jesus",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_parables_upside_down_7day.png", // Placeholder - Add your image path
    isPremium: true, // Parables often benefit from deeper reflection
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1,
            title: "The Sower: Different Soils, Different Responses",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 13, startVerse: 1, endChapter: 13, endVerse: 9, displayText: "Matthew 13:1-9"), BiblePassagePointer(bookAbbr: "MAT", startChapter: 13, startVerse: 18, endChapter: 13, endVerse: 23, displayText: "Matthew 13:18-23 (Explanation)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Jesus begins his parables by talking about how people *receive* his message. The focus isn't just on the sower or the seed, but on the condition of the 'soil'—our hearts and minds. It challenges us to consider: what prevents the message of goodness and truth from taking root and flourishing in our own lives?"
                )
            ],
            reflectionPrompt: "Jesus describes different 'soils' that receive the seed differently (path, rocky ground, thorns, good soil). Which soil best describes your heart's receptiveness right now? What 'weeds' (worries, distractions) might be choking out growth?"
        ),
        ReadingPlanDay(
            dayNumber: 2,
            title: "Mustard Seed & Yeast: Small Beginnings, Big Impact",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 13, startVerse: 31, endChapter: 13, endVerse: 33, displayText: "Matthew 13:31-33")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "In a world often impressed by size and spectacle, Jesus uses images of tiny seeds and hidden yeast to describe God's kingdom. It suggests that significant transformation often starts small, subtly, and grows unexpectedly. It's an encouragement not to despise small acts of kindness, justice, or faith."
                )
            ],
            reflectionPrompt: "The kingdom of heaven starts like a tiny mustard seed or hidden yeast. Where have you seen small, seemingly insignificant things lead to surprisingly large outcomes, either personally or in the world? How does this encourage your own small efforts?"
        ),
        ReadingPlanDay(
            dayNumber: 3,
            title: "Workers in the Vineyard: Undeserved Generosity",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 20, startVerse: 1, endChapter: 20, endVerse: 16, displayText: "Matthew 20:1-16")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This parable often rubs our sense of fairness the wrong way! Workers hired late receive the same pay as those who worked all day. It radically challenges a system based purely on merit or earning, highlighting God's surprising generosity and grace, which isn't limited by our human calculations of what's 'deserved'."
                )
            ],
            reflectionPrompt: "The landowner's generosity seems unfair to the workers who started early. Does God's grace sometimes feel 'unfair' to you? How does this parable challenge your ideas about earning, deserving, and generosity?"
        ),
        ReadingPlanDay(
            dayNumber: 4,
            title: "The Pharisee and the Tax Collector: Humility vs. Pride",
            passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 18, startVerse: 9, endChapter: 18, endVerse: 14, displayText: "Luke 18:9-14")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Jesus contrasts two approaches to God: the self-congratulatory religious leader and the humble, repentant tax collector. Surprisingly, it's the one who acknowledges his need ('God, have mercy on me, a sinner') who goes home justified. This story turns religious expectations upside down, valuing honest humility over outward displays of piety."
                )
            ],
            reflectionPrompt: "The Pharisee listed his accomplishments, while the tax collector simply asked for mercy. Which prayer posture feels more natural to you? How can self-awareness and humility open us up to connection with the Divine?"
        ),
        ReadingPlanDay(
            dayNumber: 5,
            title: "The Unforgiving Servant: Receiving and Extending Mercy",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 18, startVerse: 21, endChapter: 18, endVerse: 35, displayText: "Matthew 18:21-35")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This challenging parable links the immense forgiveness we receive from God with our responsibility to forgive others. The servant, forgiven an unpayable debt, refuses to forgive a small debt owed to him. It starkly illustrates that truly experiencing and internalizing grace should transform how we treat others."
                )
            ],
            reflectionPrompt: "The servant was forgiven a huge debt but wouldn't forgive a small one. How does reflecting on the mercy or grace you've received impact your willingness to forgive others? What makes forgiveness difficult, and what helps?"
        ),
        ReadingPlanDay(
            dayNumber: 6,
            title: "The Talents/Minas: Using Our Gifts",
            // Using Matthew's version which emphasizes varying gifts
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 25, startVerse: 14, endChapter: 25, endVerse: 30, displayText: "Matthew 25:14-30")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This parable isn't just about money; it's about stewarding whatever gifts, resources, or opportunities we've been given. The servants who use and multiply what they have are commended, while the one who buries his gift out of fear is rebuked. It challenges passivity and encourages faithful, active use of our potential for good."
                )
            ],
            reflectionPrompt: "The servants were entrusted with different amounts ('talents'). What unique gifts, skills, or resources have you been entrusted with? How can you actively use or invest them for positive impact, rather than 'burying' them out of fear or complacency?"
        ),
        ReadingPlanDay(
            dayNumber: 7,
            title: "The Wedding Banquet: An Unexpected Invitation",
            passages: [BiblePassagePointer(bookAbbr: "MAT", startChapter: 22, startVerse: 1, endChapter: 22, endVerse: 14, displayText: "Matthew 22:1-14")],
            // Luke's version (Luke 14:15-24) is also relevant, emphasizing outreach to the poor/marginalized
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "When the invited guests make excuses and refuse to come to the king's banquet, the invitation is extended unexpectedly to anyone found in the streets, 'both good and bad.' This parable dramatically illustrates God's wide, inclusive welcome, often extended to those the 'insiders' might overlook or deem unworthy."
                )
            ],
            reflectionPrompt: "The original guests declined the invitation, so it was extended to unexpected people. Who are the 'unexpected guests' God might be inviting into community or relationship today? How can we ensure our communities are truly welcoming to all?"
        ),
    ]
),
// Reading Plan: Women of Faith - Stories of Strength & Influence
// Rediscover the stories of pivotal women in scripture—leaders, prophets,
// disciples, and pioneers—whose faith and actions shaped biblical history
// and inspire us today.

ReadingPlan(
    id: "rp_women_of_faith_7day",
    title: "Women of Faith: Stories of Strength & Influence",
    description: "Rediscover the stories of pivotal women in scripture—leaders, prophets, disciples, and pioneers—whose faith and actions shaped biblical history and inspire us today. (7 days)",
    category: "Topical / Character Study",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_women_of_faith_7day.png", // Placeholder - Add your image path
    isPremium: true, // Highlighting these stories can be a premium feature
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1,
            title: "Deborah: Prophetess and Judge",
            // Focus on her leadership and confidence in God's direction
            passages: [BiblePassagePointer(bookAbbr: "JDG", startChapter: 4, startVerse: 4, endChapter: 4, endVerse: 10, displayText: "Judges 4:4-10")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "In a predominantly patriarchal society, Deborah stands out as a recognized leader—a prophetess judging Israel. She confidently gives military command based on God's direction, demonstrating remarkable authority and faith. Her story challenges assumptions about gender roles and highlights God's use of diverse leaders."
                )
            ],
            reflectionPrompt: "Deborah led Israel with wisdom and courage. What does her example teach us about recognizing and affirming leadership gifts in unexpected people or places today?"
        ),
        ReadingPlanDay(
            dayNumber: 2,
            title: "Ruth: Loyalty and Resilience",
            // Focus on her commitment to Naomi and finding favor through character
            passages: [BiblePassagePointer(bookAbbr: "RUT", startChapter: 1, startVerse: 15, endChapter: 1, endVerse: 18, displayText: "Ruth 1:15-18"), BiblePassagePointer(bookAbbr: "RUT", startChapter: 2, startVerse: 10, endChapter: 2, endVerse: 12, displayText: "Ruth 2:10-12")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Ruth, a Moabite widow, demonstrates extraordinary loyalty and courage by choosing to stay with her mother-in-law, Naomi, and move to a foreign land. Her character—her kindness and hard work—shines through, earning her respect and provision. Her story is one of resilience, faithfulness in relationships, and finding hope in difficult circumstances."
                )
            ],
            reflectionPrompt: "Ruth showed profound loyalty and took risks for her relationship with Naomi. What does her story teach us about commitment, resilience, and the power of character in navigating challenging life transitions?"
        ),
        ReadingPlanDay(
            dayNumber: 3,
            title: "Esther: Courage for Such a Time as This",
            // Focus on her bravery in approaching the king to save her people
            passages: [BiblePassagePointer(bookAbbr: "EST", startChapter: 4, startVerse: 13, endChapter: 4, endVerse: 16, displayText: "Esther 4:13-16"), BiblePassagePointer(bookAbbr: "EST", startChapter: 5, startVerse: 1, endChapter: 5, endVerse: 3, displayText: "Esther 5:1-3")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Esther, facing a terrifying situation, chooses courage over safety. Encouraged by Mordecai's famous words, 'And who knows but that you have come to your royal position for such a time as this?', she risks her life to advocate for her people. Her story is a powerful example of using one's position and influence for justice, even at great personal cost."
                )
            ],
            reflectionPrompt: "Esther used her position of influence courageously. What positions of influence (formal or informal) do you have? How might you be called to use your voice or resources 'for such a time as this' to advocate for others?"
        ),
        ReadingPlanDay(
            dayNumber: 4,
            title: "Mary, Mother of Jesus: Faith and Surrender",
            // Focus on her acceptance of God's call
            passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 1, startVerse: 26, endChapter: 1, endVerse: 38, displayText: "Luke 1:26-38 (The Annunciation)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Mary's response to the angel's astonishing announcement is one of profound faith and surrender: 'I am the Lord’s servant... May your word to me be fulfilled.' Despite the personal risks and social stigma, she trusts God's plan. Her 'yes' demonstrates incredible courage and willingness to participate in God's work in the world."
                )
            ],
            reflectionPrompt: "Mary said 'yes' to a difficult and world-changing calling. What does her response teach you about faith, trust, and willingness to participate in something bigger than yourself, even when it involves uncertainty or sacrifice?"
        ),
        ReadingPlanDay(
            dayNumber: 5,
            title: "Mary Magdalene: Witness to the Resurrection",
            // Focus on her devotion and being the first witness
            passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 20, startVerse: 1, endChapter: 20, endVerse: 2, displayText: "John 20:1-2"), BiblePassagePointer(bookAbbr: "JHN", startChapter: 20, startVerse: 11, endChapter: 20, endVerse: 18, displayText: "John 20:11-18")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Mary Magdalene's devotion is evident as she goes to the tomb early on Sunday morning. Significantly, the resurrected Jesus appears first to her and commissions her to be the first messenger—the 'apostle to the apostles'—to announce the resurrection. This highlights her importance and challenges cultural norms that often dismissed women's testimony."
                )
            ],
            reflectionPrompt: "Jesus entrusted Mary Magdalene with the crucial news of his resurrection. What does it mean that the first witness and messenger of the central event of Christian faith was a woman? How does this affirm the value of women's voices and experiences?"
        ),
        ReadingPlanDay(
            dayNumber: 6,
            title: "Lydia: Businesswoman and Church Leader",
            // Focus on her hospitality and role in the early church
            passages: [BiblePassagePointer(bookAbbr: "ACT", startChapter: 16, startVerse: 13, endChapter: 16, endVerse: 15, displayText: "Acts 16:13-15"), BiblePassagePointer(bookAbbr: "ACT", startChapter: 16, startVerse: 40, endChapter: 16, endVerse: 40, displayText: "Acts 16:40")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Lydia is described as a successful businesswoman ('dealer in purple cloth') and a worshiper of God. After hearing Paul's message, she and her household respond, and she immediately offers hospitality, opening her home to become a center for the new church in Philippi. Her story showcases female entrepreneurship, spiritual openness, and practical leadership in the early church."
                )
            ],
            reflectionPrompt: "Lydia used her resources (her home, her business background) to support the fledgling church community. How can we use our unique skills, resources, and spheres of influence to foster community and support spiritual growth?"
        ),
        ReadingPlanDay(
            dayNumber: 7,
            title: "Priscilla: Teacher and Ministry Partner",
            // Focus on her partnership with Aquila and teaching Apollos
            passages: [BiblePassagePointer(bookAbbr: "ACT", startChapter: 18, startVerse: 1, endChapter: 18, endVerse: 3, displayText: "Acts 18:1-3"), BiblePassagePointer(bookAbbr: "ACT", startChapter: 18, startVerse: 24, endChapter: 18, endVerse: 26, displayText: "Acts 18:24-26")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Priscilla is consistently mentioned alongside her husband, Aquila, suggesting a true partnership in life and ministry. Together, they work with Paul and notably take Apollos aside to explain 'the way of God more adequately.' This highlights Priscilla's theological understanding and her active role in teaching and mentoring within the early church community."
                )
            ],
            reflectionPrompt: "Priscilla worked alongside her husband and others in ministry and teaching. What does her example show us about partnership, collaboration, and the importance of women's contributions in teaching and theological understanding?"
        ),
    ]
),
// Reading Plan: Rest & Rhythm - Rediscovering Sabbath
// Explore the biblical concept of Sabbath not just as a rule, but as a gift—
// an invitation to rest, delight, cease striving, and trust in God's provision
// in a hurried world.

ReadingPlan(
    id: "rp_rest_rhythm_sabbath_7day",
    title: "Rest & Rhythm: Rediscovering Sabbath",
    description: "Explore the biblical concept of Sabbath not just as a rule, but as a gift—an invitation to rest, delight, cease striving, and trust in God's provision in a hurried world. (7 days)",
    category: "Topical / Spiritual Practices",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_rest_rhythm_sabbath_7day.png", // Placeholder - Add your image path
    isPremium: false, // Or true, adjust as needed
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1,
            title: "Creation's Rhythm: God Rests",
            passages: [BiblePassagePointer(bookAbbr: "GEN", startChapter: 2, startVerse: 1, endChapter: 2, endVerse: 3, displayText: "Genesis 2:1-3")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Sabbath isn't an afterthought; it's woven into the very fabric of creation. God's own rest after the work of creation models a rhythm of work and rest, blessing the seventh day and making it holy. This suggests rest isn't laziness, but a sacred part of the intended order of things."
                )
            ],
            reflectionPrompt: "God rested after creating. What does it mean for you that rest is built into the creation story itself? How does this challenge a culture that often values constant productivity?"
        ),
        ReadingPlanDay(
            dayNumber: 2,
            title: "Remember and Keep Holy: The Commandment",
            passages: [BiblePassagePointer(bookAbbr: "EXO", startChapter: 20, startVerse: 8, endChapter: 20, endVerse: 11, displayText: "Exodus 20:8-11")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "The Sabbath command is grounded in God's own rest in creation. It's a call to remember and set aside time, ceasing from labor. Significantly, the command extends to *everyone* in the household—family, servants, even animals—and the foreigner. It's a practice of communal rest and liberation."
                )
            ],
            reflectionPrompt: "The commandment includes rest for servants, foreigners, and animals. How does this communal aspect of Sabbath challenge individualistic approaches to rest? What does it mean to 'keep it holy'?"
        ),
        ReadingPlanDay(
            dayNumber: 3,
            title: "Sabbath as Liberation and Trust",
            // Deuteronomy's reason: remembering liberation from Egypt
            passages: [BiblePassagePointer(bookAbbr: "DEU", startChapter: 5, startVerse: 12, endChapter: 5, endVerse: 15, displayText: "Deuteronomy 5:12-15")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Deuteronomy gives a different reason for Sabbath: remembering liberation from slavery in Egypt. Here, Sabbath is an act of social justice and trust—remembering freedom and trusting God's provision, rather than relentless striving born from fear or greed, like the slave-drivers of Egypt."
                )
            ],
            reflectionPrompt: "Remembering liberation from slavery is linked to Sabbath rest. What 'slaveries' (like busyness, anxiety, consumerism) might Sabbath help liberate us from today? How is choosing rest an act of trust?"
        ),
        ReadingPlanDay(
            dayNumber: 4,
            title: "Sabbath for Human Well-being",
            passages: [BiblePassagePointer(bookAbbr: "MRK", startChapter: 2, startVerse: 23, endChapter: 2, endVerse: 28, displayText: "Mark 2:23-28")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Jesus challenges rigid interpretations of Sabbath rules that neglect human need. His statement, 'The Sabbath was made for humankind, and not humankind for the Sabbath,' reframes the practice. It's meant to be life-giving, a gift for restoration and well-being, not a burdensome obligation."
                )
            ],
            reflectionPrompt: "Jesus declared the Sabbath was made for people, not the other way around. Are there 'rules' (spoken or unspoken) about productivity or busyness in your life that hinder genuine rest and well-being? How can you prioritize rest as a gift?"
        ),
        ReadingPlanDay(
            dayNumber: 5,
            title: "Sabbath as Delight and Honor",
            passages: [BiblePassagePointer(bookAbbr: "ISA", startChapter: 58, startVerse: 13, endChapter: 58, endVerse: 14, displayText: "Isaiah 58:13-14")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Isaiah portrays Sabbath not just as stopping work, but as a 'delight' and a way to 'honor' the Lord by refraining from our usual pursuits and ways. It suggests Sabbath involves a shift in focus—turning from self-interest towards finding joy and connection with the Divine."
                )
            ],
            reflectionPrompt: "Isaiah calls Sabbath a 'delight.' What activities or non-activities genuinely bring you rest, joy, and a sense of delight? How can you intentionally incorporate these into a regular rhythm of rest?"
        ),
        ReadingPlanDay(
            dayNumber: 6,
            title: "Jesus: Lord of the Sabbath",
            // Healing on the Sabbath
            passages: [BiblePassagePointer(bookAbbr: "LUK", startChapter: 13, startVerse: 10, endChapter: 13, endVerse: 17, displayText: "Luke 13:10-17")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "Jesus frequently performed healings on the Sabbath, often drawing criticism from religious leaders. His actions underscore that acts of compassion, liberation, and restoration are perfectly aligned with the spirit of the Sabbath. It's a day for making things whole, reflecting God's restorative work."
                )
            ],
            reflectionPrompt: "Jesus saw healing and liberation as appropriate Sabbath activities. What does it mean to do 'good' on the Sabbath? What restorative or life-giving activities could be part of your Sabbath practice?"
        ),
        ReadingPlanDay(
            dayNumber: 7,
            title: "Entering God's Rest",
            passages: [BiblePassagePointer(bookAbbr: "HEB", startChapter: 4, startVerse: 9, endChapter: 4, endVerse: 11, displayText: "Hebrews 4:9-11")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "The writer of Hebrews speaks of a 'Sabbath-rest' that remains for God's people—a deeper, ongoing rest found in trusting God's finished work, rather than striving in our own efforts. While weekly Sabbath is a practice, it points towards this ultimate state of peace and reliance on God."
                )
            ],
            reflectionPrompt: "Hebrews speaks of entering a deeper 'Sabbath-rest.' Beyond a weekly day off, how can you cultivate a spirit of rest and trust in God throughout your week, ceasing from anxious striving?"
        ),
    ]
),
// Reading Plan: The Art of Lament - Praying Our Pain
// Discover the biblical practice of lament—bringing our honest grief, anger,
// confusion, and questions directly to God—as a powerful and necessary
// expression of faith.

ReadingPlan(
    id: "rp_art_of_lament_5day",
    title: "The Art of Lament: Praying Our Pain",
    description: "Discover the biblical practice of lament—bringing our honest grief, anger, confusion, and questions directly to God—as a powerful and necessary expression of faith. (5 days)",
    category: "Topical / Prayer & Spirituality",
    headerImageAssetPath: "assets/images/reading_plan_headers/rp_art_of_lament_5day.png", // Placeholder - Add your image path
    isPremium: true, // Dealing with difficult emotions can be a premium topic
    dailyReadings: [
        ReadingPlanDay(
            dayNumber: 1,
            title: "Crying Out: Honest Anguish (Psalm 13)",
            passages: [BiblePassagePointer(bookAbbr: "PSA", startChapter: 13, startVerse: 1, endChapter: 13, endVerse: 6, displayText: "Psalm 13")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 0,
                    text: "This Psalm moves rawly through the stages of lament: direct address ('How long, Lord?'), honest complaint ('Will you forget me forever?'), asking for help ('Look on me and answer'), and finally, a turn towards trust ('But I trust in your unfailing love'). It models bringing our full, unfiltered pain directly to God."
                )
            ],
            reflectionPrompt: "The psalmist asks 'How long?' four times, expressing deep frustration. What 'How long?' questions are on your heart today? Is it comfortable or uncomfortable for you to voice such raw feelings in prayer?"
        ),
        ReadingPlanDay(
            dayNumber: 2,
            title: "Questioning God: Job's Protest",
            passages: [BiblePassagePointer(bookAbbr: "JOB", startChapter: 10, startVerse: 1, endChapter: 10, endVerse: 7, displayText: "Job 10:1-7"), BiblePassagePointer(bookAbbr: "JOB", startChapter: 10, startVerse: 18, endChapter: 10, endVerse: 22, displayText: "Job 10:18-22")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Job, in his immense suffering, doesn't hold back from questioning God's actions and fairness ('Why then did you bring me out of the womb?'). His lament includes confusion and even accusation. The inclusion of Job's intense questioning in scripture validates that wrestling honestly with God, even in anger or doubt, is part of a genuine faith journey."
                )
            ],
            reflectionPrompt: "Job questions why he was born and challenges God directly. Have you ever felt angry or confused with God? What does Job's example teach us about the place of hard questions within faith?"
        ),
        ReadingPlanDay(
            dayNumber: 3,
            title: "Communal Lament: Weeping Together (Lamentations)",
            // Focus on shared grief and devastation
            passages: [BiblePassagePointer(bookAbbr: "LAM", startChapter: 1, startVerse: 1, endChapter: 1, endVerse: 5, displayText: "Lamentations 1:1-5"), BiblePassagePointer(bookAbbr: "LAM", startChapter: 2, startVerse: 11, endChapter: 2, endVerse: 13, displayText: "Lamentations 2:11-13")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "The book of Lamentations is a collection of communal grief poems mourning the destruction of Jerusalem. It gives voice to collective trauma, loss, and devastation. It reminds us that lament isn't just personal; it's also a way for communities to process shared pain and cry out for restoration together."
                )
            ],
            reflectionPrompt: "Lamentations grieves the suffering of an entire city. What communal losses or societal injustices cause you grief today? How can we practice communal lament and support each other in shared sorrow?"
        ),
        ReadingPlanDay(
            dayNumber: 4,
            title: "Jesus Laments: Grief and Compassion",
            passages: [BiblePassagePointer(bookAbbr: "JHN", startChapter: 11, startVerse: 32, endChapter: 11, endVerse: 36, displayText: "John 11:32-36 (Jesus weeps at Lazarus' tomb)"), BiblePassagePointer(bookAbbr: "LUK", startChapter: 19, startVerse: 41, endChapter: 19, endVerse: 44, displayText: "Luke 19:41-44 (Jesus weeps over Jerusalem)")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 1,
                    text: "Even Jesus expressed deep grief. He wept out of compassion at the tomb of his friend Lazarus, sharing in human sorrow. He also wept over Jerusalem, lamenting its failure to recognize the path to peace. His tears validate our own grief and show that lament flows from a heart connected to the pain of others."
                )
            ],
            reflectionPrompt: "Jesus wept in response to personal loss and societal blindness. What does his example teach us about the connection between grief, compassion, and a desire for justice or peace?"
        ),
        ReadingPlanDay(
            dayNumber: 5,
            title: "From Lament to Hope: Holding Both",
            // Passages showing a turn within lament
            passages: [BiblePassagePointer(bookAbbr: "LAM", startChapter: 3, startVerse: 19, endChapter: 3, endVerse: 26, displayText: "Lamentations 3:19-26"), BiblePassagePointer(bookAbbr: "PSA", startChapter: 42, startVerse: 5, endChapter: 42, endVerse: 6, displayText: "Psalm 42:5-6a"), BiblePassagePointer(bookAbbr: "PSA", startChapter: 42, startVerse: 11, endChapter: 42, endVerse: 11, displayText: "Psalm 42:11")],
            interspersedInsights: [
                InterspersedInsight(
                    afterPassageIndex: 2, // After all passages
                    text: "Biblical lament rarely stays only in despair. Often, even amidst raw pain, there's a turn—a recalling of God's past faithfulness ('Great is your faithfulness'), a questioning of one's own soul ('Why, my soul, are you downcast?'), and a determined choice to place hope in God. Lament holds space for both honest pain and resilient hope."
                )
            ],
            reflectionPrompt: "Many laments move from complaint towards recalling hope or trust. How can acknowledging our pain honestly actually help us move towards hope? Is it possible to hold both grief and hope at the same time?"
        ),
    ]
),


];
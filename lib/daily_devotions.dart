// lib/daily_devotionals.dart

import 'dart:math';

class Devotional {
  final String title;
  final String coreMessage;
  final String scriptureFocus;
  final String scriptureReference;
  final String reflection;
  final String prayerDeclaration;

  const Devotional({
    required this.title,
    required this.coreMessage,
    required this.scriptureFocus,
    required this.scriptureReference,
    required this.reflection,
    required this.prayerDeclaration,
  });
}

final List<Devotional> allDevotionals = [
  const Devotional(
    title: "Step Into Your Blessing",
    coreMessage: "You are on the verge of something amazing! God has already lined up opportunities, good breaks, and divine connections for you.",
    scriptureFocus: "For I know the plans I have for you,” declares the LORD, “plans to prosper you and not to harm you, plans to give you hope and a future.",
    scriptureReference: "Jeremiah 29:11 NIV",
    reflection: "Every sunrise brings a new opportunity to witness God's favor in your life. Don't be discouraged by past setbacks or current challenges. See them not as roadblocks, but as setups for a greater comeback! God is working behind the scenes, turning things to your advantage.\nYou might not see it all now, but trust that His plan is unfolding. Keep your faith stirred up, speak words of victory, and get ready to step into the fullness of the blessings He has in store for you. Expect good things; expect His unmerited favor to show up in surprising ways today!",
    prayerDeclaration: "Father, thank You for Your incredible plans for my life. I declare that I am stepping into new levels of favor and blessing. I am strong, I am equipped, and I am ready for all the good things You have for me today. Amen!",
  ),
  const Devotional(
    title: "Shake Off the Negative",
    coreMessage: "Don't let negative thoughts or the opinions of others hold you back. You are approved by God, and that's all that matters!",
    scriptureFocus: "Do not be conformed to this world, but be transformed by the renewal of your mind, that by testing you may discern what is the will of God, what is good and acceptable and perfect.",
    scriptureReference: "Romans 12:2 ESV",
    reflection: "Life will always try to throw negativity your way – doubts, fears, critical voices. But you have the power to choose what you allow to take root in your spirit. It's time to shake off any discouragement, any word curses spoken over you, any feeling of inadequacy.\nRenew your mind with what God says about you. You are chosen, you are valuable, you are more than a conqueror. When you start agreeing with God, those negative chains will break. Focus on His promises, speak His truth over your situation, and watch how your atmosphere begins to change.",
    prayerDeclaration: "Lord, I choose to reject every negative thought and word that doesn't align with Your truth. I declare that I am confident, I am capable, and I am covered by Your grace. My mind is renewed, and my spirit is strong in You. Amen!",
  ),
  const Devotional(
    title: "Expect the Unexpected Favor",
    coreMessage: "God wants to do exceedingly, abundantly above all you can ask or think. Get ready for unexpected favor and sudden breakthroughs!",
    scriptureFocus: "Now to him who is able to do far more abundantly than all that we ask or think, according to the power at work within us...",
    scriptureReference: "Ephesians 3:20 ESV",
    reflection: "Sometimes, we limit God by our own expectations. We think in terms of the natural, but our God is supernatural! He’s not confined by what seems logical or possible to us. He delights in surprising His children with blessings that we didn't see coming.\nToday, enlarge your vision. Dare to believe for those dreams that seem too big, those problems that seem too difficult. God has ways to make things happen that you've never thought of. Stay in an attitude of expectancy. His power is at work within you, preparing you for extraordinary things.",
    prayerDeclaration: "God, I thank You that You are a God of abundance and surprise! I open my heart to receive Your unexpected favor today. I believe for breakthroughs in every area of my life. I declare that something good is coming my way. Amen!",
  ),
  const Devotional(
    title: "Your Time is Coming",
    coreMessage: "Don't be discouraged by delays. God's timing is perfect, and your appointed time for breakthrough is on its way!",
    scriptureFocus: "He has made everything beautiful in its time. He has also set eternity in the human heart; yet no one can fathom what God has done from beginning to end.",
    scriptureReference: "Ecclesiastes 3:11 NIV",
    reflection: "It's easy to get frustrated when things don't happen as quickly as we'd like. But remember, God operates on a different timeline than we do. He sees the bigger picture, and He knows the perfect moment for every promise to manifest in your life.\nInstead of focusing on the 'when,' focus on staying prepared and faithful. Keep doing what you know is right, keep believing His word, and keep thanking Him in advance. Your season of fulfillment is approaching. Trust the process, and know that He is working all things together for your good.",
    prayerDeclaration: "Father, I trust Your timing. I believe that You are working all things for my good, and my breakthrough is on the way. Help me to wait with patience and joyful expectation. I declare that my time of blessing is near. Amen!",
  ),
  const Devotional(
    title: "Unleash Your Potential",
    coreMessage: "God has deposited incredible gifts and talents within you. It's time to step out and use them for His glory!",
    scriptureFocus: "For we are God’s handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.",
    scriptureReference: "Ephesians 2:10 NIV",
    reflection: "You are not an accident. You were uniquely designed by God for a specific purpose. Don't underestimate what He has placed inside of you. Maybe you feel like your talents are small or insignificant, but in God's hands, they can have a massive impact.\nDon't let fear or insecurity hold you back any longer. Take that step of faith. Start that project, share that idea, use that gift. As you begin to move, God will meet you there, opening doors and providing the resources you need. Your potential is limitless when you partner with Him.",
    prayerDeclaration: "Lord, thank You for the unique gifts You've given me. I choose to step out in faith and use them to honor You. I declare that I am equipped, empowered, and ready to fulfill my divine potential. Amen!",
  ),
  const Devotional(
    title: "Peace in the Storm",
    coreMessage: "Even when chaos surrounds you, God's peace can guard your heart and mind. Anchor yourself in Him.",
    scriptureFocus: "And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.",
    scriptureReference: "Philippians 4:7 NIV",
    reflection: "Life is full of storms – unexpected challenges, pressures, and uncertainties. It's easy to get overwhelmed and anxious. But Jesus promised us a peace that the world cannot give, a peace that surpasses our understanding.\nThis peace isn't the absence of trouble; it's the presence of God in the midst of trouble. When you feel the winds of adversity blowing, turn your focus to Him. Cast your cares upon Him, because He cares for you. Let His word be your anchor, and allow His Spirit to fill you with a calm that defies the circumstances.",
    prayerDeclaration: "Father, I thank You for Your peace that surpasses all understanding. When storms come, I will fix my eyes on You. I declare that my heart is calm, and my mind is stayed on You. Your peace rules in my life. Amen!",
  ),
  const Devotional(
    title: "New Mercies Every Morning",
    coreMessage: "Yesterday's failures are gone. Today is a fresh start, filled with God's new mercies and grace.",
    scriptureFocus: "The steadfast love of the LORD never ceases; his mercies never come to an end; they are new every morning; great is your faithfulness.",
    scriptureReference: "Lamentations 3:22-23 ESV",
    reflection: "Don't let the weight of past mistakes or regrets drag you down today. God's mercies are not a one-time offer; they are renewed every single morning! That means you get a clean slate, a fresh opportunity to walk in His goodness and His purpose.\nReceive His forgiveness, extend forgiveness to yourself and others, and step into this new day with a light heart. His faithfulness is great, and He is for you. He's not holding your past against you; He's inviting you into a brighter future. Embrace this gift of a new beginning.",
    prayerDeclaration: "Lord, thank You for Your unfailing love and new mercies that greet me this morning. I release the past and embrace the fresh start You've given me. I declare that today is filled with Your grace, goodness, and opportunities. Amen!",
  ),
  const Devotional(
    title: "The Power of Your Words",
    coreMessage: "Your words have creative power. Speak life, victory, and blessings over your situation and future.",
    scriptureFocus: "Death and life are in the power of the tongue, and those who love it will eat its fruits.",
    scriptureReference: "Proverbs 18:21 ESV",
    reflection: "God created the universe by speaking, and He has given us a similar power in our words. What are you speaking over your life, your family, your finances, your health? Are your words aligning with God's promises or with the negativity of the world?\nChoose to speak words of faith, hope, and abundance. Even if you don't see it yet, declare what God says is true. Call forth those things that are not as though they were. As you consistently speak His truth, you'll begin to see your circumstances shift and align with your declarations.",
    prayerDeclaration: "Father, I recognize the power of my words. Today, I choose to speak life, health, victory, and abundance. I declare Your promises over every area of my life. My words are building a future filled with Your blessings. Amen!",
  ),
  const Devotional(
    title: "You Are Not Alone",
    coreMessage: "In every trial, in every joy, God is with you. You never have to face life's challenges by yourself.",
    scriptureFocus: "Be strong and courageous. Do not fear or be in dread of them, for it is the LORD your God who goes with you. He will not leave you or forsake you.",
    scriptureReference: "Deuteronomy 31:6 ESV",
    reflection: "Sometimes life can feel isolating, especially when you're going through difficult times. But the truth is, God has promised to be with you always. He's not a distant observer; He's an ever-present help in times of need.\nLean on His strength when you feel weak. Draw comfort from His presence when you feel afraid or lonely. He understands what you're going through, and He has the wisdom and power to bring you through it. You are deeply loved and constantly accompanied by the King of Kings.",
    prayerDeclaration: "Lord, thank You for Your constant presence in my life. I know I am never alone. I draw strength from You, and I trust that You are guiding me through every situation. I declare Your peace and presence over my day. Amen!",
  ),
  const Devotional(
    title: "Favor Ain't Fair!",
    coreMessage: "God's favor on your life can open doors that no man can shut and bring blessings you didn't earn or deserve. Expect it!",
    scriptureFocus: "For you bless the righteous, O LORD; you cover him with favor as with a shield.",
    scriptureReference: "Psalm 5:12 ESV",
    reflection: "God's favor isn't about being perfect; it's about His goodness shining on you. It's that divine advantage, that extra something that makes things work out for you, even when the odds are stacked against you. This favor can cause people to go out of their way to help you, to promote you, to bless you.\nDon't be shy about asking for God's favor. Believe that you are a candidate for His extraordinary blessings. Walk with an attitude of expectancy, knowing that God wants to show off His goodness in your life in ways that will leave others amazed.",
    prayerDeclaration: "Father, thank You for Your unmerited favor! I declare that Your favor is a shield around me. It opens the right doors, brings the right opportunities, and causes me to prosper in all I do. I expect Your favor to show up in big ways today! Amen!",
  ),
  const Devotional(
    title: "Breakthrough is Coming",
    coreMessage: "Don't give up on the edge of your miracle. Your breakthrough is closer than you think!",
    scriptureFocus: "Let us not become weary in doing good, for at the proper time we will reap a harvest if we do not give up.",
    scriptureReference: "Galatians 6:9 NIV",
    reflection: "Many times, we're tempted to quit just before the victory. The battle might be intense, the waiting might be long, but God is faithful to His promises. He sees your perseverance, your faith, your prayers.\nThat opposition you're facing? It's often a sign that your breakthrough is imminent. The enemy wouldn't be fighting you so hard if he didn't know something good was about to happen. Hold on, stay strong in faith, and keep declaring God's word. Your harvest time is approaching!",
    prayerDeclaration: "Lord, I refuse to grow weary. I stand firm in faith, knowing that my breakthrough is on its way. I declare that I will reap a harvest of blessing because I do not give up! Thank You for Your faithfulness. Amen!",
  ),
  const Devotional(
    title: "Dare to Dream Big",
    coreMessage: "God has placed big dreams in your heart for a reason. Don't shrink back; dare to believe for the impossible!",
    scriptureFocus: "For nothing will be impossible with God.",
    scriptureReference: "Luke 1:37 ESV",
    reflection: "What are those secret dreams and desires God has whispered to your spirit? Sometimes they seem so big, so out of reach, that we're tempted to dismiss them. But if God put that dream in you, He also has the plan and the power to bring it to pass.\nDon't let fear, doubt, or the opinions of others talk you out of what God has shown you. Enlarge your vision. Start taking small steps towards that dream, trusting that God will provide the resources and open the doors as you move forward. With Him, all things are possible!",
    prayerDeclaration: "Father, I thank You for the dreams You've placed in my heart. I choose to believe for the impossible with You. I declare that I am stepping out in faith towards my God-given destiny, and You are making a way where there seems to be no way. Amen!",
  ),
  const Devotional(
    title: "Rise Above It",
    coreMessage: "You are called to live at a higher level. Don't get bogged down by petty offenses or distractions. Rise above!",
    scriptureFocus: "Set your minds on things that are above, not on things that are on earth.",
    scriptureReference: "Colossians 3:2 ESV",
    reflection: "The enemy loves to use small things – annoyances, offenses, worries – to steal your peace and distract you from your purpose. But you don't have to take that bait. You can choose to operate from a higher perspective, a heavenly perspective.\nWhen irritations come, when people try to pull you into drama, make a quality decision to rise above it. Focus on what truly matters: your relationship with God, your calling, and the eternal. Keep your thoughts on things that are pure, lovely, and praiseworthy. This is how you maintain your altitude.",
    prayerDeclaration: "Lord, help me to keep my mind set on things above. I refuse to be distracted by negativity or petty issues. I declare that I am rising above every challenge and living in Your peace and victory. Amen!",
  ),
  const Devotional(
    title: "The Blessing of Obedience",
    coreMessage: "When you obey God, even in the small things, you position yourself for His greatest blessings and open doors.",
    scriptureFocus: "If you are willing and obedient, you shall eat the good of the land;",
    scriptureReference: "Isaiah 1:19 ESV",
    reflection: "Sometimes we think obedience is about strict rules and missing out. But in God's kingdom, obedience is the pathway to blessing, freedom, and abundance. It's about trusting that God's ways are higher and better than our own.\nIs there something God has been prompting you to do? Maybe it's to forgive someone, to step out in a new area, to be more generous. Don't delay. Your obedience, even when it feels difficult or doesn't make sense, unlocks a new level of God's favor and provision in your life. He honors those who honor Him.",
    prayerDeclaration: "Father, I choose to be willing and obedient to Your voice. I trust that Your commands lead to blessing. I declare that as I walk in obedience, I will experience the good of the land You have promised. Amen!",
  ),
  const Devotional(
    title: "Overflowing Gratitude",
    coreMessage: "A grateful heart is a magnet for miracles. Count your blessings, and watch God multiply them!",
    scriptureFocus: "Give thanks in all circumstances; for this is the will of God in Christ Jesus for you.",
    scriptureReference: "1 Thessalonians 5:18 ESV",
    reflection: "It's easy to focus on what's wrong, what we don't have, or what's not working out. But when we shift our focus to gratitude, something powerful happens. Gratitude opens our eyes to the goodness of God that's already surrounding us, and it creates an atmosphere for Him to do even more.\nTake time today to consciously thank God for His blessings, big and small. Thank Him for your life, your health, your family, His provision. As you cultivate a lifestyle of thanksgiving, you'll find your joy increasing and your perspective changing. You'll start to see His hand in everything.",
    prayerDeclaration: "Lord, I am so grateful for all You have done and all You are doing in my life. My heart overflows with thanksgiving. I declare that I will give thanks in all circumstances, knowing this opens the door for more of Your goodness. Amen!",
  ),
  const Devotional(
    title: "Strength for Today",
    coreMessage: "God will give you the strength you need for whatever you face today. You are more capable than you think because He is with you.",
    scriptureFocus: "I can do all things through him who strengthens me.",
    scriptureReference: "Philippians 4:13 ESV",
    reflection: "Are you facing a challenge that feels overwhelming? Do you feel like you don't have what it takes? Remember this promise: you are not operating in your own strength alone. The same power that raised Christ from the dead lives in you!\nGod doesn't always remove the obstacles, but He always provides the strength to overcome them. Tap into His power. When you feel weak, that's when His strength is made perfect in you. Don't focus on your limitations; focus on His limitless power. You can do this!",
    prayerDeclaration: "Father, thank You for Your strengthening power within me. I declare that I can do all things through Christ who gives me strength. I am ready to face this day with courage and confidence in You. Amen!",
  ),
  const Devotional(
    title: "Divine Appointments",
    coreMessage: "God has orchestrated divine appointments for you today – people you need to meet and opportunities you need to seize.",
    scriptureFocus: "The steps of a good man are ordered by the LORD, And He delights in his way.",
    scriptureReference: "Psalm 37:23 NKJV",
    reflection: "Your life is not a series of random events. God is a strategic God, and He is constantly arranging things for your good. He's lining up the right people to come into your life, the right opportunities to cross your path. These are divine appointments, tailor-made for your destiny.\nBe alert and open today. That person you bump into, that unexpected phone call, that idea that pops into your head – it could be a divine setup. Ask God to help you recognize and step into these moments. He is guiding your steps more than you realize.",
    prayerDeclaration: "Lord, I thank You for ordering my steps and preparing divine appointments for me. Help me to be sensitive to Your leading and to recognize the opportunities You bring my way. I declare that I am in the right place at the right time, ready for Your blessings. Amen!",
  ),
  const Devotional(
    title: "Release the Past, Embrace the Future",
    coreMessage: "Don't let past hurts or disappointments define your future. God has something new and better for you.",
    scriptureFocus: "Forget the former things; do not dwell on the past. See, I am doing a new thing! Now it springs up; do you not perceive it?",
    scriptureReference: "Isaiah 43:18-19 NIV",
    reflection: "It's tempting to carry old baggage – regrets, wounds, what-ifs. But holding onto the past will prevent you from fully embracing the wonderful future God has planned. He wants to do a new thing in your life, but you have to be willing to let go of the old.\nMake a decision today to release any bitterness, any sorrow, any failure that's been weighing you down. Forgive those who hurt you, forgive yourself, and receive God's healing. As you clear out the old, you make room for the new blessings, new relationships, and new opportunities He is eager to give you.",
    prayerDeclaration: "Father, I choose to release the past and all its weight. I will not dwell on former things. I declare that I am ready for the new thing You are doing in my life. My future is bright and full of Your promises. Amen!",
  ),
  const Devotional(
    title: "A Shield Around You",
    coreMessage: "God's protection is like a shield around you, deflecting the enemy's attacks and keeping you secure.",
    scriptureFocus: "But you, O LORD, are a shield about me, my glory, and the lifter of my head.",
    scriptureReference: "Psalm 3:3 ESV",
    reflection: "In a world that can often feel uncertain and dangerous, it's comforting to know that you are under divine protection. God Himself is your shield. He is watching over you, guarding you from harm seen and unseen.\nWhen fear tries to creep in, remind yourself of this truth. Visualize His protective presence surrounding you like an impenetrable fortress. No weapon formed against you will prosper when you are hidden in Him. Walk in confidence, knowing that the Almighty God is your defender and your refuge.",
    prayerDeclaration: "Lord, thank You for being my shield and my protector. I declare that I am safe and secure in You. No harm will come near me because You are with me. I walk in boldness and peace today. Amen!",
  ),
  const Devotional(
    title: "The Joy of the Lord",
    coreMessage: "The joy of the Lord is your strength! Choose joy today, regardless of your circumstances.",
    scriptureFocus: "Do not grieve, for the joy of the LORD is your strength.",
    scriptureReference: "Nehemiah 8:10 NIV",
    reflection: "Joy isn't just a fleeting emotion based on good things happening; it's a deep-seated strength that comes from knowing God and trusting in His goodness. This joy is available to you even when things aren't perfect, even when you're facing challenges.\nMake a conscious choice to cultivate joy. Focus on God's promises, recount His past faithfulness, sing praises to Him. When you choose joy, you tap into a supernatural strength that can carry you through anything. It changes your perspective and empowers you to overcome.",
    prayerDeclaration: "Father, I choose Your joy today! I declare that the joy of the Lord is my strength. It lifts me above my circumstances and fills me with hope and power. My heart is joyful in You. Amen!",
  ),
  const Devotional(
    title: "More Than Enough",
    coreMessage: "Our God is a God of abundance, not lack. He will provide more than enough to meet your needs and fulfill your dreams.",
    scriptureFocus: "And my God will supply every need of yours according to his riches in glory in Christ Jesus.",
    scriptureReference: "Philippians 4:19 ESV",
    reflection: "Are you worried about provision? About making ends meet? It's time to shift your mindset from lack to abundance. The God you serve owns everything, and He delights in blessing His children.\nHis resources are unlimited. He's not just going to meet your needs; He wants to give you an overflow so you can be a blessing to others. Trust in His promise to supply all that you require. Look for His provision in expected and unexpected ways. Live with an open hand, ready to receive His generosity.",
    prayerDeclaration: "Lord, I thank You that You are my provider. You supply all my needs according to Your glorious riches. I declare that I live in abundance, not lack. I have more than enough to fulfill my purpose and to bless others. Amen!",
  ),
  const Devotional(
    title: "Called for Such a Time as This",
    coreMessage: "You are uniquely positioned and equipped by God for the challenges and opportunities of this very moment.",
    scriptureFocus: "For if you keep silent at this time, relief and deliverance will rise for the Jews from another place, but you and your father's house will perish. And who knows whether you have not come to the kingdom for such a time as this?",
    scriptureReference: "Esther 4:14 ESV",
    reflection: "Don't ever feel like your life is insignificant or that you don't have a purpose. God has strategically placed you in this generation, in your specific circumstances, for a reason. Like Esther, you have been called 'for such a time as this.'\nThere are people you are meant to influence, problems you are meant to solve, kindness you are meant to show. Embrace your unique calling. Don't shy away from the opportunities God gives you to make a difference, no matter how small they may seem. You are an important part of His plan.",
    prayerDeclaration: "Father, thank You for choosing me for such a time as this. I embrace my divine assignment. I declare that I will use my gifts and opportunities to bring You glory and to be a blessing to those around me. Amen!",
  ),
  const Devotional(
    title: "Rest in His Presence",
    coreMessage: "In the midst of a busy life, find true rest and refreshment in the quiet presence of God.",
    scriptureFocus: "Come to me, all who labor and are heavy laden, and I will give you rest.",
    scriptureReference: "Matthew 11:28 ESV",
    reflection: "Are you feeling weary, stressed, or burned out? The world offers many temporary fixes, but true, deep rest is found only in the presence of Jesus. He invites you to come to Him with all your burdens and cares.\nMake time to be still before Him. Turn off the noise, lay down your worries, and simply be with your Creator. In His presence, you'll find peace for your soul, renewal for your spirit, and strength for your journey. This is not wasted time; it's an essential investment in your well-being.",
    prayerDeclaration: "Lord, I come to You today for rest. I lay down my burdens and anxieties at Your feet. I declare that in Your presence, I find peace, renewal, and strength. My soul is refreshed in You. Amen!",
  ),
  const Devotional(
    title: "Goodness and Mercy Follow You",
    coreMessage: "Expect God's goodness and mercy to pursue you and overtake you every single day of your life.",
    scriptureFocus: "Surely goodness and mercy shall follow me all the days of my life, and I shall dwell in the house of the LORD forever.",
    scriptureReference: "Psalm 23:6 ESV",
    reflection: "This is not just a hopeful wish; it's a powerful declaration from God's Word! Goodness and mercy are not just occasionally available; they are actively following you, like a divine escort, every single day. God's goodness provides for you, opens doors for you, and blesses you. His mercy covers your mistakes, forgives your sins, and gives you fresh chances.\nLive with this assurance. No matter what today holds, know that God's loving-kindness and tender mercies are right there with you, working on your behalf. Expect to see evidence of His goodness all around you.",
    prayerDeclaration: "Father, I thank You that Your goodness and mercy follow me all the days of my life. I declare that I am surrounded by Your favor and enveloped in Your love. I expect to see Your goodness manifested today. Amen!",
  ),
  const Devotional(
    title: "Victorious Living",
    coreMessage: "You were not created to just survive; you were created to thrive and live a victorious life through Christ!",
    scriptureFocus: "No, in all these things we are more than conquerors through him who loved us.",
    scriptureReference: "Romans 8:37 ESV",
    reflection: "Challenges will come, but they don't have the final say. Through Jesus, you have already been given the victory over sin, over the enemy, over every obstacle that stands in your way. You are not fighting for victory; you are fighting from a position of victory!\nAdopt a conqueror's mindset. When adversity arises, see it as an opportunity for God to display His power through you. Speak His promises, stand on His Word, and refuse to be defeated. You are equipped to overcome and to live an abundant, triumphant life.",
    prayerDeclaration: "Lord, thank You that I am more than a conqueror through You! I declare that I walk in victory today over every challenge and obstacle. I am strong, courageous, and destined to win. Amen!",
  ),
];

// Function to get a random devotional for the day
// In a real app, you might want to make this more sophisticated
// to ensure the same devotional is shown for the entire day for all users,
// or at least for a single user across app sessions in a day.
// For now, it's a simple random pick.
Devotional getDevotionalOfTheDay() {
  if (allDevotionals.isEmpty) {
    // Return a default or handle error if no devotionals are available
    return const Devotional(
        title: "No Devotional Available",
        coreMessage: "Please check back later.",
        scriptureFocus: "",
        scriptureReference: "",
        reflection: "Content is being updated.",
        prayerDeclaration: "");
  }
  final random = Random();
  return allDevotionals[random.nextInt(allDevotionals.length)];
}
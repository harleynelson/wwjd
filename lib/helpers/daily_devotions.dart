// lib/daily_devotionals.dart

import 'dart:math';
import 'prefs_helper.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/models.dart';

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
    coreMessage: "You are on the verge of something amazing! Opportunities, good breaks, and divine connections are aligning for you.",
    scriptureFocus: "For I know the plans I have for you,” declares the LORD, “plans to prosper you and not to harm you, plans to give you hope and a future.",
    scriptureReference: "Jeremiah 29:11 NIV",
    reflection: "Every sunrise brings a new opportunity to witness favor in your life. Don't be discouraged by past setbacks or current challenges; see them as setups for a greater comeback! Positive forces are working behind the scenes, turning things to your advantage.\nYou might not see it all now, but trust that a beautiful plan is unfolding. Keep your faith stirred up, speak words of victory, and get ready to step into the fullness of the blessings in store for you. Expect good things; expect unmerited favor to show up in surprising ways today, not just for you, but flowing through you to bless others!",
    prayerDeclaration: "Divine Source, thank You for Your incredible plans for my life. I declare that I am stepping into new levels of favor and blessing. I am strong, I am equipped, I am ready for all the good things You have for me today, and ready to share Your goodness. Amen!",
  ),
  const Devotional(
    title: "Shake Off the Negative",
    coreMessage: "Don't let negative thoughts or the opinions of others hold you back. You are inherently worthy and approved from within!",
    scriptureFocus: "Do not be conformed to this world, but be transformed by the renewal of your mind, that by testing you may discern what is the will of God, what is good and acceptable and perfect.",
    scriptureReference: "Romans 12:2 ESV",
    reflection: "Life will always present challenges that can lead to negativity – doubts, fears, critical voices. But you have the power to choose what you allow to take root in your spirit. It's time to shake off any discouragement, any limiting beliefs spoken over you, any feeling of inadequacy.\nRenew your mind with affirmations of your true worth and potential. You are chosen, you are valuable, you are more than a conqueror. When you start aligning with this inner truth, those negative chains will break. Focus on positive possibilities, speak truth over your situation, and watch how your atmosphere begins to change, bringing light not only to your path but to those around you.",
    prayerDeclaration: "Guiding Light, I choose to reject every negative thought and word that doesn't align with my highest truth. I declare that I am confident, I am capable, and I am covered by grace. My mind is renewed, my spirit is strong, and I will be a reflection of Your positivity. Amen!",
  ),
  const Devotional(
    title: "Expect the Unexpected Favor",
    coreMessage: "The Universe/God desires to do exceedingly, abundantly above all you can ask or think. Get ready for unexpected favor and sudden breakthroughs!",
    scriptureFocus: "Now to him who is able to do far more abundantly than all that we ask or think, according to the power at work within us...",
    scriptureReference: "Ephesians 3:20 ESV",
    reflection: "Sometimes, we limit the flow of good by our own expectations. We think in terms of the purely material or logical, but the source of all good is supernatural and unlimited! It’s not confined by what seems possible to us. It delights in surprising us with blessings that we didn't see coming.\nToday, enlarge your vision. Dare to believe for those dreams that seem big, those problems that seem difficult. There are ways to make things happen that you've never thought of. Stay in an attitude of expectancy. Infinite power is at work within you, preparing you for extraordinary things that can uplift both you and your community.",
    prayerDeclaration: "Source of All Abundance, I thank You for being a God of delightful surprise! I open my heart to receive Your unexpected favor today. I believe for breakthroughs in every area of my life, that I may be a greater blessing. I declare that something good is coming my way. Amen!",
  ),
  const Devotional(
    title: "Your Time is Coming",
    coreMessage: "Don't be discouraged by delays. Divine timing is perfect, and your appointed time for breakthrough and fulfillment is on its way!",
    scriptureFocus: "He has made everything beautiful in its time. He has also set eternity in the human heart; yet no one can fathom what God has done from beginning to end.",
    scriptureReference: "Ecclesiastes 3:11 NIV",
    reflection: "It's easy to get frustrated when things don't happen as quickly as we'd like. But remember, the universe operates on a grand timeline. The bigger picture is always in view, and the perfect moment for every promise and potential to manifest in your life is known.\nInstead of focusing on the 'when,' focus on staying prepared, faithful, and aligned with your values. Keep doing what you know is right, keep believing in good outcomes, and keep expressing gratitude in advance. Your season of fulfillment is approaching. Trust the process, and know that all things are working together for your good and for the good you can bring to the world.",
    prayerDeclaration: "Guiding Wisdom, I trust Your timing. I believe that all things are working for my good, and my breakthrough is on the way. Help me to wait with patience and joyful expectation, preparing for the impact I can make. I declare that my time of blessing and service is near. Amen!",
  ),
  const Devotional(
    title: "Unleash Your Potential",
    coreMessage: "You have been gifted with incredible talents and a unique light. It's time to step out and let them shine for the good of all!",
    scriptureFocus: "For we are God’s handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.",
    scriptureReference: "Ephesians 2:10 NIV",
    reflection: "You are not an accident. You were uniquely designed with a specific purpose and inherent worth. Don't underestimate what has been placed inside of you. Maybe you feel like your talents are small or insignificant, but in the grand scheme, they can have a massive impact for good in the world.\nDon't let fear or insecurity hold you back any longer. Take that step of faith. Start that project, share that idea, use that gift. As you begin to move, support will meet you there, opening doors and providing the resources you need. Your potential is limitless when you align with your higher purpose.",
    prayerDeclaration: "Creative Spirit, thank You for the unique gifts You've given me. I choose to step out in faith and use them to honor the highest good and serve others. I declare that I am equipped, empowered, and ready to fulfill my divine potential for the greater good. Amen!",
  ),
  const Devotional(
    title: "Peace in the Storm",
    coreMessage: "Even when chaos surrounds you, an inner peace can guard your heart and mind. Anchor yourself in that calm center.",
    scriptureFocus: "And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.",
    scriptureReference: "Philippians 4:7 NIV",
    reflection: "Life is full of storms – unexpected challenges, pressures, and uncertainties. It's easy to get overwhelmed and anxious. But there is a promise of peace that the world cannot give, a peace that surpasses our understanding.\nThis peace isn't the absence of trouble; it's the presence of a steadfast calm in the midst of trouble. When you feel the winds of adversity blowing, turn your focus inward to that quiet space. Release your cares, knowing you are supported. Let wisdom be your anchor, and allow your spirit to fill you with a calm that defies the circumstances, a peace you can share.",
    prayerDeclaration: "Source of Peace, I thank You for Your peace that surpasses all understanding. When storms come, I will fix my eyes on my inner strength and wisdom. I declare that my heart is calm, my mind is stayed on You. Your peace rules in my life, and I pray to be a conduit of that peace to others. Amen!",
  ),
  const Devotional(
    title: "New Mercies Every Morning",
    coreMessage: "Yesterday's failures are gone. Today is a fresh start, filled with new mercies, grace, and opportunities for growth.",
    scriptureFocus: "The steadfast love of the LORD never ceases; his mercies never come to an end; they are new every morning; great is your faithfulness.",
    scriptureReference: "Lamentations 3:22-23 ESV",
    reflection: "Don't let the weight of past mistakes or regrets drag you down today. Divine mercies are not a one-time offer; they are renewed every single morning! That means you get a clean slate, a fresh opportunity to walk in goodness and purpose.\nReceive forgiveness, extend forgiveness to yourself and others, fostering healing and reconciliation. Faithfulness is great, and the universe supports your renewal. It's not holding your past against you; it's inviting you into a brighter future, one of wholeness and renewed relationships. Embrace this gift of a new beginning.",
    prayerDeclaration: "Eternal Love, thank You for Your unfailing compassion and new mercies that greet me this morning. I release the past and embrace the fresh start You've given me, extending grace as I have received it. I declare that today is filled with Your grace, goodness, and opportunities for connection. Amen!",
  ),
  const Devotional(
    title: "The Power of Your Words",
    coreMessage: "Your words have creative power. Speak life, affirmation, and blessings over your situation, your future, and the world around you.",
    scriptureFocus: "Death and life are in the power of the tongue, and those who love it will eat its fruits.",
    scriptureReference: "Proverbs 18:21 ESV",
    reflection: "The universe responds to energy, and words carry immense energy. What are you speaking over your life, your family, your community, your health? Are your words aligning with positive possibilities or with negativity?\nChoose to speak words of faith, hope, and abundance. Even if you don't see it yet, declare what you desire to be true, in alignment with the highest good. Call forth those things that are not as though they were. As you consistently speak with positive intention, you'll begin to see your circumstances and the atmosphere around you shift and align with your declarations.",
    prayerDeclaration: "Creative Source, I recognize the power of my words. Today, I choose to speak life, health, victory, and abundance. I declare positive intentions over every area of my life. My words are building a future filled with blessings for myself and for those I can influence for good. Amen!",
  ),
  const Devotional(
    title: "You Are Not Alone",
    coreMessage: "In every trial, in every joy, a loving presence is with you. You never have to face life's challenges by yourself.",
    scriptureFocus: "Be strong and courageous. Do not fear or be in dread of them, for it is the LORD your God who goes with you. He will not leave you or forsake you.",
    scriptureReference: "Deuteronomy 31:6 ESV",
    reflection: "Sometimes life can feel isolating, especially when you're going through difficult times. But the truth is, a supportive presence has promised to be with you always. It's not a distant observer; it's an ever-present help in times of need.\nLean on this inner strength when you feel weak. Draw comfort from this presence when you feel afraid or lonely. You are understood, deeply loved, and constantly accompanied. You are never truly alone in your journey or your efforts to bring kindness to the world.",
    prayerDeclaration: "Ever-present Spirit, thank You for Your constant presence in my life. I know I am never alone. I draw strength from You, and I trust that You are guiding me through every situation, empowering me to be present for others. I declare Your peace and presence over my day. Amen!",
  ),
  const Devotional(
    title: "Favor Shines on You",
    coreMessage: "Expect life's favor to open doors that no one can shut and bring blessings you didn't even know to ask for. You are worthy of it!",
    scriptureFocus: "For you bless the righteous, O LORD; you cover him with favor as with a shield.",
    scriptureReference: "Psalm 5:12 ESV",
    reflection: "Divine favor isn't about being perfect; it's about inherent goodness shining upon you. It's that advantage, that extra something that makes things work out for you, even when the odds seem stacked against you. This favor can cause people to go out of their way to help you, to support you, to bless you.\nDon't be shy about affirming your worthiness of life's extraordinary blessings. Walk with an attitude of expectancy, knowing that the universe wants to express its goodness in your life in ways that will leave others amazed and draw them to love. Be open to receiving.",
    prayerDeclaration: "Generous Universe, thank You for the unmerited favor that shines on me! I declare that this favor is a shield around me. It opens the right doors, brings the right opportunities, and causes me to prosper in all I do, that I might be a generous channel of Your blessings. I expect favor to show up in big ways today! Amen!",
  ),
  const Devotional(
    title: "Breakthrough is Coming",
    coreMessage: "Don't give up on the edge of your miracle. Your breakthrough is closer than you think! Keep moving forward.",
    scriptureFocus: "Let us not become weary in doing good, for at the proper time we will reap a harvest if we do not give up.",
    scriptureReference: "Galatians 6:9 NIV",
    reflection: "Many times, we're tempted to quit just before the victory. The effort might be intense, the waiting might be long, but the universe responds to persistent, positive action. Your perseverance, your faith, your intentions are seen and valued.\nThat opposition you're facing? It's often a sign that your breakthrough is imminent. Challenges arise when something significant is about to shift. Hold on, stay strong in faith, and keep declaring positive outcomes. Your harvest time is approaching, bringing with it opportunities to lift others.",
    prayerDeclaration: "Unfailing Support, I refuse to grow weary. I stand firm in faith, knowing that my breakthrough is on its way. I declare that I will reap a harvest of blessing for myself and to share, because I do not give up! Thank You for Your faithfulness. Amen!",
  ),
  const Devotional(
    title: "Dare to Dream Big",
    coreMessage: "Those big dreams in your heart were placed there for a reason. Don't shrink back; dare to believe in the possibility of their manifestation!",
    scriptureFocus: "For nothing will be impossible with God.",
    scriptureReference: "Luke 1:37 ESV",
    reflection: "What are those secret dreams and desires that have been whispered to your spirit? Sometimes they seem so big, so out of reach, that we're tempted to dismiss them. But if that dream resonates deeply within you, the capacity and the plan to bring it to pass also exist within and around you.\nDon't let fear, doubt, or the opinions of others talk you out of what feels true for you. Enlarge your vision. Start taking small steps towards that dream, trusting that support will arrive and doors will open as you move forward. With a connection to the divine, all things are possible.",
    prayerDeclaration: "Infinite Possibility, I thank You for the dreams You've placed in my heart. I choose to believe in their power and potential. I declare that I am stepping out in faith towards my inspired destiny, one that includes making a positive mark on the world. You are making a way where there seems to be no way. Amen!",
  ),
  const Devotional(
    title: "Rise Above It",
    coreMessage: "You are called to live from a higher perspective. Don't get bogged down by petty offenses or distractions. Choose to rise above!",
    scriptureFocus: "Set your minds on things that are above, not on things that are on earth.",
    scriptureReference: "Colossians 3:2 ESV",
    reflection: "Life will present small things – annoyances, offenses, worries – that can try to steal your peace and distract you from your purpose. But you don't have to take that bait. You can choose to operate from a higher perspective, one of wisdom and compassion.\nWhen irritations come, when people try to pull you into drama, make a quality decision to rise above it. Focus on what truly matters: your inner peace, your calling to love and serve, and the eternal values that guide compassionate living. Keep your thoughts on things that are pure, lovely, and praiseworthy. This is how you maintain your spiritual altitude.",
    prayerDeclaration: "Higher Self, help me to keep my mind set on things above. I refuse to be distracted by negativity or petty issues. I declare that I am rising above every challenge, living in peace and victory, and focusing on what truly uplifts. Amen!",
  ),
  const Devotional(
    title: "The Blessing of Aligned Action",
    coreMessage: "When your actions align with your highest values and intuition, you position yourself for life's greatest blessings and open doors.",
    scriptureFocus: "If you are willing and obedient, you shall eat the good of the land;",
    scriptureReference: "Isaiah 1:19 ESV",
    reflection: "Sometimes we think 'obedience' is about strict rules. In a broader sense, it's about aligning with inner wisdom and universal principles of goodness. This alignment is the pathway to blessing, freedom, and abundance. It's about trusting that these ways are higher and better than purely ego-driven paths.\nIs there something your intuition has been prompting you to do? Maybe it's to extend forgiveness, to step out in a new area of service, to be more generous or compassionate. Don't delay. Your aligned action, even when it feels difficult or doesn't make immediate logical sense, unlocks new levels of favor and provision in your life, enabling you to be a greater force for good.",
    prayerDeclaration: "Inner Wisdom, I choose to be willing and to act in alignment with Your guidance. I trust that such actions lead to blessing. I declare that as I walk this path, I will experience the good You have promised, and be equipped to share it. Amen!",
  ),
  const Devotional(
    title: "Overflowing Gratitude",
    coreMessage: "A grateful heart is a magnet for miracles and joy. Count your blessings, express your thanks, and watch life multiply them!",
    scriptureFocus: "Give thanks in all circumstances; for this is the will of God in Christ Jesus for you.",
    scriptureReference: "1 Thessalonians 5:18 ESV",
    reflection: "It's easy to focus on what's perceived as wrong, what we feel we don't have, or what's not working out. But when we shift our focus to gratitude, something powerful happens. Gratitude opens our eyes to the goodness that's already surrounding us, and it creates an atmosphere for even more to flow in.\nTake time today to consciously thank the Universe/God for all blessings, big and small. Express gratitude for your life, your health, your loved ones, and all provision. As you cultivate a lifestyle of thanksgiving, you'll find your joy increasing and your perspective changing. You'll start to see goodness in everything, inspiring you to share that joy and abundance with the world.",
    prayerDeclaration: "Source of All Good, I am so grateful for all You have provided and all You are doing in my life. My heart overflows with thanksgiving. I declare that I will give thanks in all circumstances, knowing this opens the door for more of Your goodness to flow through me to others. Amen!",
  ),
  const Devotional(
    title: "Strength for Today",
    coreMessage: "The strength you need for whatever you face today is within you and around you. You are more capable than you think because you are supported.",
    scriptureFocus: "I can do all things through him who strengthens me.",
    scriptureReference: "Philippians 4:13 ESV",
    reflection: "Are you facing a challenge that feels overwhelming? Do you feel like you don't have what it takes? Remember this promise: you are not operating in your own limited strength alone. A power greater than yourself, the same power that creates worlds, lives in you and works through you!\nLife doesn't always remove obstacles, but it always provides the strength to overcome them. Tap into this inner and universal power. When you feel weak, that's when this greater strength can be made perfect in you. Don't focus on your limitations; focus on limitless potential. You can do this, and in doing so, inspire others by your resilience.",
    prayerDeclaration: "Infinite Strength, thank You for Your empowering presence within and around me. I declare that I can do all things through the Christ/Divine energy that strengthens me. I am ready to face this day with courage and confidence, and to be a source of strength for those around me. Amen!",
  ),
  const Devotional(
    title: "Divine Appointments & Connections",
    coreMessage: "Life orchestrates meaningful connections for you today – people you need to meet, wisdom you need to hear, and opportunities you need to seize.",
    scriptureFocus: "The steps of a good man are ordered by the LORD, And He delights in his way.",
    scriptureReference: "Psalm 37:23 NKJV",
    reflection: "Your life is not a series of random events. There is a higher intelligence, a strategic flow, constantly arranging things for your growth and good. It's lining up the right people to come into your life, the right insights to cross your path. These are divine appointments and connections, tailor-made for your journey.\nBe alert and open today. That person you bump into, that unexpected phone call, that idea that pops into your head – it could be a setup for something wonderful. Ask for clarity to recognize and step into these moments. You are being guided more than you realize, leading you to moments of connection and shared purpose.",
    prayerDeclaration: "Guiding Presence, I thank You for ordering my steps and preparing divine connections for me. Help me to be sensitive to Your leading and to recognize the opportunities You bring my way. I declare that I am in the right place at the right time, ready for Your blessings and for the connections that allow me to bless others. Amen!",
  ),
  const Devotional(
    title: "Release the Past, Embrace the Future",
    coreMessage: "Don't let past hurts or disappointments define your future. A new beginning, full of potential and healing, is always available.",
    scriptureFocus: "Forget the former things; do not dwell on the past. See, I am doing a new thing! Now it springs up; do you not perceive it?",
    scriptureReference: "Isaiah 43:18-19 NIV",
    reflection: "It's tempting to carry old baggage – regrets, wounds, what-ifs. But holding onto the past can prevent you from fully embracing the wonderful future that awaits. The universe is always ready to support a new thing in your life, but you have to be willing to let go of the old.\nMake a decision today to release any bitterness, any sorrow, any failure that's been weighing you down. Forgive those who hurt you (for your own peace), forgive yourself, and receive the healing that is offered. As you clear out the old, you make room for new blessings, new relationships built on grace, and new opportunities for growth and service.",
    prayerDeclaration: "Spirit of Renewal, I choose to release the past and all its weight. I will not dwell on former things. I declare that I am ready for the new thing You are doing in my life. My future is bright and full of Your promises for healing, restoration, and making all things new. Amen!",
  ),
  const Devotional(
    title: "A Shield of Light Around You",
    coreMessage: "Divine protection is like a shield of light around you, deflecting negativity and keeping your spirit secure and at peace.",
    scriptureFocus: "But you, O LORD, are a shield about me, my glory, and the lifter of my head.",
    scriptureReference: "Psalm 3:3 ESV",
    reflection: "In a world that can often feel uncertain, it's comforting to know that you are enfolded in divine protection. This loving presence is your shield, watching over you, guarding you from harm seen and unseen.\nWhen fear or anxiety tries to creep in, remind yourself of this truth. Visualize this protective light surrounding you like an impenetrable fortress. No negativity can permanently affect you when you are centered in this awareness. Walk in confidence, knowing that the Almighty is your defender, your refuge, and a refuge for all who seek shelter.",
    prayerDeclaration: "Protective Light, thank You for being my shield and my safeguard. I declare that I am safe and secure in Your embrace. No harm will come near my true self because You are with me. I pray for Your protection over all who are vulnerable. I walk in boldness and peace today. Amen!",
  ),
  const Devotional(
    title: "The Joy of the Divine",
    coreMessage: "The joy of connection with the Divine is your strength! Choose joy today, find it in small things, regardless of your circumstances.",
    scriptureFocus: "Do not grieve, for the joy of the LORD is your strength.",
    scriptureReference: "Nehemiah 8:10 NIV",
    reflection: "Joy isn't just a fleeting emotion based on good things happening; it's a deep-seated strength that comes from knowing you are loved, connected, and part of something vast and good. This joy is available to you even when things aren't perfect, even when you're facing challenges.\nMake a conscious choice to cultivate joy. Focus on beauty, on kindness, on the promises of spiritual truth. Recount past blessings, sing, or simply breathe in gratitude. When you choose joy, you tap into a supernatural strength that can carry you through anything. It changes your perspective, empowers you to overcome, and radiates to those you encounter.",
    prayerDeclaration: "Source of All Joy, I choose Your joy today! I declare that this divine joy is my strength. It lifts me above my circumstances, fills me with hope and power, and makes me a beacon of Your light. My heart is joyful in You. Amen!",
  ),
  const Devotional(
    title: "More Than Enough, For All",
    coreMessage: "The Universe is a place of abundance, not lack. There is more than enough to meet everyone's needs and support collective dreams.",
    scriptureFocus: "And my God will supply every need of yours according to his riches in glory in Christ Jesus.",
    scriptureReference: "Philippians 4:19 ESV",
    reflection: "Are you worried about provision, for yourself or others? It's time to shift our collective mindset from lack to abundance. The Source of all life owns everything, and delights in the flourishing of all its children.\nIts resources are unlimited. It doesn't just meet needs; it desires an overflow so that all can be a blessing to each other. Trust in the universal promise of supply. Look for provision in expected and unexpected ways, for yourself and for your community. Live with an open hand and a generous spirit, ready to receive and to share.",
    prayerDeclaration: "Abundant Provider, I thank You that You are the source of all supply. You meet all our needs according to Your glorious riches. I declare that we live in a universe of abundance, not lack. We have more than enough to fulfill our purpose, to live generously, and to bless others abundantly. Amen!",
  ),
  const Devotional(
    title: "Called for This Time, Together",
    coreMessage: "You are uniquely positioned and equipped for the challenges and opportunities of this very moment, to contribute to a better world.",
    scriptureFocus: "For if you keep silent at this time, relief and deliverance will rise for the Jews from another place, but you and your father's house will perish. And who knows whether you have not come to the kingdom for such a time as this?",
    scriptureReference: "Esther 4:14 ESV",
    reflection: "Don't ever feel like your life is insignificant or that you don't have a vital role to play. You have been strategically placed in this generation, in your specific circumstances, for a reason. Like Esther, you have been called 'for such a time as this.'\nThere are people you are meant to influence, systems you can help improve, kindness and justice you are meant to embody. Embrace your unique calling to bring positive change, offer compassion, and reflect divine love in your sphere of influence. You are an important part of a collective plan for a more just and loving world.",
    prayerDeclaration: "Guiding Spirit, thank You for choosing me for such a time as this. I embrace my divine assignment. I declare that I will use my gifts and opportunities to bring You glory, to advocate for justice and compassion, and to be a blessing to those around me, working together for good. Amen!",
  ),
  const Devotional(
    title: "Rest in Presence, Emerge Renewed",
    coreMessage: "In the midst of a busy life, find true rest and refreshment in quiet moments of connection with your inner Being and the Divine.",
    scriptureFocus: "Come to me, all who labor and are heavy laden, and I will give you rest.",
    scriptureReference: "Matthew 11:28 ESV",
    reflection: "Are you feeling weary, stressed, or burned out? The world offers many temporary distractions, but true, deep rest is found in the sanctuary of your own presence, connected to the Source of all life. You are invited to come with all your burdens and cares.\nMake time to be still. Turn off the external noise, lay down your worries, and simply be with your Creator, your higher self. In this presence, you'll find peace for your soul, renewal for your spirit, and strength for your journey of love and service. This is not wasted time; it's an essential investment in your well-being and your capacity to contribute meaningfully.",
    prayerDeclaration: "Eternal Source, I come to You today for rest. I lay down my burdens and anxieties at Your feet. I declare that in Your presence, I find peace, renewal, and strength. My soul is refreshed in You, preparing me to engage with the world with renewed compassion. Amen!",
  ),
  const Devotional(
    title: "Goodness and Mercy Abound",
    coreMessage: "Expect divine goodness and mercy to actively pursue and embrace you, and through you, to touch the world every single day.",
    scriptureFocus: "Surely goodness and mercy shall follow me all the days of my life, and I shall dwell in the house of the LORD forever.",
    scriptureReference: "Psalm 23:6 ESV",
    reflection: "This is not just a hopeful wish; it's a powerful affirmation of spiritual truth! Goodness and mercy are not just occasionally available; they are actively flowing, like a divine escort, every single day. Divine goodness provides, opens doors, and blesses. Divine mercy understands, forgives, and offers fresh chances.\nLive with this assurance. No matter what today holds, know that loving-kindness and tender mercies are right there with you, working on your behalf and through you. Expect to see evidence of this goodness all around you, and be inspired to extend that goodness and mercy to others.",
    prayerDeclaration: "Loving Presence, I thank You that Your goodness and mercy follow me all the days of my life. I declare that I am surrounded by Your favor and enveloped in Your love. I expect to see Your goodness manifested today, and I pray to be a conduit of that same goodness and mercy in the lives I touch. Amen!",
  ),
  const Devotional(
    title: "Victorious & Empowering Living",
    coreMessage: "You were not created to just survive; you were created to thrive, live a victorious life, and empower others to do the same!",
    scriptureFocus: "No, in all these things we are more than conquerors through him who loved us.",
    scriptureReference: "Romans 8:37 ESV",
    reflection: "Challenges will come, but they don't have the final say. Through your connection with the Divine, you have already been given the capacity for victory over negativity, over limitations, over every obstacle that stands in your way. You are not fighting for victory; you are expressing it from a position of inner strength!\nAdopt a conqueror's mindset. When adversity arises, see it as an opportunity for divine power and wisdom to be displayed through you. Speak promises of hope, stand on universal truths, and refuse to be defeated. You are equipped to overcome, to live an abundant, triumphant life, and to help others find their victory too.",
    prayerDeclaration: "Empowering Spirit, thank You that I am more than a conqueror through You! I declare that I walk in victory today over every challenge and obstacle. I am strong, courageous, destined to win, and committed to helping others rise. Amen!",
  ),
  const Devotional(
    title: "Open Doors of Opportunity",
    coreMessage: "New doors of opportunity are opening for you, even ones you didn't expect. Walk through them with courage and faith!",
    scriptureFocus: "See, I have placed before you an open door that no one can shut.",
    scriptureReference: "Revelation 3:8 NIV",
    reflection: "Life is constantly presenting new pathways and possibilities. Sometimes, these doors are clearly marked, other times they appear unexpectedly. Don't let fear of the unknown or past disappointments hold you back. The same loving Source that guides the universe is also guiding you towards growth and fulfillment.\nBe observant and receptive. That new idea, that chance encounter, that unexpected offer – it could be an open door. Trust your intuition, step forward with courage, and know that you are equipped for whatever lies ahead. These opportunities are not just for your benefit, but also for the good you can bring to the world through them.",
    prayerDeclaration: "Divine Opener of Ways, I thank You for the new doors of opportunity You are placing before me. I choose to walk through them with courage, faith, and a heart ready to serve. I declare that I am guided, prepared, and ready for these new adventures. Amen!",
  ),
  const Devotional(
    title: "The Power of a Thankful Heart",
    coreMessage: "Gratitude unlocks the fullness of life. A thankful heart attracts more blessings and magnifies the good already present.",
    scriptureFocus: "In everything give thanks; for this is the will of God in Christ Jesus for you.",
    scriptureReference: "1 Thessalonians 5:18 NKJV",
    reflection: "It's easy to focus on what's missing, but true joy is found in appreciating what we have. Gratitude shifts your perspective, turning ordinary moments into blessings and challenges into opportunities for growth. When you cultivate a thankful heart, you create a positive energy that draws more good into your life.\nMake it a practice to count your blessings daily, no matter how small they may seem. Express your appreciation for the people, the experiences, and the simple gifts that enrich your life. A spirit of gratitude not only elevates your own being but also becomes a beacon of light for others.",
    prayerDeclaration: "Grateful Heart, I thank You for the countless blessings in my life. I choose to cultivate an attitude of gratitude in all circumstances. I declare that my thankfulness opens the way for even greater joy, abundance, and opportunities to share these gifts. Amen!",
  ),
  const Devotional(
    title: "You Are Resilient",
    coreMessage: "You are stronger than you think and more resilient than you know. Life's challenges are shaping you, not breaking you.",
    scriptureFocus: "We are hard pressed on every side, but not crushed; perplexed, but not in despair; persecuted, but not abandoned; struck down, but not destroyed.",
    scriptureReference: "2 Corinthians 4:8-9 NIV",
    reflection: "Life inevitably brings trials and setbacks. There will be times when you feel pressed and tested. But within you lies an incredible resilience, a divine spark that cannot be extinguished. These challenges are not meant to destroy you, but to reveal the strength and character you carry.\nEmbrace each experience as a chance to grow stronger, wiser, and more compassionate. Remember past victories and how you've overcome difficulties before. You have an inner wellspring of power to draw from. You will not just get through this; you will come out refined and more capable than ever, ready to inspire others with your journey.",
    prayerDeclaration: "Unshakeable Spirit, I thank You for the resilience You've woven into my being. I declare that I am strong, courageous, and capable of overcoming any obstacle. Challenges refine me, they don't define me. I rise above, empowered and victorious. Amen!",
  ),
  const Devotional(
    title: "Shine Your Light",
    coreMessage: "You have a unique light within you meant to illuminate the world. Don't hide it; let it shine brightly for all to see!",
    scriptureFocus: "You are the light of the world. A town built on a hill cannot be hidden. Neither do people light a lamp and put it under a bowl. Instead they put it on its stand, and it gives light to everyone in the house.",
    scriptureReference: "Matthew 5:14-15 NIV",
    reflection: "Each person carries a unique spark, a divine light that has the power to bring warmth, hope, and inspiration to others. Don't underestimate the impact of your authentic self, your kindness, your passion, your unique gifts. The world needs your specific light.\nDon't let self-doubt or fear of judgment dim your radiance. Step out, be yourself, and share your gifts generously. Whether it's a smile, an encouraging word, a creative talent, or an act of service, letting your light shine contributes to a brighter, more loving world for everyone.",
    prayerDeclaration: "Source of All Light, thank You for the unique light You've placed within me. I choose to let it shine brightly and without reservation. I declare that my life will be a beacon of hope, love, and positivity, illuminating the paths of others. Amen!",
  ),
  const Devotional(
    title: "The Gift of Today",
    coreMessage: "This very day is a precious gift, a fresh canvas. Paint it with joy, purpose, and acts of kindness.",
    scriptureFocus: "The steadfast love of the Lord never ceases; his mercies never come to an end; they are new every morning; great is your faithfulness.",
    scriptureReference: "Lamentations 3:22-23 ESV",
    reflection: "Each morning brings a brand new opportunity, a clean slate untouched by yesterday's worries or tomorrow's uncertainties. This day is a gift, offering fresh chances to experience joy, to pursue your purpose, and to make a positive impact, however small.\nDon't let the preciousness of today be lost in the rush. Pause, breathe, and set an intention to live this day fully. Look for moments of beauty, extend kindness, and take a step, no matter how small, towards what truly matters to you. Embrace the gift of 'now'.",
    prayerDeclaration: "Giver of all Good Gifts, thank You for the precious gift of this new day. I receive it with a grateful heart. I declare that I will live today with joy, purpose, and intentional kindness, making the most of every moment. Amen!",
  ),
  const Devotional(
    title: "Believe in Your Breakthrough",
    coreMessage: "Even if you can't see it yet, your breakthrough is being orchestrated. Keep believing, keep expecting, keep moving forward!",
    scriptureFocus: "Now faith is confidence in what we hope for and assurance about what we do not see.",
    scriptureReference: "Hebrews 11:1 NIV",
    reflection: "Sometimes the path to our dreams and desires involves a period of waiting, of unseen progress. It's in these times that faith is crucial. Faith isn't just wishing; it's a deep inner knowing that good things are on their way, that solutions are forming, even when external circumstances haven't caught up yet.\nDon't be discouraged if your breakthrough hasn't manifested instantly. Continue to nurture your hopes, speak affirmations, and take inspired actions. The universe is always working in your favor when your intentions are aligned with good. Your consistent belief is a powerful magnet.",
    prayerDeclaration: "Faithful Provider, I choose to believe in the breakthroughs You have for me, even when I cannot yet see them. My faith is strong, my expectation is high. I declare that my positive shifts are on their way, and I am ready to receive them with gratitude. Amen!",
  ),
  const Devotional(
    title: "The Ripple Effect of Kindness",
    coreMessage: "One small act of kindness can create a ripple effect, touching more lives than you can imagine. Be a source of good today.",
    scriptureFocus: "Therefore encourage one another and build each other up, just as in fact you are doing.",
    scriptureReference: "1 Thessalonians 5:11 NIV",
    reflection: "Never underestimate the power of your kindness. A simple smile, a listening ear, an encouraging word, a helping hand – these seemingly small gestures can have a profound impact. You may not always see the full extent of the ripples you create, but know that every act of love and compassion sends out positive energy into the world.\nLook for opportunities to be kind today. It doesn't have to be a grand gesture. Small, consistent acts of goodness collectively make the world a better, more loving place. Be the change you wish to see, one kind act at a time.",
    prayerDeclaration: "Spirit of Compassion, inspire me to perform acts of kindness today. Help me to be a source of encouragement and support to those around me. I declare that my actions, however small, will create positive ripples and contribute to a more loving world. Amen!",
  ),
  const Devotional(
    title: "Embrace Your Journey",
    coreMessage: "Your life is a unique journey, with its own lessons, challenges, and triumphs. Embrace every step with grace and an open heart.",
    scriptureFocus: "Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.",
    scriptureReference: "Proverbs 3:5-6 NIV",
    reflection: "It's easy to compare our journey to others, to wish we were further along, or to regret past detours. But your path is uniquely yours, perfectly designed for your growth and unfolding. Every experience, both joyful and challenging, holds valuable lessons and contributes to the person you are becoming.\nInstead of resisting or rushing, try to embrace where you are right now. Trust that you are always guided and supported. Be open to the lessons, celebrate the progress, and walk your path with grace, knowing that every step is meaningful.",
    prayerDeclaration: "Divine Guide, I embrace my unique journey with an open heart. I trust that You are leading me and that every step has purpose. I declare that I am learning, growing, and moving forward with grace and courage. My path is blessed. Amen!",
  ),
  const Devotional(
    title: "The Strength of Unity",
    coreMessage: "There is incredible strength when we come together in unity, supporting and uplifting one another towards a common good.",
    scriptureFocus: "How good and pleasant it is when God’s people live together in unity!",
    scriptureReference: "Psalm 133:1 NIV",
    reflection: "While individual strength is important, our collective power is magnified when we unite for positive purposes. When we set aside differences and focus on shared values like love, compassion, and justice, we can achieve extraordinary things. Supporting each other's dreams, offering encouragement during struggles, and working together for the betterment of our communities creates a powerful synergy.\nLook for ways to connect and collaborate with others who share a vision for a better world. Celebrate diversity, practice empathy, and be a force for unity. Together, we are stronger and can make a far greater impact.",
    prayerDeclaration: "Spirit of Unity, I pray for greater unity and understanding among all people. Help me to be a bridge-builder and a supportive presence in my communities. I declare that by working together in love, we can create powerful positive change. Amen!",
  ),
  const Devotional(
    title: "Cultivate Inner Stillness",
    coreMessage: "In the midst of life's busyness, find moments to cultivate inner stillness. It's in the quiet that you connect with profound wisdom and peace.",
    scriptureFocus: "Be still, and know that I am God.",
    scriptureReference: "Psalm 46:10 NIV",
    reflection: "Our world is often noisy and demanding, pulling our attention in countless directions. It's essential to consciously create moments of stillness, to quiet the external chatter and tune into your inner landscape. In these moments of quiet contemplation or meditation, you can connect with a deeper wisdom, a sense of peace, and clear guidance.\nDon't see stillness as unproductive; it's a vital practice for rejuvenation and clarity. Even a few minutes of quiet breathing can recenter you. Make space for stillness today, and listen to the gentle whispers of your heart and the Divine.",
    prayerDeclaration: "Peaceful Presence, I seek moments of inner stillness today. Help me to quiet the noise and connect with Your profound wisdom and peace. I declare that in stillness, I find clarity, renewal, and a deeper connection to my true self. Amen!",
  ),
  const Devotional(
    title: "Seeds of Greatness",
    coreMessage: "Within you are seeds of greatness, planted by the Creator. Nurture them with faith and action, and watch them flourish.",
    scriptureFocus: "The kingdom of heaven is like a mustard seed, which a man took and planted in his field. Though it is the smallest of all seeds, yet when it grows, it is the largest of garden plants and becomes a tree...",
    scriptureReference: "Matthew 13:31-32 NIV",
    reflection: "Don't ever discount the potential that lies within you, even if it seems small or undeveloped right now. Every great achievement, every significant impact, starts as a tiny seed – an idea, a talent, a desire to make a difference. These are your seeds of greatness.\nYour role is to nurture them. Water them with faith and positive belief. Give them sunlight through consistent action and effort. Protect them from the weeds of doubt and discouragement. With patient cultivation, even the smallest seed can grow into something magnificent that blesses many.",
    prayerDeclaration: "Divine Gardener, thank You for the seeds of greatness You have planted within me. I commit to nurturing them with faith, diligence, and positive action. I declare that my potential is unfolding, and I will bear much fruit for Your glory and the good of all. Amen!",
  ),
  const Devotional(
    title: "The Courage to Change",
    coreMessage: "Change can be challenging, but it's often the pathway to new growth and greater blessings. Embrace it with courage.",
    scriptureFocus: "See, I am doing a new thing! Now it springs up; do you not perceive it? I am making a way in the wilderness and streams in the wasteland.",
    scriptureReference: "Isaiah 43:19 NIV",
    reflection: "We often find comfort in the familiar, even if it's not serving our highest good. Change can feel unsettling or even frightening. But growth rarely happens in our comfort zones. Sometimes, the universe nudges us—or outright pushes us—towards a new path, a new way of being, for our own evolution.\nIf you're facing a season of change, try to see it not as a disruption, but as an invitation to something new and better. Trust that even in the wilderness, a way is being made. Summon your courage, lean on your inner strength, and step forward. Greater things await on the other side of your willingness to change.",
    prayerDeclaration: "Spirit of Transformation, grant me the courage to embrace necessary changes in my life. Help me to see them as opportunities for growth and new beginnings. I declare that I am moving forward with faith, adaptability, and an open heart to the new things You are doing. Amen!",
  ),
  const Devotional(
    title: "Living a Legacy of Love",
    coreMessage: "More than achievements or possessions, the greatest legacy we can leave is one of love, kindness, and positive impact.",
    scriptureFocus: "And now these three remain: faith, hope and love. But the greatest of these is love.",
    scriptureReference: "1 Corinthians 13:13 NIV",
    reflection: "When all is said and done, what will truly matter is how we loved – how we loved the Divine, how we loved ourselves, and how we loved others. Material things fade, accomplishments can be forgotten, but the love we share and the kindness we extend create lasting ripples in the world.\nConsider today how your actions, words, and choices are contributing to a legacy of love. Are you building people up? Are you showing compassion? Are you using your gifts to serve? Strive to make love the guiding principle of your life, and you will leave an indelible mark on the hearts you touch and the world you inhabit.",
    prayerDeclaration: "Eternal Love, may my life be a testament to Your love. Guide me to live in such a way that I build a legacy of kindness, compassion, and positive impact. I declare that love is my highest aim and my greatest offering. Amen!",
  ),
  const Devotional(
    title: "The Unfolding Masterpiece",
    coreMessage: "Your life is an unfolding masterpiece, co-created with the Divine. Trust the process, even the parts you don't yet understand.",
    scriptureFocus: "For we are his workmanship, created in Christ Jesus for good works, which God prepared beforehand, that we should walk in them.",
    scriptureReference: "Ephesians 2:10 ESV",
    reflection: "Imagine an artist at work on a grand canvas. In the early stages, there might be seemingly random strokes, colors that don't yet make sense. But the artist has a vision. Your life is much the same. There are experiences, challenges, and joys that are all part of a larger, beautiful design being woven together.\nTrust that even the confusing or difficult parts have a purpose in the overall masterpiece. Keep aligning with your highest intentions, keep growing, keep loving. The full picture is still emerging, and it will be more beautiful than you can imagine. You are a work in progress, and a divine work of art.",
    prayerDeclaration: "Master Artist, I trust in Your creative process in my life. Help me to see the beauty in the unfolding, even in the unfinished parts. I declare that my life is becoming a magnificent masterpiece, reflecting Your wisdom, love, and grace. Amen!",
  ),
  const Devotional(
    title: "Overflowing with Hope",
    coreMessage: "Let hope overflow in your heart, a confident expectation of good things to come, sourced from an unwavering faith.",
    scriptureFocus: "May the God of hope fill you with all joy and peace as you trust in him, so that you may overflow with hope by the power of the Holy Spirit.",
    scriptureReference: "Romans 15:13 NIV",
    reflection: "Hope is more than wishful thinking; it's a powerful spiritual force. It's the joyful and confident expectation that, regardless of current circumstances, good will ultimately prevail and divine promises will be fulfilled. This kind of hope isn't self-generated; it's a gift that comes from trusting in a loving and all-powerful Source.\nNurture this hope within you. Feed it with positive affirmations, with time spent in gratitude, and by focusing on the good you see in the world and in others. As you allow yourself to be filled with this divine hope, it will not only sustain you but also spill over and inspire everyone you meet.",
    prayerDeclaration: "God of Hope, fill me to overflowing with Your divine hope today. May it be the bedrock of my joy and peace. I declare that I am a vessel of hope, confidently expecting Your goodness to manifest in my life and in the world. Amen!",
  ),
  const Devotional(
    title: "The Courage of Your Convictions",
    coreMessage: "Stand firm in what you know to be true and right in your heart. Your convictions have power when aligned with love and wisdom.",
    scriptureFocus: "For God has not given us a spirit of fear, but of power and of love and of a sound mind.",
    scriptureReference: "2 Timothy 1:7 NKJV",
    reflection: "There will be times when your inner knowing, your deepest values, may run counter to popular opinion or external pressures. It takes courage to stand by your convictions, especially when it's not the easy path. But this courage doesn't come from a place of aggression; it comes from a spirit of power, love, and a sound mind – a clarity rooted in divine truth.\nWhen you act from this centered place, your convictions become a force for good, not just for yourself but as an example and inspiration for others. Trust that inner voice of integrity, and let it guide your steps with both strength and compassion.",
    prayerDeclaration: "Spirit of Truth, grant me the courage to stand firm in my convictions when they are rooted in love and wisdom. May I live authentically and speak my truth with grace, contributing to a more just and understanding world. Amen!",
  ),
  const Devotional(
    title: "Unlimited Supply, Infinite Source",
    coreMessage: "Release any fear of lack. You are connected to an infinite Source that has an unlimited supply of all good things.",
    scriptureFocus: "And my God will meet all your needs according to the riches of his glory in Christ Jesus.",
    scriptureReference: "Philippians 4:19 NIV",
    reflection: "Often, our anxieties stem from a belief in limitation – limited resources, limited opportunities, limited love. But the truth is, the Universe, the Divine Source, operates from a place of boundless abundance. There is more than enough good to go around for everyone.\nShift your mindset from scarcity to abundance. Focus on the infinite supply available, not on perceived shortages. As you align your thoughts with this truth of plenty, and act with generosity, you open yourself up to receive all that you need and more, becoming a conduit for that abundance to flow to others as well.",
    prayerDeclaration: "Infinite Source, I thank You for Your unlimited supply. I release all fears of lack and open myself to Your abundant provision in every area of my life. I declare that I am a channel for Your abundance, receiving and sharing freely. Amen!",
  ),
  const Devotional(
    title: "The Beauty of Becoming",
    coreMessage: "Embrace the journey of becoming. You are constantly evolving, growing, and unfolding into more of your true, magnificent self.",
    scriptureFocus: "Being confident of this, that he who began a good work in you will carry it on to completion until the day of Christ Jesus.",
    scriptureReference: "Philippians 1:6 NIV",
    reflection: "Life is a process of continuous growth and unfolding. Don't be discouraged if you haven't 'arrived' yet or if you still see areas for improvement. The journey itself is where the beauty lies – in the learning, the stretching, the becoming.\nBe patient and compassionate with yourself. Celebrate every small step of progress. Trust that a divine hand is guiding your evolution, shaping you into an ever-more radiant expression of your unique potential. Each day offers a new chance to learn, to love more deeply, and to become more fully who you were created to be.",
    prayerDeclaration: "Divine Potter, thank You for the ongoing work You are doing in me. I embrace the journey of becoming with patience and joy. I declare that I am evolving, growing stronger, and unfolding into the magnificent being You designed me to be. Amen!",
  ),
  const Devotional(
    title: "Radiate Positive Energy",
    coreMessage: "Your energy is contagious. Choose to radiate positivity, hope, and love, and watch how it transforms your environment and interactions.",
    scriptureFocus: "Let your light so shine before men, that they may see your good works and glorify your Father in heaven.",
    scriptureReference: "Matthew 5:16 NKJV",
    reflection: "We all emit an energy, a vibration, that affects those around us. When you consciously choose to cultivate positive thoughts and emotions – gratitude, joy, love, hope – you become a source of uplifting energy. This positivity not only benefits you but also has the power to elevate the atmosphere wherever you go.\nBe mindful of the energy you're bringing into your interactions today. A warm smile, an encouraging word, a compassionate presence can make a significant difference. As you radiate good, you'll find that good is often reflected back to you, creating a beautiful cycle of positive exchange.",
    prayerDeclaration: "Source of Light, fill me with Your positive energy today. May I radiate hope, love, and joy to everyone I encounter. I declare that my presence is a blessing, uplifting and inspiring others. Amen!",
  ),
  const Devotional(
    title: "The Wisdom of Listening",
    coreMessage: "True wisdom often comes not from speaking, but from deeply listening – to others, to your intuition, and to the still, small voice within.",
    scriptureFocus: "My dear brothers and sisters, take note of this: Everyone should be quick to listen, slow to speak and slow to become angry.",
    scriptureReference: "James 1:19 NIV",
    reflection: "In our fast-paced world, it's easy to get caught up in expressing our own views. But profound insights and deeper connections are often found when we cultivate the art of listening. Listening with an open heart to another person can build bridges of understanding and compassion. Listening to our own intuition can guide us towards our truest path. And listening in moments of quiet contemplation can connect us with divine wisdom.\nPractice active, empathetic listening today. Seek to understand rather than just to be understood. You might be surprised by the wisdom and guidance that emerge when you create space for true hearing.",
    prayerDeclaration: "Spirit of Wisdom, help me to be a better listener today – to others, to my inner guidance, and to You. I open my heart and mind to receive the insights that come through quiet attention. May I learn and grow through the power of listening. Amen!",
  ),
  const Devotional(
    title: "Step Out of Your Comfort Zone",
    coreMessage: "Your greatest growth often lies just outside your comfort zone. Dare to take a step into the new and unknown today!",
    scriptureFocus: "For God did not give us a spirit of timidity, but a spirit of power, of love and of self-discipline.",
    scriptureReference: "2 Timothy 1:7 NIV (variant)",
    reflection: "It's natural to seek comfort and familiarity. But if we stay only where we're comfortable, we limit our potential for growth and new experiences. The universe is always inviting us to stretch, to learn, to expand. Often, the very things that feel a bit intimidating are the gateways to our next level of development and blessing.\nIdentify one small area today where you can step just outside your comfort zone. Maybe it's speaking up, trying something new, or reaching out. Remember, you are equipped with a spirit of power and love, not fear. Embrace the stretch!",
    prayerDeclaration: "Empowering Presence, grant me the courage to step beyond my comfort zone today. I release fear and embrace the opportunity to grow, learn, and discover new strengths. I declare I am expanding into my fullest potential. Amen!",
  ),
  const Devotional(
    title: "The Tapestry of Your Life",
    coreMessage: "Every thread – every joy, sorrow, success, and challenge – is being woven into the beautiful and unique tapestry of your life.",
    scriptureFocus: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
    scriptureReference: "Romans 8:28 NIV",
    reflection: "From our limited perspective, some experiences in life may seem random, out of place, or even negative. But from a higher viewpoint, every single thread is essential to the overall design of the masterpiece that is your life. The darker threads often provide the contrast that makes the brighter ones shine even more brilliantly.\nTrust the Divine Weaver. Know that even the challenging experiences are contributing to your strength, wisdom, and compassion. Embrace the whole tapestry, with its varied colors and textures, for it is uniquely yours and wonderfully made, contributing to the beauty of the whole creation.",
    prayerDeclaration: "Master Weaver, I trust Your design for my life. Thank You for weaving every experience into a beautiful tapestry that serves a higher purpose. I embrace all of it with gratitude and faith, knowing it contributes to my growth and the good I can share. Amen!",
  ),
  const Devotional(
    title: "Find Joy in the Simple Things",
    coreMessage: "True joy isn't always in grand events, but often hidden in the simple, everyday moments. Open your eyes to the beauty around you.",
    scriptureFocus: "Rejoice always, pray continually, give thanks in all circumstances; for this is God’s will for you in Christ Jesus.",
    scriptureReference: "1 Thessalonians 5:16-18 NIV",
    reflection: "We often chase big excitements, thinking joy resides only in major achievements or extraordinary experiences. While those are wonderful, lasting joy can also be found in the simple, often overlooked, gifts of daily life: a sunrise, a shared laugh, a moment of peace, the beauty of nature, a kind gesture.\nCultivate an awareness of these simple joys. Practice mindfulness and gratitude for the present moment. When you learn to find happiness in the everyday, your life becomes richer and more consistently joyful, and you become a source of that simple joy for others.",
    prayerDeclaration: "Giver of Joy, help me to find and appreciate the simple blessings and joys in my life today. I open my heart to the beauty of the present moment. I declare that my life is filled with moments of delight and gratitude. Amen!",
  ),
  const Devotional(
    title: "Your Unique Contribution Matters",
    coreMessage: "You have a unique contribution to make to the world that no one else can. Embrace your gifts and share them authentically.",
    scriptureFocus: "Each of you should use whatever gift you have received to serve others, as faithful stewards of God’s grace in its various forms.",
    scriptureReference: "1 Peter 4:10 NIV",
    reflection: "Don't ever think that what you have to offer is insignificant. Your unique blend of talents, experiences, passions, and perspectives is needed in the world. Whether your contribution seems big or small in your own eyes, it has value and can make a real difference in the lives of others and in the collective good.\nIdentify your gifts – what comes naturally to you? What do you love to do? How can you use these to serve, to create, to uplift? Step out and share your authentic self. The world is waiting for your unique expression.",
    prayerDeclaration: "Divine Gifter, thank You for the unique gifts and abilities You've entrusted to me. I commit to using them faithfully to serve others and to make a positive contribution to the world. I declare that my unique offering matters. Amen!",
  ),
  const Devotional(
    title: "The Healing Power of Nature",
    coreMessage: "Connect with the natural world today. Its beauty, resilience, and rhythms have a profound power to heal, restore, and inspire.",
    scriptureFocus: "The heavens declare the glory of God; the skies proclaim the work of his hands.",
    scriptureReference: "Psalm 19:1 NIV",
    reflection: "In our often-hectic, screen-filled lives, it's easy to become disconnected from the natural world. Yet, nature holds immense wisdom and healing energy. A walk in the park, the sight of a blooming flower, the sound of birdsong, the feeling of the sun on your skin – these simple experiences can soothe the soul, calm the mind, and reconnect you to something vast and beautiful.\nMake an effort to spend some time in nature today, even if it's just for a few moments. Observe its details, breathe in its freshness, and allow its inherent harmony to restore your own. It's a direct connection to the Creator's artistry.",
    prayerDeclaration: "Creator of All, thank You for the healing beauty and wisdom of the natural world. I will take time today to connect with Your creation and allow its peace to restore my spirit. I declare my reverence for the Earth and all its wonders. Amen!",
  ),
  const Devotional(
    title: "Let Go and Let God/Good Flow",
    coreMessage: "Release your grip on trying to control everything. Surrender your worries, trust the process, and allow divine good to flow into your life.",
    scriptureFocus: "Cast all your anxiety on him because he cares for you.",
    scriptureReference: "1 Peter 5:7 NIV",
    reflection: "We often try to force outcomes, micromanage situations, and carry the weight of the world on our shoulders. This can lead to stress, anxiety, and a feeling of being overwhelmed. There's profound freedom and power in learning to let go, to surrender our tight grip, and to trust that a higher wisdom is at work.\nIdentify what you're trying too hard to control today. Consciously release it. Offer your worries and anxieties to the Divine. Trust that when you create space by letting go, you allow for better solutions, unexpected help, and a more peaceful flow of good to enter your life and the lives of those you care for.",
    prayerDeclaration: "All-Knowing Guide, I release my need to control. I surrender my worries and anxieties to You. I trust in Your perfect plan and timing. I declare that I am open and receptive to the flow of divine good in all areas of my life. Amen!",
  ),
  const Devotional(
    title: "The Strength of Gentleness",
    coreMessage: "True strength is often found not in force, but in gentleness, compassion, and understanding. Cultivate these qualities.",
    scriptureFocus: "Let your gentleness be evident to all. The Lord is near.",
    scriptureReference: "Philippians 4:5 NIV",
    reflection: "In a world that sometimes equates strength with aggression or dominance, it's important to remember the profound power of gentleness. A gentle word can diffuse anger, a compassionate touch can heal, and an understanding heart can build bridges. Gentleness is not weakness; it is strength under control, guided by love.\nPractice gentleness today – with yourself and with others. Respond with kindness even in challenging situations. Offer understanding where there is conflict. You'll find that this approach not only creates more peace in your interactions but also reveals a deeper, more resilient kind of strength within you and inspires it in others.",
    prayerDeclaration: "Gentle Spirit, cultivate in me a spirit of gentleness, compassion, and understanding. May my strength be expressed through kindness and empathy. I declare that my gentleness will be a healing and unifying force in my interactions today. Amen!",
  ),
  const Devotional(
    title: "Abundance is Your Birthright",
    coreMessage: "You were created to experience abundance in all its forms – love, joy, health, peace, and provision. Claim it!",
    scriptureFocus: "The thief comes only to steal and kill and destroy; I have come that they may have life, and have it to the full.",
    scriptureReference: "John 10:10 NIV",
    reflection: "Sometimes, limiting beliefs or past experiences can make us feel unworthy or that abundance is for others, not for us. But the truth is, you are a child of a limitless Creator, and abundance in every good thing is your spiritual birthright. This isn't just about material wealth, but about a richness of spirit, overflowing joy, vibrant health, deep peace, and meaningful connections.\nChallenge any thoughts of lack or unworthiness. Affirm that you are open and receptive to the fullness of life. Expect good things, look for them, and be grateful for them. As you align with this truth, you'll begin to experience more of the abundant life you were designed for, and become a source of that abundance for the world.",
    prayerDeclaration: "Giver of Abundant Life, I claim my birthright of abundance in all its forms! I release any beliefs in lack or limitation. I declare that I am worthy and receptive to overflowing love, joy, health, peace, and provision, and I will share these generously. Amen!",
  ),
  const Devotional(
    title: "Listen to Your Heart's Song",
    coreMessage: "Your heart has a unique song, a calling that resonates with your deepest truth. Listen closely and dare to follow its melody.",
    scriptureFocus: "Delight yourself in the LORD, and he will give you the desires of your heart.",
    scriptureReference: "Psalm 37:4 ESV",
    reflection: "Amidst the noise and expectations of the world, it's easy to lose touch with the quiet song of your own heart – your true passions, your deepest desires, the unique path that brings you alive. This inner melody is a form of divine guidance, leading you towards your most authentic and fulfilling life.\nTake time to listen. What truly excites you? What makes your spirit soar? What quiet nudges are you feeling? Don't dismiss these as impractical or unimportant. When you align your life with your heart's song, you find not only personal joy but also your greatest capacity to contribute meaningfully to others.",
    prayerDeclaration: "Divine Composer, help me to hear and follow the unique song of my heart today. I trust its melody to guide me towards my truest purpose and greatest joy. I declare that I am courageously aligning my life with my deepest passions and callings. Amen!",
  ),
  const Devotional(
    title: "Today's Miracles Await",
    coreMessage: "Approach today with an open heart and expectant spirit, for miracles, big and small, are always possible and waiting to unfold.",
    scriptureFocus: "Jesus said to them, 'Have faith in God. Truly, I say to you, whoever says to this mountain, ‘Be taken up and thrown into the sea,’ and does not doubt in his heart, but believes that what he says will come to pass, it will be done for him.'",
    scriptureReference: "Mark 11:22-23 ESV",
    reflection: "We often think of miracles as grand, rare events. But a miracle is simply an experience of divine intervention, a shift in perception, or an unexpected blessing that transcends ordinary understanding. These can happen every day, in ways both subtle and profound, if we are open to them.\nCultivate an atmosphere of expectancy. Believe in the possibility of good surprises, of healing, of provision, of loving connections appearing in your life. Speak words of faith over your challenges. An open and believing heart is a powerful invitation for everyday miracles to manifest, not only for you but as a testament to what's possible for all.",
    prayerDeclaration: "Worker of Wonders, I approach this day with an open heart, expecting to witness Your miracles. I believe in Your power to transform situations and bring unexpected blessings. I declare that I am attuned to the miraculous, ready to receive and share Your goodness. Amen!",
  ),
];

Future<Devotional> getDevotionalOfTheDay() async {
  if (allDevotionals.isEmpty) {
    return const Devotional(
        title: "No Devotional Available",
        coreMessage: "Please check back later.",
        scriptureFocus: "",
        scriptureReference: "",
        reflection: "Content is being updated.",
        prayerDeclaration: "");
  }

  // Ensure PrefsHelper is initialized (usually in main.dart, but good practice)
  // await PrefsHelper.init(); // Not strictly needed here if already done in main

  String currentDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? lastDateStr = PrefsHelper.getLastDevotionalDate();
  int lastIndex = PrefsHelper.getLastDevotionalIndex();
  int newIndex = 0;

  if (lastDateStr == currentDateStr && lastIndex >= 0 && lastIndex < allDevotionals.length) {
    // Same day, and valid lastIndex: show the same devotional
    newIndex = lastIndex;
  } else {
    // New day or first time / invalid index: get next devotional
    newIndex = (lastIndex + 1) % allDevotionals.length;
    await PrefsHelper.setLastDevotionalDate(currentDateStr);
    await PrefsHelper.setLastDevotionalIndex(newIndex);
  }
  
  // Safety check for index bounds, though modulo should handle it with non-empty list
  if (newIndex < 0 || newIndex >= allDevotionals.length) {
      newIndex = 0; // Default to first if something went wrong
      // Also update prefs if we had to reset
      if (lastDateStr != currentDateStr || PrefsHelper.getLastDevotionalIndex() != 0){
          await PrefsHelper.setLastDevotionalDate(currentDateStr);
          await PrefsHelper.setLastDevotionalIndex(newIndex);
      }
  }

  return allDevotionals[newIndex];
}

// --- NEW: Developer function to force the next devotional ---
Future<Devotional> forceNextDevotional() async {
  if (allDevotionals.isEmpty) {
    return const Devotional(
        title: "No Devotional Available",
        coreMessage: "Please check back later.",
        scriptureFocus: "",
        scriptureReference: "",
        reflection: "Content is being updated.",
        prayerDeclaration: "");
  }
  
  int lastIndex = PrefsHelper.getLastDevotionalIndex();
  int newIndex = (lastIndex + 1) % allDevotionals.length;
  
  // Update prefs to reflect this forced change as if it's a new day
  String currentDateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  await PrefsHelper.setLastDevotionalDate(currentDateStr); // Set to today
  await PrefsHelper.setLastDevotionalIndex(newIndex);
  
  print("Forced next devotional. New index: $newIndex");
  return allDevotionals[newIndex];
}


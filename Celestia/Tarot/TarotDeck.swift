import Foundation

enum TarotCard: String, CaseIterable, Codable {

    // MARK: - Major Arcana (22)

    case theFool
    case theMagician
    case theHighPriestess
    case theEmpress
    case theEmperor
    case theHierophant
    case theLovers
    case theChariot
    case strength
    case theHermit
    case wheelOfFortune
    case justice
    case theHangedMan
    case death
    case temperance
    case theDevil
    case theTower
    case theStar
    case theMoon
    case theSun
    case judgement
    case theWorld

    // MARK: - Wands (14)

    case aceOfWands
    case twoOfWands
    case threeOfWands
    case fourOfWands
    case fiveOfWands
    case sixOfWands
    case sevenOfWands
    case eightOfWands
    case nineOfWands
    case tenOfWands
    case pageOfWands
    case knightOfWands
    case queenOfWands
    case kingOfWands

    // MARK: - Cups (14)

    case aceOfCups
    case twoOfCups
    case threeOfCups
    case fourOfCups
    case fiveOfCups
    case sixOfCups
    case sevenOfCups
    case eightOfCups
    case nineOfCups
    case tenOfCups
    case pageOfCups
    case knightOfCups
    case queenOfCups
    case kingOfCups

    // MARK: - Swords (14)

    case aceOfSwords
    case twoOfSwords
    case threeOfSwords
    case fourOfSwords
    case fiveOfSwords
    case sixOfSwords
    case sevenOfSwords
    case eightOfSwords
    case nineOfSwords
    case tenOfSwords
    case pageOfSwords
    case knightOfSwords
    case queenOfSwords
    case kingOfSwords

    // MARK: - Pentacles (14)

    case aceOfPentacles
    case twoOfPentacles
    case threeOfPentacles
    case fourOfPentacles
    case fiveOfPentacles
    case sixOfPentacles
    case sevenOfPentacles
    case eightOfPentacles
    case nineOfPentacles
    case tenOfPentacles
    case pageOfPentacles
    case knightOfPentacles
    case queenOfPentacles
    case kingOfPentacles

    // MARK: - Computed Properties

    var isMajor: Bool {
        switch self {
        case .theFool, .theMagician, .theHighPriestess, .theEmpress,
             .theEmperor, .theHierophant, .theLovers, .theChariot,
             .strength, .theHermit, .wheelOfFortune, .justice,
             .theHangedMan, .death, .temperance, .theDevil,
             .theTower, .theStar, .theMoon, .theSun,
             .judgement, .theWorld:
            return true
        default:
            return false
        }
    }

    var name: String {
        switch self {
        // Major Arcana
        case .theFool: return "The Fool"
        case .theMagician: return "The Magician"
        case .theHighPriestess: return "The High Priestess"
        case .theEmpress: return "The Empress"
        case .theEmperor: return "The Emperor"
        case .theHierophant: return "The Hierophant"
        case .theLovers: return "The Lovers"
        case .theChariot: return "The Chariot"
        case .strength: return "Strength"
        case .theHermit: return "The Hermit"
        case .wheelOfFortune: return "Wheel of Fortune"
        case .justice: return "Justice"
        case .theHangedMan: return "The Hanged Man"
        case .death: return "Death"
        case .temperance: return "Temperance"
        case .theDevil: return "The Devil"
        case .theTower: return "The Tower"
        case .theStar: return "The Star"
        case .theMoon: return "The Moon"
        case .theSun: return "The Sun"
        case .judgement: return "Judgement"
        case .theWorld: return "The World"
        // Wands
        case .aceOfWands: return "Ace of Wands"
        case .twoOfWands: return "Two of Wands"
        case .threeOfWands: return "Three of Wands"
        case .fourOfWands: return "Four of Wands"
        case .fiveOfWands: return "Five of Wands"
        case .sixOfWands: return "Six of Wands"
        case .sevenOfWands: return "Seven of Wands"
        case .eightOfWands: return "Eight of Wands"
        case .nineOfWands: return "Nine of Wands"
        case .tenOfWands: return "Ten of Wands"
        case .pageOfWands: return "Page of Wands"
        case .knightOfWands: return "Knight of Wands"
        case .queenOfWands: return "Queen of Wands"
        case .kingOfWands: return "King of Wands"
        // Cups
        case .aceOfCups: return "Ace of Cups"
        case .twoOfCups: return "Two of Cups"
        case .threeOfCups: return "Three of Cups"
        case .fourOfCups: return "Four of Cups"
        case .fiveOfCups: return "Five of Cups"
        case .sixOfCups: return "Six of Cups"
        case .sevenOfCups: return "Seven of Cups"
        case .eightOfCups: return "Eight of Cups"
        case .nineOfCups: return "Nine of Cups"
        case .tenOfCups: return "Ten of Cups"
        case .pageOfCups: return "Page of Cups"
        case .knightOfCups: return "Knight of Cups"
        case .queenOfCups: return "Queen of Cups"
        case .kingOfCups: return "King of Cups"
        // Swords
        case .aceOfSwords: return "Ace of Swords"
        case .twoOfSwords: return "Two of Swords"
        case .threeOfSwords: return "Three of Swords"
        case .fourOfSwords: return "Four of Swords"
        case .fiveOfSwords: return "Five of Swords"
        case .sixOfSwords: return "Six of Swords"
        case .sevenOfSwords: return "Seven of Swords"
        case .eightOfSwords: return "Eight of Swords"
        case .nineOfSwords: return "Nine of Swords"
        case .tenOfSwords: return "Ten of Swords"
        case .pageOfSwords: return "Page of Swords"
        case .knightOfSwords: return "Knight of Swords"
        case .queenOfSwords: return "Queen of Swords"
        case .kingOfSwords: return "King of Swords"
        // Pentacles
        case .aceOfPentacles: return "Ace of Pentacles"
        case .twoOfPentacles: return "Two of Pentacles"
        case .threeOfPentacles: return "Three of Pentacles"
        case .fourOfPentacles: return "Four of Pentacles"
        case .fiveOfPentacles: return "Five of Pentacles"
        case .sixOfPentacles: return "Six of Pentacles"
        case .sevenOfPentacles: return "Seven of Pentacles"
        case .eightOfPentacles: return "Eight of Pentacles"
        case .nineOfPentacles: return "Nine of Pentacles"
        case .tenOfPentacles: return "Ten of Pentacles"
        case .pageOfPentacles: return "Page of Pentacles"
        case .knightOfPentacles: return "Knight of Pentacles"
        case .queenOfPentacles: return "Queen of Pentacles"
        case .kingOfPentacles: return "King of Pentacles"
        }
    }

    var uprightMeaning: String {
        switch self {
        // Major Arcana
        case .theFool: return "New beginnings, innocence, and a leap of faith. Trust the journey ahead."
        case .theMagician: return "Manifestation, willpower, and resourcefulness. You have everything you need."
        case .theHighPriestess: return "Intuition, mystery, and the subconscious. Listen to your inner voice."
        case .theEmpress: return "Abundance, nurturing, and fertility. Creation flows through you."
        case .theEmperor: return "Authority, structure, and stability. Take control with confidence."
        case .theHierophant: return "Tradition, spiritual guidance, and conformity. Seek wisdom from mentors."
        case .theLovers: return "Love, harmony, and meaningful choices. Follow your heart's truth."
        case .theChariot: return "Determination, willpower, and triumph. Victory through focused effort."
        case .strength: return "Inner courage, patience, and compassion. Gentle power overcomes all."
        case .theHermit: return "Introspection, solitude, and inner guidance. The answers lie within."
        case .wheelOfFortune: return "Destiny, turning points, and cycles. Change is the only constant."
        case .justice: return "Fairness, truth, and accountability. Balance will be restored."
        case .theHangedMan: return "Surrender, new perspective, and letting go. Pause brings clarity."
        case .death: return "Transformation, endings, and renewal. What ends makes space for rebirth."
        case .temperance: return "Balance, moderation, and patience. Harmony comes through integration."
        case .theDevil: return "Bondage, materialism, and shadow self. Recognize what chains you."
        case .theTower: return "Sudden upheaval, revelation, and liberation. Destruction clears the path."
        case .theStar: return "Hope, inspiration, and serenity. Healing light shines after darkness."
        case .theMoon: return "Illusion, fear, and the subconscious. Navigate uncertainty with intuition."
        case .theSun: return "Joy, success, and vitality. Radiant energy illuminates your path."
        case .judgement: return "Rebirth, inner calling, and absolution. Rise to your highest self."
        case .theWorld: return "Completion, accomplishment, and wholeness. A cycle reaches fulfillment."
        // Wands
        case .aceOfWands: return "Creative spark, new inspiration, bold initiative."
        case .twoOfWands: return "Planning ahead, making decisions, future vision."
        case .threeOfWands: return "Expansion, foresight, overseas opportunities."
        case .fourOfWands: return "Celebration, harmony, homecoming joy."
        case .fiveOfWands: return "Competition, conflict, diverse viewpoints clashing."
        case .sixOfWands: return "Victory, recognition, public acclaim."
        case .sevenOfWands: return "Defiance, perseverance, standing your ground."
        case .eightOfWands: return "Swift action, momentum, rapid progress."
        case .nineOfWands: return "Resilience, persistence, last stand courage."
        case .tenOfWands: return "Heavy burdens, responsibility, near completion."
        case .pageOfWands: return "Enthusiasm, exploration, free spirit."
        case .knightOfWands: return "Adventure, impulsiveness, passionate pursuit."
        case .queenOfWands: return "Confidence, warmth, determined leadership."
        case .kingOfWands: return "Visionary leader, bold entrepreneur, charisma."
        // Cups
        case .aceOfCups: return "New love, compassion, emotional awakening."
        case .twoOfCups: return "Partnership, mutual attraction, deep connection."
        case .threeOfCups: return "Friendship, celebration, community joy."
        case .fourOfCups: return "Contemplation, apathy, missed opportunities."
        case .fiveOfCups: return "Loss, grief, focusing on what remains."
        case .sixOfCups: return "Nostalgia, childhood memories, innocence."
        case .sevenOfCups: return "Fantasy, choices, wishful thinking."
        case .eightOfCups: return "Walking away, seeking deeper meaning."
        case .nineOfCups: return "Wish fulfillment, contentment, emotional satisfaction."
        case .tenOfCups: return "Harmony, family bliss, lasting happiness."
        case .pageOfCups: return "Creative messages, intuitive insights, dreamer."
        case .knightOfCups: return "Romance, charm, following the heart."
        case .queenOfCups: return "Emotional depth, compassion, nurturing intuition."
        case .kingOfCups: return "Emotional balance, diplomacy, calm wisdom."
        // Swords
        case .aceOfSwords: return "Mental clarity, breakthrough, raw truth."
        case .twoOfSwords: return "Indecision, stalemate, difficult choices ahead."
        case .threeOfSwords: return "Heartbreak, sorrow, painful truth revealed."
        case .fourOfSwords: return "Rest, recovery, quiet contemplation needed."
        case .fiveOfSwords: return "Conflict, defeat, hollow victory."
        case .sixOfSwords: return "Transition, moving on, calmer waters ahead."
        case .sevenOfSwords: return "Deception, strategy, getting away with something."
        case .eightOfSwords: return "Feeling trapped, self-imposed restrictions, victim mindset."
        case .nineOfSwords: return "Anxiety, nightmares, overwhelming worry."
        case .tenOfSwords: return "Rock bottom, painful ending, inevitable conclusion."
        case .pageOfSwords: return "Curiosity, restlessness, new ideas emerging."
        case .knightOfSwords: return "Ambition, fast action, charging ahead."
        case .queenOfSwords: return "Clear boundaries, independence, honest communication."
        case .kingOfSwords: return "Intellectual authority, truth, analytical mind."
        // Pentacles
        case .aceOfPentacles: return "New financial opportunity, prosperity seed planted."
        case .twoOfPentacles: return "Juggling priorities, adaptability, balancing resources."
        case .threeOfPentacles: return "Teamwork, skilled collaboration, mastery in progress."
        case .fourOfPentacles: return "Security, control, holding on tightly."
        case .fiveOfPentacles: return "Hardship, isolation, financial worry."
        case .sixOfPentacles: return "Generosity, charity, giving and receiving."
        case .sevenOfPentacles: return "Patience, long-term investment, assessing progress."
        case .eightOfPentacles: return "Diligence, craftsmanship, skill development."
        case .nineOfPentacles: return "Luxury, self-sufficiency, enjoying rewards."
        case .tenOfPentacles: return "Legacy, wealth, family prosperity."
        case .pageOfPentacles: return "Ambition, desire to learn, new venture."
        case .knightOfPentacles: return "Hard work, routine, steady reliable progress."
        case .queenOfPentacles: return "Practicality, nurturing abundance, grounded comfort."
        case .kingOfPentacles: return "Wealth, business acumen, disciplined success."
        }
    }

    var reversedMeaning: String {
        switch self {
        // Major Arcana
        case .theFool: return "Recklessness, risk-taking, and naivety. Look before you leap."
        case .theMagician: return "Manipulation, trickery, and untapped potential. Beware of illusions."
        case .theHighPriestess: return "Secrets, disconnection from intuition. Trust is clouded."
        case .theEmpress: return "Creative block, dependence, and neglect. Nurture yourself first."
        case .theEmperor: return "Tyranny, rigidity, and loss of control. Flex before you break."
        case .theHierophant: return "Rebellion, unorthodoxy, and challenging the status quo."
        case .theLovers: return "Disharmony, imbalance, and misaligned values. Reassess your choices."
        case .theChariot: return "Lack of direction, aggression, and scattered energy. Refocus."
        case .strength: return "Self-doubt, weakness, and insecurity. Reclaim your inner power."
        case .theHermit: return "Isolation, loneliness, and withdrawal. Reconnect with the world."
        case .wheelOfFortune: return "Bad luck, resistance to change. Flow with the current."
        case .justice: return "Injustice, dishonesty, and lack of accountability."
        case .theHangedMan: return "Stalling, resistance, and needless sacrifice. Stop martyring yourself."
        case .death: return "Resistance to change, stagnation. Let go of what no longer serves."
        case .temperance: return "Imbalance, excess, and impatience. Realign your energies."
        case .theDevil: return "Breaking free, reclaiming power, detachment from toxicity."
        case .theTower: return "Fear of change, averting disaster, delayed upheaval."
        case .theStar: return "Despair, disconnection, and lost faith. Rekindle your hope."
        case .theMoon: return "Releasing fear, clarity emerging, truth surfaces."
        case .theSun: return "Temporary sadness, lack of clarity. The light will return."
        case .judgement: return "Self-doubt, refusal of the call. Don't ignore your purpose."
        case .theWorld: return "Incompletion, shortcuts, and lack of closure. Finish what you started."
        // Wands
        case .aceOfWands: return "Delays, lack of motivation, false starts."
        case .twoOfWands: return "Fear of the unknown, poor planning."
        case .threeOfWands: return "Obstacles to progress, limited thinking."
        case .fourOfWands: return "Instability, broken celebrations, tension at home."
        case .fiveOfWands: return "Avoiding conflict, inner turmoil, compromise."
        case .sixOfWands: return "Ego, fall from grace, private achievement."
        case .sevenOfWands: return "Giving up, overwhelmed, losing ground."
        case .eightOfWands: return "Delays, frustration, scattered energy."
        case .nineOfWands: return "Exhaustion, paranoia, stubbornness."
        case .tenOfWands: return "Burnout, refusing to delegate, collapse."
        case .pageOfWands: return "Lack of direction, setbacks, hasty decisions."
        case .knightOfWands: return "Recklessness, haste, scattered energy."
        case .queenOfWands: return "Jealousy, selfishness, demanding nature."
        case .kingOfWands: return "Impulsiveness, overbearing, ruthless ambition."
        // Cups
        case .aceOfCups: return "Blocked emotions, emptiness, repressed feelings."
        case .twoOfCups: return "Imbalance in relationship, broken trust."
        case .threeOfCups: return "Overindulgence, gossip, isolation."
        case .fourOfCups: return "Sudden awareness, accepting what is offered."
        case .fiveOfCups: return "Acceptance, moving on, finding peace."
        case .sixOfCups: return "Living in the past, unrealistic nostalgia."
        case .sevenOfCups: return "Clarity of purpose, making a decision."
        case .eightOfCups: return "Fear of moving on, stagnation."
        case .nineOfCups: return "Dissatisfaction, materialism, greed."
        case .tenOfCups: return "Broken family, misaligned values."
        case .pageOfCups: return "Emotional immaturity, creative block."
        case .knightOfCups: return "Moodiness, unrealistic expectations."
        case .queenOfCups: return "Emotional insecurity, codependency."
        case .kingOfCups: return "Emotional manipulation, volatility."
        // Swords
        case .aceOfSwords: return "Confusion, chaos, misuse of power."
        case .twoOfSwords: return "Information overload, impossible choice."
        case .threeOfSwords: return "Recovery, forgiveness, releasing pain."
        case .fourOfSwords: return "Restlessness, burnout, refusing to rest."
        case .fiveOfSwords: return "Reconciliation, making amends."
        case .sixOfSwords: return "Resistance to change, unfinished business."
        case .sevenOfSwords: return "Confession, conscience, getting caught."
        case .eightOfSwords: return "Self-acceptance, new perspective, freedom."
        case .nineOfSwords: return "Hope, reaching out, worst is over."
        case .tenOfSwords: return "Recovery, regeneration, lessons learned."
        case .pageOfSwords: return "All talk no action, hasty communication."
        case .knightOfSwords: return "Impulsiveness, no direction, burnout."
        case .queenOfSwords: return "Cold-hearted, bitter, overly critical."
        case .kingOfSwords: return "Abuse of power, manipulation, cruelty."
        // Pentacles
        case .aceOfPentacles: return "Missed opportunity, poor planning, instability."
        case .twoOfPentacles: return "Overwhelm, disorganization, financial mess."
        case .threeOfPentacles: return "Lack of teamwork, poor quality, disharmony."
        case .fourOfPentacles: return "Greed, materialism, financial insecurity."
        case .fiveOfPentacles: return "Recovery, spiritual wealth, turning corner."
        case .sixOfPentacles: return "Strings attached, one-sided generosity."
        case .sevenOfPentacles: return "Impatience, wasted effort, poor returns."
        case .eightOfPentacles: return "Lack of focus, perfectionism, shortcuts."
        case .nineOfPentacles: return "Over-investment in work, financial setback."
        case .tenOfPentacles: return "Family disputes, financial loss, instability."
        case .pageOfPentacles: return "Lack of progress, procrastination."
        case .knightOfPentacles: return "Stagnation, laziness, feeling stuck."
        case .queenOfPentacles: return "Work-life imbalance, neglecting self-care."
        case .kingOfPentacles: return "Financial loss, stubbornness, poor investments."
        }
    }
}

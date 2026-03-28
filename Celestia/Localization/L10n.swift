import Foundation

/// Centralized localization for all UI strings.
/// AI-generated readings are localized via PromptBuilder's language instruction.
/// This file handles static UI text localization.
struct L10n {
    let lang: AppLanguage

    // MARK: - Tabs

    var tabToday: String { s("Today", "Hoy", "Hoje", "今日", "오늘", "Aujourd'hui", "आज", "Heute", "今日", "今日") }
    var tabTarot: String { s("Tarot", "Tarot", "Tarô", "タロット", "타로", "Tarot", "टैरो", "Tarot", "塔羅", "塔罗") }
    var tabChat: String { s("Chat", "Chat", "Chat", "チャット", "채팅", "Chat", "चैट", "Chat", "聊天", "聊天") }
    var tabMatch: String { s("Match", "Sinastría", "Sinastria", "相性", "궁합", "Affinités", "मिलान", "Kompatibilität", "配對", "配对") }
    var tabProfile: String { s("Profile", "Perfil", "Perfil", "プロフィール", "프로필", "Profil", "प्रोफ़ाइल", "Profil", "個人資料", "个人资料") }

    // MARK: - Welcome / Onboarding

    var appName: String { "Caelus" }
    var welcomeSubtitle: String { s("Your Personal AI Astrologer", "Tu astrólogo personal de IA", "Seu astrólogo pessoal de IA", "あなた専属のAI占星術師", "나만의 AI 점성술사", "Votre astrologue IA personnel", "आपका निजी AI ज्योतिषी", "Dein persönlicher KI-Astrologe", "您的私人AI占星師", "您的私人AI占星师") }
    var welcomePrivacy: String { s("100% on-device · Your data never leaves your phone", "100% en dispositivo · Tus datos nunca salen de tu teléfono", "100% no dispositivo · Seus dados nunca saem do seu celular", "100%オンデバイス · データは端末から出ません", "100% 온디바이스 · 데이터가 기기를 떠나지 않습니다", "100% sur l'appareil · Vos données restent sur votre téléphone", "100% ऑन-डिवाइस · आपका डेटा आपके फ़ोन से बाहर नहीं जाता", "100% auf dem Gerät · Deine Daten verlassen nie dein Handy", "100%離線運行 · 您的資料不會離開手機", "100%离线运行 · 您的数据不会离开手机") }
    var beginJourney: String { s("Begin Your Journey", "Comienza tu viaje", "Comece sua jornada", "星の旅を始める", "여정을 시작하세요", "Commencez votre voyage", "अपनी यात्रा शुरू करें", "Beginne deine Reise", "開始您的旅程", "开始您的旅程") }
    var chooseLanguage: String { s("Choose Your Language", "Elige Tu Idioma", "Escolha Seu Idioma", "言語を選択", "언어를 선택하세요", "Choisissez Votre Langue", "अपनी भाषा चुनें", "Wähle Deine Sprache", "選擇您的語言", "选择您的语言") }
    var continueButton: String { s("Continue", "Continuar", "Continuar", "続ける", "계속", "Continuer", "जारी रखें", "Weiter", "繼續", "继续") }

    // MARK: - Birth Data

    var tellMeAboutYou: String { s("Tell Me About You", "Cuéntame Sobre Ti", "Conte-me Sobre Você", "あなたのことを教えて", "당신에 대해 알려주세요", "Parlez-moi de Vous", "अपने बारे में बताएं", "Erzähl mir von Dir", "告訴我關於你", "告诉我关于你") }
    var yourName: String { s("Your Name", "Tu Nombre", "Seu Nome", "お名前", "이름", "Votre Nom", "आपका नाम", "Dein Name", "您的名字", "您的名字") }
    var birthDate: String { s("Birth Date", "Fecha de Nacimiento", "Data de Nascimento", "生年月日", "생년월일", "Date de Naissance", "जन्म तिथि", "Geburtsdatum", "出生日期", "出生日期") }
    var birthTime: String { s("Birth Time (as exact as possible)", "Hora de Nacimiento (lo más exacta posible)", "Hora de Nascimento (o mais exata possível)", "出生時刻（できるだけ正確に）", "출생 시간 (가능한 정확하게)", "Heure de Naissance (aussi précise que possible)", "जन्म समय (जितना सटीक हो सके)", "Geburtszeit (so genau wie möglich)", "出生時間（盡可能精確）", "出生时间（尽可能精确）") }
    var birthCity: String { s("Birth City", "Ciudad de Nacimiento", "Cidade de Nascimento", "出生地", "출생 도시", "Ville de Naissance", "जन्म शहर", "Geburtsstadt", "出生城市", "出生城市") }
    var searchCity: String { s("Search city...", "Buscar ciudad...", "Buscar cidade...", "都市を検索...", "도시 검색...", "Rechercher une ville...", "शहर खोजें...", "Stadt suchen...", "搜尋城市...", "搜索城市...") }
    var revealChart: String { s("Reveal My Chart ✧", "Revelar Mi Carta ✧", "Revelar Meu Mapa ✧", "チャートを表示 ✧", "차트 공개 ✧", "Révéler Mon Thème ✧", "मेरा चार्ट दिखाएं ✧", "Mein Horoskop Enthüllen ✧", "揭示我的星盤 ✧", "揭示我的星盘 ✧") }
    var cosmicBlueprint: String { s("Your cosmic blueprint is ready", "Tu mapa cósmico está listo", "Seu mapa cósmico está pronto", "あなたの宇宙の設計図が完成", "당신의 우주 청사진이 완성되었습니다", "Votre carte cosmique est prête", "आपका ब्रह्मांडीय ब्लूप्रिंट तैयार है", "Dein kosmischer Plan ist bereit", "您的宇宙藍圖已就緒", "您的宇宙蓝图已就绪") }
    var exploreStars: String { s("Explore Your Stars", "Explora Tus Estrellas", "Explore Suas Estrelas", "星を探る", "별을 탐험하세요", "Explorez Vos Étoiles", "अपने सितारे खोजें", "Erkunde Deine Sterne", "探索您的星空", "探索您的星空") }

    // MARK: - Today View

    var readingStars: String { s("Reading the stars...", "Leyendo las estrellas...", "Lendo as estrelas...", "星を読んでいます...", "별을 읽고 있습니다...", "Lecture des étoiles...", "सितारे पढ़ रहे हैं...", "Die Sterne lesen...", "正在解讀星象...", "正在解读星象...") }
    var todaysReading: String { s("TODAY'S READING", "LECTURA DE HOY", "LEITURA DE HOJE", "今日の占い", "오늘의 리딩", "LECTURE DU JOUR", "आज का पठन", "HEUTIGE LESUNG", "今日運勢", "今日运势") }
    var cosmicEnergy: String { s("COSMIC ENERGY", "ENERGÍA CÓSMICA", "ENERGIA CÓSMICA", "宇宙エネルギー", "우주 에너지", "ÉNERGIE COSMIQUE", "ब्रह्मांडीय ऊर्जा", "KOSMISCHE ENERGIE", "宇宙能量", "宇宙能量") }
    var love: String { s("Love", "Amor", "Amor", "愛", "사랑", "Amour", "प्रेम", "Liebe", "愛情", "爱情") }
    var career: String { s("Career", "Carrera", "Carreira", "仕事", "직업", "Carrière", "करियर", "Karriere", "事業", "事业") }
    var health: String { s("Health", "Salud", "Saúde", "健康", "건강", "Santé", "स्वास्थ्य", "Gesundheit", "健康", "健康") }
    var spiritual: String { s("Spiritual", "Espiritual", "Espiritual", "精神", "영성", "Spirituel", "आध्यात्मिक", "Spirituell", "靈性", "灵性") }
    var stardust: String { s("Stardust", "Polvo Estelar", "Poeira Estelar", "スターダスト", "스타더스트", "Poussière d'Étoiles", "स्टारडस्ट", "Sternenstaub", "星塵", "星尘") }
    var dayStreak: String { s("day streak", "días seguidos", "dias seguidos", "日連続", "일 연속", "jours consécutifs", "दिन लगातार", "Tage in Folge", "天連續", "天连续") }
    var dailyStardust: String { s("Daily Stardust!", "¡Polvo Estelar Diario!", "Poeira Estelar Diária!", "デイリースターダスト！", "일일 스타더스트!", "Poussière d'Étoiles Quotidienne !", "दैनिक स्टारडस्ट!", "Täglicher Sternenstaub!", "每日星塵！", "每日星尘！") }

    // MARK: - Weekly

    var weeklyDeepReading: String { s("Weekly Deep Reading", "Lectura Profunda Semanal", "Leitura Profunda Semanal", "週間ディープリーディング", "주간 심층 리딩", "Lecture Approfondie Hebdomadaire", "साप्ताहिक गहन पठन", "Wöchentliche Tiefenlesung", "每週深度解讀", "每周深度解读") }
    var weeklySubtitle: String { s("A comprehensive forecast for your week ahead", "Un pronóstico completo para tu semana", "Uma previsão completa para sua semana", "今週の総合的な予報", "다가오는 한 주의 종합 예보", "Prévisions complètes pour votre semaine", "आपके आने वाले सप्ताह का व्यापक पूर्वानुमान", "Eine umfassende Prognose für deine Woche", "您一週的綜合預測", "您一周的综合预测") }
    var generateWeekly: String { s("Generate Weekly Reading", "Generar Lectura Semanal", "Gerar Leitura Semanal", "週間リーディングを生成", "주간 리딩 생성", "Générer la Lecture Hebdomadaire", "साप्ताहिक पठन बनाएं", "Wochenlesung Erstellen", "生成每週解讀", "生成每周解读") }
    var loveRelationships: String { s("Love & Relationships", "Amor y Relaciones", "Amor e Relacionamentos", "愛と人間関係", "사랑과 관계", "Amour et Relations", "प्रेम और संबंध", "Liebe & Beziehungen", "愛情與感情", "爱情与感情") }
    var careerFinances: String { s("Career & Finances", "Carrera y Finanzas", "Carreira e Finanças", "仕事と財務", "직업과 재정", "Carrière et Finances", "करियर और वित्त", "Karriere & Finanzen", "事業與財運", "事业与财运") }
    var healthWellness: String { s("Health & Wellness", "Salud y Bienestar", "Saúde e Bem-estar", "健康とウェルネス", "건강과 웰빙", "Santé et Bien-être", "स्वास्थ्य और कल्याण", "Gesundheit & Wohlbefinden", "健康與養生", "健康与养生") }
    var spiritualGrowth: String { s("Spiritual Growth", "Crecimiento Espiritual", "Crescimento Espiritual", "精神的成長", "영적 성장", "Croissance Spirituelle", "आध्यात्मिक विकास", "Spirituelles Wachstum", "靈性成長", "灵性成长") }
    var weekAhead: String { s("Week Ahead Prediction", "Predicción de la Semana", "Previsão da Semana", "来週の予測", "한 주 예측", "Prédiction de la Semaine", "आने वाले सप्ताह की भविष्यवाणी", "Wochenvorausschau", "本週預測", "本周预测") }
    var savedToJournal: String { s("Saved to Journal", "Guardado en Diario", "Salvo no Diário", "ジャーナルに保存", "일지에 저장됨", "Enregistré dans le Journal", "डायरी में सहेजा गया", "Im Tagebuch Gespeichert", "已儲存到日記", "已保存到日记") }
    var saveToJournal: String { s("Save to Journal", "Guardar en Diario", "Salvar no Diário", "ジャーナルに保存", "일지에 저장", "Enregistrer dans le Journal", "डायरी में सहेजें", "Im Tagebuch Speichern", "儲存到日記", "保存到日记") }

    // MARK: - Chat

    var chatCaelus: String { s("✧ Caelus", "✧ Caelus", "✧ Caelus", "✧ カエルス", "✧ 카엘루스", "✧ Caelus", "✧ कैलस", "✧ Caelus", "✧ Caelus", "✧ Caelus") }
    var unlimited: String { s("Unlimited ✧", "Ilimitado ✧", "Ilimitado ✧", "無制限 ✧", "무제한 ✧", "Illimité ✧", "असीमित ✧", "Unbegrenzt ✧", "無限 ✧", "无限 ✧") }
    var oneFreeToday: String { s("1 free today", "1 gratis hoy", "1 grátis hoje", "本日1回無料", "오늘 1회 무료", "1 gratuit aujourd'hui", "आज 1 मुफ़्त", "1 heute gratis", "今天1次免費", "今天1次免费") }
    var askCaelus: String { s("Ask Caelus...", "Pregúntale a Caelus...", "Pergunte ao Caelus...", "カエルスに聞く...", "카엘루스에게 물어보세요...", "Demandez à Caelus...", "कैलस से पूछें...", "Frage Caelus...", "詢問Caelus...", "询问Caelus...") }
    var consultingCosmos: String { s("Consulting the cosmos...", "Consultando el cosmos...", "Consultando o cosmos...", "宇宙に相談中...", "우주에 상담 중...", "Consultation du cosmos...", "ब्रह्मांड से परामर्श...", "Den Kosmos befragen...", "正在諮詢宇宙...", "正在咨询宇宙...") }

    // MARK: - Tarot

    var tarotReading: String { s("Tarot Reading", "Lectura de Tarot", "Leitura de Tarô", "タロットリーディング", "타로 리딩", "Tirage de Tarot", "टैरो रीडिंग", "Tarot-Lesung", "塔羅占卜", "塔罗占卜") }
    var tarotSubtitle: String { s("Let the cards reveal what the stars whisper", "Deja que las cartas revelen lo que susurran las estrellas", "Deixe as cartas revelarem o que as estrelas sussurram", "カードが星のささやきを明かします", "카드가 별의 속삭임을 드러냅니다", "Laissez les cartes révéler ce que murmurent les étoiles", "कार्ड बताएं कि सितारे क्या कहते हैं", "Lass die Karten enthüllen, was die Sterne flüstern", "讓牌卡揭示星星的低語", "让牌卡揭示星星的低语") }
    var yourQuestion: String { s("Your Question (optional)", "Tu Pregunta (opcional)", "Sua Pergunta (opcional)", "あなたの質問（任意）", "질문 (선택사항)", "Votre Question (facultatif)", "आपका प्रश्न (वैकल्पिक)", "Deine Frage (optional)", "您的問題（可選）", "您的问题（可选）") }
    var whatWeighs: String { s("What weighs on your mind?", "¿Qué pesa en tu mente?", "O que pesa na sua mente?", "何が気になっていますか？", "무엇이 마음에 걸리나요?", "Qu'est-ce qui vous préoccupe ?", "आपके मन में क्या है?", "Was beschäftigt dich?", "什麼事情在您心中？", "什么事情在您心中？") }
    var tapToReveal: String { s("Tap each card to reveal", "Toca cada carta para revelar", "Toque cada carta para revelar", "カードをタップして表示", "카드를 탭하여 공개", "Appuyez sur chaque carte", "प्रत्येक कार्ड टैप करें", "Tippe auf jede Karte", "點擊每張牌揭示", "点击每张牌揭示") }
    var notEnoughStardust: String { s("Not Enough Stardust", "Sin Suficiente Polvo Estelar", "Poeira Estelar Insuficiente", "スターダスト不足", "스타더스트 부족", "Pas Assez de Poussière d'Étoiles", "पर्याप्त स्टारडस्ट नहीं", "Nicht Genug Sternenstaub", "星塵不足", "星尘不足") }
    var newReading: String { s("New Reading", "Nueva Lectura", "Nova Leitura", "新しいリーディング", "새 리딩", "Nouveau Tirage", "नया पठन", "Neue Lesung", "新占卜", "新占卜") }
    var caelusInterpretation: String { s("Caelus' Interpretation", "Interpretación de Caelus", "Interpretação de Caelus", "カエルスの解釈", "카엘루스의 해석", "Interprétation de Caelus", "कैलस की व्याख्या", "Caelus' Deutung", "Caelus的牌義解析", "Caelus的牌义解析") }
    var starsAligning: String { s("The stars are aligning their wisdom...", "Las estrellas alinean su sabiduría...", "As estrelas alinham sua sabedoria...", "星が知恵を集めています...", "별들이 지혜를 모으고 있습니다...", "Les étoiles alignent leur sagesse...", "सितारे अपनी बुद्धि संरेखित कर रहे हैं...", "Die Sterne richten ihre Weisheit aus...", "星星正在匯聚智慧...", "星星正在汇聚智慧...") }
    var reversed: String { s("REVERSED", "INVERTIDA", "INVERTIDA", "逆位置", "역방향", "INVERSÉ", "उल्टा", "UMGEKEHRT", "逆位", "逆位") }

    // MARK: - Compatibility

    var compatibility: String { s("Compatibility", "Compatibilidad", "Compatibilidade", "相性", "궁합", "Compatibilité", "संगतता", "Kompatibilität", "配對", "配对") }
    var noConnections: String { s("No Connections Yet", "Sin Conexiones Aún", "Sem Conexões Ainda", "まだ接続がありません", "아직 연결이 없습니다", "Aucune Connexion", "अभी कोई कनेक्शन नहीं", "Noch Keine Verbindungen", "尚無配對", "尚无配对") }
    var addSomeone: String { s("Add someone to discover your cosmic compatibility", "Agrega a alguien para descubrir tu compatibilidad cósmica", "Adicione alguém para descobrir sua compatibilidade cósmica", "誰かを追加して宇宙の相性を発見", "누군가를 추가하여 우주적 궁합을 발견하세요", "Ajoutez quelqu'un pour découvrir votre compatibilité cosmique", "किसी को जोड़ें और अपनी ब्रह्मांडीय संगतता खोजें", "Füge jemanden hinzu, um deine kosmische Kompatibilität zu entdecken", "添加對象以發現你們的宇宙配對", "添加对象以发现你们的宇宙配对") }
    var addContact: String { s("Add Contact", "Agregar Contacto", "Adicionar Contato", "連絡先を追加", "연락처 추가", "Ajouter un Contact", "संपर्क जोड़ें", "Kontakt Hinzufügen", "新增聯繫人", "新增联系人") }
    var delete: String { s("Delete", "Eliminar", "Excluir", "削除", "삭제", "Supprimer", "हटाएं", "Löschen", "刪除", "删除") }
    var you: String { s("You", "Tú", "Você", "あなた", "당신", "Vous", "आप", "Du", "你", "你") }
    var caelusReading: String { s("Caelus' Reading", "Lectura de Caelus", "Leitura de Caelus", "カエルスのリーディング", "카엘루스의 리딩", "Tirage de Caelus", "कैलस की रीडिंग", "Caelus' Legung", "Caelus的占卜", "Caelus的占卜") }
    var advice: String { s("Advice", "Consejo", "Conselho", "アドバイス", "조언", "Conseil", "सलाह", "Ratschlag", "建議", "建议") }
    var readingStarsTogether: String { s("Reading your stars together...", "Leyendo sus estrellas juntos...", "Lendo suas estrelas juntos...", "一緒に星を読んでいます...", "함께 별을 읽고 있습니다...", "Lecture de vos étoiles ensemble...", "आपके सितारे एक साथ पढ़ रहे हैं...", "Eure Sterne zusammen lesen...", "正在一起解讀你們的星象...", "正在一起解读你们的星象...") }

    // MARK: - Contact Form

    var name: String { s("Name", "Nombre", "Nome", "名前", "이름", "Nom", "नाम", "Name", "姓名", "姓名") }
    var theirName: String { s("Their name", "Su nombre", "Nome deles", "相手の名前", "상대방 이름", "Leur nom", "उनका नाम", "Ihr Name", "對方的名字", "对方的名字") }
    var relationship: String { s("Relationship", "Relación", "Relacionamento", "関係", "관계", "Relation", "संबंध", "Beziehung", "關係", "关系") }
    var partner: String { s("Partner", "Pareja", "Parceiro", "パートナー", "파트너", "Partenaire", "साथी", "Partner", "伴侶", "伴侣") }
    var friend: String { s("Friend", "Amigo", "Amigo", "友人", "친구", "Ami", "मित्र", "Freund", "朋友", "朋友") }
    var family: String { s("Family", "Familia", "Família", "家族", "가족", "Famille", "परिवार", "Familie", "家人", "家人") }
    var crush: String { s("Crush", "Interés", "Crush", "好きな人", "짝사랑", "Béguin", "क्रश", "Schwarm", "暗戀", "暗恋") }
    var includeBirthTime: String { s("Include Birth Time", "Incluir Hora de Nacimiento", "Incluir Hora de Nascimento", "出生時刻を含む", "출생 시간 포함", "Inclure l'Heure de Naissance", "जन्म समय शामिल करें", "Geburtszeit Einbeziehen", "包含出生時間", "包含出生时间") }
    var cancel: String { s("Cancel", "Cancelar", "Cancelar", "キャンセル", "취소", "Annuler", "रद्द करें", "Abbrechen", "取消", "取消") }
    var save: String { s("Save", "Guardar", "Salvar", "保存", "저장", "Enregistrer", "सहेजें", "Speichern", "儲存", "保存") }

    // MARK: - Profile

    var profile: String { s("Profile", "Perfil", "Perfil", "プロフィール", "프로필", "Profil", "प्रोफ़ाइल", "Profil", "個人資料", "个人资料") }
    var yourPlanets: String { s("Your Planets", "Tus Planetas", "Seus Planetas", "あなたの惑星", "당신의 행성", "Vos Planètes", "आपके ग्रह", "Deine Planeten", "您的行星", "您的行星") }
    var streak: String { s("Streak", "Racha", "Sequência", "連続", "연속", "Série", "लगातार", "Serie", "連續", "连续") }
    var balance: String { s("Balance", "Saldo", "Saldo", "残高", "잔액", "Solde", "शेष", "Guthaben", "餘額", "余额") }
    var claimDaily: String { s("Claim Daily +2 ✦", "Reclamar Diario +2 ✦", "Resgatar Diário +2 ✦", "デイリー +2 ✦ を受け取る", "일일 +2 ✦ 받기", "Réclamer +2 ✦ Quotidien", "दैनिक +2 ✦ प्राप्त करें", "Täglich +2 ✦ Einlösen", "領取每日 +2 ✦", "领取每日 +2 ✦") }
    var starPassActive: String { s("Star Pass Active", "Star Pass Activo", "Star Pass Ativo", "スターパス有効", "스타 패스 활성", "Star Pass Actif", "स्टार पास सक्रिय", "Star Pass Aktiv", "星空通行證已啟用", "星空通行证已启用") }
    var freeTier: String { s("Free Tier", "Plan Gratuito", "Plano Gratuito", "無料プラン", "무료 플랜", "Gratuit", "मुफ़्त प्लान", "Kostenlos", "免費版", "免费版") }
    var upgrade: String { s("Upgrade", "Mejorar", "Melhorar", "アップグレード", "업그레이드", "Améliorer", "अपग्रेड", "Upgrade", "升級", "升级") }
    var referFriend: String { s("Refer a Friend", "Referir a un Amigo", "Indicar um Amigo", "友達を紹介", "친구 추천", "Parrainer un Ami", "मित्र को रेफ़र करें", "Freund Empfehlen", "推薦好友", "推荐好友") }
    var settings: String { s("Settings", "Configuración", "Configurações", "設定", "설정", "Paramètres", "सेटिंग्स", "Einstellungen", "設定", "设置") }
    var language: String { s("Language", "Idioma", "Idioma", "言語", "언어", "Langue", "भाषा", "Sprache", "語言", "语言") }

    // MARK: - Journal

    var journal: String { s("Journal", "Diario", "Diário", "ジャーナル", "일지", "Journal", "डायरी", "Tagebuch", "日記", "日记") }
    var journalAwaits: String { s("Your Journal Awaits", "Tu Diario Espera", "Seu Diário Aguarda", "ジャーナルが待っています", "일지가 기다리고 있습니다", "Votre Journal Vous Attend", "आपकी डायरी आपका इंतज़ार कर रही है", "Dein Tagebuch Wartet", "您的日記等待著您", "您的日记等待着您") }
    var journalEmpty: String { s("Your readings will appear here as a chronicle of your cosmic journey", "Tus lecturas aparecerán aquí como una crónica de tu viaje cósmico", "Suas leituras aparecerão aqui como uma crônica da sua jornada cósmica", "あなたの宇宙の旅の記録がここに表示されます", "당신의 우주 여행 연대기가 여기에 나타납니다", "Vos lectures apparaîtront ici comme une chronique de votre voyage cosmique", "आपकी रीडिंग आपकी ब्रह्मांडीय यात्रा की कालक्रम के रूप में यहां दिखाई देंगी", "Deine Lesungen erscheinen hier als Chronik deiner kosmischen Reise", "您的占卜記錄將在此顯示，作為您宇宙旅程的編年史", "您的占卜记录将在此显示，作为您宇宙旅程的编年史") }
    var dailyHoroscope: String { s("Daily Horoscope", "Horóscopo Diario", "Horóscopo Diário", "デイリーホロスコープ", "일일 운세", "Horoscope du Jour", "दैनिक राशिफल", "Tageshoroskop", "每日星座運勢", "每日星座运势") }
    var weeklyReading: String { s("Weekly Reading", "Lectura Semanal", "Leitura Semanal", "週間リーディング", "주간 리딩", "Lecture Hebdomadaire", "साप्ताहिक पठन", "Wochenlesung", "每週解讀", "每周解读") }
    var reading: String { s("Reading", "Lectura", "Leitura", "リーディング", "리딩", "Lecture", "पठन", "Lesung", "占卜", "占卜") }

    // MARK: - Referral

    var shareStars: String { s("Share the Stars", "Comparte las Estrellas", "Compartilhe as Estrelas", "星を共有", "별을 공유하세요", "Partagez les Étoiles", "सितारे साझा करें", "Teile die Sterne", "分享星空", "分享星空") }
    var inviteFriends: String { s("Invite Friends to Caelus", "Invita amigos a Caelus", "Convide amigos para o Caelus", "友達をCaelusに招待", "친구를 Caelus에 초대", "Invitez des amis sur Caelus", "दोस्तों को Caelus पर आमंत्रित करें", "Lade Freunde zu Caelus ein", "邀請朋友加入Caelus", "邀请朋友加入Caelus") }
    var referralReward: String { s("Both you and your friend earn 15 ✦ Stardust when they join and complete their birth chart.", "Tú y tu amigo ganan 15 ✦ cuando se unan y completen su carta natal.", "Você e seu amigo ganham 15 ✦ quando eles entram e completam seu mapa.", "友達が参加して出生チャートを完成させると、あなたと友達の両方に15 ✦が付与されます。", "친구가 가입하고 출생 차트를 완성하면 둘 다 15 ✦를 받습니다.", "Vous et votre ami gagnez 15 ✦ quand ils rejoignent et complètent leur thème.", "जब वे शामिल होते हैं तो आप और आपके मित्र दोनों 15 ✦ कमाते हैं।", "Du und dein Freund erhalten je 15 ✦ wenn sie beitreten.", "您和您的朋友在加入並完成星盤後各獲得15 ✦", "您和您的朋友在加入并完成星盘后各获得15 ✦") }
    var thisMonth: String { s("This Month", "Este Mes", "Este Mês", "今月", "이번 달", "Ce Mois", "इस महीने", "Diesen Monat", "本月", "本月") }
    var remaining: String { s("Remaining", "Restante", "Restante", "残り", "남은", "Restant", "शेष", "Verbleibend", "剩餘", "剩余") }
    var totalEarned: String { s("Total Earned", "Total Ganado", "Total Ganho", "合計獲得", "총 획득", "Total Gagné", "कुल अर्जित", "Gesamt Verdient", "累計獲得", "累计获得") }
    var copied: String { s("Copied!", "¡Copiado!", "Copiado!", "コピーしました！", "복사됨!", "Copié !", "कॉपी किया!", "Kopiert!", "已複製！", "已复制！") }
    var copy: String { s("Copy", "Copiar", "Copiar", "コピー", "복사", "Copier", "कॉपी", "Kopieren", "複製", "复制") }
    var shareInviteLink: String { s("Share Invite Link", "Compartir Enlace", "Compartilhar Link", "招待リンクを共有", "초대 링크 공유", "Partager le Lien", "लिंक साझा करें", "Link Teilen", "分享邀請連結", "分享邀请链接") }
    var referralHistory: String { s("Referral History", "Historial de Referidos", "Histórico de Indicações", "紹介履歴", "추천 이력", "Historique des Parrainages", "रेफ़रल इतिहास", "Empfehlungsverlauf", "推薦記錄", "推荐记录") }
    var friendJoined: String { s("Friend joined", "Amigo se unió", "Amigo entrou", "友達が参加", "친구가 가입", "Ami a rejoint", "मित्र शामिल हुए", "Freund beigetreten", "好友已加入", "好友已加入") }

    // MARK: - Paywall

    var unlockStars: String { s("Unlock the full power of the stars", "Desbloquea todo el poder de las estrellas", "Desbloqueie todo o poder das estrelas", "星の全力を解放", "별의 힘을 모두 해제하세요", "Débloquez toute la puissance des étoiles", "सितारों की पूरी शक्ति अनलॉक करें", "Entfessle die volle Kraft der Sterne", "解鎖星空的全部力量", "解锁星空的全部力量") }
    var stardustAndPass: String { s("Stardust & Star Pass", "Polvo Estelar y Star Pass", "Poeira Estelar e Star Pass", "スターダスト＆スターパス", "스타더스트 & 스타 패스", "Poussière d'Étoiles & Star Pass", "स्टारडस्ट और स्टार पास", "Sternenstaub & Star Pass", "星塵與星空通行證", "星尘与星空通行证") }
    var starPassIncludes: String { s("STAR PASS INCLUDES", "STAR PASS INCLUYE", "STAR PASS INCLUI", "スターパスに含まれるもの", "스타 패스 포함 내용", "STAR PASS COMPREND", "स्टार पास में शामिल", "STAR PASS BEINHALTET", "星空通行證包含", "星空通行证包含") }
    var monthlyStardust: String { s("80 ✦ Stardust every month", "80 ✦ Polvo Estelar cada mes", "80 ✦ Poeira Estelar todo mês", "毎月80 ✦ スターダスト", "매월 80 ✦ 스타더스트", "80 ✦ Poussière d'Étoiles chaque mois", "हर महीने 80 ✦ स्टारडस्ट", "80 ✦ Sternenstaub jeden Monat", "每月80 ✦ 星塵", "每月80 ✦ 星尘") }
    var unlimitedChat: String { s("Unlimited chat messages", "Mensajes de chat ilimitados", "Mensagens de chat ilimitadas", "チャットメッセージ無制限", "무제한 채팅 메시지", "Messages de chat illimités", "असीमित चैट संदेश", "Unbegrenzte Chat-Nachrichten", "無限聊天訊息", "无限聊天消息") }
    var detailedDaily: String { s("Detailed daily horoscope", "Horóscopo diario detallado", "Horóscopo diário detalhado", "詳細なデイリーホロスコープ", "상세한 일일 운세", "Horoscope quotidien détaillé", "विस्तृत दैनिक राशिफल", "Detailliertes Tageshoroskop", "詳細每日星座運勢", "详细每日星座运势") }
    var priorityReading: String { s("Priority reading generation", "Generación de lectura prioritaria", "Geração de leitura prioritária", "優先リーディング生成", "우선 리딩 생성", "Génération de lecture prioritaire", "प्राथमिकता पठन", "Prioritäts-Lesung", "優先占卜生成", "优先占卜生成") }
    var exclusiveThemes: String { s("Exclusive chart themes", "Temas de carta exclusivos", "Temas de mapa exclusivos", "限定チャートテーマ", "독점 차트 테마", "Thèmes de cartes exclusifs", "विशेष चार्ट थीम", "Exklusive Chart-Themen", "獨家星盤主題", "独家星盘主题") }
    var orBuyStardust: String { s("Or buy Stardust", "O compra Polvo Estelar", "Ou compre Poeira Estelar", "またはスターダストを購入", "또는 스타더스트 구매", "Ou acheter de la Poussière d'Étoiles", "या स्टारडस्ट खरीदें", "Oder Sternenstaub Kaufen", "或購買星塵", "或购买星尘") }
    var subscribe: String { s("Subscribe", "Suscribirse", "Assinar", "サブスクリプション", "구독", "S'abonner", "सदस्यता लें", "Abonnieren", "訂閱", "订阅") }
    var autoRenew: String { s("Subscriptions auto-renew. Cancel anytime in Settings.", "Las suscripciones se renuevan automáticamente. Cancela en Configuración.", "Assinaturas renovam automaticamente. Cancele em Configurações.", "サブスクリプションは自動更新です。設定からいつでもキャンセル。", "구독은 자동 갱신됩니다. 설정에서 언제든 취소 가능.", "Les abonnements se renouvellent automatiquement. Annulez dans les Paramètres.", "सदस्यताएं स्वतः नवीनीकृत होती हैं। सेटिंग्स में कभी भी रद्द करें।", "Abonnements verlängern sich automatisch. Jederzeit in den Einstellungen kündbar.", "訂閱自動續訂。可隨時在設定中取消。", "订阅自动续订。可随时在设置中取消。") }
    var termsOfUse: String { s("Terms of Use", "Términos de Uso", "Termos de Uso", "利用規約", "이용약관", "Conditions d'Utilisation", "उपयोग की शर्तें", "Nutzungsbedingungen", "使用條款", "使用条款") }
    var privacyPolicy: String { s("Privacy Policy", "Política de Privacidad", "Política de Privacidade", "プライバシーポリシー", "개인정보 처리방침", "Politique de Confidentialité", "गोपनीयता नीति", "Datenschutzrichtlinie", "隱私權政策", "隐私权政策") }
    var restorePurchases: String { s("Restore Purchases", "Restaurar Compras", "Restaurar Compras", "購入を復元", "구매 복원", "Restaurer les Achats", "खरीदारी पुनर्स्थापित करें", "Käufe Wiederherstellen", "恢復購買", "恢复购买") }

    // MARK: - Misc UI

    var selected: String { s("Selected:", "Seleccionado:", "Selecionado:", "選択済み:", "선택됨:", "Sélectionné :", "चयनित:", "Ausgewählt:", "已選擇:", "已选择:") }
    var available: String { s("available", "disponible", "disponível", "利用可能", "사용 가능", "disponible", "उपलब्ध", "verfügbar", "可用", "可用") }
    var birthCityOptional: String { s("Birth City (optional)", "Ciudad de Nacimiento (opcional)", "Cidade de Nascimento (opcional)", "出生地（任意）", "출생 도시 (선택사항)", "Ville de Naissance (facultatif)", "जन्म शहर (वैकल्पिक)", "Geburtsstadt (optional)", "出生城市（可選）", "出生城市（可选）") }
    var drawCards: String { s("Draw Cards", "Sacar Cartas", "Tirar Cartas", "カードを引く", "카드 뽑기", "Tirer les Cartes", "कार्ड निकालें", "Karten Ziehen", "抽牌", "抽牌") }
    var channeling: String { s("Channeling", "Canalizando", "Canalizando", "チャネリング中", "채널링 중", "Canalisation de", "चैनलिंग", "Channeling", "正在感應", "正在感应") }
    var sun: String { s("Sun", "Sol", "Sol", "太陽", "태양", "Soleil", "सूर्य", "Sonne", "太陽", "太阳") }
    var moon: String { s("Moon", "Luna", "Lua", "月", "달", "Lune", "चंद्रमा", "Mond", "月亮", "月亮") }
    var rising: String { s("Rising", "Ascendente", "Ascendente", "上昇", "상승", "Ascendant", "लग्न", "Aszendent", "上升", "上升") }
    var purchaseError: String { s("Purchase Error", "Error de Compra", "Erro na Compra", "購入エラー", "구매 오류", "Erreur d'Achat", "खरीद त्रुटि", "Kauffehler", "購買錯誤", "购买错误") }
    var purchaseFailed: String { s("Purchase failed. Please try again.", "La compra falló. Inténtalo de nuevo.", "A compra falhou. Tente novamente.", "購入に失敗しました。再試行してください。", "구매에 실패했습니다. 다시 시도해주세요.", "L'achat a échoué. Veuillez réessayer.", "खरीद विफल। कृपया पुनः प्रयास करें।", "Kauf fehlgeschlagen. Bitte erneut versuchen.", "購買失敗，請重試。", "购买失败，请重试。") }
    var fullChartRequired: String { s("Full chart comparison requires birth time and city for both people", "La comparación completa requiere hora y ciudad de nacimiento para ambos", "A comparação completa requer hora e cidade de nascimento para ambos", "完全なチャート比較には両者の出生時刻と場所が必要です", "전체 차트 비교에는 두 사람의 출생 시간과 도시가 필요합니다", "La comparaison complète nécessite l'heure et la ville de naissance pour les deux", "पूर्ण चार्ट तुलना के लिए दोनों के जन्म समय और शहर आवश्यक हैं", "Vollständiger Vergleich erfordert Geburtszeit und -ort für beide", "完整的星盤比較需要雙方的出生時間和城市", "完整的星盘比较需要双方的出生时间和城市") }
    var shareTheStars: String { s("Share the stars!", "¡Comparte las estrellas!", "Compartilhe as estrelas!", "星を共有しよう！", "별을 공유하세요!", "Partagez les étoiles !", "सितारे साझा करें!", "Teile die Sterne!", "分享星空！", "分享星空！") }
    var inviteEarn: String { s("Invite a friend to Caelus and you both earn 15 ✦", "Invita a un amigo a Caelus y ambos ganan 15 ✦", "Convide um amigo para o Caelus e ambos ganham 15 ✦", "友達をCaelusに招待すると、二人とも15 ✦獲得", "친구를 Caelus에 초대하면 둘 다 15 ✦ 획득", "Invitez un ami sur Caelus et gagnez tous les deux 15 ✦", "मित्र को Caelus पर आमंत्रित करें, दोनों 15 ✦ प्राप्त करें", "Lade einen Freund zu Caelus ein und verdient beide 15 ✦", "邀請好友加入Caelus，雙方各獲得15 ✦", "邀请好友加入Caelus，双方各获得15 ✦") }

    // MARK: - Greeting

    func goodGreeting(_ timeOfDay: String, _ name: String) -> String {
        let greeting: String
        switch lang {
        case .en: greeting = "☽ Good \(timeOfDay), \(name)"
        case .es: greeting = "☽ Buen\(timeOfDay == "morning" ? "os días" : timeOfDay == "afternoon" ? "as tardes" : "as noches"), \(name)"
        case .pt: greeting = "☽ Bo\(timeOfDay == "morning" ? "m dia" : timeOfDay == "afternoon" ? "a tarde" : "a noite"), \(name)"
        case .ja: greeting = "☽ \(name)さん、\(timeOfDay == "morning" ? "おはよう" : timeOfDay == "afternoon" ? "こんにちは" : "こんばんは")"
        case .ko: greeting = "☽ \(name)님, \(timeOfDay == "morning" ? "좋은 아침" : timeOfDay == "afternoon" ? "좋은 오후" : "좋은 저녁")"
        case .fr: greeting = "☽ Bon\(timeOfDay == "morning" ? "jour" : "soir"), \(name)"
        case .hi: greeting = "☽ \(timeOfDay == "morning" ? "शुभ प्रभात" : timeOfDay == "afternoon" ? "शुभ दोपहर" : "शुभ संध्या"), \(name)"
        case .de: greeting = "☽ Guten \(timeOfDay == "morning" ? "Morgen" : timeOfDay == "afternoon" ? "Tag" : "Abend"), \(name)"
        case .zhHant: greeting = "☽ \(name)，\(timeOfDay == "morning" ? "早安" : timeOfDay == "afternoon" ? "午安" : "晚安")"
        case .zhHans: greeting = "☽ \(name)，\(timeOfDay == "morning" ? "早上好" : timeOfDay == "afternoon" ? "下午好" : "晚上好")"
        }
        return greeting
    }

    // MARK: - Helper

    /// Order: en, es, pt, ja, ko, fr, hi, de, zhHant, zhHans
    private func s(_ en: String, _ es: String, _ pt: String, _ ja: String, _ ko: String, _ fr: String, _ hi: String, _ de: String, _ zhHant: String, _ zhHans: String) -> String {
        switch lang {
        case .en: return en
        case .es: return es
        case .pt: return pt
        case .ja: return ja
        case .ko: return ko
        case .fr: return fr
        case .hi: return hi
        case .de: return de
        case .zhHant: return zhHant
        case .zhHans: return zhHans
        }
    }
}

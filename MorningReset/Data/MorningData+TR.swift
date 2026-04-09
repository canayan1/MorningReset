import Foundation

extension MorningData {

    static var protectTR: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Protect",
            meaning: [
                "Bu sabah düşük başlıyor. Günü ona göre ayarla.",
                "Bugün hassas başlıyor. Kullanılabilir tut.",
                "Bugün dengeye yönel. Yoğunluk bekleyebilir.",
                "Sabah sinyalleri karışık. Daha fazlasını almadan önce dengeyi bul.",
                "Yüksek kapasiteli bir sabah değil. Talepleri düşük tut.",
                "Yumuşak başlangıç. Sabahı cam gibi muamele et.",
                "Düşük yakıt. Baskı değil, dikkatle ilerle.",
                "İçeride sessiz hava. Kapıyı çok hızlı açma.",
                "Yarı ışıklı sabah. Odayı zorla aydınlatma.",
                "Beden sabır istiyor. Bir kez dinle.",
                "Tutulmuş nefes gibi bir sabah. Gürültüye bırakma.",
                "Saklı sabah. Biriktirebileceğin hiçbir şeyi harcama."
            ][i],
            startWith: [
                "ayaklar yere, sonra su — başka hiçbir şey henüz",
                "yavaşça kalk, perdeleri aç, her şeyden önce su",
                "banyo, su, kolay bir iş — bu sırayla",
                "ayağa kalk, su iç, sonra sonu belli bir iş",
                "nazikçe kalk, önce su, sonra en öngörülebilir işin",
                "yatağın kenarında otur, iki kez nefes al, sonra su",
                "kalk, tek bir lamba yak, telefona uzanmadan önce su iç",
                "ayaklar yere, üç yavaş nefes, su, sessiz bir iş",
                "ayağa kalk, bir pencere aç, su, sonra listendeki en kolay şey",
                "kalk, yüzüne serin su çarp, sonra bir bardak su iç",
                "dik otur, on sayıya kadar yavaş nefes al, su, sonra bir hareket",
                "ayaklar yere, gözler odada, su, başka hiçbir şey"
            ][i],
            avoid: [
                "yerleşmeden önce mesajlar",
                "tepkisel planlama",
                "haberler ve akışlar",
                "yerleşmeden yüksek riskli kararlar",
                "yarına erteleyebileceğin kararlar",
                "acil cevap isteyen her şey",
                "kendini herkesle, her yerde kıyaslamak",
                "bu sabahı verimli yapma dürtüsü",
                "bir şey yemeden önce gelen kutusu",
                "ilk bardak suyundan önce başkasının acil durumu",
                "henüz bozulmamış şeyleri tamir etme sarmalı",
                "bugün taşıyabileceğinden fazlasını vaat etmek"
            ][i],
            win: [
                "sakin bir ilk saat",
                "sarmal yok, çökme yok",
                "kendini yıpratmadan hareket edecek kadar berrak",
                "sabahı sağlam bitirmek",
                "kendini tüketmeden yapılmış bir iş",
                "sabahı tankta bir şeyler kalarak bitirmek",
                "kendine verdiğin sözleri bozmamak",
                "sert başlangıç yerine yumuşak iniş",
                "öğleden önce sessiz bir başarı",
                "sabahı sinir sistemin sağlamken bırakmak",
                "küçük bir şeye zamanında gelmek",
                "özür borçlu olmadığın bir sabah"
            ][i],
            music: [
                "yavaş, geniş, sözsüz",
                "ambient, minimal, ritim baskısı yok",
                "düşük tempo, seyrek düzenleme",
                "enstrümantal, hiçbir şey talepkar değil",
                "sessiz, dikkat çekmeyen, arka plan",
                "yumuşak piyano, oda sıcaklığında",
                "uzatılmış akorlar, hava durumu gibi",
                "neoklasik, kâğıt inceliğinde",
                "tek enstrüman, tek düşünce",
                "bulanık kenarlar, ritim yok",
                "tutulmuş bir nota üzerinde alan kaydı",
                "bant hışırtısı ve yavaş bir akor"
            ][i],
            bonus: [
                "Günün sözü: sistemi zorlamadan önce koru.",
                "Sabah sinyali: toparlanma günü. nazikçe ilerle.",
                "Sabah sinyali: düşük sinyal günü. ritmini koru.",
                "Günün sözü: sağlam bir zemin sallantılı bir tavandan iyidir.",
                "Sabah sinyali: düşük gün. kendini fazla uzatma.",
                "Günün sözü: küçük ve bitmiş, büyük ve terk edilmişten iyidir.",
                "Sabah sinyali: ince hava. hareket etmeden önce nefes al.",
                "Günün sözü: kendine bir söz ver, fazlası değil.",
                "Sabah sinyali: çizgiyi tut, genişletme.",
                "Günün sözü: dinlenmek de bir yöndür.",
                "Sabah sinyali: yürüyerek geç, koşarak değil.",
                "Günün sözü: gün yeterince uzun."
            ][i]
        )
    }

    static var steadyTR: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Steady",
            meaning: [
                "Hareket edecek kadar dengelisin. Günü doğru kullan.",
                "Bu sabah çalışılabilir. Boşa harcama.",
                "Bu sabah büyük bir ağırlık yok. Temiz kullan.",
                "Ne yüksek ne düşük. Elindekiyle çalış.",
                "Bu sabah temiz bir başlangıç. Kullan.",
                "İçeride ortalama hava. Ortalama hava yeterli.",
                "Önünde hiçbir engel yok. Pazarlık yapmadan başla.",
                "Sessiz motor, dolu depo. Dikkatli sür.",
                "Düz zemin. Dürüst bir adım at.",
                "Sakin taban çizgisi. Uyarana uzanma.",
                "Çalışılabilir sabah. Süsleme.",
                "Durgun su. Karşısına değil, içinden geç."
            ][i],
            startWith: [
                "kalk, su, sonra güne şekil veren iş",
                "şimdi kalk, su, sonra girdi almadan önce kasıtlı bir eylem",
                "ayaklar yere, su, sonra en net önceliğin",
                "ayağa kalk, su, sonra gerçek bir sebep olmadan ertelediğin iş",
                "kalk, su, sonra somut bir çıktı — planlama seansı değil",
                "kalk, su, sonra gerçekten önemli olan şeye yirmi dakika",
                "ayaklar yere, su, sonra günün ilk gerçek cümlesi",
                "kalk, su, sonra bir sonraki hamleyi kolaylaştıran hamle",
                "ayağa kalk, su, sonra açıklamadan önce işe başla",
                "ayaklar yere, su, sonra anladığın kısımla başla",
                "kalk, su, sonra bir paragraf, bir tekrar, bir arama",
                "ayağa kalk, su, sonra doğru şeyin en küçük versiyonu"
            ][i],
            avoid: [
                "ısınma kılığına girmiş rastgele kaydırma",
                "ivmeden önce gürültü",
                "sahte verimlilik",
                "uygulamak yerine optimize etmek",
                "başlaman gereken şeyi aşırı hazırlamak",
                "kullanmak yerine araçlarını yeniden düzenlemek",
                "açık tutman gerekmeyen beşinci sekme",
                "bir sonraki adımını değiştirmeyen bir şeyi kontrol etmek",
                "güne başlamak yerine düzenlemenin konforu",
                "ilk cümleden önce ikinci fincan kahve",
                "yapmak yerine işi kendine açıklamak",
                "hareketle cevap vermeden önce hangi iş diye sormak"
            ][i],
            win: [
                "temiz yapılmış anlamlı bir şey",
                "sabahtan öğlene temiz hareket",
                "berraklık, ritim, gereksiz sapmalar yok",
                "sabah bitmeden bir şeyde gerçek ilerleme",
                "sabah tükenmeden ileri hareket",
                "hayal edileni parlamak yerine küçük versiyonu göndermek",
                "sabahı bulduğundan hafif bırakmak",
                "bir şey bitirildi, sonra bir sonraki başladı",
                "öğleden sonrayı hak eden bir sabah",
                "oyalanma yok, özür yok, sadece bitmiş bir iş",
                "kafanda değil, sayfada kanıt",
                "bileşen hareket"
            ][i],
            music: [
                "odaklı, hafif, orta tempo",
                "enstrümantal, tutarlı ritim",
                "lo-fi, ılımlı hız, ani sıçramalar yok",
                "temiz arka plan, sabit vuruş",
                "düşük dikkat dağınıklığı, dengeli enerji",
                "tokyo lo-fi, sabit kick",
                "sıcak minimal house, meşgul değil",
                "iskandinav downtempo, ölçülü",
                "japon city pop sabah yüzü",
                "modern caz, sadece fırça",
                "ambient tekno, sohbet hacminde",
                "post-rock, doruk noktası yok"
            ][i],
            bonus: [
                "Günün sözü: ritim yoğunluğu yener.",
                "Sabah sinyali: bu sabah sürtünme yok. harekette kal.",
                "Sabah sinyali: sabit hava. temiz icraat için iyi gün.",
                "Günün sözü: kullan. fazla düşünme.",
                "Sabah sinyali: temiz taban çizgisi. çalışmak için iyi koşullar.",
                "Günün sözü: hareket, çoğu sabah sorusunun cevabı.",
                "Sabah sinyali: dramatik bir şey yok, armağan da bu.",
                "Günün sözü: planın sıkıcı versiyonuna güven.",
                "Sabah sinyali: istikrar bir rekabet avantajı.",
                "Günün sözü: küçük ve sürekli, büyük ve ara sırayı yener.",
                "Sabah sinyali: dürüst iş için sessiz koşullar.",
                "Günün sözü: ritmi koru, tempoyu sonra değiştir."
            ][i]
        )
    }

    static var pushTR: MorningResult {
        let i = variantIndex
        return MorningResult(
            mode: "Push",
            meaning: [
                "Bu sabah güçlü sinyaller var. Erken harekete geç.",
                "Bu sabahın kaldıracı var. Seyreltme.",
                "Kullanılabilir bir ivme var. Yönlendir.",
                "Koşullar iyi. Sabahın kaymasına izin verme.",
                "Sabah çıktıya yöneliyor. Bir yön ver.",
                "Rüzgâr arkadan esiyor. Hızlanmadan önce nişan al.",
                "Yüksek sinyal. Küçük işlere harcama.",
                "Açık yol. Doğru çıkışı erken seç.",
                "Motor sıcak. Gerçek tırmanışta kullan.",
                "Parlak pencere. Açıkken hareket et.",
                "Sabah sana temiz bir atış sunuyor. Kullan.",
                "Dolu sabah. En yüksek kaldıraçlı işe harca."
            ][i],
            startWith: [
                "hızla kalk, su, sonra en zor iş — bu sırayla",
                "yataktan çık, su, sonra akış açılmadan gerçek iş",
                "ayağa kalk, su, sonra en yüksek getirili iş",
                "şimdi kalk, su, sonra bir şey açmadan önce somut bir şey",
                "kalk, önce su, sonra tam dikkatini isteyen iş",
                "kalk, su, sonra öğlene kadar bitirmiş olmaktan memnun kalacağın şey",
                "ayaklar yere, su, sonra gerçek tırmanışa doksan dakika",
                "ayağa kalk, su, sonra pazarlık ettiğin iş",
                "kalk, su, sonra tüm günün zeminini yükselten hamle",
                "yataktan çık, su, sonra cesaret isteyen kısımla başla",
                "kalk, su, sonra kafandaki değil var olan versiyonu gönder",
                "ayağa kalk, su, sonra bir şey kontrol etmeden önce taahhüt et"
            ][i],
            avoid: [
                "çıktıdan önce idari işler",
                "bir şey yapmadan önce her şeyi kontrol etmek",
                "dağınık çaba",
                "taahhüt etmeden önce çok uzun ısınmak",
                "gerçek işten zaman çalan düşük değerli görevler",
                "hazırlığı iş gibi göstermek",
                "sabahını yeniden yönlendirmek isteyen slack mesajı",
                "sabahı sığ sekmelere harcamak",
                "tek cümle olabilecek herhangi bir toplantı",
                "gelen kutusunun önceliklerini belirlemesine izin vermek",
                "yapmak yerine iş hakkında okumak",
                "yanlış şeyi parlamak"
            ][i],
            win: [
                "gerçek ilerlemenin güçlü bir bloğu",
                "öğleden önce ilerleme",
                "enerjiyi somut bir şeye dönüştür",
                "ilk iki saatte gerçek çıktı",
                "gerçekten önemli olan şeyde önemli bir hamle",
                "gönder, çirkin olsa bile, küçük olsa bile",
                "günün şeklini değiştiren doksan dakika",
                "kaçındığın kısmı bitir",
                "sabahı çaba kanıtıyla değil, iş kanıtıyla bırak",
                "gönder. döngüyü kapat. devam et.",
                "verilmiş, uygulanmış ve unutulmuş bir karar",
                "var olan versiyon, var olmayandan iyidir"
            ][i],
            music: [
                "enerjik, odaklı, düşük kaos",
                "itici tempo, söz yok",
                "yüksek enerji, yapılandırılmış ritim",
                "hızlı tempolu, temiz düzenleme",
                "ivme kurucu, dikkat dağıtıcı değil",
                "deep house, itici ama ölçülü",
                "gün doğumunda tekno, drop yok",
                "elektronik post-rock, hep ileri",
                "krautrock motorik, çizgiyi tut",
                "düşük sesle uk garage",
                "minimal tekno, tek hipnotik döngü",
                "afrobeat enstrümantal, tüm beden"
            ][i],
            bonus: [
                "Günün sözü: yüksek sinyalli sabah. küçük işlere harcama.",
                "Günün sözü: çıktı penceresi açık. geç içinden.",
                "Sabah sinyali: ileri hareket yüksek. hedefini iyi seç.",
                "Günün sözü: böyle bir sabaha yavaş girme.",
                "Sabah sinyali: güçlü sinyal. hedefi erken koy.",
                "Günün sözü: hedefsiz güçlü sabah, boşa giden sabah.",
                "Sabah sinyali: kaldıraç günü. bileştir.",
                "Günün sözü: bu sabaha doğrudan ol.",
                "Sabah sinyali: yeşil ışık. izin isteme.",
                "Günün sözü: dar nişan al, sert vur, devam et.",
                "Sabah sinyali: yükselen dalga. kürek çek.",
                "Günün sözü: sabah ikinci kez sormayacak."
            ][i]
        )
    }
}

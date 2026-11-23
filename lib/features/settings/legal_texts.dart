// Proje planındaki "Yasal metinler (taslak)" sekmesinden alınmıştır.
// Köşeli parantezli yerler ([Ad Soyad], [iletisim@ornek.com], [bölge],
// [aktarım aracı], [süre], [tarih]) yayından önce doldurulmalıdır.

const kvkkText = '''
# KVKK Aydınlatma Metni

Veri sorumlusu. Peerless uygulaması [Ad Soyad] tarafından kişisel bir proje olarak geliştirilmektedir. 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) kapsamında veri sorumlusu [Ad Soyad]'dır. İletişim: [iletisim@ornek.com].

İşlenen kişisel veriler.
• Kimlik ve hesap: E-posta adresi, şifre (şifrelenmiş olarak), nickname, görünen ad
• Profil: Biyografi, profil fotoğrafı, kapak görseli
• Kullanıcı içeriği: Paylaşımlar, taslaklar, görseller, yorumlar, beğeniler, kaydedilenler, etiketler
• Etkileşim ve güvenlik: Engellenen kullanıcılar, şikayetler, moderasyon kayıtları
• Teknik: Bildirim cihaz anahtarı, dil ve tema tercihleri, oturum ve erişim kayıtları (IP adresi, tarih-saat)

İşleme amaçları. Hesap oluşturma ve giriş; profilin ve paylaşımların diğer kullanıcılara gösterilmesi; yorum, beğeni ve bildirim özelliklerinin çalışması; şikayetlerin incelenmesi ve kurallara aykırı içeriğin kaldırılması; uygulamanın güvenliğinin sağlanması; yasal yükümlülüklerin yerine getirilmesi.

Hukuki sebepler. Veriler KVKK md. 5/2 kapsamında; kullanım koşulları sözleşmesinin kurulması ve ifası (c), veri sorumlusunun hukuki yükümlülüğü (ç), kullanıcının kendisi tarafından alenileştirilmiş olması (d; herkese açık paylaşımlar ve profil için) ve temel hak ve özgürlüklere zarar vermemek kaydıyla meşru menfaat (f; güvenlik ve moderasyon için) sebeplerine dayanılarak işlenir.

Toplama yöntemi. Veriler uygulama üzerinden, kullanıcının kendisinin girmesiyle ve uygulamanın kullanımı sırasında otomatik yollarla elektronik ortamda toplanır.

Aktarım. Veriler yalnızca hizmetin çalışması için gerekli altyapı sağlayıcılarına aktarılır: Supabase (veritabanı, kimlik doğrulama, dosya depolama; sunucular [bölge]) ve Google Firebase (push bildirimleri). Bu sağlayıcıların sunucuları yurt dışında olduğundan aktarım KVKK md. 9'a uygun olarak [aktarım aracı] ile yapılır. Kanunen yetkili kamu kurumlarının talebi dışında üçüncü kişilerle paylaşılmaz, satılmaz, reklam amacıyla kullanılmaz.

Saklama süresi. Veriler hesap açık olduğu sürece saklanır. Hesap silme talebinden 30 gün sonra hesap ve ona bağlı tüm veriler silinir; bu sürede giriş yapılırsa talep iptal olur. Yedeklerde kalan kopyalar en geç [süre] içinde silinir. Yasal yükümlülük gerektiren kayıtlar ilgili mevzuattaki süre kadar saklanır.

Haklarınız (KVKK md. 11). Kişisel verilerinizin işlenip işlenmediğini öğrenme, işlenmişse bilgi talep etme, işleme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme, yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri bilme, eksik veya yanlış işlenmişse düzeltilmesini isteme, silinmesini veya yok edilmesini isteme, bu işlemlerin aktarılan üçüncü kişilere bildirilmesini isteme, otomatik sistemlerle analiz sonucu aleyhinize bir sonuç çıkmasına itiraz etme ve kanuna aykırı işleme nedeniyle zarara uğrarsanız zararın giderilmesini talep etme haklarına sahipsiniz.

Başvuru. Taleplerinizi kayıtlı e-posta adresinizden [iletisim@ornek.com] adresine iletebilirsiniz. Başvurular en geç 30 gün içinde ücretsiz olarak sonuçlandırılır. Profil, paylaşım ve hesap silme işlemlerini uygulama içinden de yapabilirsiniz.

Son güncelleme: [tarih]''';

const termsText = '''
# Kullanım Koşulları

1. Kabul. Peerless'a kayıt olarak bu koşulları kabul etmiş sayılırsın. Uygulama [Ad Soyad] tarafından kişisel bir proje olarak sunulur ve ücretsizdir.

2. Yaş sınırı. Kayıt olmak için en az 16 yaşında olmalısın.

3. Hesap. Hesabının ve şifrenin güvenliğinden sen sorumlusun. Başkasını taklit eden, yanıltıcı ya da hakaret içeren nickname ve görünen ad kullanılamaz.

4. İçerik ve haklar. Paylaştığın içeriğin hakları sende kalır. Paylaşarak, içeriğinin Peerless içinde diğer kullanıcılara gösterilmesi için ücretsiz ve süresi içeriği silene kadar olan bir izin vermiş olursun. Alıntı paylaşırken asıl yazara ait olduğunu belirtmeli ve başkasının eserini kendi eserin gibi sunmamalısın.

5. Yasak içerik. Hakaret, taciz, nefret söylemi, tehdit, spam veya reklam, müstehcen ya da şiddet içeren içerik, kişisel verilerin izinsiz paylaşılması, telif haklarının ihlali ve Türkiye Cumhuriyeti kanunlarına aykırı her türlü içerik yasaktır.

6. Moderasyon. Şikayet edilen içerikler incelenir. Kurallara aykırı içerik ve yorumlar kaldırılabilir, kullanıcıya uyarı verilebilir veya hesap kalıcı olarak kapatılabilir.

7. Hesabın silinmesi. Hesabını istediğin zaman ayarlardan silebilirsin; silme 30 gün sonra kesinleşir.

8. Sorumluluk. Uygulama olduğu gibi sunulur; kesintisiz veya hatasız çalışacağı garanti edilmez. Kullanıcıların paylaştığı içeriklerden paylaşan kullanıcı sorumludur.

9. Değişiklikler. Bu koşullar güncellenebilir; önemli değişiklikler uygulama içinde duyurulur.

10. Uygulanacak hukuk. Bu koşullara Türkiye Cumhuriyeti hukuku uygulanır.

İletişim: [iletisim@ornek.com] · Son güncelleme: [tarih]''';

**BEYEN HAVVA**

**030119112**

**Sinyal İşleme Dersi**

**Proje : matlab ile sentezleme**


MuseScore'da yazılan Lamma Bada parçasını ParseMusicXML işlevi kullanılarak ayrıştırıldı. Bu sayede 152x19'luk bir matris elde dildi.

**Müziği sentezlemek için kullanılacak sütunlar :**

  2 . Sütun : süre (vuruş olarak) duration (in beats) 

  4 . Sütun : midi adım (dinlenmeler için 0) midi pitch (0 for rests)

  7 . Sütun : Süre (saniye cinsinden,çeyrek = 100bpm veya skorda belirtildiği gibi) duration (in seconds, quarter = 100bpm or as given in score)

  8 . Sütun : ölçü numarası (tek tabanlı) measure number (one-based)


<details><summary>note.m dosyası</summary>

 
 function freq=note(sayi)
  freq=(2^((sayi-69)/12))*440;
 end
 


Yukarıda verilmiş olan note fonksiyonuna, sentez kodunda parse edilen verinin 4. sütununda bulunan notaların MIDI numaraları sırasıyla parametre olarak gönderilmektedir. note fonksiyonu MIDI numaralarını kullanarak her nota için frekansı döndürmektedir.

 
 freq(k,1)=note(parser(k,4));
 

Döndürdüğü frekans değerlerini de yukarıda göründüğü gibi freq isimli matrisin ilk sütununa yazdırmaktadır.

</details>


<details><summary>sentez.m dosyası</summary>


 
 parser=parseMusicXML("muzik/nota.musicxml");
 

parseMusicXML fonksiyonu, parametre olarak aldığı nota.musicxml dosyasını ayrıştırarak parser ismindeki matrise yazmaktadır. Buradan sonra ayrıştırılmış veriye ihtiyaç duyulan her noktada bu matris, farklı sütunlarına erişilerek kullanılacaktır.

 
 zarfSecimi = 1;
 % 1 ise ADSR , 0 ise Exponential Envelope.
 harSecimi =1 ;
 % 1 ise Asıl sinyali çalar.


zarf seçimi değişkeni 
harmonik sayısı değişkeni 


 A = 1; 
 freq=zeros(140,1); 
 exp_Toplam = [];
 ADSR_Toplam = []; 


A değişkeni program içerisinde üretilen nota sinyallerinin genlik değeridir. Varsayılan olarak 1 ayarlanan bu değişken, harSecimi değişkeni 1'den farklı bir değer alırsa o değer ile çarpılarak harmoniklerin elde edilmesinde kullanılmaktadır.
freq matrisinin tanımlanması: Frekansları tutmak amacıyla kullanılan freq matrisi programın başında, MIDI numaralarının sayısı esas alınarak, zeros fonksiyonu ile boş bir şekilde oluşturulmuştur.
ADSR_Toplam ve exp_Toplam matrislerinin tanımlanması: Bu matrislerde teker teker zarfa sokulan notalar üst üste eklenerek melodi oluşturulmaktadır.


 freq_Uzunluk = size(freq);


freq_Uzunluk değişkeninde, freq matrisinin uzunluğu tutulmaktadır. Bu değişken ile for döngüsünün bitiş değerini belirlemek amaçlanmaktadır.


 freq(k,1)=note(parser(k,4));


Programın başında boş olarak oluşturulan (0'lar matrisi) freq matrisinin birinci sütununa note fonksiyonuna parametre olarak gönderilen, parse edilmiş verileri bulunduran parser matrisinin 4. sütununda tutulan notaların MIDI numaraları yardımıyla yazılmaktadır.


 zaman = 0: 1/10000 :parser(k,7);


t zamanının hesaplanması: t zamanı, zaman değişkeninde, 1/10000 örnekleme frekansı ile parser fonksiyonunun 7. sütunu kullanılarak oluşturulmuştur.


 nota_Sinyal = A * cos(2*pi*freq(k,1)*zaman);


Nota Sinyalinin oluşturulması: nota_Sinyal değişkeni notaların frekans ve zaman değerleri kullanılarak, nota sinyallerinin oluşturulmasını sağlamaktadır.


 harmonik_Sinyal=nota_Sinyal;
 if(harSecimi~=1)
 for n = 2:harSecimi
  A = 1/n;
  har_cosx = A * cos( 2 * pi * freq(k,1) * zaman * n); 
  harmonik_Sinyal = harmonik_Sinyal + (har_cosx);
 end
 end


Harmoniklerin oluşturulması: Burada bulunan if-else deyimi har_Kac seçimine göre harmoniklerin oluşturulup oluşturulmayacağına karar verir. Eğer harSecimi değeri 1'den farklı ise programın bu parçası çalışmaktadır. For döngüsünün 2'den başlamasının sebebi de budur.Yukarıda anlatıldığı üzere  A değişkeni yerine o esnada oluşturulan kaçıncı harmonikse (1/n) tipinde yazdırılmaktadır.Sonrasında ise harmonik sinyaller oluşturulup, asıl sinyalin üzerine toplanmaktadır.


 if zarfSecimi == 1 
      dur = length(zaman);
      ADSR = [ linspace(0,1.5,floor(dur/5)) linspace(1.5,1,ceil(dur/10)) ones(1,floor(dur/2)) linspace(1,0,floor(dur/5)) ];
      ADSR_Sinyal = ADSR .* harmonik_Sinyal; 
      ADSR_Toplam = [ ADSR_Toplam ADSR_Sinyal ]; 


Sinyalin ADSR tipi zarfa sokulması: zarfSecimi değeri 1 iken notalar ADSR tipi zarfa sokulmaktadır. If deyimi bunun içindir. ADSR matrisinde zarf oluşturulmuştur. ADSR_Sinyal matrisinde ise harmonik_Sinyal, ADSR tipi zarfa sokularak ADSR_Sinyal matrisine atılmıştır.ADSR_Toplam matrisinde ise zarf işlemine tabi tutulan notalar üst üste eklenerek zarflı melodi oluşturulmaktadır.


 elseif zarfSecimi == 0 
    
      exp_Zarf = exp( -zaman / parser(k,2) );
      exp_Sinyal = exp_Zarf .* harmonik_Sinyal;
      exp_Toplam = [ exp_Toplam exp_Sinyal ];

      end


Sinyalin Exponential tipi zarfa sokulması: zarfSecimi değeri 0 iken notalar Exponential tipi zarfa sokulmaktadır. If deyimi bunun içindir. exp_Zarf matrisinde zarf oluşturulmuştur.exp_Sinyal matrisinde ise harmonik_Sinyal, Exponential tipi zarfa sokularak exp_Sinyal matrisine atılmıştır. exp_Toplam matrisinde ise zarf işlemine tabi tutulan notalar üst üste eklenerek zarflı melodi oluşturulmaktadır.


  if zarfSecimi == 1
     
     ADSR_Toplam = (ADSR_Toplam)';
     reverb = reverberator('PreDelay',0.15,'WetDryMix',0.2);
     reverb_ADSR=reverb(ADSR_Toplam);
     sound(reverb_ADSR,10000)
     
     plot(ADSR_Toplam)
     figure
     plot(reverb_ADSR)


Eğer zarfSecimi değişkeninin değeri 1 olarak atanmışsa program melodiyi ADSR tipi zarfa sokup, zarfa sokulmuş melodiye yankı ekleyip, bu zarf tipine ait grafikleri çizdirmek için bulunan kod bloklarını çalıştırmaktadır.ADSR tipi zarfın seçildiği düşünülsün, if-else deyiminin içindeki ilk satır ADSR zarfına sokulmuş melodiyi tutan matrisin transpozesi alınmaktadır. Bunun sebebi reverb fonksiyonunun matrisi satırlar matrisi olarak istemesidir.ADSR tipi zarfa sokulmuş yankı eklenmeyen melodinin grafiği ve ADSR tipi zarfa sokulmuş yankılı melodinin grafiği, plot fonksiyonu ile çizdirilmiştir.


 elseif zarfSecimi == 0
     exp_Toplam = (exp_Toplam)';
     reverb = reverberator('PreDelay',0.15,'WetDryMix',0.2);
     reverb_Exp=reverb(exp_Toplam);
     sound(reverb_Exp,10000)

     plot(exp_Toplam) 
     figure
     plot(reverb_Exp)
     
    end


Eğer zarfSecimi değişkeni 0 olarak atanmışsa program melodiyi Exponential tipi zarfa sokup, zarfa sokulmuş melodiye yankı ekleyip, bu zarf tipine ait grafikleri çizdirmek için bulunan kod bloklarını çalıştırmaktadır.Exponential tipi zarfın seçildiği düşünülsün, if-else deyiminin içindeki ilk satır Exponential zarfına sokulmuş melodiyi tutan matrisin transpozesi alınmaktadır. Bunun sebebi reverb fonksiyonunun matrisi satırlar matrisi olarak istemesidir.Exponential tipi zarfa sokulmuş yankı eklenmeyen melodinin grafiği ve Exponential tipi zarfa sokulmuş yankılı melodinin grafiği, plot fonksiyonu ile çizdirilmiştir

<details><summary>Reverb Fonksiyonu</summary>
 Reverb fonksiyonunun tanımlanması:
reverb = reverberator, bir ses sinyaline yapay yansıma ekleyen bir reverb sistemi nesnesi oluşturur.
reverb = reverberator (Name, Value) her özellik adını belirtilen değere ayarlar. Belirtilmemiş özelliklerin varsayılan değerleri vardır.
 Reverb fonksiyonunun açıklaması:
Aksi belirtilmedikçe, özellikler değiştirilemez; bu, nesneyi çağırdıktan sonra değerlerini değiştiremeyeceğiniz anlamına gelir. Onları çağırdığınızda nesneler kilitlenir ve serbest bırakma işlevi onları açar.
Bir özellik ayarlanabilir ise, değerini istediğiniz zaman değiştirebilirsiniz.
 Reverb fonksiyonunun parametreleri:

1) PreDelay : [0, 1] aralığında gerçek bir skaler olarak belirtilen saniye cinsinden yankılanma için ön gecikmedir.
Yankılanma için ön gecikme, doğrudan duyma sesi ile ilk erken yansıma arasında geçen süredir.
Ayarlanabilir mi ? : Evet
Veri Tipleri: Single | Double

2) WetDryMix : WetDry Mix, [0, 1] aralığında gerçek bir pozitif skaler olarak belirtilir.
WetDry Mix, reverberatör sistem nesnenizin verdiği wet (reverberated), dry (orijinal) sinyallerin oranıdır.
Ayarlanabilir: Evet
Veri Tipleri: Single | Double

3) SampleRate : Pozitif skaler olarak belirtilen Hz cinsinden giriş örnek oranı.
Ayarlanabilir: Evet
Veri Tipleri: Single | Double
</details>

</details>











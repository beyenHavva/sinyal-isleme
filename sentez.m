parser = parseMusicXML("müzik/nota.musicxml");

zarfSecimi = 1;
 % zarf tipi seçim değişkeni, 1 ise ADSR , 0 ise Exponential Envelope.
harSecimi = 1; 
 % harmonik seçim değişkeni. 1 ise Asıl sinyali çalar.8

A = 1;
 % Genlik değeri 1 olarak ayarlandı.
freq = size(parser); 
 % notaların frekanslarının tutulacağı matris boş olarak oluşturuldu.
exp_Toplam = []; 
 % Exp tipi zarfa girmiş notaların toplamı.
ADSR_Toplam = [];
 % ADSR tipi zarfa girmiş notaların toplamı.

freq_Uzunluk = size(freq);
 % Frekans matrisinin büyüklüğü alındı. (freq_Uzunluk değişkeninde. Bu değişken ile for döngüsünün
 % bitiş değerini belirlemek amaçlanmaktadır.).


for k = 1 : freq(1)
   % For döngüsü başlangıcı.
    
      freq(k,1) = note(parser(k,4));
       % Frekans değerleri note fonksiyonu yardımıyla oluşturuldu.
       % Programın başında boş olarak oluşturulan ( 0 lar matrisi ) freq matrisinin birinci 
       % sütununa note fonksiyonuna parametre olarak gönderilen, parse edilmiş verileri bulunduran
       % parser matrisinin 4. sütununda tutulan notaların MIDI numaraları yardımıyla yazılmaktadır.

      zaman = 0 : 1/10000 : parser(k,7); 
       % t zamanlarını hesaplamak için gerekli değerler
       % parse edilmiş verinin ilgili sütunlarından çekildi.
       % t zamanı, zaman değişkeninde, 1/10000 örnekleme frekansı ile parser fonksiyonunun 7. sütunu 
       % kullanılarak oluşturulmuştur.

      nota_Sinyal = A * cos ( 2 * pi * freq(k,1) * zaman ); 
       % Nota sinyalleri oluşturuldu.
       % nota_Sinyal değişkeni notaların frekans ve zaman değerleri kullanılarak, nota sinyallerinin
       % oluşturulmasını sağlamaktadır.
    
      harmonik_Sinyal=nota_Sinyal;

      if (harSecimi~=1 )
       % Sinyalin harmoniklerinin alınıp alınmayacağına karar veren if yapısı.
       % Eğer harSecimi değeri 1 den farklı ise programın bu parçası çalışmamaktadır.For döngüsünün 2 
       % den başlamasının sebebi de budur.
      for n = 2 : harSecimi
          A = 1/n;
           % Değişkenlerin tanımlanması kısmında anlatıldığı üzere A değişkeni yerine o esnada
           % oluşturulan kaçıncı harmonikse (1/n) tipinde yazdırılmaktadır.
          har_cosx = A * cos(2 * pi * freq(k,1) * zaman * n); 
           % Sinyalin harmoniklerinin alınması.
          harmonik_Sinyal = harmonik_Sinyal + (har_cosx);
           % Sonrasında ise harmonik sinyaller oluşturulup, asıl sinyalin üzerine toplanmaktadır.
          
      end
      end
      
      
      
     if zarfSecimi == 1
      % Hangi zarfın kullanılacağını seçmek için oluşturulan if-else yapısı başlangıcı.
      % ADSR tipi zarf yapısının uygulanması.
      
      dur = length(zaman);

       % ADSR zarfı altındayken her aşamanın yüzde ne kadar süre alacağını belirtmek içindir 
      ADSR = [ linspace(0,1.5,floor(dur/5)) linspace(1.5,1,ceil(dur/10)) ones(1,floor(dur/2)) linspace(1,0,floor(dur/5)) ];
      
      ADSR_Sinyal = ADSR .* harmonik_Sinyal; 
       % Sinyallerin zarfa sokulması işlemi.ADSR_Sinyal matrisinde ise harmonik_Sinyal, ADSR tipi 
       % zarfa sokularak ADSR_Sinyal matrisine atılmıştır.
     
      ADSR_Toplam = [ADSR_Toplam ADSR_Sinyal]; 
       % ADSR zarfına girmiş notaların tek bir matrise atılması.
       % ADSR_Toplam matrisinde ise zarf işlemine tabi tutulan notalar üst üste eklenerek zarflı 
       % melodi oluşturulmaktadır.
      
      elseif zarfSecimi == 0
       % Exp tipi zarf yapısının uygulanması. 
    
      exp_Zarf = exp(-zaman / parser(k,2));
      
      exp_Sinyal = exp_Zarf .* harmonik_Sinyal; 
       % Sinyallerin zarfa sokulması işlemi. exp_Sinyal matrisinde ise harmonik_Sinyal, Exponential
       % tipi zarfa sokularak exp_Sinyal matrisine atılmıştır.
      exp_Toplam = [ exp_Toplam  exp_Sinyal ];
       % exp_Toplam matrisinde ise zarf işlemine tabi tutulan notalar üst üste eklenerek zarflı 
       % melodi oluşturulmaktadır.
      
     end
       % Seçim işleminin bittiği if-else yapısı sonu.
       
      
end 

if zarfSecimi == 1
     
     ADSR_Toplam = (ADSR_Toplam)'; 
      % ADSR zarfındaki melodiyi tutan matrisin transpozesinin alınması. ADSR zarfına sokulmuş melodiyi
      % tutan matrisin transpozesi alınmaktadır. Bunun sebebi reverb fonksiyonunun matrisi satırlar
      % matrisi olarak istemesidir  
     reverb = reverberator('PreDelay',0.15,'WetDryMix',0.2); 
      % Reverb fonksiyonunun değerlerinin atanması.
     reverb_ADSR=reverb(ADSR_Toplam); 
      % Reverb Fonksiyonunun kullanılması.
     sound(reverb_ADSR,10000) 
      % Melodinin çaldırılması.
     
     plot(ADSR_Toplam) 
      % Zarflı sinyalin çizdirilmesi.
     legend('ADSR tipi toplam sinyal.');
     figure
     plot(reverb_ADSR) 
      % Zarflı ve yankılı sinyalin çizdirilmesi.
     legend('ADSR tipi,yankılı toplam sinyal.');
     % ADSR tipi zarfa sokulmuş yankı eklenmeyen melodinin grafiği ve ADSR tipi zarfa sokulmuş yankılı
     % melodinin grafiği, plot fonksiyonu ile çizdirilmiştir

elseif zarfSecimi == 0
        
     exp_Toplam = (exp_Toplam)'; 
      % Exp zarfındaki melodiyi tutan matrisin transpozesinin alınması. Exponential zarfına sokulmuş
      % melodiyi tutan matrisin transpozesi alınmaktadır. Bunun sebebi reverb fonksiyonunun matrisi
      % satırlar matrisi olarak istemesidir  
     reverb = reverberator('PreDelay',0.15,'WetDryMix',0.2); 
      % Reverb fonksiyonunun değerlerinin atanması.
     reverb_Exp=reverb(exp_Toplam);
      % Reverb Fonksiyonunun kullanılması.
     sound(reverb_Exp,10000) 
      % Melodinin çaldırılması.
     
     plot(exp_Toplam) 
      % Zarflı sinyalin çizdirilmesi.
     legend('Exp tipi toplam sinyal.');
     figure
     plot(reverb_Exp)
      % Zarflı ve yankılı sinyalin çizdirilmesi.
     legend('Exp tipi,yankılı toplam sinyal.');
     % Exponential tipi zarfa sokulmuş yankı eklenmeyen melodinin grafiği ve Exponential tipi zarfa
     % sokulmuş yankılı melodinin grafiği, plot fonksiyonu ile çizdirilmiştir
     
    end

figure
plot(harmonik_Sinyal)
legend('Yalın sinyal.');



#Bağlanılacak Sunucu Bilgilerinin Alınması
#Kullancıdan Al
$Username = Read-Host "Kullanıcı Adı"
$Password = Read-Host "Şifre"
Write-Host "`n"
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pass

#İşlemlerin yapılacağı sunucu listesi. 
$IPS = "D:\denemeD\ipler.txt" 

foreach($IP in Get-Content $IPS) 
{
    echo "$IP Adresine Bağlanıldı"
    Invoke-Command -ComputerName $IP -Credential $credential -ScriptBlock { 

    #Son oluşturma tarihi X günden az olanlar silinecektir 
    $file_age = "3"

    #Klasör içinde silinecek dosya uzantıları 
    $filetype1 = "*.txt"
    $filetype2 = "*.csv"

    #Scriptin silme işlemi yapacağı dizin
    $TargetFolder = "C:\CSVFormat\"

    #Scriptin yedek alacağı dizin
    $DestinationPATH = "D:\Yedek\"

    #Silinecek dosya isminde aşağıdaki kelimeler varsa silme haricinde tutulur 
    $namefilter_1="Silinen"
    $namefilter_2="Dokümanlar"
    
    #Silme işleminin yapılacağı dizindeki dosyaların filtrelenmesi
    $TFiles = Get-ChildItem $TargetFolder -recurse -include $filetype1,$filetype2

    Write-Output "Zipleme ve Silme İşlemlerine Başlanıyor"

    #İşlemlerin yapılacağı klasör altındaki dosyaları kontrol etme işlemleri
    foreach ($File in $TFiles)
    {
    
    #Eğer klasör içinde belirtilen tarihte dosya varsa ve dosyanın uzantısı .txt ise
    if (($File.Lastwritetime -lt ($(Get-Date).AddDays(-$file_age))) -and ("*$($File.Extension)" -like $filetype1))
    {
            #Txt dosyalarını zipleme ve silme işlemi
            Compress-Archive $File -DestinationPath "$DestinationPATH\txt_Dokümanlar.zip" -Update
            Write-Output "$($File) dosyası ziplendi."

            Remove-Item $File -force
            Write-Output "$($File) dosyası silindi."
    }
    #Eğer klasör içinde belirtilen tarihte dosya varsa ve dosyanın uzantısı .csv ise
    if (($File.Lastwritetime -lt ($(Get-Date).AddDays(-$file_age))) -and ("*$($File.Extension)" -like $filetype2))
    {
            #Csv dosyalarını zipleme ve silme işlemi
            Compress-Archive $File -DestinationPath "$DestinationPATH\csv_Dokümanlar.zip" -Update
            Write-Output "$($File) dosyası ziplendi."

            Remove-Item $File -force
            Write-Output "$($File) dosyası silindi."
    }
    }

    #Zip dosyalarını isimlendirme
    Get-ChildItem "$DestinationPATH" -Filter "*Dokümanlar.zip" -Recurse | Rename-Item -NewName {$_.BaseName + $_.LastWriteTime.toString("_hhmm_yyyyMMdd") + ".zip"}
    }
    Write-Output "$($IP) Sunucusunda Zipleme ve Silme İşlemleri Tamamlanmıştır.`n"
}

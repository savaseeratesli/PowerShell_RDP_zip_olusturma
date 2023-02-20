#Bağlanılacak Sunucu Bilgilerinin Alınması
#Kullancıdan Al
$Username = Read-Host "Sunucu Kullanıcı Adını Giriniz"
$Password = Read-Host "Sunucu Kullanıcı Şifresini Giriniz" 

$pass = ConvertTo-SecureString -AsPlainText $Password -Force

 foreach($IP in Get-Content D:\denemeD\ipler.txt) {
    echo "$IP Adresine Bağlanıldı";
    #baglanilan ip uzerinde yapilacak islemler buranin icerisinde
    #Start-Sleep -Seconds 2;

    $credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pass
    Invoke-Command -ComputerName $IP -Credential $credential -ScriptBlock { 

#Scriptin silme işlemi yapacağı klasör
$TargetFolder = Read-Host "İşlemin Yapılacağı Uzantıyı Giriniz"

#Dosyaları zipini alıp zipleme
Compress-Archive -Path "$TargetFolder\*.txt" -DestinationPath "$TargetFolder\txt_Dökümanlar.zip"
Compress-Archive -Path "$TargetFolder\*.xlsx" -DestinationPath "$TargetFolder\xlsx_Dökümanlar.zip"

Start-Sleep -Seconds 5;

#Klasör içinde silinecek dosyaların özellikleri 
$filetype1 = "*.txt"
$filetype2 = "*.xlsx"

#Bunları içerenleri silme
$namefilter_1="Silinen"
$namefilter_2="Dökümanlar"

#Son üç günden sonrasını sil 
$file_age = "0"

Start-Sleep -Seconds 10

foreach ($i in Get-ChildItem $TargetFolder -recurse -include $filetype1,$filetype2)
{

if (($i.Lastwritetime -lt($(Get-Date).AddDays(-$file_age))) -and ($i.name -notmatch $namefilter_1) -and ($i.name -notmatch $namefilter_2))
{

#Silinen dosyaları belirtilen dosyaya yazsın.
echo $i.Name $i.LastWriteTime >> "$TargetFolder\SilinenDökümanlar.txt"
Remove-Item $i -force 

}
}

#Dosyaları sil zip al
Get-ChildItem $TargetFolder -Filter "*Dökümanlar.zip" -Recurse | Rename-Item -NewName {$_.BaseName + $_.LastWriteTime.toString("_yyyyMMdd") + ".zip"}

echo "İşlem Tamamlanmıştır."

}

}







* ·­Òë±¾lngÉú³ÉÆ÷

frmcaption1 = thisform.caption 

cStr2 = ""
cStr3 = ""

For i = 1 To this.ControlCount

	cStr2 = ALLTRIM(frmcaption1) + [;] + this.Controls(i).name + [=]
    IF LEFT(this.Controls(i).name,3) = "grd"
        grd1 = this.Controls(i).name
        FOR k = 1 TO this.&grd1..columncount
          cStr = ALLTRIM(frmcaption1) + [;] + grd1 +".column"+alltrim(str(k))+".header1"+[=]
          *?cStr
          cStr2 = cStr2 + cStr + CHR(13)
        ENDFOR 
    ENDIF 
    cStr3 = cStr3 + cStr2 + CHR(13)
    
NEXT

=STRTOFILE(cStr3,"C:\Temp_lng.TXT")

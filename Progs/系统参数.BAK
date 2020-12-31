*--------------------------------------------------------------------------------------
* 系统参数.PRG
*--------------------------------------------------------------------------------------
SET SAFETY OFF        && 决定改写已有文件之前是否显示对话框
SET TALK OFF          && 决定 Visual FoxPro 是否显示命令结果
SET CENTURY ON        && 显示年份为4位
SET DATE ANSI         && yy.mm.dd (年月日格式)
SET DELETED ON        && ON 为使用范围子句处理记录(包括在相关表中的记录)的命令忽略标有删除标记的记录。
SET EXCLUSIVE OFF     && (私有数据工作期的默认方式)允许网络上的任何用户共享和修改网络上打开的表。
SET HELP ON           && 允许打开帮助
SET ESCAPE OFF        && 禁止运行的程序在按 Esc 键后被中断
SET NULLDISPLAY TO '' && 去除一切值带 null
SET MULTILOCKS ON


*-----设置程序主目录-------------------------
RELEASE gcMainPath
PUBLIC  gcMainPath
gcMainPath = Sys(5)+SYS(2003)+"\"          && 设置当前根目录为系统路径 +SYS(2003)
*gcMainPath = ADDBS(JUSTPATH(SYS(16,1)))  && 设置当前目录为系统路径
*SET DEFAULT TO c:\ 
SET DEFAULT TO &gcMainPath

CD "\FoxproAPI\"
SET PATH TO ;DATA;FORMS;LIBS;MENUS;PROGS;REPORTS;BMP;EXCEL;LNG
*----------------------------------------------


*-----设置系统公共变量-------------------------
RELEASE c版本号,c版权,cSqlServer,cLng,cColor,cfrmname
PUBLIC  c版本号,c版权,cSqlServer,cLng,cColor,cfrmname

c版本号='V20200720'
c版权 = '版权所有：(C)EbongSoft 2020'
*----------------------------------------------

*------从sys.ini 文件里面获取默认信息---------------------------------
If !File('Sys.ini')
    Messagebox('配制文件 Sys.ini 不存在！'+Space(5),16,'信息提示')
    QUIT
Endif
lcConfigStr=Upper(Filetostr('Sys.ini')) &&将INI文件转成字符串
lnConfigStrLine=Memlines(lcConfigStr)      &&取得INI文件的行数
For I=1 To lnConfigStrLine
    lcRowStr=Mline(lcConfigStr,I)  &&取得INI文件的每行
    Do Case
        Case Upper('ServerIPAdress=')$lcRowStr
            csqlserver=Alltrim(Strextract(lcRowStr,Upper('ServerIPAdress=')))  && 数据库路径
        CASE UPPER('Lanuage=')$lcRowStr
            cLng=Alltrim(Strextract(lcRowStr,Upper('Lanuage=')))  && 默认语言
        Case Upper('Color=')$lcRowStr
            cColor=Alltrim(Strextract(lcRowStr,Upper('Color='))) && 默认主题颜色
    Endcase
Endfor


*--------------------------------------------------------------------------------------

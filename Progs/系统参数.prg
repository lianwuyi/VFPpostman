*--------------------------------------------------------------------------------------
* ϵͳ����.PRG
*--------------------------------------------------------------------------------------
SET SAFETY OFF        && ������д�����ļ�֮ǰ�Ƿ���ʾ�Ի���
SET TALK OFF          && ���� Visual FoxPro �Ƿ���ʾ������
SET CENTURY ON        && ��ʾ���Ϊ4λ
SET DATE ANSI         && yy.mm.dd (�����ո�ʽ)
SET DELETED ON        && ON Ϊʹ�÷�Χ�Ӿ䴦���¼(��������ر��еļ�¼)��������Ա���ɾ����ǵļ�¼��
SET EXCLUSIVE OFF     && (˽�����ݹ����ڵ�Ĭ�Ϸ�ʽ)���������ϵ��κ��û�������޸������ϴ򿪵ı�
SET HELP ON           && ����򿪰���
SET ESCAPE OFF        && ��ֹ���еĳ����ڰ� Esc �����ж�
SET NULLDISPLAY TO '' && ȥ��һ��ֵ�� null
SET MULTILOCKS ON


*-----���ó�����Ŀ¼-------------------------
RELEASE gcMainPath
PUBLIC  gcMainPath
gcMainPath = Sys(5)+SYS(2003)+"\"          && ���õ�ǰ��Ŀ¼Ϊϵͳ·�� +SYS(2003)
*gcMainPath = ADDBS(JUSTPATH(SYS(16,1)))  && ���õ�ǰĿ¼Ϊϵͳ·��
*SET DEFAULT TO c:\ 
SET DEFAULT TO &gcMainPath

CD "\FoxproAPI\"
SET PATH TO ;DATA;FORMS;LIBS;MENUS;PROGS;REPORTS;BMP;EXCEL;LNG
*----------------------------------------------


*-----����ϵͳ��������-------------------------
RELEASE c�汾��,c��Ȩ,cSqlServer,cLng,cColor,cfrmname
PUBLIC  c�汾��,c��Ȩ,cSqlServer,cLng,cColor,cfrmname

c�汾��='V20200720'
c��Ȩ = '��Ȩ���У�(C)EbongSoft 2020'
*----------------------------------------------

*------��sys.ini �ļ������ȡĬ����Ϣ---------------------------------
If !File('Sys.ini')
    Messagebox('�����ļ� Sys.ini �����ڣ�'+Space(5),16,'��Ϣ��ʾ')
    QUIT
Endif
lcConfigStr=Upper(Filetostr('Sys.ini')) &&��INI�ļ�ת���ַ���
lnConfigStrLine=Memlines(lcConfigStr)      &&ȡ��INI�ļ�������
For I=1 To lnConfigStrLine
    lcRowStr=Mline(lcConfigStr,I)  &&ȡ��INI�ļ���ÿ��
    Do Case
        Case Upper('ServerIPAdress=')$lcRowStr
            csqlserver=Alltrim(Strextract(lcRowStr,Upper('ServerIPAdress=')))  && ���ݿ�·��
        CASE UPPER('Lanuage=')$lcRowStr
            cLng=Alltrim(Strextract(lcRowStr,Upper('Lanuage=')))  && Ĭ������
        Case Upper('Color=')$lcRowStr
            cColor=Alltrim(Strextract(lcRowStr,Upper('Color='))) && Ĭ��������ɫ
    Endcase
Endfor


*--------------------------------------------------------------------------------------

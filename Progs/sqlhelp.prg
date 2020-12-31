
*
*!* �м�㣨��Ƴ�tosql()������
*

*!*	ʾ����
*!*	SELECT assets
*!*	COPY all to ..\test.dbf 

*!*	* ���浽SQL���ݿ� ��������SaveRecord([���浽SQL�ı���],[����ID���ֶ�],[save/delete/query],[SQL��ѯ���]��
*!*	SaveRecord([ASSETS],[ASSET_ID],[SAVE])


FUNCTION SqlHelp(pTable,pKeyField,pMethod,pStatement)
    
	pTable = UPPER ( pTable )  && ����ǰ���������ָĳɴ�д
    pKeyField = UPPER ( pKeyField ) 
    pMethod = UPPER( pMethod )    
    
    IF EMPTY(pTable)=.T. OR EMPTY(pKeyField)=.T.OR EMPTY(pMethod)=.T.
        MESSAGEBOX( [ Can't find parameters ], 16, [ Error ], 2000 )
		RETURN
    ENDIF 

    IF pMethod <> [QUERY] 
        IF !FILE([..\test.dbf])
    	    MESSAGEBOX( [ Can't find ..\test.dbf ], 16, [ Error ], 2000 )
		    RETURN
        ENDIF 
 
		SELECT 0
		USE ..\test.dbf EXCLUSIVE
		PACK   
		GO TOP  
*!*			IF TYPE( pTable + [.] + pKeyField )=[U]
*!*			  MESSAGEBOX( [ The KeyField is wrong ], 16, [ Error ], 2000 )
*!*			  USE
*!*			  RETURN 
*!*			ENDIF 	
		keyvalue = &pKeyField && �����ϵ�����ID��
		USE
    ENDIF 

    DO �������ݿ�.prg 
   
    IF pMethod = [QUERY] AND EMPTY(pStatement)=.T.
        MESSAGEBOX( [ Can't find statement ], 16, [ Error ], 2000 )
		RETURN       
    ENDIF  
    
    IF pMethod = [QUERY] AND EMPTY(pStatement)=.F.
        cExpr = pStatement + [ order by ] + pKeyField 
		lr = SQLExec ( lnHandle, cExpr )
		COPY all to ..\test.dbf
		IF lr < 0
		   Msg = [Unable to query] + CHR(13) + cExpr
		   MESSAGEBOX( Msg, 16, [SQL error] )
		   RETURN 
		ENDIF
		
		*MESSAGEBOX( [ ��ѯ�ɹ�! ], 64, [��ʾ��] )      
        SQLDISCONNECT(0)	
        RETURN 
    ENDIF 
    
    IF pMethod = [DELETE] && ��ɾ����--------------------------------------------------------
        Dlm = IIF ( TYPE ( pKeyField ) = [C], ['], [] )  && �ж�pKeyField �Ƿ�Ϊ"c"�ַ��ͣ�����ǣ�����'�������򲻼ӡ�
		cExpr = [DELETE ] + pTable + [ WHERE ] + pKeyField + [=] + Dlm + TRANSFORM ( m.KeyValue ) + Dlm  && cExpr= Delete cp where 
		lr = SQLExec ( lnHandle, cExpr )
		IF lr < 0
		   Msg = [Unable to delete record] + CHR(13) + cExpr
		   MESSAGEBOX( Msg, 16, [SQL error] )
		   RETURN 
		ENDIF
		*MESSAGEBOX( [ ID��] + ALLTRIM(STR(KeyValue)) +  [ ɾ���ɹ�! ], 64, [��ʾ��] )      
        DELETE FILE ..\test.dbf 
        SQLDISCONNECT(0)	
        RETURN 
    ENDIF 
    
	Cmd = [SELECT * FROM ] + pTable + [ WHERE 1=2]
	lr = SQLEXEC( lnHandle, Cmd )  && ���������ǣ��鿴���ṹ1=2����FALSE ��û�еõ��κ����ݣ�ֻ����ʾ�ֶ����ƶ��ѡ�
	IF lr <1
		MESSAGEBOX( [Unable to connect], 16, [SQL Connection error], 2000 )
		RETURN 
	ENDIF 
	COPY all to ..\test_sql.dbf 
	USE

    RELEASE nLastKeyVal
    PUBLIC  nLastKeyVal

	IF keyvalue > 0 && key��ֵʱ����ɾ������
	    
		Cmd = [DELETE FROM ] + pTable + [ WHERE ] + pKeyField + [=] + ALLTRIM(STR(keyvalue))
		lr1 = SQLEXEC( lnHandle, Cmd )  
		IF lr < 1
			MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 )
			RETURN 
		ENDIF 
		nLastKeyVal = TRANSFORM(keyvalue)
		
	ELSE && ��ȡ���µ�KEY

		Cmd = [SELECT Name FROM SysObjects WHERE Name='KEYS' AND Type='U']  && Cmd= select Name from SysObjects where name='KEYS' and type='U'
		lr = SQLEXEC( lnHandle, Cmd )  && ��ѯ�Ƿ��б����� KEYS �ı���
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && ��ѯ������
		ENDIF
		IF RECCOUNT([SQLResult]) = 0 && �����ѯ���ؽ����0 ����û��KEYS����
		   Cmd = [CREATE TABLE Keys ( TableName Char(20), LastKeyVal Integer )] && ���� ���� KEYS���ֶ� TableName char(20),LastKeyVal Integer
		   SQLEXEC( lnHandle, Cmd )
		ENDIF

		Cmd = [SELECT LastKeyVal FROM Keys WHERE TableName='] + pTable + ['] && �����ѯ�������0�����ѯKeys����tablename���ڵ�ǰ������lastkeyval�Ƕ��٣�
		lr = SQLEXEC( lnHandle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && �����������
		ENDIF

		IF RECCOUNT([SQLResult]) = 0 && �����ѯ���ؽ����0 ����
		   Cmd = [INSERT INTO Keys VALUES ('] +  pTable + [', 0 )] && ����keys���� ��ǰ������0 ��2��ֵ��
		   lr = SQLEXEC( lnHandle, Cmd )
		   IF lr < 0
		      MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && �����������
		   ENDIF
		ENDIF

		Cmd = [UPDATE Keys SET LastKeyVal=LastKeyVal + 1 WHERE TableName='] +  pTable + [']
		lr = SQLEXEC( lnHandle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && �����������
		ENDIF
		      
		Cmd = [SELECT LastKeyVal FROM Keys WHERE TableName='] +  pTable + [']
		lr = SQLEXEC( lnHandle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && �����������
		ENDIF
		nLastKeyVal = TRANSFORM(SQLResult.LastKeyVal) &&transform������������ȡlastkeyva�����ֵ����ֵ��nLastKeyVal
		
	ENDIF 
	
	*** ��test.dbf��ʱ������׷�ӵ�test_sql.dbf
	SELECT 0
	USE ..\test_sql.dbf EXCLUSIVE 
    APPEND FROM ..\test.dbf 
    REPLACE ALL &pKeyField WITH VAL(nLastKeyVal)
    cRecCount = TRANSFORM(RECCOUNT())
    GO TOP 
   
    SCAN
	    LOCAL I
	    Cmd  = [INSERT INTO ] + pTable + [ VALUES ( ]  && ���ñ�����cmd���� ���ӵ�ǰ���� ��cmd= INSERT INTO +��ǰdbf����+ values (��
	    FOR I = 1 TO FCOUNT()
	        fld  = FIELD(I)
	        IF TYPE(Fld) = [G]
	           LOOP
	        ENDIF
	        dta  = &Fld
	        typ  = VARTYPE(dta)
	        cdta = ALLTRIM(TRANSFORM(dta))
	        cdta = CHRTRAN ( cdta, CHR(39),CHR(146) )
	        DO CASE
	           CASE Typ $ [CM]
	                Cmd = Cmd + ['] + cDta + ['] + [, ]
	           CASE Typ $ [IN]
	                Cmd = Cmd +       cDta       + [, ]
	           CASE Typ = [D]
	                IF cDta = [/  /]
	                   cDta = []
	                ENDIF
	                Cmd = Cmd + ['] + cDta + ['] + [, ]
	           CASE Typ = [T]
	                IF cDta = [/  /]
	                   cDta = []
	                ENDIF
	                Cmd = Cmd + ['] + cDta + ['] + [, ]
	           CASE Typ = [L]
	                Cmd = Cmd + IIF('F'$cdta,[0],[1]) + [, ]
	        ENDCASE
	      ENDFOR
	    *USE
	    
	    Cmd = LEFT(Cmd,LEN(cmd)-2) + [ )]

	    lr = SQLEXEC( lnHandle, Cmd )
	    IF lr < 0
	       MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && �����������
	       *SUSPEND
	    ENDIF
	    * MESSAGEBOX( [ ID��] + nLastKeyVal + [ ����ɹ�! ], 64, [ ��ʾ��] )
    
    ENDSCAN 
    USE 
        
    DELETE FILE ..\test.dbf 
    DELETE FILE ..\test_sql.dbf 
    
    SQLDISCONNECT(0)	

ENDFUNC 
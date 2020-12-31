
*
*!* 中间层（设计成tosql()函数）
*

*!*	示例：
*!*	SELECT assets
*!*	COPY all to ..\test.dbf 

*!*	* 保存到SQL数据库 方法：【SaveRecord([保存到SQL的表名],[主键ID的字段],[save/delete/query],[SQL查询语句]】
*!*	SaveRecord([ASSETS],[ASSET_ID],[SAVE])


FUNCTION SqlHelp(pTable,pKeyField,pMethod,pStatement)
    
	pTable = UPPER ( pTable )  && 将当前表单的名字改成大写
    pKeyField = UPPER ( pKeyField ) 
    pMethod = UPPER( pMethod )    
    
    IF EMPTY(pTable)=.T. OR EMPTY(pKeyField)=.T.OR EMPTY(pMethod)=.T.
        MESSAGEBOX( [ Can't find parameters ], 16, [ Error ], 2000 )
		RETURN
    ENDIF 

    IF pMethod <> [QUERY] OR pMethod <> [DELETE]
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
		keyvalue = &pKeyField && 表单上的主键ID号
		USE
    ENDIF 

    DO 连接数据库.prg 
   
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
		
		*MESSAGEBOX( [ 查询成功! ], 64, [提示：] )      
        SQLDISCONNECT(0)	
        RETURN 
    ENDIF 
    
    IF pMethod = [DELETE] && 【删除】--------------------------------------------------------
        Dlm = IIF ( TYPE ( pKeyField ) = [C], ['], [] )  && 判断pKeyField 是否为"c"字符型，如果是，加上'，不是则不加。
		cExpr = [DELETE ] + pTable + [ WHERE ] + pKeyField + [=] + Dlm + TRANSFORM ( m.KeyValue ) + Dlm  && cExpr= Delete cp where 
		lr = SQLExec ( lnHandle, cExpr )
		IF lr < 0
		   Msg = [Unable to delete record] + CHR(13) + cExpr
		   MESSAGEBOX( Msg, 16, [SQL error] )
		   RETURN 
		ENDIF
		*MESSAGEBOX( [ ID：] + ALLTRIM(STR(KeyValue)) +  [ 删除成功! ], 64, [提示：] )      
        DELETE FILE ..\test.dbf 
        SQLDISCONNECT(0)	
        RETURN 
    ENDIF 
    
	Cmd = [SELECT * FROM ] + pTable + [ WHERE 1=2]
	lr = SQLEXEC( lnHandle, Cmd )  && 产生句子是：查看表结构1=2，即FALSE ，没有得到任何数据，只是显示字段名称而已。
	IF lr <1
		MESSAGEBOX( [Unable to connect], 16, [SQL Connection error], 2000 )
		RETURN 
	ENDIF 
	COPY all to ..\test_sql.dbf 
	USE

    RELEASE nLastKeyVal
    PUBLIC  nLastKeyVal

	IF keyvalue > 0 && key有值时，先删除数据
	
		Cmd = [DELETE FROM ] + pTable + [ WHERE ] + pKeyField + [=] + ALLTRIM(STR(keyvalue))
		lr1 = SQLEXEC( lnHandle, Cmd )  
		IF lr < 1
			MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 )
			RETURN 
		ENDIF 
		nLastKeyVal = TRANSFORM(keyvalue)
		
	ELSE && 获取个新的KEY

		Cmd = [SELECT Name FROM SysObjects WHERE Name='KEYS' AND Type='U']  && Cmd= select Name from SysObjects where name='KEYS' and type='U'
		lr = SQLEXEC( lnHandle, Cmd )  && 查询是否有表名是 KEYS 的表。
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 查询语句出错
		ENDIF
		IF RECCOUNT([SQLResult]) = 0 && 如果查询返回结果是0 ，（没有KEYS表）
		   Cmd = [CREATE TABLE Keys ( TableName Char(20), LastKeyVal Integer )] && 创建 表名 KEYS，字段 TableName char(20),LastKeyVal Integer
		   SQLEXEC( lnHandle, Cmd )
		ENDIF

		Cmd = [SELECT LastKeyVal FROM Keys WHERE TableName='] + pTable + ['] && 如果查询结果不是0，则查询Keys表内tablename等于当前表名的lastkeyval是多少，
		lr = SQLEXEC( lnHandle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
		ENDIF

		IF RECCOUNT([SQLResult]) = 0 && 如果查询返回结果是0 ，则
		   Cmd = [INSERT INTO Keys VALUES ('] +  pTable + [', 0 )] && 添加keys表里 当前表名和0 这2个值。
		   lr = SQLEXEC( lnHandle, Cmd )
		   IF lr < 0
		      MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
		   ENDIF
		ENDIF

		Cmd = [UPDATE Keys SET LastKeyVal=LastKeyVal + 1 WHERE TableName='] +  pTable + [']
		lr = SQLEXEC( lnHandle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
		ENDIF
		      
		Cmd = [SELECT LastKeyVal FROM Keys WHERE TableName='] +  pTable + [']
		lr = SQLEXEC( lnHandle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
		ENDIF
		nLastKeyVal = TRANSFORM(SQLResult.LastKeyVal) &&transform（）函数，提取lastkeyva里的数值，赋值给nLastKeyVal
		
	ENDIF 
	
	*** 将test.dbf临时表数据追加到test_sql.dbf
	SELECT 0
	USE ..\test_sql.dbf EXCLUSIVE 
    APPEND FROM ..\test.dbf 
    REPLACE ALL &pKeyField WITH VAL(nLastKeyVal)
    cRecCount = TRANSFORM(RECCOUNT())
    GO TOP 
   
    SCAN
	    LOCAL I
	    Cmd  = [INSERT INTO ] + pTable + [ VALUES ( ]  && 设置变量，cmd等于 添加当前数据 “cmd= INSERT INTO +当前dbf表名+ values (”
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
	       MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
	       *SUSPEND
	    ENDIF
	    * MESSAGEBOX( [ ID：] + nLastKeyVal + [ 保存成功! ], 64, [ 提示：] )
    
    ENDSCAN 
    USE 
        
    DELETE FILE ..\test.dbf 
    DELETE FILE ..\test_sql.dbf 
    
    SQLDISCONNECT(0)	

ENDFUNC 
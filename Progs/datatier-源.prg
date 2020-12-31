*!*	---------------------------------------------------------------
*!*	函数说明：
*!*	1.DEFINE CALSS 名字 as Custom：自定义类过程。
*!*	2.PARAMETERS：将调用程序传来的数据赋值给私有内存变量或数组。【接收的参数仅在本段程序内有效，其调用的子程序也是看不到的(相当于在参数上加了一个Local)】
*!*	3.LPARAMETERS：将调用程序传入的数据，赋值给局部内存变量和数组。不仅在本程序内有效，【在子程序内也可访问】
*!*----------------------------------------------------------------
*!*	变量说明：
*!*	1.pTable是当前临时表
*!*	---------------------------------------------------------------
*!*	PROCEDURE CreateCursor   && 创建临时表，创建一个跟SQL表一样字段的dbf表。
*!*	PROCEDURE GetHandle      && 获得句柄


*!*	FUNCTION GetNextKeyValue  && 获取keys表里的ID。
*!*	---------------------------------------------------------------


DEFINE CLASS DataTier AS Custom   && 自定义DataTier类
*!*	AccessMethod = []	&& Any attempt to assign a value to this property will be trapped 
* 					   by the "setter" method AccessMethod_Assign.
*!*	ConnectionString = [Driver={SQL Server};Server=(local);Database=Northwind;UID=sa;PWD=;]
ConnectionString = [Driver={SQL Server};Server=123.207.38.110;Database=xlydb;UID=sa;PWD=Eb123456;]
Handle       = 0

*!*	PROCEDURE AccessMethod_Assign  && 类过程，判断AM是属于什么类型的标签。
*!*	PARAMETERS AM
*!*	DO CASE
*!*	   CASE AM = [DBF]
*!*			THIS.AccessMethod = [DBF]	&& FoxPro tables
*!*	   CASE AM = [SQL]
*!*			THIS.AccessMethod = [SQL]	&& MS Sql Server
*!*			THIS.GetHandle
*!*	   CASE AM = [XML]
*!*	        MESSAGEBOX( [Implemented in Chapter 5], 16, _VFP.Caption, 2000 )
*!*			THIS.AccessMethod = []	&& FoxPro XMLAdapter
*!*	   CASE AM = [WC]
*!*	        MESSAGEBOX( [Implemented in Chapter 5], 16, _VFP.Caption, 2000 )
*!*			THIS.AccessMethod = []	&& FoxPro XMLAdapter
*!*	   OTHERWISE
*!*			MESSAGEBOX( [Incorrect access method ] + AM, 16, [Setter error] )
*!*			THIS.AccessMethod = []
*!*	ENDCASE
*!*	_VFP.Caption = [Data access method: ] + THIS.AccessMethod
*!*	ENDPROC


PROCEDURE CreateCursor   && 创建临时表---------------------------
LPARAMETERS pTable  && pTable 临时表
LPARAMETERS pTable, pKeyField  

*!*	IF THIS.AccessMethod = [DBF]
*!*	   IF NOT USED ( pTable )
*!*	      SELECT 0
*!*	      USE ( pTable ) ALIAS ( pTable )
*!*	   ENDIF
*!*	   SELECT ( pTable )
*!*	   IF NOT EMPTY ( pKeyField )
*!*	      SET ORDER TO TAG ( pKeyField )
*!*	   ENDIF
*!*	   RETURN
*!*	ENDIF
Cmd = [SELECT * FROM ] + pTable + [ WHERE 1=2]
*!*	DO CASE
*!*	   CASE THIS.AccessMethod = [SQL]
		SQLEXEC( THIS.Handle, Cmd )  && 产生句子是：SQLEXEC(THIS.Handle,select * from 表名 WHERE 1=2 )  查看表结构(1=2，即FALSE ，没有得到任何数据，只是显示字段名称而已。)
		AFIELDS ( laFlds )  && 返回 laFlds 的字段数量
		USE
		CREATE CURSOR ( pTable ) FROM ARRAY laFlds  && 创建临时表 ptable 字段跟SQL的字段一样。
*!*	   CASE THIS.AccessMethod = [XML]
*!*	   CASE THIS.AccessMethod = [WC]
*!*	ENDCASE


PROCEDURE GetHandle  && 获得句柄------------------------------------
*!*	IF THIS.AccessMethod = [SQL]
   IF THIS.Handle > 0
      RETURN
   ENDIF
   THIS.Handle = SQLSTRINGCONNECT( THIS.ConnectionString ) && 将返回正非零数值作为语句句柄。如果SQLSTRINGCONNECT（）无法建立连接，则返回-1。
   IF THIS.Handle < 1
*!*	      MESSAGEBOX( [Unable to connect], 16, [SQL Connection error], 2000 )
      MESSAGEBOX( [无法连接], 16, [SQL连接出错], 2000 )
   ENDIF
*!*	  ELSE
*!*	   Msg = [A SQL connection was requested, but access method is ] + THIS.AccessMethod
*!*	   MESSAGEBOX( Msg, 16, [SQL Connection error], 2000 )
*!*	   THIS.AccessMethod = []
*!*	ENDIF
RETURN


PROCEDURE GetMatchingRecords  && 获取匹配记录-----------------------------
LPARAMETERS pTable, pFields, pExpr
pFields = IIF ( EMPTY ( pFields ), [*], pFields )  && 判断 pFields是否为空，空则显示*号，不空显示字段。
pExpr   = IIF ( EMPTY ( pExpr ), [], ;
		  [ WHERE ] + STRTRAN ( UPPER ( ALLTRIM ( pExpr ) ), [WHERE ], [] ) )  && 判断pExpr是否为空，空则显示空，不空显示 where + 
cExpr   = [SELECT ] + pFields + [ FROM ] + pTable + pExpr  && cExpr= select (pFields或者*) from 当前表名 (空或者where pExpr)
IF NOT USED ( pTable )
   RetVal = THIS.CreateCursor ( pTable )
ENDIF
*!*	DO CASE
*!*	   CASE THIS.AccessMethod = [DBF]
*!*			&cExpr
*!*	   CASE THIS.AccessMethod = [SQL]
		lr = SQLExec ( THIS.Handle, cExpr )
		IF lr >= 0
		   THIS.FillCursor()
		  ELSE
		   Msg = [Unable to return records] + CHR(13) + cExpr
		   MESSAGEBOX( Msg, 16, [SQL error] )
		ENDIF
*!*	ENDCASE
ENDPROC


PROCEDURE CreateView  && 创建视图 --------------------------------
LPARAMETERS pTable
IF NOT USED( pTable ) && 如果ptable无法打开。
   MESSAGEBOX( [Can't find cursor ] + pTable, 16, [Error creating view], 2000 )  && 找不到游标 pTable,创建视图时出错
   RETURN
ENDIF
SELECT ( pTable ) && 打开当前临时表
AFIELDS( laFlds ) && 返回 laFlds 的字段数量
SELECT 0
CREATE CURSOR ( [View] + pTable ) FROM ARRAY laFlds && 创建临时表 View+pTable,字段跟原来的字段一样。
ENDFUNC


PROCEDURE GetOneRecord  && 获得一条记录----------------------------
LPARAMETERS pTable, pKeyField, pKeyValue
SELECT ( pTable )
Dlm   = IIF ( TYPE ( pKeyField ) = [C], ['], [] )
IF THIS.AccessMethod = [DBF]
   cExpr = [LOCATE FOR ] + pKeyField + [=] + Dlm + TRANSFORM ( pKeyValue ) + Dlm
 ELSE
   cExpr = [SELECT * FROM ] + pTable + [ WHERE ] + pKeyField + [=] + Dlm + TRANSFORM ( pKeyValue ) + Dlm
ENDIF
DO CASE
   CASE THIS.AccessMethod = [DBF]
		&cExpr
   CASE THIS.AccessMethod = [SQL]
		lr = SQLExec ( THIS.Handle, cExpr )
		IF lr >= 0
		   THIS.FillCursor( pTable )
		  ELSE
		   Msg = [Unable to return record] + CHR(13) + cExpr
		   MESSAGEBOX( Msg, 16, [SQL error] )
		ENDIF
ENDCASE
ENDFUNC


PROCEDURE FillCursor  && 加载全部数据  ----------------------------
LPARAMETERS pTable
*!*	IF THIS.AccessMethod = [DBF]
*!*	   RETURN
*!*	ENDIF
SELECT ( pTable )  && 打开当前表单
ZAP  && 删除全部数据
APPEND FROM DBF ( [SQLResult] ) && 追加SQL返回的结果数据
USE IN SQLResult && 打开SQL返回的结果数据表
GO TOP && 指定到数据第一条数据
ENDPROC


PROCEDURE DeleteRecord  && 删除记录  --------------------------------
LPARAMETERS pTable, pKeyField
*!*	ForExpr  = IIF ( THIS.AccessMethod = [DBF], [ FOR ], [ WHERE ] )
KeyValue = EVALUATE ( pTable + [.] + pKeyField )  && EVALUATE()计算字符表达式的值并返回结果
Dlm      = IIF ( TYPE ( pKeyField ) = [C], ['], [] )  && 判断pKeyField 是否为"c"字符型，如果是，加上'，不是则不加。
*!*	DO CASE
*!*	   CASE THIS.AccessMethod = [DBF]
*!*			cExpr = [DELETE FOR ] + pKeyField + [=] + Dlm + TRANSFORM ( m.KeyValue ) + Dlm
*!*			&cExpr
*!*			SET DELETED ON
*!*			GO TOP
*!*	   CASE THIS.AccessMethod = [SQL]
		cExpr = [DELETE ] + pTable + [ WHERE ] + pKeyField + [=] + Dlm + TRANSFORM ( m.KeyValue ) + Dlm  && cExpr= Delete cp where 
		lr = SQLExec ( THIS.Handle, cExpr )
		IF lr < 0
		   Msg = [Unable to delete record] + CHR(13) + cExpr
		   MESSAGEBOX( Msg, 16, [SQL error] )
		ENDIF
*!*	ENDCASE
ENDFUNC


PROCEDURE SaveRecord  && 保存记录  --------------------------------
PARAMETERS pTable, pKeyField, pAdding
*!*	IF THIS.AccessMethod = [DBF]
*!*	   RETURN
*!*	ENDIF
*IF pAdding  && 传递过来变量是 adding，则运行插入语句
	THIS.InsertRecord ( pTable, pKeyField )  && 【插入记录过程】
* ELSE  && 不是，则执行修改语句
*	THIS.UpdateRecord ( pTable, pKeyField )  && 【修改记录过程】
*ENDIF
ENDPROC


PROCEDURE InsertRecord  && 插入记录 ------------------------------
LPARAMETERS pTable, pKeyField
cExpr = THIS.BuildInsertCommand ( pTable, pKeyField )   && 【建立插入命令过程】
_ClipText = cExpr && 这系统变量存储的就是剪贴板的内容
*!*	DO CASE
*!*	   CASE THIS.AccessMethod = [SQL]
		lr = SQLExec ( THIS.Handle, cExpr )   && 拿CP表执行后得出 lr=SQLExec(this.handle,instert cp(产品id,产品类别,产品名称) values （1,'1','1')）
		IF lr < 0  && 如果返回<0
       *!* msg = [Unable to insert record; command follows:] + CHR(13) + cExpr  
		   msg = [无法插入记录；命令如下：] + CHR(13) + cExpr  
		   MESSAGEBOX( Msg, 16, [SQL error] )
		ELSE 
		  MESSAGEBOX( [保存成功!], 16, [提示：] )
		ENDIF
*!*	ENDCASE
ENDFUNC


PROCEDURE UpdateRecord
LPARAMETERS pTable, pKeyField
cExpr = THIS.BuildUpdateCommand ( pTable, pKeyField )
_ClipText = cExpr
DO CASE
   CASE THIS.AccessMethod = [SQL]
		lr = SQLExec ( THIS.Handle, cExpr )
		IF lr < 0
		   msg = [Unable to update record; command follows:] + CHR(13) + cExpr
		   MESSAGEBOX( Msg, 16, [SQL error] )
		ENDIF
ENDCASE
ENDFUNC


FUNCTION BuildInsertCommand && 建立插入命令-------------------------------------
PARAMETERS pTable, pKeyField

Cmd = [INSERT ] + pTable + [ ( ]  && Cmd = insert 当前表名 (
FOR I = 1 TO FCOUNT() && FCOUNT() 返回当前表单字段数目

	Fld = UPPER(FIELD(I)) && 返回表中该字段的名称，并将他大写，且赋值给 fld

    * Can't deal with GENERAL fields, so ignore them 无法处理通用字段，因此忽略它们
	IF TYPE ( Fld ) = [G]  && 如果字符类型是G，通用字段的话，则忽略
	   LOOP && 在循环中如果遇到loop命令，则结束本次循环，程序重新返回循环开始（do while或for语句开头），重新判断循环条件，如果满足则继续循环。
	ENDIF

    * Skip SQL Server identity fields:
    *!*		IF Fld = UPPER(pKeyField)
    *!*		   LOOP
    *!*		ENDIF
    ***************************************

	Cmd = Cmd + Fld + [, ]  && 循环写入 Cmd  
ENDFOR
Cmd = LEFT(Cmd,LEN(Cmd)-2) + [ } VALUES ( ]  && 拿CP表执行后得出?cmd：【 instert cp(产品id,产品类别,产品名称) values （ 】

FOR I = 1 TO FCOUNT()  && 再次循环，fcount（）返回当前表单字段的数目
	Fld = FIELD(I)  && 获取当前字段的名称，赋值给Fld
	IF TYPE ( Fld ) = [G]  && 如果该字段是 G类型，即通用类型的字符，则忽略
	   LOOP && 循环忽略命令
	ENDIF

	* Skip SQL Server identity fields:
	*!*		IF Fld = UPPER(pKeyField)
	*!*		   LOOP
	*!*		ENDIF
	***************************************

	Dta = ALLTRIM(TRANSFORM ( &Fld )) &&  TRANSFORM()将字符或者数字转换成字符串
	Dta = CHRTRAN ( Dta, CHR(39), CHR(146) )		&& get rid of single quotes in the data 删除数据中的单引号
	Dta = IIF ( Dta = [/  /], [], Dta )  && 如果数据是/ /,则去除
	Dta = IIF ( Dta = [.F.], [0], Dta )  && 如果数据是 .F.,则改为0
	Dta = IIF ( Dta = [.T.], [1], Dta )  && 如果数据是 .T.,则改为1
	Dlm = IIF ( TYPE ( Fld ) $ [CM],['],; && 如果数据是字符型，则加[']
	      IIF ( TYPE ( Fld ) $ [DT],['],; && 如果数据是日期型，也加[']
	      IIF ( TYPE ( Fld ) $ [IN],[],	[]))) &&如果数据是数值型，则不加任何符号
	Cmd = Cmd + Dlm + Dta + Dlm + [, ]  && 循环写入
ENDFOR
Cmd = LEFT ( Cmd, LEN(Cmd) -2) + [ )]  && Remove ", " add " )"    删除[，]号，增加[)]号
RETURN Cmd  && 返回Cmd  拿CP表执行后得出?cmd：【 instert cp(产品id,产品类别,产品名称) values （1,'1','1') 】
ENDFUNC


FUNCTION BuildUpdateCommand
PARAMETERS pTable, pKeyField
Cmd = [UPDATE ]  + pTable + [ SET ]
FOR I = 1 TO FCOUNT()
	Fld = UPPER(FIELD(I))
	IF Fld = UPPER(pKeyField)
	   LOOP
	ENDIF
	IF TYPE ( Fld ) = [G]
	   LOOP
	ENDIF
	Dta = ALLTRIM(TRANSFORM ( &Fld ))
	IF Dta = [.NULL.]
	   DO CASE
		  CASE TYPE ( Fld ) $ [CMDT]
			   Dta = []
		  CASE TYPE ( Fld ) $ [INL]
			   Dta = [0]
	   ENDCASE
	ENDIF
	Dta = CHRTRAN ( Dta, CHR(39), CHR(146) )		&& get rid of single quotes in the data
	Dta = IIF ( Dta = [/  /], [], Dta )
	Dta = IIF ( Dta = [.F.], [0], Dta )
	Dta = IIF ( Dta = [.T.], [1], Dta )
	Dlm = IIF ( TYPE ( Fld ) $ [CM],['],;
	      IIF ( TYPE ( Fld ) $ [DT],['],;
	      IIF ( TYPE ( Fld ) $ [IN],[],	[])))
	Cmd = Cmd + Fld + [=] + Dlm + Dta + Dlm + [, ]
ENDFOR
Dlm = IIF ( TYPE ( pKeyField ) = [C], ['], [] )
Cmd = LEFT ( Cmd, LEN(Cmd) -2 )			;
	+ [ WHERE ] + pKeyField + [=] 		;
	+ + Dlm + TRANSFORM(EVALUATE(pKeyField)) + Dlm
RETURN Cmd
ENDFUNC


PROCEDURE SelectCmdToSQLResult
LPARAMETERS pExpr
DO CASE
   CASE THIS.AccessMethod = [DBF]
		 pExpr = pExpr + [ INTO CURSOR SQLResult]
		&pExpr
   CASE THIS.AccessMethod = [SQL]
		lr = SQLExec ( THIS.Handle, pExpr )
		IF lr < 0
		   Msg = [Unable to return records] + CHR(13) + cExpr
		   MESSAGEBOX( Msg, 16, [SQL error] )
		ENDIF
ENDCASE
ENDFUNC


FUNCTION GetNextKeyValue  && 获取下一个键值----------------------------------------【从KEYS表获得ID，并且将KEYS表的ID+1】
LPARAMETERS pTable  &&  当前表单变量
EXTERNAL ARRAY laVal  && 这是一个数组
pTable = UPPER ( pTable )  && 将当前表单的名字改成大写
*!*	DO CASE

*!*	   CASE THIS.AccessMethod = [DBF]
*!*			IF NOT FILE ( [Keys.DBF] )
*!*			   CREATE TABLE Keys ( TableName Char(20), LastKeyVal Integer )
*!*			ENDIF
*!*			IF NOT USED ( [Keys] )
*!*			   USE Keys IN 0
*!*			ENDIF
*!*			SELECT Keys
*!*			LOCATE FOR TableName = pTable
*!*			IF NOT FOUND()
*!*			   INSERT INTO Keys VALUES ( pTable, 0 )
*!*			ENDIF
*!*			Cmd = [UPDATE Keys SET LastKeyVal=LastKeyVal + 1 ]	;
*!*				+ [ WHERE TableName='] + pTable + [']
*!*			&Cmd
*!*			Cmd = [SELECT LastKeyVal FROM Keys WHERE TableName = '] ;
*!*				+ pTable + [' INTO ARRAY laVal]
*!*			&Cmd
*!*			USE IN Keys
*!*			RETURN TRANSFORM(laVal(1))

*!*	   CASE THIS.AccessMethod = [SQL]
        *** 查询keys表是否存在。——————
		Cmd = [SELECT Name FROM SysObjects WHERE Name='KEYS' AND Type='U']  && Cmd= select Name from SysObjects where name='KEYS' and type='U'
		lr = SQLEXEC( THIS.Handle, Cmd )  && 查询是否有表名是 KEYS 的表。
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 查询语句出错
		ENDIF
		IF RECCOUNT([SQLResult]) = 0 && 如果查询返回结果是0 ，（没有KEYS表）
		   Cmd = [CREATE TABLE Keys ( TableName Char(20), LastKeyVal Integer )] && 创建 表名 KEYS，字段 TableName char(20),LastKeyVal Integer
		   SQLEXEC( THIS.Handle, Cmd )
		ENDIF
		*** —————————————————
		
		***查询keys表内lastkeyval是多少———
		Cmd = [SELECT LastKeyVal FROM Keys WHERE TableName='] + pTable + ['] && 如果查询结果不是0，则查询Keys表内tablename等于当前表名的lastkeyval是多少，
		lr = SQLEXEC( THIS.Handle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
		ENDIF

		IF RECCOUNT([SQLResult]) = 0 && 如果查询返回结果是0 ，则
		   Cmd = [INSERT INTO Keys VALUES ('] +  pTable + [', 0 )] && 添加keys表里 当前表名和0 这2个值。
		   lr = SQLEXEC( THIS.Handle, Cmd )
		   IF lr < 0
		      MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
		   ENDIF
		ENDIF
        ***——————————————————

		***修改keys表里跟tablename=ctable的lastkeyval值+1———
		Cmd = [UPDATE Keys SET LastKeyVal=LastKeyVal + 1 WHERE TableName='] +  pTable + [']
		lr = SQLEXEC( THIS.Handle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
		ENDIF
        ***——————————————————
     
		***查询keys表里跟tablename=ctable的lastkeyval值———        
		Cmd = [SELECT LastKeyVal FROM Keys WHERE TableName='] +  pTable + [']
		lr = SQLEXEC( THIS.Handle, Cmd )
		IF lr < 0
		   MESSAGEBOX( "SQL Error:"+ CHR(13) + Cmd, 16 ) && 调出出错语句
		ENDIF
        ***——————————————————
        
		nLastKeyVal = TRANSFORM(SQLResult.LastKeyVal) &&transform（）函数，提取lastkeyva里的数值，赋值给nLastKeyVal
		USE IN SQLResult
		RETURN TRANSFORM(nLastKeyVal)

*!*	ENDCASE
ENDDEFINE


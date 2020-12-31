*!*	调用方法：
*!*	*** 获取权限
*!*	cfrmname = ALLTRIM(thisform.Name)
*!*	DO quanxian.prg

*!*	IF thisform.txtCust_id.Value > 0 AND EDIT <> 1
*!*	    MESSAGEBOX("权限不足。",16,"Error")
*!*	    RETURN 
*!*	ENDIF 

frmname1 = cfrmname

*-连接数据库----------------------------------------------
DO WHILE .T.
	DO 连接数据库.prg
    
    ***查询SQL
	ln1=SQLExec(lnHandle,'select * from [AUTHORITYS] where USER_ID=?cuserid and MENUFRM=?frmname1') 	
	COPY all to ..\test.dbf 	
    USE 
    
	If ln1<=0  && 查询数据不成功，断开所有数据连接
	  MESSAGEBOX ("查询数据库失败……",16+0+0,"提示")
	  EXIT
	ENDIF

    RELEASE EDIT,DEL,FIND,AUDITING,EXPORT
    PUBLIC  EDIT,DEL,FIND,AUDITING,EXPORT
    
    EDIT = 0
    DEL = 0 
    FIND = 0
    AUDITING = 0
    EXPORT = 0   
    
    SELECT 0 
    USE ..\test.dbf EXCLUSIVE 
    COUNT TO ss
    
    IF ss = 0 OR EMPTY(ss)
      MESSAGEBOX("请让管理员给您分配权限...",16,"Error")
      USE
      SQLDISCONNECT(0) && 断开所有数据连
      RELEASE lnHandle && 删除连接句柄变量
      RETURN TO MASTER
    ENDIF 
    
    GO TOP 
    EDIT = EDIT
    DEL = DEL
    FIND = FIND
    AUDITING = AUDITING
    EXPORT = EXPORT
    USE 
    
  EXIT 
ENDDO

SQLDISCONNECT(0) && 断开所有数据连接
RELEASE lnHandle && 删除连接句柄变量
DELETE FILE ..\test.dbf 

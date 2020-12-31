*!*	调用方法
*!*	DO is64os.prg
*!*	IF IS64 = .T.
*!*	   ?'该系统为64位'
*!*	ENDIF 

DECLARE LONG GetNativeSystemInfo IN Kernel32 STRING@
RELEASE IS64
PUBLIC  IS64
IS64=_Is64bitSystem()
*?IS64
CLEAR DLLS
RETURN

FUNCTION _Is64bitSystem()
    LOCAL stSI
    stSI = REPLICATE(0h00, 36)
    GetNativeSystemInfo(@stSI)
    RETURN INLIST(CTOBIN(LEFT(stSI,2), "2RS"), 6, 9)
    *is64os = INLIST(CTOBIN(LEFT(stSI,2), "2RS"), 6, 9)
ENDFUNC
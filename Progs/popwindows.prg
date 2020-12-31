
*!* VFP中仿MSN的右下角消息提示窗口

*!* 调用方法：
*!* PopWindows(cFrmCap,cFrmIco,nLayer,nWaitTime,cLblCap,cMess)
*!* cFrmCap: C型，窗口的标题
*!* cFrmIco: C型，窗口图标，若你程序中使用SET PATH设置了搜索路径，此处可以写相对路径
*!* nLayer:  N型，窗口透明度，最小值0（完全透明），最大值250（完全不透明）
*!* nWaitTime: N型，等待时间。以毫秒为单位，1秒=1000毫秒
*!* cLblCap: C型，显示信息的标题
*!* cMess:  C型，要显示的信息

*!* 调用示例：
popWindows('提示','..\bmp\net01.ico',250,0,,'系统有版本，请及时升级。')

*!* 说明：
*!* 1、这只是一个思路，你可以通过此思路创建自己的消息窗口，比如加入图片……
*!* 2、因为调用的顶层表单，且设置了透明度，所以不会影响你的基本界面
*!* 3、若不希望窗口自动消失，可设置"等待时间"为0；
*!* 4、当然，当窗口的EDITBOX获得焦点时，也不会自动消失的（单击表单后消失）
*!* 5、编译为EXE为200K，占用内存300K以下（我用DELPHI编译后50K，占用内存30K，为何如此差距？）

FUNCTION popWindows

LPARAMETERS pcCaption,pcIco,pnLayer,pnWaitTim,pcMesCap,pcMes,plMaxButt,plMinButt

PUBLIC oFrmPopWindow
oFrmPopWindow=NEWOBJECT("FrmPopWindow")
lcStuBar=SET("Status Bar")  &&狐友xs160提供界面问题的解决办法
SET STATUS BAR ON
oFrmPopWindow.Show
SET STATUS BAR &lcStuBar.
RETURN
DEFINE CLASS FrmPopWindow AS form
  DataSession = 2 
AlwaysOnTop=.T.            &&若编译为EXE或APP使用，此属性不用设置，TIMER里有设定，效果会更好（从WINDOWS任务栏后面开始上升）
AllowOutput = .F.
ShowInTaskbar=.F.          && 谢谢xywf网友
  Height = 132
  Width = 277 
  BackColor = RGB(255,255,255)
  BorderStyle = 2
  Caption = pcCaption
  Icon = pcIco
  MaxButton = plMaxButt
  MinButton = plMinButt
  ShowWindow = 2
  Visible = .F.
  Name = "FrmPopWindow"
  Layerdd= pnLayer
  MesCap = pcMesCap
  Mes = pcMes
  
  
  PROCEDURE Load
   this.Left = SYSMETRIC(21) - this.Width - SYSMETRIC(3) * 2
   this.Top = SYSMETRIC(22)
   this.AddProperty('FormHeight',this.Height)
   this.AddProperty('FormWidth',this.Width)
   this.AddProperty('FormActive',.T.)
  ENDPROC
  
  PROCEDURE Click
   this.formactive = .T.
  ENDPROC
  
  PROCEDURE Init
   THIS.MY_setwindow(this.layerdd)
   *this.lblCaption.caption = this.MesCap
   this.Edit1.value = this.Mes
  ENDPROC
  PROCEDURE My_SetWindow
   LPARAMETERS pnLayer
   DECLARE INTEGER SetLayeredWindowAttributes IN win32api  INTEGER HWND, INTEGER crKey, INTEGER bAlpha, INTEGER dwFlags
   DECLARE INTEGER SetWindowLong IN user32.DLL INTEGER hWnd, INTEGER nIndex, INTEGER dwNewLong
   DECLARE INTEGER GetWindowLong IN user32.DLL  INTEGER hWnd, INTEGER nIndex
   #DEFINE LWA_COLORKEY    1
   #DEFINE LWA_ALPHA        2
   #DEFINE GWL_EXSTYLE        -20
   #DEFINE WS_EX_LAYERED    0x00080000
   lnFlags = GetWindowLong(thisform.hwnd, GWL_EXSTYLE)
   lnFlags = BITOR(lnFlags, WS_EX_LAYERED)            
   SetWindowLong(thisform.HWnd , GWL_EXSTYLE, lnFlags) 
   i=0
   DO WHILE i<=254
    j=i
    SetLayeredWindowAttributes(thisform.hwnd,RGB(255,255,255) , j, LWA_ALPHA)
    i = i +20
   ENDDO
   SetLayeredWindowAttributes(thisform.hwnd,thisform.BackColor ,pnLayer, LWA_ALPHA)
   *!* *-- 在任务栏中隐藏
   *!* #DEFINE WS_EX_TOOLWINDOW    0x0000008
   *!* lnFlags = GetWindowLong(thisform.hwnd, WS_EX_TOOLWINDOW)    &&Gets the existing flags from the window
   *!* lnFlags = BITOR(lnFlags, WS_EX_TOOLWINDOW)            &&Appends the Layered flag to the existing ones
   *!* SetWindowLong(thisform.HWnd , GWL_EXSTYLE, lnFlags)
  ENDPROC
  PROCEDURE DblClick
   thisform.Release
  ENDPROC
  PROCEDURE Unload
   thisform.Release
  ENDPROC  
  
*!*	  ADD OBJECT lblCaption AS label WITH ;
*!*	   AutoSize = .T.,;
*!*	   BackStyle = 0,;
*!*	   Caption = '',;
*!*	   Height = 16,;
*!*	   Left = 6,;
*!*	   Top = 5,;
*!*	   Name = "lblCaption"

*!*	  ADD OBJECT check1 AS checkbox WITH ;
*!*	   BackStyle = 0,;
*!*	   Caption = ' 不再提示',;
*!*	   Height = 16,;
*!*	   Left = 6,;
*!*	   Top = 112,;
*!*	   Name = "check1" 
  
  ADD OBJECT Edit1 AS EditBox WITH ;
   Anchor = 15,;
   Height = 132,;
   Left = 0,;
   Name = 'Edit1',;
   Top = 0, ;
   Width = 277
  
  PROCEDURE Edit1.MouseDown
   LPARAMETERS nButton, nShift, nXCoord, nYCoord
   thisform.FormActive = .F.
  ENDPROC
  
  PROCEDURE Edit1.LostFocus
   thisform.FormActive = .T.
  ENDPROC
  ADD OBJECT tmrShow AS Timer WITH ;
   Name = 'tmrShow',;
   Interval = 10
   
  ADD OBJECT tmrWait AS Timer WITH ;
   Name = 'tmrWait',;
   Interval = pnWaitTim,;
   Enabled = .F.
  
  ADD OBJECT tmrHide AS Timer WITH ;
   Name = 'tmrHide',;
   Interval = 10,;
   Enabled = .F.
  

  PROCEDURE tmrShow.Timer
   IF SYSMETRIC(22)-thisform.Top = thisform.Height +SYSMETRIC(4) * 2
    this.Enabled = .F.
    thisform.tmrWait.Enabled = .T.
    thisform.AlwaysOnTop = .T.
   ELSE
    thisform.Top = thisform.Top - 1
   ENDIF
  ENDPROC
  
  PROCEDURE tmrWait.Timer
   IF thisform.tmrHide.Enabled = .F.
    thisform.tmrHide.Enabled = .T.
   ENDIF
  ENDPROC
  
  PROCEDURE tmrHide.Timer
   IF thisform.FormActive
    IF thisform.Height<>thisform.Formheight OR thisform.Width<>thisform.Formwidth
     thisform.Height = thisform.FormHeight
     thisform.Width = thisform.FormWidth
    ENDIF
    IF thisform.Top=SYSMETRIC(22)
     this.Enabled = .F.
     thisform.Release
    ELSE
     thisform.AlwaysOnTop = .F.
     thisform.Top = thisform.Top + 2
    ENDIF
   ENDIF
  ENDPROC
ENDDEFINE
*ENDFUNC

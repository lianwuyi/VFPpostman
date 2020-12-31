* ³£ÓÃÓï·¨

SELECT Ship_noteitem
a1 = RECNO()
COUNT TO ss
go top 
i=1 
do WHILE .t.
 IF i > ss
   EXIT
 ELSE 
   repl no with i 
 ENDIF 
   i=i+1 
   skip 
enddo 
GO a1
CHR(13)
thisform.grdShip_noteitem.column3.SetFocus 



LPARAMETERS nColIndex
* --- Update the Extended amount as per the QTY * PRICE.
REPLACE ORDER_ITEMS.EXTENDED WITH ROUND(ORDER_ITEMS.QTY * ORDER_ITEMS.PRICE,2)
* --- Write the changes to the DBF.
= TABLEUPDATE(.T.)

* --- Call to recalculate the Sub-totals. 
IF thisform.CheckAuto.Value = .T.
   thisform.gridfooter1.calcTotal()
ENDIF   

* --- Refresh the Grid with any new values.
Thisform.Grid1.Refresh

#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} User Function fMbroPed
    Funcao utilizada para montar a tela padrao da mbrowse Modelo 3, 2 tabelas separadas com cabeçalho e com grid 
	Tabelas SC5 e SC6
    @type  Function
    @author Scheron Martins
    @since 27/09/2023
    @version 1.0
    @param Nenhum
    @return Vazio (nil)
    @example Exemplo da utilizacao do Modelo 3
        @see : MBrowse               https://tdn.totvs.com/pages/releaseview.action?pageId=24346981
               Banco de Dados        https://tdn.totvs.com/display/tec/Banco+de+Dados
/*/

User Function AxCAD3()
Private cCadastro := "Pedido de Venda"
Private cAlias1	  := "SC5"
Private cAlias2	  := "SC6"
Private cOpcao	  := ""
Private bCampo	  := {|nField| FieldName(nField)}

aRotina := {{ "Pesquisar" ,"AxPesqui",0,1},;
			{ "Visualizar","U_Model3('VISUALIZAR')"	,0,2},;
			{ "Incluir"	  ,"U_Model3('INCLUIR')"	,0,3},;
			{ "Alterar"	  ,"U_Model3('ALTERAR')"	,0,4},;
			{ "Excluir"	  ,"U_Model3('EXCLUIR')"	,0,5}}

mBrowse( 6,1,22,75, cAlias1,,,,,,)

Return

User Function Model3(cOpcao)
Local _n1
Local nUsado 	:= 0

Private aCols   := {}
Private aReg    := {}
Private aHeader := {}

DbSelectArea(cAlias1)
DbSetOrder(1)

//	nOpcE da Enchoice 3 = Incluir , 4 = Alterar, 5 = Excluir
//	nOpcG da Getdados 3 = Incluir , 4 = Alterar, 5 = Excluir
Do Case
	Case cOpcao == "INCLUIR"
        RegToMemory(cAlias1,(cOpcao=="INCLUIR"))
		nOpcE:=3	
		nOpcG:=3	
	Case cOpcao == "ALTERAR"
        RegToMemory(cAlias1,.F.)
		nOpcE:=4
		nOpcG:=4
	Case cOpcao == "VISUALIZAR"
        RegToMemory(cAlias1,.F.)
		nOpcE:=2
		nOpcG:=2
	Case cOpcao == "EXCLUIR"
        RegToMemory(cAlias1,.F.)
		nOpcE:=5
		nOpcG:=5
	Otherwise
		Return
EndCase

DbSelectArea("SX3")
DbSetOrder(1) 
DbSeek(cAlias2)
While !Eof() .And.(X3_ARQUIVO==cAlias2)
	If AllTrim(X3_CAMPO)== "C6_ITEM"
		DbSkip()
		Loop
	EndIf
	IF X3Uso(X3_USADO ) .And. cNivel >= X3_NIVEL
		nUsado++
		aAdd(aHeader,{	Trim(X3_TITULO),	;
						X3_CAMPO,X3_PICTURE,;
                        X3_TAMANHO,			;
						X3_DECIMAL,			;
						"AllwaysTrue()",	;
                        X3_USADO,			;
						X3_TIPO,			;
						X3_ARQUIVO,			;
                        X3_CONTEXT})                                            
	EndIf
	DbSkip()                                      	
EndDo

If cOpcao =="INCLUIR"
	aCols:={Array(nUsado+1)} 
	aCols[1,nUsado+1]:=.F.
	For _n1:=1 to nUsado
		aCols[1,_n1]:=CriaVar(aHeader[_n1,2],.T.)          
	Next
else
	DbSelectArea(cAlias2)
	DbSetOrder(1)
	DbSeek(xFilial()+SC5->C5_NUM)
	Do While !EOF() .And. SC6->C6_NUM == M->C5_NUM
		aAdd( aREG, SC6->( RecNo()))
		aAdd( aCols,Array(nUsado+1))
		For _n1:=1 to nUsado
			aCols[Len(aCols),_n1]:=FieldGet(FieldPos(aHeader[_n1,2])) 
		Next
		aCols[Len(aCols),nUsado+1]:=.F.
		DbSkip()
	EndDo
EndIf
If Len( aCols ) > 0
        cAliasEnchoice	:= cAlias1
        cAliasGetD		:= cAlias2
        cLinOk			:= "AllWaysTrue()"
        cTudOk			:= "AllWaysTrue()"
        cFieldOk		:= "AllWaysTrue()"
		
		lRet:= Modelo3(cCadastro,cAliasEnchoice,cAliasGetD,,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

//		A variavel lRet será verdadeira caso o usuario clique no botão "Confirma"
        ElseIf lRet
			If nOpcE==3
				IncMod3(aCols)
				ConfirmSX8()
			ElseIf nOpcE==4
				AltMod3(aCols)
			ElseIf nOpce==5
				ExcMod3()
			Else
		
			RollBackSX8()	
		Endif
EndIf
Return

Static Function IncMod3(aCols)
Local nX, nI

	dbSelectArea("SC6")
	dbSetOrder(1)
	For nX := 1 To Len( aCOLS )
		If !aCOLS[ nX, Len( aCOLS[nX] )]
			RecLock( "SC6", .T. )
			For nI := 1 To Len( aHeader )
				FieldPut( FieldPos( Trim( aHeader[nI, 2] ) ),aCOLS[nX,nI] )
			Next nI
			SC6->C6_FILIAL  := xFilial("SC6")
			SC6->C6_NUM     := M->C5_NUM
			MsUnLock()
		Endif
	Next nX
	dbSelectArea( "SC5" )
	RecLock( "SC5", .T. )
	For nX := 1 To FCount()
		If "FILIAL" $ FieldName( nX )
			FieldPut( nX, xFilial( "SC5") )
		Else
			FieldPut( nX, M->&( Eval( bCampo, nX ) ) )
		Endif
	Next nX
	MsUnLock()
Return

Static Function AltMod3(aCols)
Local nI,nX

	dbSelectArea(cAlias2)
	dbSetOrder(1)
	For nX := 1 To Len( aCOLS )
			If nX <= Len( aREG )
				( cAlias2 )->( dbGoto( aREG[nX] ) )
				RecLock(cAlias2,.F.)
				If aCOLS[ nX, Len( aHeader ) + 1 ]
					( cAlias2 )->( dbDelete() )
				Endif
			Else
				If !aCOLS[ nX, Len( aHeader ) + 1 ]
					RecLock(cAlias2, .T. )
				Endif
			Endif
			If !aCOLS[ nX, Len(aHeader)+1 ]
				For nI := 1 To Len( aHeader )
					FieldPut( FieldPos( Trim( aHeader[ nI, 2] ) ),aCOLS[ nX, nI ] )
				Next nI
				
			Endif
			( cAlias2 )->( MsUnLock() )
		Next nX
		dbSelectArea(cAlias1)
		RecLock( cAlias1, .F. )
		For nX := 1 To FCount()
			If "FILIAL" $ FieldName( nX )
				FieldPut( nX, xFilial(cAlias1))
			Else
				FieldPut( nX, M->&( Eval( bCampo, nX ) ) )
			Endif
	Next
	( cAlias1 )->( MsUnLock() )
Return

Static Function ExcMod3()

dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xFilial("SC6") + SC6->C6_NUM)
While SC6->(!EOF())
	If SC6->(C6_FILIAL + C6_NUM) == xFilial("SC5") + SC5->C5_NUM
		RecLock("SC6")
		SC6->( dbDelete() )
		SC6->( MsUnlock() )
	EndIf
	SC6->( dbSkip() )
Enddo

dbSelectArea("SC5")
RecLock("SC5",.F.)
SC5->( dbDelete() )
SC5->( MsUnlock() )
Return
